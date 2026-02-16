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

// Models
@class PGDocument;
@class PGNode;
@class PGBookmark;

// Views
#import "PGDocumentWindow.h"
#import "PGClipView.h"

#if !__has_feature(objc_arc)
@class PGImageView;
@class PGBezelPanel;
@class PGLoadingGraphic;
@class PGFindView;
@class PGFindlessTextView;

// Controllers
@class PGThumbnailController;
@class PGFullSizeContentController;
#endif

// Other Sources
#import "PGGeometryTypes.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PGDisplayControllerActiveNodeDidChangeNotification;
extern NSString *const PGDisplayControllerActiveNodeWasReadNotification;
extern NSString *const PGDisplayControllerTimerDidChangeNotification;

@interface PGDisplayController : NSWindowController <NSWindowDelegate, NSMenuItemValidation,
	PGClipViewDelegate, PGDocumentWindowDelegate>
#if !__has_feature(objc_arc)
{
	@private
	IBOutlet PGClipView *clipView;
	IBOutlet PGFindView *findView;
	IBOutlet NSSearchField *searchField;
	IBOutlet PGFindView *goToPageView;
	IBOutlet NSTextField *pageNumberField;
	IBOutlet NSView *errorView;
	IBOutlet NSTextField *errorLabel;
	IBOutlet NSTextField *errorMessage;
	IBOutlet NSButton *reloadButton;
	IBOutlet NSView *passwordView;
	IBOutlet NSTextField *passwordLabel;
	IBOutlet NSTextField *passwordField;

	PGDocument *_activeDocument;
	PGNode *_activeNode;
	PGImageView *_imageView;
	PGPageLocation _initialLocation;
	BOOL _reading;
	NSUInteger _displayImageIndex;

	PGBezelPanel *_graphicPanel;
	PGLoadingGraphic *_loadingGraphic;
	PGBezelPanel *_infoPanel;

	PGThumbnailController *_thumbnailController;

	PGBezelPanel *_findPanel;
	PGFindlessTextView *_findFieldEditor;

	NSDate *_nextTimerFireDate;
	NSTimer *_timer;

	PGFullSizeContentController *_fullSizeContentController;

	NSRect _windowFrameForNonFullScreenMode;
	BOOL _isInFullSizeContentModeForNonFullScreenMode;
}
#endif

+ (NSArray *)pasteboardTypes;

- (IBAction)saveImagesTo:(nullable id)sender;
- (IBAction)setAsDesktopPicture:(nullable id)sender;
- (IBAction)setCopyAsDesktopPicture:(nullable id)sender;
- (IBAction)moveToTrash:(nullable id)sender;

- (IBAction)copy:(nullable id)sender;
- (IBAction)selectAll:(nullable id)sender;
- (IBAction)performFindPanelAction:(nullable id)sender;
- (IBAction)hideFindPanel:(nullable id)sender;

- (IBAction)toggleFullscreen:(nullable id)sender;
- (IBAction)toggleEntireWindowOrScreen:(nullable id)sender;
- (IBAction)toggleInfo:(nullable id)sender;
- (IBAction)toggleThumbnails:(nullable id)sender;
- (IBAction)changeReadingDirection:(nullable id)sender;
- (IBAction)changeSortOrder:(nullable id)sender;
- (IBAction)changeSortDirection:(nullable id)sender;
- (IBAction)changeSortRepeat:(nullable id)sender;
- (IBAction)revertOrientation:(nullable id)sender;
- (IBAction)changeOrientation:(nullable id)sender;
- (IBAction)toggleAnimation:(nullable id)sender;

- (IBAction)changeImageScaleMode:(nullable id)sender;
- (IBAction)zoomIn:(nullable id)sender;
- (IBAction)zoomOut:(nullable id)sender;
- (IBAction)changeImageScaleFactor:(nullable id)sender;
- (IBAction)minImageScaleFactor:(nullable id)sender;
- (IBAction)maxImageScaleFactor:(nullable id)sender;

- (IBAction)previousPage:(nullable id)sender;
- (IBAction)nextPage:(nullable id)sender;
- (IBAction)firstPage:(nullable id)sender;
- (IBAction)lastPage:(nullable id)sender;

- (IBAction)firstOfPreviousFolder:(nullable id)sender;
- (IBAction)firstOfNextFolder:(nullable id)sender;
- (IBAction)skipBeforeFolder:(nullable id)sender;
- (IBAction)skipPastFolder:(nullable id)sender;
- (IBAction)firstOfFolder:(nullable id)sender;
- (IBAction)lastOfFolder:(nullable id)sender;

- (IBAction)jumpToPage:(nullable id)sender;

- (IBAction)pauseDocument:(nullable id)sender;
- (IBAction)pauseAndCloseDocument:(nullable id)sender;

