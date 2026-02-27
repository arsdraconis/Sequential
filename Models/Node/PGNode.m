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
#import "PGNode.h"

// Models
#import "PGBookmark.h"
#import "PGContainerAdapter.h"
#import "PGDocument.h"
#import "PGResourceAdapter.h"
#import "PGResourceIdentifier.h"

// Controllers
#import "PGDisplayController.h"

// Other Sources
#import "PGAppKitAdditions.h"
#import "PGFoundationAdditions.h"

NS_ASSUME_NONNULL_BEGIN

static NSComparisonResult CompareByteSize(uint64_t a, uint64_t b)
{
    if (a == b) return NSOrderedSame;
    if (a < b) return NSOrderedAscending;
    return NSOrderedDescending;
}

static uint64_t GetByteSizeForSortingOrDisplay(PGResourceAdapter *ra)
{
    return ra.isContainer ? ((PGContainerAdapter *)ra).byteSizeOfAllChildren
                          : ra.dataProvider.dataByteSize;
}

NSString * const PGNodeLoadingDidProgressNotification = @"PGNodeLoadingDidProgress";
NSString * const PGNodeReadyForViewingNotification    = @"PGNodeReadyForViewing";

NSString * const PGImageRepKey = @"PGImageRep";

NSString * const PGNodeErrorDomain = @"PGNodeError";

enum
{
    PGNodeNothing          = 0,
    PGNodeLoading          = 1 << 0,
    PGNodeReading          = 1 << 1,
    PGNodeLoadingOrReading = PGNodeLoading | PGNodeReading
};    // PGNodeStatus.

@interface PGNode ()

@property (nonatomic, weak) id<PGNodeParenting> parent;
@property (nonatomic, strong) PGDisplayableIdentifier *identifier;
//@property (nonatomic, strong) PGDataProvider *dataProvider;
@property (nonatomic, strong, nullable) NSMutableArray<PGResourceAdapter *> *potentialAdapters;
@property (nonatomic, strong) PGResourceAdapter *resourceAdapter;
@property (nonatomic, assign) PGNodeStatus status;

@property (nonatomic, assign) BOOL viewable;
@property (nonatomic, strong) NSMenuItem *menuItem;
@property (nonatomic, assign) BOOL allowMenuItemUpdates;

- (instancetype)init NS_UNAVAILABLE;

- (void)_stopLoading;

- (void)_updateMenuItem;
- (void)_updateFileAttributes;

@end

@implementation PGNode

//	MARK: +PGNode

+ (NSArray *)pasteboardTypes
{
    return @[NSPasteboardTypeString, NSPasteboardTypeRTFD, NSFileContentsPboardType];
}

//	MARK: +NSObject

+ (void)initialize
{
    srandom((unsigned)time(NULL));    // Used by our shuffle sort.
}

//	MARK: - PGNode

- (nullable instancetype)initWithParent:(id<PGNodeParenting>)parent
                             identifier:(PGDisplayableIdentifier *)ident
{
    if (!(self = [super init])) return nil;
    if (!ident)
    {
        self = nil;
        return nil;
    }
    _parent                     = parent;
    _identifier                 = ident;
    _menuItem                   = [[NSMenuItem alloc] init];
    _menuItem.representedObject = [NSValue valueWithNonretainedObject:self];
    _menuItem.action            = @selector(jumpToPage:);
    _allowMenuItemUpdates       = YES;
    [self _updateMenuItem];
    [_identifier PG_addObserver:self selector:@selector(identifierIconDidChange:)
                           name:PGDisplayableIdentifierIconDidChangeNotification];
    [_identifier PG_addObserver:self selector:@selector(identifierDisplayNameDidChange:)
                           name:PGDisplayableIdentifierDisplayNameDidChangeNotification];
    return self;
}

//	MARK: -

- (void)setDataProvider:(PGDataProvider *)dp
{
    NSParameterAssert(dp);
    if (dp == _dataProvider) return;
    _dataProvider = dp;
    [self reload];
}

- (void)reload
{
    _status |= PGNodeLoading;
    _potentialAdapters = [[_dataProvider adaptersForNode:self] mutableCopy];
    [self _setResourceAdapter:_potentialAdapters.lastObject];
    if (_potentialAdapters.count) [_potentialAdapters removeLastObject];
    [_resourceAdapter loadIfNecessary];
}

