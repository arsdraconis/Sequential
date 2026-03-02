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
@class PGDisplayableIdentifier;
@class PGSubscription;

NS_ASSUME_NONNULL_BEGIN

// 2021/07/21 modernized
@interface PGResourceIdentifier : NSObject <NSSecureCoding>

@property(readonly) PGResourceIdentifier *identifier;
@property(readonly) PGDisplayableIdentifier *displayableIdentifier;
@property(readonly, nullable) PGResourceIdentifier *superidentifier;
@property(readonly) PGResourceIdentifier *rootIdentifier;
/// Equivalent to -URLByFollowingAliases:NO.
@property(readonly) NSURL *URL;
@property(readonly) NSInteger index;
@property(readonly) BOOL hasTarget;
@property(readonly) BOOL isFileIdentifier;

+ (instancetype)resourceIdentifierWithURL:(NSURL *)URL;

- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (PGResourceIdentifier *)subidentifierWithIndex:(NSInteger)index;

/// Our URL, or our superidentifier's otherwise.
- (NSURL *)superURLByFollowingAliases:(BOOL)flag;
- (nullable NSURL *)URLByFollowingAliases:(BOOL)flag;

- (nullable PGSubscription *)subscriptionWithDescendents:(BOOL)flag;

@end


//	MARK: -
@interface PGDisplayableIdentifier : PGResourceIdentifier

@property (nonatomic, assign) BOOL postsNotifications;
@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, copy, nullable) NSString *customDisplayName;
/// The name from the filesystem or raw address of the URL.
@property (nonatomic, copy) NSString *naturalDisplayName;
@property (nonatomic, readonly, nullable) NSColor* labelColor;

- (NSAttributedString *)attributedStringWithAncestory:(BOOL)flag;
- (void)noteNaturalDisplayNameDidChange;

@end

//	MARK: -
@interface NSURL(PGResourceIdentifierCreation)

@property(readonly) PGResourceIdentifier *PG_resourceIdentifier;
@property(readonly) PGDisplayableIdentifier *PG_displayableIdentifier;

@end

NS_ASSUME_NONNULL_END
