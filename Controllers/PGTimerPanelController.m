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
#import "PGTimerPanelController.h"

#import "Sequential-Swift.h"

#import "PGDocument.h"
#import "PGPrefObject.h"
#import "PGDisplayController.h"
#import "PGFoundationAdditions.h"
#import "PGGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGTimerPanelController ()

@property (nonatomic, weak) IBOutlet PGTimerButton *timerButton;
@property (nonatomic, weak) IBOutlet NSTextField *remainingField;
@property (nonatomic, weak) IBOutlet NSTextField *totalField;
@property (nonatomic, weak) IBOutlet NSSlider *intervalSlider;
@property (nonatomic, strong, nullable) NSTimer *updateTimer;

@end

//	MARK: -
@implementation PGTimerPanelController

- (instancetype)init
{
    return [self initWithWindowNibName:@"PGTimer"];
}

- (void)dealloc
{
    [self PG_removeObserver];
    [_updateTimer invalidate];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self _updateOnTimer:nil];
}

//	MARK: PGTimerPanelController

- (IBAction)toggleTimer:(id)sender
{
    self.displayController.timerRunning = !self.displayController.timerRunning;
}

- (IBAction)changeTimerInterval:(id)sender
{
    NSTimeInterval const interval = round([sender doubleValue]);
    [self _currentPrefObject].timerInterval = interval;
    [self _updateOnTimer:nil];
}

//	MARK: -

- (void)displayControllerTimerDidChange:(NSNotification *)aNotif
{
    [self _update];
}

//	MARK: PGTimerPanelController(Private)

- (PGPrefObject *)_currentPrefObject
{
    PGDocument * const doc = self.displayController.activeDocument;
    return doc ? doc : [PGPrefObject globalPrefObject];
}

- (void)_update
{
    PGDisplayController * const d = self.displayController;
    BOOL const run = d.timerRunning;
    if (!self.shown || !run)
    {
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
    else if (!_updateTimer)
    {
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:PGAnimationFramerate target:self
                                                      selector:@selector(_updateOnTimer:)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    _timerButton.enabled  = !!d;
    _timerButton.buttonIcon = run ? AEIconTypeStop : AEIconTypePlay;
    [self _updateOnTimer:nil];
}

- (void)_updateOnTimer:(nullable NSTimer *)timer
{
    NSTimeInterval const interval = [self _currentPrefObject].timerInterval;
    BOOL const running            = self.displayController.timerRunning;
    NSTimeInterval timeRemaining  = interval;
    if (running)
    {
        NSDate * const fireDate = self.displayController.nextTimerFireDate;
        timeRemaining           = MAX(0.0f, fireDate ? [fireDate timeIntervalSinceNow] : 0.0f);
    }
    _timerButton.progress       = running ? (CGFloat)((interval - timeRemaining) / interval) : 0.0f;
    NSString *formatString = NSLocalizedString(@"%.1f seconds",
                                               @"Display string for timer intervals. %.1f is replaced with the remaining seconds and tenths of seconds.");
    _remainingField.stringValue = [NSString localizedStringWithFormat: formatString, timeRemaining];
    if (!timer)
    {
        _totalField.stringValue     = [NSString localizedStringWithFormat:formatString, interval];
        _intervalSlider.doubleValue = interval;
        _intervalSlider.enabled     = !!self.displayController;
    }
}

//	MARK: PGFloatingPanelController

- (void)setShown:(BOOL)flag
{
    super.shown = flag;
    [self _update];
}

- (NSString *)nibName
{
    return @"PGTimer";
}

- (BOOL)setDisplayControllerReturningWasChanged:(nullable PGDisplayController *)controller
{
    PGDisplayController * const oldController = self.displayController;
    if (![super setDisplayControllerReturningWasChanged:controller]) return NO;
    [oldController PG_removeObserver:self name:PGDisplayControllerTimerDidChangeNotification];
    PGDisplayController * const newController = self.displayController;
    [newController PG_addObserver:self selector:@selector(displayControllerTimerDidChange:)
                             name:PGDisplayControllerTimerDidChangeNotification];
    [self _update];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
