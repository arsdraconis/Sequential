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
#import "PGBookmarkController.h"

#import "Notifications.h"

#import "PGResourceIdentifier.h"
#import "PGBookmark.h"
#import "PGDocumentController.h"
#import "PGAppKitAdditions.h"
#import "PGFoundationAdditions.h"

NS_ASSUME_NONNULL_BEGIN

// 2023/08/12 the paused document data blob is too large for NSUserDefaults in macOS 12 Monterey:
// "Sequential [User Defaults] CFPrefsPlistSource (Domain: com.SequentialX.Sequential,
// User: kCFPreferencesCurrentUser, ByHost: No, Container: (null), Contents Need Refresh: Yes):
// Attempting to store >= 4194304 bytes of data in CFPreferences/NSUserDefaults on this platform
// is invalid. This is a bug in Sequential or a library it uses."
//
// Solution: store this data in a separate file in the Application Support folder instead of in
// the app's UserDefaults object.
static NSString *const PGPausedDocumentsFileName       = @"PausedDocuments.plist";
//static NSString *const PGPausedDocumentsKey            = @"PGPausedDocuments4"; // file-ref is NSURL (not AliasHandle)
#if 0
static NSString *const PGPausedDocumentsDeprecated3Key = @"PGPausedDocuments3"; // Deprecated after 2.1.2.
static NSString *const PGPausedDocumentsDeprecated2Key = @"PGPausedDocuments2"; // Deprecated after 1.3.2.
static NSString *const PGPausedDocumentsDeprecatedKey  = @"PGPausedDocuments"; // Deprecated after 1.2.2.
#endif

static PGBookmarkController *sharedBookmarkController = nil;

static
NSURL*
GetBookmarksFileURL(BOOL createParentFolderIfNonExistant) {
	NSFileManager*		fileMgr = NSFileManager.defaultManager;
	NSArray<NSURL*>*	urls = [fileMgr URLsForDirectory:NSApplicationSupportDirectory
											   inDomains:NSUserDomainMask];
	if(nil == urls || 1 != urls.count)
		return nil;

	NSURL*	parentFolder = [urls[0] URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier
																   isDirectory:YES];
	if(nil == parentFolder)
		return nil;
	NSError*	error = nil;
	BOOL		b = createParentFolderIfNonExistant ?
					[fileMgr createDirectoryAtURL:parentFolder
					  withIntermediateDirectories:NO
									   attributes:nil
											error:&error] : YES;
//if(!b) NSLog(@"error %@", error);
	if(!b) {
		if(!error || !error.userInfo)
			return nil;

		id	ue	=	(error.userInfo)[NSUnderlyingErrorKey];
		if(!ue || ![ue isKindOfClass:NSError.class])
			return nil;

		error	=	(NSError*) ue;
		if(NSPOSIXErrorDomain != error.domain || EEXIST != error.code)
			return nil;
	}

	return [parentFolder URLByAppendingPathComponent:PGPausedDocumentsFileName isDirectory:NO];
}

// MARK: -
@interface PGBookmarkController()

@property (nonatomic, weak) IBOutlet NSMenuItem *bookmarkItem;
@property (nonatomic, weak) IBOutlet NSMenu *bookmarkMenu;
@property (nonatomic, strong) IBOutlet NSMenuItem *emptyMenuItem;
@property (nonatomic, strong) NSMutableArray<PGBookmark*> *bookmarks;

- (void)_updateMenuItemForBookmark:(PGBookmark *)aBookmark;
/// Removes without updating.
- (void)_removeBookmarkAtIndex:(NSUInteger)index;
- (void)_saveBookmarks;

@end

//	MARK: -
@implementation PGBookmarkController

