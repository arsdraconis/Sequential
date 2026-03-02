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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class PGDocument;
@class PGResourceIdentifier;
@class PGBookmark;
@class PGDisplayController;
@class PGDisplayableIdentifier;


typedef NSUInteger BeforeState;

#define PGScaleMax 16.0f
#define PGScaleMin (1.0f / 16.0f)

@interface PGDocumentController : NSResponder <NSMenuDelegate, NSMenuItemValidation>

@property (nonatomic, copy, nonnull) NSArray<PGDisplayableIdentifier *> *recentDocumentIdentifiers;
@property (readonly) NSUInteger maximumRecentDocumentCount;
@property (readonly, nonnull) PGDisplayController *displayControllerForNewDocument;
@property (nonatomic, assign, getter=isFullscreen) BOOL fullscreen;
@property (readonly) BOOL canToggleFullscreen;
@property (nonatomic, assign) BOOL usesEntireScreenWhenInFullScreen;
@property (readonly) BOOL canToggleUsesEntireScreenWhenInFullScreen;
@property (readonly, nonnull) NSArray *documents;
@property (readonly, nonnull) NSMenu *scaleMenu;
@property (nonatomic, weak) IBOutlet NSSlider *scaleSlider;
@property (readonly, strong, nonnull) IBOutlet NSMenu *defaultPageMenu;
@property (nonatomic, weak, nullable) PGDocument *currentDocument;
@property (readonly) BOOL pathFinderRunning;

+ (PGDocumentController *)sharedDocumentController;

- (IBAction)orderFrontStandardAboutPanel:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)switchToFileManager:(id)sender;

- (IBAction)open:(id)sender;
- (IBAction)openURL:(id)sender;
- (IBAction)openRecentDocument:(id)sender;
- (IBAction)clearRecentDocuments:(id)sender;
- (IBAction)closeAll:(id)sender;

- (IBAction)toggleInspector:(id)sender;
- (IBAction)toggleTimer:(id)sender;
- (IBAction)toggleActivity:(id)sender;
- (IBAction)selectPreviousDocument:(id)sender;
- (IBAction)selectNextDocument:(id)sender;
- (IBAction)activateDocument:(id)sender;

- (IBAction)showKeyboardShortcuts:(id)sender;

- (BOOL)performEscapeKeyAction;
- (BOOL)performZoomIn;
- (BOOL)performZoomOut;
- (BOOL)performToggleFullscreen;


- (void)addDocument:(PGDocument *)document;
- (void)removeDocument:(PGDocument *)document;
- (nullable PGDocument *)documentForIdentifier:(PGResourceIdentifier *)ident;
- (nullable PGDocument *)next:(BOOL)flag documentBeyond:(PGDocument *)document;
- (nullable NSMenuItem *)windowsMenuItemForDocument:(PGDocument *)document;

- (nullable id)openDocumentWithContentsOfIdentifier:(PGResourceIdentifier *)ident
                                            display:(BOOL)flag;
- (nullable id)openDocumentWithContentsOfURL:(NSURL *)URL display:(BOOL)flag;
- (nullable id)openDocumentWithBookmark:(PGBookmark *)aBookmark display:(BOOL)flag;
- (void)noteNewRecentDocument:(PGDocument *)document;
- (void)noteDeletedRecentDocument:(PGDocument *)document;

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event
          withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

- (void)recentDocumentIdentifierDidChange:(nullable NSNotification *)aNotif;

- (BeforeState)togglePanelsForExitingFullScreen:(BOOL)exitingFullScreen
                                withBeforeState:(BeforeState)state;

@end

NS_ASSUME_NONNULL_END
