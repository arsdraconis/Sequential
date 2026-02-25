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
#import <tgmath.h>

// Other Sources
#import "PGFoundationAdditions.h"

NS_ASSUME_NONNULL_BEGIN


@implementation PGPrefObject

//	MARK: +PGPrefObject

+ (id)globalPrefObject
{
    static PGPrefObject *obj = nil;
    if (!obj) obj = [[self alloc] init];
    return obj;
}

- (void)setShowsInfo:(BOOL)flag
{
    if (!flag == !_showsInfo) return;
    _showsInfo = flag;
    [NSUserDefaults.standardUserDefaults setShowsInfo:flag];
}

- (void)setShowsThumbnails:(BOOL)flag
{
    if (!flag == !_showsThumbnails) return;
    _showsThumbnails = flag;
    [NSUserDefaults.standardUserDefaults setShowsThumbnailSidebar:flag];
}

- (void)setReadingDirection:(PGReadingDirection)aDirection
{
    if (aDirection == _readingDirection) return;
    _readingDirection = aDirection;
    [NSUserDefaults.standardUserDefaults setDefaultReadingDirection:aDirection];
}

- (void)setImageScaleMode:(PGImageScaleMode)aMode
{
    _imageScaleMode   = aMode;
    _imageScaleFactor = 1;
    [NSUserDefaults.standardUserDefaults setImageScaleMode:aMode];
    [NSUserDefaults.standardUserDefaults setImageScaleFactor:1.0];
    [self PG_postNotificationName:PGPrefObjectImageScaleDidChangeNotification
                         userInfo:@{PGPrefObjectAnimateKey: @YES}];
}

- (void)setImageScaleFactor:(CGFloat)factor
{
    [self setImageScaleFactor:factor animate:YES];
}

- (void)setImageScaleFactor:(CGFloat)factor animate:(BOOL)flag
{
    NSParameterAssert(factor > 0.0f);
    // If it's close to 1, fudge it.
    CGFloat const newFactor = fabs(1.0f - factor) < 0.01f ? 1.0f : factor;
    _imageScaleFactor = newFactor;
    _imageScaleMode   = PGImageScaleModeConstantFactor;
    [NSUserDefaults.standardUserDefaults setImageScaleFactor:newFactor];
    [NSUserDefaults.standardUserDefaults setImageScaleMode:PGImageScaleModeConstantFactor];
    [self PG_postNotificationName:PGPrefObjectImageScaleDidChangeNotification
                         userInfo:@{PGPrefObjectAnimateKey: @(flag)}];
}

- (void)setAnimatesImages:(BOOL)flag
{
    if (!flag == !_animatesImages) return;
    _animatesImages = flag;
    [NSUserDefaults.standardUserDefaults setAnimatesImages:flag];
}

- (void)setSortOrder:(PGSortOrder)anOrder
{
    if (anOrder == _sortOrder) return;
    _sortOrder = anOrder;
    [NSUserDefaults.standardUserDefaults setSortOrder:anOrder];
}

- (void)setSortDescending:(BOOL)sortDescending
{
    if (sortDescending == _sortDescending) return;
    _sortDescending = sortDescending;
    [NSUserDefaults.standardUserDefaults setSortDescending:sortDescending];
}

- (void)setSortRepeat:(BOOL)sortRepeat
{
    if (sortRepeat == _sortRepeat) return;
    _sortRepeat = sortRepeat;
    [NSUserDefaults.standardUserDefaults setIsRepeatEnabled:sortRepeat];
}

- (void)setTimerInterval:(NSTimeInterval)interval
{
    if (interval == _timerInterval) return;
    _timerInterval = interval;
    [NSUserDefaults.standardUserDefaults setTimerInterval:interval];
}

- (void)setBaseOrientation:(PGOrientation)anOrientation
{
    if (anOrientation == _baseOrientation) return;
    _baseOrientation = anOrientation;
    [NSUserDefaults.standardUserDefaults setBaseOrientation:anOrientation];
}

- (BOOL)isCurrentSortOrder:(PGSortOrder)order
{
    return order == self.sortOrder;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        NSUserDefaults * const d = [NSUserDefaults standardUserDefaults];
        _showsInfo        = d.showsInfo;
        _showsThumbnails  = d.showsThumbnailSidebar;
        _readingDirection = d.defaultReadingDirection;
        _imageScaleMode   = d.imageScaleMode;
        _imageScaleFactor = d.imageScaleFactor;
        _animatesImages   = d.animatesImages;
        _sortOrder        = d.sortOrder;
        _timerInterval    = d.timerInterval;
        _baseOrientation  = d.baseOrientation;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