- (instancetype)init
{
    if((self = [super init])) {
        if(!sharedBookmarkController) {
            sharedBookmarkController = self;
        }

        // 2023/08/12 now saved to a separate file instead of NSUserDefaults (because it generates too-much-data warnings)
        NSURL* url = GetBookmarksFileURL(NO);
//        NSLog(@"%@ url = %@", PGPausedDocumentsFileName, url);
        NSError* error = nil;
        NSData* bookmarksData = [NSData dataWithContentsOfURL:url options:0 error:&error];

        BOOL bookmarksDataIsFromPGPausedDocumentsKey = nil != bookmarksData;

        // 2023/08/12 transfer list of paused documents from UserDefaults to separate file
        if(!bookmarksDataIsFromPGPausedDocumentsKey)
        {
            bookmarksData = [NSUserDefaults.standardUserDefaults objectForKey:@"PGPausedDocuments4"];
            if(nil != bookmarksData)
            {
                [NSUserDefaults.standardUserDefaults removeObjectForKey:@"PGPausedDocuments4"];
            }
        }
        else
        {
            // if these deprecated entries still exist then purge them
            [NSUserDefaults.standardUserDefaults removeObjectForKey:@"PGPausedDocuments4"];
            [NSUserDefaults.standardUserDefaults removeObjectForKey:@"PGPausedDocuments3"];
        }

        // 2021/07/21 modernized
        if(bookmarksData)
        {
            NSError* error = nil;
            NSSet* classes = [NSSet setWithArray:@[[NSMutableArray class], [PGBookmark class]]];
            _bookmarks = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes
                                                             fromData:bookmarksData
                                                                error:&error];
        }
        if(!_bookmarks)
        {
            _bookmarks = [NSMutableArray new];
        }

        NSParameterAssert([_bookmarks isKindOfClass:[NSMutableArray class]]);
        if(!bookmarksDataIsFromPGPausedDocumentsKey)
        {
            [self _saveBookmarks];
        }
    }
    return self;
}

- (void)dealloc
{
    [self PG_removeObserver];
}

+ (PGBookmarkController*)sharedBookmarkController
{
    return sharedBookmarkController ? sharedBookmarkController : [self new];
}

- (void)awakeFromNib
{
    for(PGBookmark *const bookmark in _bookmarks)
    {
        [self addMenuItemForBookmark:bookmark];
    }
}

- (IBAction)open:(id)sender
{
	PGBookmark *const bookmark = ((NSMenuItem *)sender).representedObject;
	BOOL const deleteBookmark = _deletesBookmarks || NSEventModifierFlagOption & NSApp.currentEvent.modifierFlags;
	if(!deleteBookmark && bookmark.isValid) {
		[[PGDocumentController sharedDocumentController] openDocumentWithBookmark:bookmark display:YES];
		return;
	}
	NSAlert *const alert = [NSAlert new];
	alert.alertStyle = NSAlertStyleInformational;
	NSButton *const deleteButton = [alert addButtonWithTitle:NSLocalizedString(@"Delete Bookmark", nil)];
	NSButton *const cancelButton = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	if(deleteBookmark) return [self removeBookmark:bookmark];
	alert.messageText = [NSString stringWithFormat:NSLocalizedString(@"The file referenced by the bookmark %@ could not be found.", @"Bookmarked file could not be found error. %@ is replaced with the missing page's saved filename."), bookmark.fileIdentifier.displayName];
	[alert setInformativeText:NSLocalizedString(@"It may have been moved or deleted.", @"Bookmarked file could not be found error informative text.")];
	deleteButton.keyEquivalent = @"";
	cancelButton.keyEquivalent = @"\r";
	if([alert runModal] == NSAlertFirstButtonReturn) [self removeBookmark:bookmark];
	else [self _updateMenuItemForBookmark:bookmark];
}

- (void)setDeletesBookmarks:(BOOL)flag
{
	_deletesBookmarks = flag;
	_bookmarkItem.title = flag ? NSLocalizedString(@"Delete", @"The title of the bookmarks menu. Two states.") : NSLocalizedString(@"Resume", @"The title of the bookmarks menu. Two states.");
}

- (void)addBookmark:(PGBookmark *)aBookmark
{
	NSUInteger i;
	while((i = [_bookmarks indexOfObject:aBookmark]) != NSNotFound) [self _removeBookmarkAtIndex:i];
	[_bookmarks addObject:aBookmark];
	[self addMenuItemForBookmark:aBookmark];
	[self _saveBookmarks];
}

