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
#import "PGPDFAdapter.h"

// Models
#import "PGNode.h"
#import "PGResourceIdentifier.h"

// Other Sources
#import "PGAppKitAdditions.h"
#import "PGGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGPDFPageAdapter : PGResourceAdapter <PGResourceAdapterImageGeneration>
@end

// MARK: -
@interface PGPDFPageDataProvider : PGDataProvider

@property (readonly) NSPDFImageRep *mainRep;
@property (readonly) NSPDFImageRep *threadRep;
@property (readonly) NSInteger pageIndex;

- (instancetype)initWithMainRep:(NSPDFImageRep *)mainRep
                      threadRep:(NSPDFImageRep *)threadRep
                      pageIndex:(NSInteger)page NS_DESIGNATED_INITIALIZER;

@end

//	MARK: -
@implementation PGPDFAdapter

//	MARK: PGContainerAdapter

- (PGRecursionPolicy)descendantRecursionPolicy
{
    return PGRecursePolicyToAnyDepth;
}

//	MARK: PGResourceAdapter

- (void)load
{
    NSData * const data = self.data;
    if (!data || ![NSPDFImageRep canInitWithData:data])
    {
        return [self.node loadFinishedForAdapter:self];
    }
    NSPDFImageRep * const mainRep = [[NSPDFImageRep alloc] initWithData:data];
    if (!mainRep) return [self.node fallbackFromFailedAdapter:self];
    NSPDFImageRep * const threadRep = [mainRep copy];

    NSUInteger const pageCount = mainRep.pageCount;
    NSMutableArray * const nodes = [NSMutableArray arrayWithCapacity:pageCount];
    NSLocale *currentLocale = [NSLocale currentLocale];
    for (NSUInteger i = 0; i < pageCount; i++)
    {
        PGDisplayableIdentifier * const identifier = [self.node.identifier subidentifierWithIndex:i].displayableIdentifier;
        identifier.naturalDisplayName = [@(i + 1) descriptionWithLocale:currentLocale];
        PGNode * const node = [[PGNode alloc] initWithParent:self identifier:identifier];
        if (!node) continue;
        node.dataProvider = [[PGPDFPageDataProvider alloc] initWithMainRep:mainRep
                                                                 threadRep:threadRep
                                                                 pageIndex:i];
        [nodes addObject:node];
    }
    
    [self setUnsortedChildren:nodes presortedOrder:PGSortOrderInnate];
    [self.node loadFinishedForAdapter:self];
}

- (BOOL)canSaveData
{
    return YES;
}

- (BOOL)hasSavableChildren
{
    return NO;
}

- (void)generateThumbnailForContainer
{
    //	2023/10/22 generate a thumbnail image using the adapter for page 0; when
    //	the thumbnail has been generated, the code in
    //	-_setThumbnailImageInOperation:imageRep:thumbnailSize:orientation:opaque:
    //	will get the container's instance and invoke -setThumbnail: on it to set
    //	the container's thumbnail to page 0's thumbnail
    for (PGNode * const node in self.unsortedChildren)
    {
        NSAssert([node.dataProvider isKindOfClass:PGPDFPageDataProvider.class], @"!PGPDFPageDataProvider");
        NSInteger const pageIndex = ((PGPDFPageDataProvider *)node.dataProvider).pageIndex;
        if (0 != pageIndex) continue;

        (void)node.resourceAdapter.thumbnail;    //	triggers thumbnail generation
        break;
    }
}

@end

//	MARK: -
@implementation PGPDFPageAdapter

//	MARK: PGResourceAdapter

- (BOOL)isResolutionIndependent
{
    return YES;
}

- (nullable PGNode *)sortedViewableNodeFirst:(BOOL)flag
                            matchSearchTerms:(NSArray *)terms
                                  stopAtNode:(PGNode *)descendent
{
    if (!self.node.isViewable || self.node == descendent) return nil;
    NSInteger const index = ((PGPDFPageDataProvider *)self.dataProvider).pageIndex;
    if (NSNotFound == index) return nil;
    for (id const term in terms)
    {
        if (![term isKindOfClass:[NSNumber class]] || [term integerValue] - 1 != index)
        {
            return nil;
        }
    }
    return self.node;
}

- (BOOL)adapterIsViewable
{
    return YES;
}

- (void)read
{
    NSPDFImageRep * const rep = ((PGPDFPageDataProvider *)self.dataProvider).mainRep;
    rep.currentPage = ((PGPDFPageDataProvider *)self.dataProvider).pageIndex;
    [self.node readFinishedWithImageRep:rep];
}

- (BOOL)canGenerateRealThumbnail
{
    return YES;
}

//	MARK: <PGResourceAdapterImageGeneration>

// main image is created in -read so only need to create thumbnail image
// 2023/10/21
- (void)generateImagesInOperation:(NSOperation *)operation thumbnailSize:(NSSize)size
{
    NSPDFImageRep * const repForThumb = ((PGPDFPageDataProvider *)self.dataProvider).threadRep;
    if (!repForThumb) return;

    // repForThumb must be used within a @synchronized(repForThumb)
    // because it's a shared variable; not doing so causes the wrong
    // thumbnail image to be generated
    @synchronized(repForThumb)
    {
        NSInteger const pageIndex = ((PGPDFPageDataProvider *)self.dataProvider).pageIndex;
        repForThumb.currentPage   = pageIndex;
        // 2023/10/22 if this is the first page in the PDF file, set the
        // thumbnail image of the PDF container to the same thumbnail
        [self _setThumbnailImageInOperation:operation
                                   imageRep:repForThumb
                              thumbnailSize:size
                                orientation:PGUpright
                                     opaque:YES
                setParentContainerThumbnail:0 == pageIndex];
    }
}

@end

//	MARK: -

@interface PGPDFPageDataProvider ()

@property (nonatomic, strong) NSPDFImageRep *mainRep;
@property (nonatomic, strong) NSPDFImageRep *threadRep;
@property (nonatomic, assign) NSInteger pageIndex;

- (instancetype)init NS_UNAVAILABLE;

@end


//	MARK: -
@implementation PGPDFPageDataProvider

- (instancetype)initWithMainRep:(NSPDFImageRep *)mainRep
                      threadRep:(NSPDFImageRep *)threadRep
                      pageIndex:(NSInteger)page
{
    NSParameterAssert(mainRep);
    NSParameterAssert(threadRep);

    if ((self = [super init]))
    {
        _mainRep   = mainRep;
        _threadRep = threadRep;
        _pageIndex = page;
    }
    return self;
}

//	MARK: PGDataProvider(PGResourceAdapterLoading)

- (NSArray *)adapterClassesForNode:(PGNode *)node
{
    return @[[PGPDFPageAdapter class]];
}

@end

NS_ASSUME_NONNULL_END