- (void)loadFinishedForAdapter:(PGResourceAdapter *)adapter
{
    NSParameterAssert(PGNodeLoading & _status);
    NSParameterAssert(adapter == _resourceAdapter);
    
    [self _stopLoading];
    [self readIfNecessary];
}

- (void)fallbackFromFailedAdapter:(PGResourceAdapter *)adapter
{
    NSParameterAssert(PGNodeLoading & _status);
    NSParameterAssert(adapter == _resourceAdapter);
    
    [self _setResourceAdapter:_potentialAdapters.lastObject];
    if (!_potentialAdapters.count) return [self _stopLoading];
    [_potentialAdapters removeLastObject];
    [_resourceAdapter loadIfNecessary];
}

//	MARK: -

- (nullable NSImage *)thumbnail
{
    return PGNodeLoading & _status ? nil : self.resourceAdapter.thumbnail;
}

- (BOOL)isViewable
{
    return _viewable;
}

- (PGNode *)viewableAncestor
{
    return _viewable ? self : self.parentNode.viewableAncestor;
}

- (BOOL)canBookmark
{
    return self.isViewable && self.identifier.hasTarget;
}

- (PGBookmark *)bookmark
{
    return [[PGBookmark alloc] initWithNode:self];
}

//	MARK: -

- (void)becomeViewed
{
    [self.resourceAdapter.activity prioritize:self];
    if (PGNodeReading & _status) return;
    _status |= PGNodeReading;
    [self readIfNecessary];
}

- (void)readIfNecessary
{
    if ((PGNodeLoadingOrReading & _status) == PGNodeReading) [_resourceAdapter read];
}

- (void)setIsReading:(BOOL)reading
{    //	2023/10/21
    NSParameterAssert((PGNodeLoadingOrReading & _status) == PGNodeNothing
                      || (PGNodeLoadingOrReading & _status) == PGNodeReading);
    
    if (reading)
    {
        _status |= PGNodeReading;
    }
    else
    {
        _status &= ~PGNodeReading;
    }
}

- (void)readFinishedWithImageRep:(nullable NSImageRep *)aRep
{
    NSParameterAssert((PGNodeLoadingOrReading & _status) == PGNodeReading);
    _status &= ~PGNodeReading;
    [self PG_postNotificationName:PGNodeReadyForViewingNotification
                         userInfo:@{PGImageRepKey: aRep}];
}

//	MARK: -

- (void)removeFromDocument
{
    if (self.document.node == self)
        [self.document close];
    else
        [self.parentAdapter removeChild:self];
}

- (void)detachFromTree
{
    @synchronized(self)
    {
        _parent = nil;
    }
}

- (NSComparisonResult)compare:(PGNode *)node
{
    NSParameterAssert(node);
    NSParameterAssert([self document]);
    
    PGSortOrder const o        = self.document.sortOrder;
    NSInteger const d          = self.document.sortDescending ? -1 : 1;
    PGDataProvider * const dp1 = self.resourceAdapter.dataProvider;
    PGDataProvider * const dp2 = node.resourceAdapter.dataProvider;
    NSComparisonResult r       = NSOrderedSame;
    
    switch (o)
    {
        case PGSortOrderInnate:
            return NSOrderedSame;
            
        // For containers like folders, compare filenames like the Finder does.
        // See https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/SearchingStrings.html#//apple_ref/doc/uid/20000149-SW4
        // Note that although the docs suggest -[NSString localizedStandardCompare:], it doesn't seem to have the same behavior under Tahoe
        case PGSortOrderUnspecified:
        case PGSortOrderByName:
            r = [dp1.identifier.displayableIdentifier.displayName localizedStandardCompare:dp2.identifier.displayableIdentifier.displayName];
            break;
            
        case PGSortOrderByDateModified:
            r = [dp1.dateModified compare:dp2.dateModified];
            break;
            
        case PGSortOrderByDateCreated:
            r = [dp1.dateCreated compare:dp2.dateCreated];
            break;
            
        case PGSortOrderBySize:
            r = CompareByteSize(GetByteSizeForSortingOrDisplay(self.resourceAdapter),
                                GetByteSizeForSortingOrDisplay(node.resourceAdapter));
            break;
        case PGSortOrderByKind:
            r = [dp1.kindString compare:dp2.kindString];
            break;
        case PGSortOrderShuffle:
            return random() & 1 ? NSOrderedAscending : NSOrderedDescending;
    }
    return (NSOrderedSame == r
                ? [self.identifier.displayName PG_localizedCaseInsensitiveNumericCompare:node.identifier.displayName]
                : r) * d;    // If the actual sort order doesn't produce a distinct ordering, then sort by name too.
}

