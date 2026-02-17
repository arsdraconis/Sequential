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

// Other Sources
#import "PGFoundationAdditions.h"
#import "PGGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSBezierPath (PGAppKitAdditions)

+ (void)PG_drawIcon:(AEIconType)type inRect:(NSRect)b
{
    NSBezierPath * const p = [self bezierPath];
    CGFloat const scale    = MIN(NSWidth(b), NSHeight(b));
    switch (type)
    {
        case AEPlayIcon:
        {
            CGFloat const r = round(scale / 10.0f);
            [p appendBezierPathWithArcWithCenter:NSMakePoint(round(NSMaxX(b) - r),
                                                             round(NSMidY(b)))
                                          radius:r
                                      startAngle:60.0f
                                        endAngle:-60.0f
                                       clockwise:YES];
            [p appendBezierPathWithArcWithCenter:NSMakePoint(round(NSMinX(b) + NSWidth(b) * 0.1f + r),
                                                             round(NSMinY(b)
                                                                   + NSHeight(b) * 0.05f
                                                                   + r * 1.0f))
                                          radius:r
                                      startAngle:-60.0f
                                        endAngle:180.0f
                                       clockwise:YES];
            [p appendBezierPathWithArcWithCenter:NSMakePoint(round(NSMinX(b) + NSWidth(b) * 0.1f + r),
                                                             round(NSMinY(b)
                                                                   + NSHeight(b) * 0.95f
                                                                   - r * 1.0f))
                                          radius:r
                                      startAngle:180.0f
                                        endAngle:60.0f
                                       clockwise:YES];
            [p fill];
            break;
        }

        case AEPauseIcon:
            p.lineWidth    = scale / 4.0f;
            p.lineCapStyle = NSLineCapStyleRound;
            [p moveToPoint:NSMakePoint(NSMinX(b) + NSWidth(b) * 0.25f,
                                       NSMinY(b) + NSHeight(b) * 0.85f)];
            [p lineToPoint:NSMakePoint(NSMinX(b) + NSWidth(b) * 0.25f,
                                       NSMinY(b) + NSHeight(b) * 0.15f)];
            [p moveToPoint:NSMakePoint(NSMinX(b) + NSWidth(b) * 0.75f,
                                       NSMinY(b) + NSHeight(b) * 0.85f)];
            [p lineToPoint:NSMakePoint(NSMinX(b) + NSWidth(b) * 0.75f,
                                       NSMinY(b) + NSHeight(b) * 0.15f)];
            [p stroke];
            break;

        case AEStopIcon:
            NSRectFillUsingOperation(NSIntegralRect(NSInsetRect(b, NSWidth(b) * 0.15f, NSHeight(b) * 0.15f)),
                                     NSCompositingOperationSourceOver);
            break;

        default:
            return;
    }
}

+ (void)PG_drawSpinnerInRect:(NSRect)r startAtPetal:(NSInteger)petal
{
    [NSBezierPath setDefaultLineWidth:MIN(NSWidth(r), NSHeight(r)) / 11.0f];
    [NSBezierPath setDefaultLineCapStyle:NSLineCapStyleRound];
    NSUInteger i = 0;
//    const CGFloat PI = M_PI;
    const CGFloat PIx2 = M_PI * 2;
    for (; i < 12; i++)
    {
        [[[NSColor PG_bezelForegroundColor]
            colorWithAlphaComponent:petal < 0.0f ? 0.1f : ((petal + i) % 12) / -12.0f + 1.0f] set];
        [NSBezierPath
            strokeLineFromPoint:NSMakePoint(NSMidX(r) + cosf(PIx2 * i / 12.0f) * NSWidth(r) / 4.0f,
                                            NSMidY(r) + sinf(PIx2 * i / 12.0f) * NSHeight(r) / 4.0f)
                        toPoint:NSMakePoint(NSMidX(r) + cosf(PIx2 * i / 12.0f) * NSWidth(r) / 2.0f,
                                            NSMidY(r) + sinf(PIx2 * i / 12.0f) * NSHeight(r) / 2.0f)];
    }
    [NSBezierPath setDefaultLineWidth:1];
    [NSBezierPath setDefaultLineJoinStyle:NSLineJoinStyleMiter];
}

@end

//	MARK: -
@implementation NSColor (PGAppKitAdditions)

//	MARK: +NSColor(PGAppKitAdditions)

+ (NSColor *)PG_bezelBackgroundColor
{
    return [NSColor colorWithDeviceWhite:48.0f / 255.0f alpha:0.75f];
}

+ (NSColor *)PG_bezelForegroundColor
{
    return [NSColor colorWithDeviceWhite:0.95f alpha:0.9f];
}

//	MARK: NSColor(PGAppKitAdditions)

- (NSColor *)PG_checkerboardPatternColor
{
    NSImage *image = [NSImage imageNamed:@"Checkerboard"];
    CGFloat fraction = 0.05f;
    
    NSSize const s = image.size;
    NSRect const r = (NSRect){NSZeroPoint, s};
    NSImage * const pattern = [[NSImage alloc] initWithSize:s];
    
    [pattern lockFocus];
    [self set];
    NSRectFill(r);
    [image drawInRect:r fromRect:NSZeroRect operation:NSCompositingOperationSourceAtop
             fraction:fraction];
    [pattern unlockFocus];
    return [NSColor colorWithPatternImage:pattern];
}


@end

//	MARK: -
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
@interface NSWorkspace (PGSnowLeopardOrLater)
- (BOOL)setDesktopImageURL:(NSURL *)URL
                 forScreen:(NSScreen *)screen
                   options:(NSUInteger)options
                     error:(out NSError **)outError;
- (NSUInteger)desktopImageOptionsForScreen:(NSScreen *)screen;
@end

//	MARK: -
@implementation NSScreen (PGAppKitAdditions)

+ (nullable NSScreen *)PG_mainScreen
{
    NSArray * const screens = [self screens];
    return screens.count ? screens[0] : nil;
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
