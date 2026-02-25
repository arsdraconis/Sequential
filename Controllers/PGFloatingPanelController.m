/* Copyright © 2007-2009, The Sequential Project
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the the Sequential Project nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE SEQUENTIAL PROJECT ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE SEQUENTIAL PROJECT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */
#import "PGFloatingPanelController.h"

#import "PGNode.h"
#import "PGDisplayController.h"
#import "PGFoundationAdditions.h"

NS_ASSUME_NONNULL_BEGIN


@interface PGFloatingPanelController ()

@property (nonatomic, strong, nullable) PGDisplayController *displayController;

- (void)_updateWithDisplayController:(nullable PGDisplayController *)controller;

@end


//	MARK: -
@implementation PGFloatingPanelController

- (id)initWithWindowNibName:(NSString *)name
{
    if ((self = [super initWithWindowNibName:name]))
    {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(windowDidBecomeMain:)
                                                   name:NSWindowDidBecomeMainNotification
                                                 object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(windowDidResignMain:)
                                                   name:NSWindowDidResignMainNotification
                                                 object:nil];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithWindowNibName:[self nibName]];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self windowDidBecomeMain:nil];
    [(NSPanel *)self.window setBecomesKeyOnlyIfNeeded:YES];
#if 1    //    2022/02/15
    [self.window setFrameUsingName:self.windowFrameAutosaveName];
#else
    NSString * const savedFrame =
        [[NSUserDefaults standardUserDefaults] objectForKey:[self windowFrameAutosaveName]];
    if (savedFrame)
    {
        NSRect r         = NSRectFromString(savedFrame);
        NSSize const min = [[self window] minSize];
        NSSize const max = [[self window] maxSize];
        r.size.width     = MIN(MAX(min.width, NSWidth(r)), max.width);
        r.size.height    = MIN(MAX(min.height, NSHeight(r)), max.height);
        [[self window] setFrame:r display:YES];
    }
#endif

    // NSLog(@"collectionBehavior %lu", self.window.collectionBehavior);

    //    Do not do this; it causes the floating windows to not transition to macOS
    //    fullscreen mode correctly - probably one of the settings is incorrect;
    //    because the default behavior works correctly anyway, there's no need for this.
    //    It looks like Preview.app hides its Info window before entering fullscreen
    //    mode and then shows the Info window once the transition to fullscreen mode
    //    has been completed. That's now what this app does too.
    /*    NSWindowCollectionBehavior cb = NSWindowCollectionBehaviorMoveToActiveSpace |
            NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorIgnoresCycle |
            NSWindowCollectionBehaviorFullScreenAuxiliary |
            NSWindowCollectionBehaviorFullScreenDisallowsTiling;
        if(@available(macOS 13.0, *))
            cb |= NSWindowCollectionBehaviorAuxiliary;

        self.window.collectionBehavior = cb;    */
}

- (nullable NSString *)nibName
{
    return nil;
}

- (NSString *)windowFrameAutosaveName
{
    NSString * const name = [self nibName];
    return name ? [NSString stringWithFormat:@"%@PanelFrame", name] : [NSString string];
}

- (void)_updateWithDisplayController:(nullable PGDisplayController *)controller
{
    PGDisplayController * const c = controller ? controller : NSApp.mainWindow.windowController;
    [self setDisplayControllerReturningWasChanged:[c isKindOfClass:[PGDisplayController class]]
                                                      ? c
                                                      : nil];
}

- (void)setShown:(BOOL)flag forFullScreenTransition:(BOOL)forFullScreenTransition
{
    if (flag == _shown) return;
    
    _shown = flag;
    id<PGFloatingPanelProtocol> pr = !forFullScreenTransition && [self conformsToProtocol:@protocol(PGFloatingPanelProtocol)]
        ? (id<PGFloatingPanelProtocol>)self
        : nil;
    if (flag)
    {
        [pr windowWillShow];
        [super showWindow:self];
    }
    else
    {
        [pr windowWillClose];
        if (forFullScreenTransition)
        {
            [self.window orderOut:self];
        }
        else
        {
            [self.window performClose:self];
        }
    }
}

- (void)toggleShown
{
    [self setShown:!self.shown forFullScreenTransition:NO];
}

- (void)toggleShownUsing:(PGFloatingPanelToggleInstruction)i
{
    NSAssert(PGFloatingPanelToggleInstructionHide == i && self.isShown
                 || PGFloatingPanelToggleInstructionShowAtStatusWindowLevel == i && !self.isShown,
             @"");
    if (PGFloatingPanelToggleInstructionShowAtStatusWindowLevel == i)
    {
        self.window.level = NSStatusWindowLevel;
    }
    [self setShown:!self.shown forFullScreenTransition:YES];
}

- (BOOL)setDisplayControllerReturningWasChanged:(nullable PGDisplayController *)controller
{
    if (controller == _displayController) return NO;
    _displayController = controller;
    return YES;
}


- (IBAction)showWindow:(nullable id)sender
{
    [self setShown:YES];
}

- (BOOL)shouldCascadeWindows
{
    return NO;
}


//	MARK: - <NSWindowDelegate>
- (void)windowDidResize:(nullable NSNotification *)notification
{
    [self.window saveFrameUsingName:self.windowFrameAutosaveName];
}

- (void)windowDidMove:(NSNotification *)notification
{
    [self windowDidResize:nil];
}

- (void)windowWillClose:(NSNotification *)aNotif
{
    _shown = NO;

    if ([self conformsToProtocol:@protocol(PGFloatingPanelProtocol)])
    {
        [(id<PGFloatingPanelProtocol>)self windowWillClose];
    }
}

- (void)windowDidBecomeMain:(nullable NSNotification *)aNotif
{
    [self _updateWithDisplayController:aNotif ? [aNotif.object windowController] : NSApp.mainWindow.windowController];
}

- (void)windowDidResignMain:(NSNotification *)aNotif
{
    [self _updateWithDisplayController:nil];
}

@end

NS_ASSUME_NONNULL_END