- (BOOL)writeToPasteboard:(nullable NSPasteboard *)pboard types:(NSArray *)types
{
    BOOL wrote = NO;
    if ([types containsObject:NSPasteboardTypeString])
    {
        if (pboard)
        {
            [pboard addTypes:@[NSPasteboardTypeString] owner:nil];
            [pboard setString:self.identifier.displayName forType:NSPasteboardTypeString];
        }
        wrote = YES;
    }
    
    //	2023/09/10 the original code is time- and space- expensive if the caller does
    //	not provide a NSPasteboard instance. When one is provided, the NSData instance
    //	must be created, but if one is not provided, avoid the creation of the NSData
    //	instance. This improves overall performance when anything involving the
    //	Services menu occurs, as well as when updating the menu items in the menu bar.
    NSData *data = nil;
    if ([types containsObject:NSPasteboardTypeRTFD])
    {
        if (pboard)
        {
            data = self.resourceAdapter.data;

            [pboard addTypes:@[NSPasteboardTypeRTFD] owner:nil];
            NSFileWrapper * const wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
            wrapper.preferredFilename         = self.identifier.displayName;
            NSAttributedString * const string = [NSAttributedString
                attributedStringWithAttachment:[[NSTextAttachment alloc] initWithFileWrapper:wrapper]];
            //	2021/07/21 cannot pass nil to -RTFDFileWrapperFromRange::documentAttributes:
            //	for the documentAttributes: parameter
            [pboard
                setData:[string RTFDFromRange:NSMakeRange(0, string.length)
                            documentAttributes:@{NSDocumentTypeDocumentAttribute: @"some doc type"}]
                forType:NSPasteboardTypeRTFD];
        }
        wrote = YES;
    }
    if ([types containsObject:NSFileContentsPboardType])
    {
        if (pboard)
        {
            if (!data) data = self.resourceAdapter.data;

            [pboard addTypes:@[NSFileContentsPboardType] owner:nil];
            [pboard setData:data forType:NSFileContentsPboardType];
        }
        wrote = YES;
    }

    return wrote;
}

- (void)addToMenu:(NSMenu *)menu flatten:(BOOL)flatten
{
    [_menuItem PG_removeFromMenu];
    if (flatten && self.resourceAdapter.hasChildren)
    {
        [self.resourceAdapter addChildrenToMenu:menu];
    }
    else
    {
        [self.resourceAdapter addChildrenToMenu:_menuItem.submenu];
        [menu addItem:_menuItem];
    }
}

//	MARK: -

- (PGNode *)ancestorThatIsChildOfNode:(PGNode *)aNode
{
    PGNode * const parent = self.parentNode;
    return aNode == parent ? self : [parent ancestorThatIsChildOfNode:aNode];
}

- (BOOL)isDescendantOfNode:(nullable PGNode *)aNode
{
    return [self ancestorThatIsChildOfNode:aNode] != nil;
}

//	MARK: -

- (void)identifierIconDidChange:(NSNotification *)aNotif
{
    [self _updateMenuItem];
}

- (void)identifierDisplayNameDidChange:(NSNotification *)aNotif
{
    [self _updateMenuItem];
    if ([self.document isCurrentSortOrder:PGSortOrderByName])
    {
        [self.parentAdapter noteChildValueForCurrentSortOrderDidChange:self];
    }
    [self.document noteNodeDisplayNameDidChange:self];
}

//	MARK: -

- (void)noteIsViewableDidChange
{
    BOOL const showsLoadingIndicator = !!(PGNodeLoading & _status);
    BOOL const viewable = showsLoadingIndicator || _resourceAdapter.adapterIsViewable;
    if (viewable == _viewable) return;
    _viewable = viewable;
    [self.document noteNodeIsViewableDidChange:self];
}

//	MARK: - PGNode(Private)

- (void)_setResourceAdapter:(PGResourceAdapter *)adapter
{
    if (adapter == _resourceAdapter) return;
    [_resourceAdapter.activity setParentActivity:nil];
    _resourceAdapter = adapter;
    PGActivity * const parentActivity = self.parentAdapter.activity;
    _resourceAdapter.activity.parentActivity = parentActivity ? parentActivity : self.document.activity;
    [self _updateFileAttributes];
    [self noteIsViewableDidChange];
}