- (IBAction)reload:(nullable id)sender;
- (IBAction)decrypt:(nullable id)sender;

#if __has_feature(objc_arc)
@property (readonly, nullable) PGDocument *activeDocument;
@property (readonly) PGNode *activeNode;
@property (readonly, nullable) NSWindow *windowForSheet;
@property (nonatomic, copy) NSSet *selectedNodes;	//	2023/10/02 was readonly
@property (readonly, nullable) PGNode *selectedNode;
@property (readonly, weak) PGClipView *clipView;
@property (readonly) PGPageLocation initialLocation;
@property (readonly, getter = isReading) BOOL reading;
@property (readonly, getter = isDisplayingImage) BOOL displayingImage;
@property (readonly) BOOL canShowInfo;
@property (readonly) BOOL shouldShowInfo;
@property (readonly) BOOL loadingIndicatorShown;
@property (nonatomic, assign) BOOL findPanelShown;
@property (nonatomic, assign) BOOL goToPagePanelShown;
@property (readonly) NSDate *nextTimerFireDate;
@property (nonatomic, assign) BOOL timerRunning;
@property (nonatomic, assign, getter=isInFullSizeContentModeForNonFullScreenMode)
					BOOL inFullSizeContentModeForNonFullScreenMode;
#else
@property(readonly) PGDocument *activeDocument;
@property(readonly) PGNode *activeNode;
@property(readonly) NSWindow *windowForSheet;
@property(copy, nonatomic) NSSet *selectedNodes;	//	2023/10/02 was readonly
@property(readonly) PGNode *selectedNode;
@property(readonly) PGClipView *clipView;
@property(readonly) PGPageLocation initialLocation;
@property(readonly, getter = isReading) BOOL reading;
@property(readonly, getter = isDisplayingImage) BOOL displayingImage;
@property(readonly) BOOL canShowInfo;
@property(readonly) BOOL shouldShowInfo;
@property(readonly) BOOL loadingIndicatorShown;
@property(assign) BOOL findPanelShown;
@property(assign) BOOL goToPagePanelShown;
@property(readonly) NSDate *nextTimerFireDate;
@property(assign) BOOL timerRunning;
@property(assign, getter = isInFullSizeContentModeForNonFullScreenMode)
					BOOL inFullSizeContentModeForNonFullScreenMode;
#endif

- (BOOL)setActiveDocument:(nullable PGDocument *)document closeIfAppropriate:(BOOL)flag; // Returns YES if the window was closed.
- (void)activateDocument:(PGDocument *)document;

- (void)setActiveNode:(PGNode *)aNode forward:(BOOL)flag;
- (BOOL)tryToSetActiveNode:(PGNode *)aNode forward:(BOOL)flag;
- (BOOL)tryToGoForward:(BOOL)forward allowAlerts:(BOOL)flag;
- (void)loopForward:(BOOL)flag;
- (void)prepareToLoop; // Call this before sending -tryToLoop….
- (BOOL)tryToLoopForward:(BOOL)loopForward toNode:(PGNode *)node pageForward:(BOOL)pageForward allowAlerts:(BOOL)flag;
- (void)activateNode:(PGNode *)node;

- (void)showLoadingIndicator;
- (void)offerToOpenBookmark:(PGBookmark *)bookmark;
- (void)advanceOnTimer;

- (void)zoomBy:(CGFloat)factor animate:(BOOL)flag;
- (BOOL)zoomKeyDown:(NSEvent *)firstEvent;

- (void)clipViewFrameDidChange:(NSNotification *)aNotif;

- (void)nodeLoadingDidProgress:(NSNotification *)aNotif;
- (void)nodeReadyForViewing:(nullable NSNotification *)aNotif;

- (void)documentWillRemoveNodes:(NSNotification *)aNotif;
- (void)documentSortedNodesDidChange:(NSNotification *)aNotif;
- (void)documentNodeDisplayNameDidChange:(NSNotification *)aNotif;
- (void)documentNodeIsViewableDidChange:(nullable NSNotification *)aNotif;
- (void)documentBaseOrientationDidChange:(NSNotification *)aNotif;

- (void)documentShowsInfoDidChange:(nullable NSNotification *)aNotif;
- (void)documentShowsThumbnailsDidChange:(nullable NSNotification *)aNotif;
- (void)documentReadingDirectionDidChange:(nullable NSNotification *)aNotif;
- (void)documentImageScaleDidChange:(NSNotification *)aNotif;
- (void)documentAnimatesImagesDidChange:(nullable NSNotification *)aNotif;
- (void)documentTimerIntervalDidChange:(NSNotification *)aNotif;

- (void)thumbnailControllerContentInsetDidChange:(nullable NSNotification *)aNotif;
- (void)prefControllerBackgroundPatternColorDidChange:(nullable NSNotification *)aNotif;

@end

NS_ASSUME_NONNULL_END