- (void)removeBookmark:(PGBookmark *)aBookmark
{
	if(!aBookmark) return;
	[self _removeBookmarkAtIndex:[_bookmarks indexOfObject:aBookmark]];
	[self _saveBookmarks];
}

- (void)addMenuItemForBookmark:(PGBookmark *)aBookmark
{
	NSParameterAssert(aBookmark);
	[_emptyMenuItem PG_removeFromMenu];
	if(_bookmarkMenu.numberOfItems) [_bookmarkMenu itemAtIndex:0].keyEquivalent = @"";
	NSMenuItem *const item = [NSMenuItem new];
	item.target = self;
	item.action = @selector(open:);
	item.representedObject = aBookmark;
	[_bookmarkMenu insertItem:item atIndex:0];
	[aBookmark PG_addObserver:self selector:@selector(bookmarkDidUpdate:) name:PGBookmarkDidUpdateNotification];
	[self _updateMenuItemForBookmark:aBookmark];
}
- (nullable PGBookmark *)bookmarkForIdentifier:(PGResourceIdentifier *)ident
{
	for(PGBookmark *const bookmark in _bookmarks) if(PGEqualObjects(bookmark.documentIdentifier, ident)) return bookmark;
	return nil;
}

- (void)bookmarkDidUpdate:(NSNotification *)aNotif
{
	NSParameterAssert(aNotif);
	[self _updateMenuItemForBookmark:aNotif.object];
	[self _saveBookmarks];
}

//	MARK: PGBookmarkController(Private)

- (void)_updateMenuItemForBookmark:(PGBookmark *)aBookmark
{
	NSInteger const index = [_bookmarkMenu indexOfItemWithRepresentedObject:aBookmark];
	if(-1 == index) return; // Fail gracefully.
	NSMenuItem *const item = [_bookmarkMenu itemAtIndex:index];
	if(!aBookmark.isValid) {
		[item setAttributedTitle:nil];
		item.title = [NSString stringWithFormat:NSLocalizedString(@"Missing File %@", @"Bookmark menu item used when the file named %@ cannot be found."), aBookmark.fileIdentifier.displayName];
		return;
	}
	NSMutableAttributedString *const title = [NSMutableAttributedString new];
	[title appendAttributedString:[aBookmark.documentIdentifier attributedStringWithAncestory:NO]];
	if(!PGEqualObjects(aBookmark.documentIdentifier, aBookmark.fileIdentifier)) {
		[title.mutableString appendFormat:@" %C ", (unichar)0x25B8];
		[title appendAttributedString:[aBookmark.fileIdentifier attributedStringWithAncestory:NO]];
	}
	item.attributedTitle = title;
}
- (void)_removeBookmarkAtIndex:(NSUInteger)index
{
	[_bookmarks[index] PG_removeObserver:self name:PGBookmarkDidUpdateNotification];
	[_bookmarks removeObjectAtIndex:index];
	[_bookmarkMenu removeItemAtIndex:_bookmarkMenu.numberOfItems - index - 1];
	if(!_bookmarks.count) [_bookmarkMenu addItem:_emptyMenuItem];
}

- (void)_saveBookmarks
{
    // 2023/08/12 now saved to a separate file instead of NSUserDefaults (because it generates too-much-data warnings)
    NSError*	error = nil;
    NSData*		archivedBookmarks = [NSKeyedArchiver archivedDataWithRootObject:_bookmarks
                                                       requiringSecureCoding:YES
                                                                       error:&error];
    if(nil == archivedBookmarks || nil != error)
        return;
    
    NSURL*	url = GetBookmarksFileURL(YES);
//    NSLog(@"%@ url = %@", PGPausedDocumentsFileName, url);
    (void) [archivedBookmarks writeToURL:url options:NSDataWritingAtomic error:&error];
}

@end

NS_ASSUME_NONNULL_END