- (void)_stopLoading
{
    _potentialAdapters = nil;
    _status &= ~PGNodeLoading;
    [self noteIsViewableDidChange];
    [self.document noteNodeThumbnailDidChange:self recursively:NO];
}

//	MARK: -

- (void)_updateMenuItem
{
    if (!_allowMenuItemUpdates) return;
    
    NSMutableAttributedString * const label = [[self.identifier attributedStringWithAncestory:NO] mutableCopy];
    NSString *info = nil;
    NSDate *date = nil;
    PGDataProvider * const dp = self.resourceAdapter.dataProvider;
    
    switch (self.document.sortOrder)
    {
        case PGSortOrderByDateModified:
            date = dp.dateModified;
            break;
        case PGSortOrderByDateCreated:
            date = dp.dateCreated;
            break;
        case PGSortOrderBySize:
            info = [@(GetByteSizeForSortingOrDisplay(self.resourceAdapter)) PG_bytesAsLocalizedString];
            break;
        case PGSortOrderByKind:
            info = dp.kindString;
            break;
            
        default:
            break;
    }
    
    if (date && !info)
    {
        info = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle
                                              timeStyle:NSDateFormatterShortStyle];
    }
    
    if (info)
    {
        NSAttributedString *string = [[NSAttributedString alloc]
                                      initWithString:[NSString stringWithFormat:@" (%@)", info]
                                          attributes:@{
                                              NSForegroundColorAttributeName: NSColor.grayColor,
                                              NSFontAttributeName: [NSFont boldSystemFontOfSize:12]
                                    }];
        [label appendAttributedString:string];
    }
        
    _menuItem.attributedTitle = label;
}

- (void)_updateFileAttributes
{
    [self.parentAdapter noteChildValueForCurrentSortOrderDidChange:self];
    [self _updateMenuItem];
}

//	MARK: - NSObject

- (void)dealloc
{
    [_resourceAdapter.activity setParentActivity:nil];

    // Using our generic -PG_removeObserver is about twice as slow as removing the observer for the
    // specific objects we care about. When closing huge folders of thousands of files, this makes a
    // big difference. Even now it's still the slowest part.
    [_identifier PG_removeObserver:self name:PGDisplayableIdentifierIconDidChangeNotification];
    [_identifier PG_removeObserver:self name:PGDisplayableIdentifierDisplayNameDidChangeNotification];
}

//	MARK: - NSObject(NSObject)

- (NSUInteger)hash
{
    return [[self class] hash] ^ self.identifier.hash;
}

- (BOOL)isEqual:(id)anObject
{
    //	2024/03/09 bugfix: the original code tested for
    //	equality by checking for same-class-type and for
    //	same-identifier, where the same-identifier test
    //	consists of testing the identifier instance var
    //	of both objects as well as the superidentifier
    //	instance var of both objects. The problem is
    //	that, for objects inside an archive, the
    //	superidentifier is a PGAliasIdentifier for in-
    //	-archive folders and they only test the URL of
    //	the archive file itself and not the parent-path.
    //	This causes strange problems when an archive has
    //	different folders containing similarly-named
    //	sub-folders. The easiest way to fix this is to
    //	add another test: the parent nodes must match
    //	which is, arguably, what the original code
    //	should have been doing all along. This is-
    //	-same-parent test is done first because it's a
    //	quick address comparison, whereas the other
    //	tests involve more work.
    return self.parentNode == ((PGNode *)anObject).parentNode
        && [anObject isMemberOfClass:[self class]]
        && PGEqualObjects(self.identifier, ((PGNode *)anObject).identifier);
}

//	MARK: -

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@(%@) %p: %@>", self.class, _resourceAdapter.class, self,
                                      self.identifier];
}

//	MARK: - <PGResourceAdapting>

- (PGNode *)parentNode
{
    return _parent.containerAdapter.node;
}

- (PGContainerAdapter *)parentAdapter
{
    return _parent.containerAdapter;
}

- (PGNode *)rootNode
{
    return self.parentNode ? self.parentNode.rootNode : self;
}

- (PGDocument *)document
{
    return _parent.document;
}

//	MARK: -

- (void)noteFileEventDidOccurDirect:(BOOL)flag
{
    [self.identifier noteNaturalDisplayNameDidChange];
    [self _updateFileAttributes];
    [_resourceAdapter noteFileEventDidOccurDirect:flag];
}

- (void)noteSortOrderDidChange
{
    [self _updateMenuItem];
    [_resourceAdapter noteSortOrderDidChange];
}

@end

NS_ASSUME_NONNULL_END
