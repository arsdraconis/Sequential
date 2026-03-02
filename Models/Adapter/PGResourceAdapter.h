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
#import "PGActivity.h"
#import "PGDataProvider.h"
#import "PGNode.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const PGPasswordKey;

typedef NS_ENUM(NSInteger, PGRecursionPolicy) {
    PGRecursePolicyToMaxDepth = 0,
    PGRecursePolicyToAnyDepth = 1,
    PGRecursePolicyNoFurther  = 2,
};

// MARK: -
@protocol PGResourceAdapterImageGeneratorCompletion <NSObject> // 2023/10/21

@required
- (void)generationDidCompleteInOperation:(NSOperation *)operation;

@end

// MARK: -
@interface PGResourceAdapter : NSObject <PGActivityOwner, PGResourceAdapting, PGResourceAdapterImageGeneratorCompletion>

@property (readonly) PGNode *node;
@property (readonly) __kindof PGDataProvider *dataProvider;

@property (readonly) PGContainerAdapter *containerAdapter;
@property (readonly) PGContainerAdapter *rootContainerAdapter;
@property (readonly) NSUInteger depth;
@property (readonly) PGRecursionPolicy recursionPolicy;
@property (readonly) BOOL shouldRecursivelyCreateChildren;

@property (readonly) NSData *data;
@property (readonly) uint64_t dataByteSize;    // 2023/09/17
@property (readonly) BOOL canGetData;
@property (readonly) BOOL hasNodesWithData;

@property (readonly) BOOL isContainer;
@property (readonly) BOOL hasChildren;

///	The byte size, folder and image counts returned are for the *direct* children
///	of the object that this adapter represents; children which are more than 1
///	level deep are *not* included. Use .byteSizeOfAllChildren for the byte size
///	of all children at all levels. Returns ULONG\_MAX when isContainer = NO.
@property (readonly) uint64_t byteSizeAndFolderAndImageCount;
/// Returns ULONG\_MAX when isContainer = NO.
@property (readonly) uint64_t byteSizeOfAllChildren;

@property (readonly) BOOL isSortedFirstViewableNodeOfFolder;
@property (readonly) BOOL hasRealThumbnail;
@property (readonly, getter=isResolutionIndependent) BOOL resolutionIndependent;
@property (readonly) BOOL canSaveData;
@property (readonly) BOOL hasSavableChildren;

@property (readonly) BOOL nodeIsFirstOfFolder;    // 2022/11/04 added
@property (readonly) BOOL nodeIsLastOfFolder;     // 2022/11/04 added

@property (retain) NSError *error;

@property (readonly, nullable) NSDictionary *imageProperties;

@property (nonatomic, readonly) NSImage *thumbnail;
@property (nonatomic, readonly) NSImage *fastThumbnail;
@property (nonatomic, readonly) NSImage *realThumbnail;
@property (nonatomic, readonly) BOOL canGenerateRealThumbnail;

@property (readonly) NSUInteger viewableNodeIndex;
@property (readonly) NSUInteger viewableNodeCount;

- (BOOL)hasViewableNodeCountGreaterThan:(NSUInteger)anInt;

+ (NSDictionary *)typesDictionary;
+ (NSArray *)supportedFileTypes;
+ (NSArray *)supportedMIMETypes;

- (instancetype)initWithNode:(PGNode *)node
                dataProvider:(PGDataProvider *)dataProvider NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;


- (BOOL)adapterIsViewable;
- (void)loadIfNecessary;
/// Sent by -loadIfNecessary, never call it directly. -[node loadFinishedForAdapter:]
/// OR -[node fallbackFromFailedAdapter:] must be sent sometime hereafter.
- (void)load;
/// Sent by -[PGNode readIfNecessary], never call it directly.
/// -readFinishedWithImageRep: must be sent sometime hereafter.
- (void)read;

- (void)invalidateThumbnail;

- (PGOrientation)orientationWithBase:(BOOL)flag;
- (void)clearCache;
- (void)addChildrenToMenu:(NSMenu *)menu;

- (nullable PGNode *)nodeForIdentifier:(nullable PGResourceIdentifier *)ident;
- (PGNode *)sortedViewableNodeFirst:(BOOL)flag;
- (nullable PGNode *)sortedViewableNodeFirst:(BOOL)flag
                                  stopAtNode:(nullable PGNode *)descendent
                                 includeSelf:(BOOL)includeSelf;
- (PGNode *)sortedViewableNodeNext:(BOOL)flag;
- (PGNode *)sortedViewableNodeNext:(BOOL)flag includeChildren:(BOOL)children;
/// Returns a node that will still exist after the change.
- (PGNode *)sortedViewableNodeNext:(BOOL)flag
            afterRemovalOfChildren:(NSArray *)removedChildren
                          fromNode:(PGNode *)changedNode;
- (nullable PGNode *)sortedFirstViewableNodeInFolderNext:(BOOL)forward inclusive:(BOOL)inclusive;
- (nullable PGNode *)sortedFirstViewableNodeInFolderFirst:(BOOL)flag;
- (nullable PGNode *)sortedViewableNodeInFolderFirst:(BOOL)flag;
- (PGNode *)sortedViewableNodeNext:(BOOL)flag matchSearchTerms:(NSArray *)terms;
- (nullable PGNode *)sortedViewableNodeFirst:(BOOL)flag
                            matchSearchTerms:(NSArray *)terms
                                  stopAtNode:(PGNode *)descendent;


- (void)noteResourceDidChange;

@end

// MARK: -
// Private API for use by sub-classes only; clients of PGResourceAdapter
// should not call these; they are used to send the results of the image
// generation to the PGResourceAdapter instance for later use when
// -drawRect: is invoked
@interface PGResourceAdapter (PrivateMethodsForSubclassUse)

- (void)_startGeneratingImages;
- (void)_setThumbnailImageInOperation:(NSOperation *)operation
                             imageRep:(NSImageRep *)rep
                        thumbnailSize:(NSSize)size
                          orientation:(PGOrientation)orientation
                               opaque:(BOOL)opaque
          setParentContainerThumbnail:(BOOL)setParentContainerThumbnail;

@end

// MARK: -
// 2023/10/21
/// Sub-classes of PGResourceAdapter must implement this protocol
@protocol PGResourceAdapterImageGeneration <NSObject>

@required
///	Invoked on a page in a PDF container.
- (void)generateImagesInOperation:(NSOperation *)operation thumbnailSize:(NSSize)thumbnailSize;

@optional
/// Invoked on a PDF container. Searches for the page with index 0 and invokes its
/// \_startGeneratingImages method:
- (void)generateThumbnailForContainer;

@end

// MARK: -
@interface PGDataProvider (PGResourceAdapterLoading)

- (NSArray *)adapterClassesForNode:(PGNode *)node;
- (NSArray *)adaptersForNode:(PGNode *)node;

@end

NS_ASSUME_NONNULL_END
