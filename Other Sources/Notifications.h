//
//  Notifications.h
//  Sequential
//
//  Created by nulldragon on 2026-02-23.
//

#import <Foundation/Foundation.h>

// This file exposes notification names to Swift after their original
// modules have been removed, but before Objective-C code that relies on them
// has been converted to Swift.

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PGWindowBackgroundDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString *const PGFullScreenBackgroundDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString *const PGDisplayScreenDidChangeNotification NS_REFINED_FOR_SWIFT;

extern NSString * const PGPrefObjectShowsInfoDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectShowsThumbnailsDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectReadingDirectionDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectImageScaleDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectUpscalesToFitScreenDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectAnimatesImagesDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectSortOrderDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectTimerIntervalDidChangeNotification NS_REFINED_FOR_SWIFT;
extern NSString * const PGPrefObjectBaseOrientationDidChangeNotification NS_REFINED_FOR_SWIFT;


NS_ASSUME_NONNULL_END
