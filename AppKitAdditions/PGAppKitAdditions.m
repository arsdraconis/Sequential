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
#import "PGAppKitAdditions.h"

#import "Sequential-Swift.h"

#import "PGFoundationAdditions.h"
#import "PGGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSEvent (PGAppKitAdditions)

- (NSPoint)PG_locationInView:(NSView *)view
{
    NSParameterAssert([view window] == [self window]);
    NSPoint const p = self.locationInWindow;
    return view ? [view convertPoint:p fromView:nil] : p;
}

@end

//	MARK: -
@interface NSMenu (AEUndocumented)
- (id)_menuImpl;
@end

@protocol AECarbonMenuImpl
- (void)performActionWithHighlightingForItemAtIndex:(NSInteger)integer;
@end

@implementation NSMenuItem (PGAppKitAdditions)

- (void)PG_removeFromMenu
{
    [self.menu removeItem:self];
}

- (BOOL)PG_performAction
{
    NSMenu * const menu = self.menu;
    [menu update];
    if (!self.enabled) return NO;
    NSInteger const i = [menu indexOfItem:self];
    if (!PGIsSnowLeopardOrLater() && [menu respondsToSelector:@selector(_menuImpl)])
    {
        id const menuImpl = [menu _menuImpl];
        if ([menuImpl respondsToSelector:@selector(performActionWithHighlightingForItemAtIndex:)])
        {
            [menuImpl performActionWithHighlightingForItemAtIndex:i];
            return YES;
        }
    }
    [menu performActionForItemAtIndex:i];
    return YES;
}

@end



//	MARK: -
@implementation NSWindow (PGAppKitAdditions)

- (NSRect)PG_contentRect
{
    // TODO: Make sure this works correctly when the window is being dragged/resized.
    return [self contentRectForFrameRect:self.frame];
}

- (void)PG_setContentRect:(NSRect)aRect
{
    NSSize const min        = self.minSize;
    NSSize const max        = self.maxSize;
    NSRect r                = [self frameRectForContentRect:aRect];
    r.size.width            = MIN(MAX(min.width, NSWidth(r)), max.width);
    CGFloat const newHeight = MIN(MAX(min.height, NSHeight(r)), max.height);
    r.origin.y += NSHeight(r) - newHeight;
    r.size.height = newHeight;
    [self setFrame:r display:YES];
}

@end

NS_ASSUME_NONNULL_END
