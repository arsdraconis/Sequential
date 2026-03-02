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
#import "PGPrefObject.h"

#import "PGActivity.h"
#import "PGGeometryTypes.h"
#import "PGNodeParenting.h"

@class PGNode;
@class PGResourceIdentifier;
@class PGDisplayableIdentifier;
@class PGSubscription;
@class PGBookmark;
@class PGImageView;
@class PGDisplayController;

NS_ASSUME_NONNULL_BEGIN

@interface PGDocument : PGPrefObject <PGActivityOwner, PGNodeParenting>

@property (readonly) PGDisplayableIdentifier *rootIdentifier;
@property (readonly) PGNode *node;
@property (nonatomic, strong, nullable) PGDisplayController *displayController;
@property (readonly, getter=isOnline) BOOL online;
@property (readonly) NSMenu *pageMenu;
/// Indicates whether to batch changes for performance.
@property (nonatomic, getter=isProcessingNodes) BOOL processingNodes;

- (instancetype)initWithIdentifier:(PGDisplayableIdentifier *)ident;
- (instancetype)initWithURL:(NSURL *)aURL;
- (instancetype)initWithBookmark:(PGBookmark *)aBookmark;

- (void)getStoredNode:(out PGNode * _Nullable * _Nullable)outNode
            imageView:(out PGImageView * _Nullable * _Nullable)outImageView
               offset:(out NSSize *)outOffset
                query:(out NSString * _Nullable * _Nullable)outQuery;    // No arguments may be NULL.
- (void)storeNode:(PGNode *)node
        imageView:(PGImageView *)imageView
           offset:(NSSize)offset
            query:(NSString *)query;
- (BOOL)getStoredWindowFrame:(out NSRect *)outFrame;
- (void)storeWindowFrame:(NSRect)frame;

- (void)createUI;
- (void)close;
- (void)openBookmark:(PGBookmark *)aBookmark;

- (void)noteNode:(PGNode *)node willRemoveNodes:(NSArray *)anArray;
- (void)noteSortedChildrenDidChange;
- (void)noteNodeIsViewableDidChange:(PGNode *)node;
- (void)noteNodeThumbnailDidChange:(PGNode *)node recursively:(BOOL)flag;
- (void)noteNodeDisplayNameDidChange:(PGNode *)node;
- (void)noteNodeDidCache:(PGNode *)node;
- (void)addOperation:(NSOperation *)operation;

- (void)identifierIconDidChange:(NSNotification *)aNotif;
- (void)subscriptionEventDidOccur:(NSNotification *)aNotif;

@end

NS_ASSUME_NONNULL_END
