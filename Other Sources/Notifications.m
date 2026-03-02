//
//  Notifications.m
//  Sequential
//
//  Created by nulldragon on 2026-02-23.
//

#import "Notifications.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const PGWindowBackgroundDidChangeNotification =
    @"PGWindowBackgroundDidChange";
NSString * const PGFullScreenBackgroundDidChangeNotification =
    @"PGFullScreenBackgroundDidChange";
NSString * const PGDisplayScreenDidChangeNotification =
    @"PGDisplayScreenDidChange";

NSString * const PGPrefObjectShowsInfoDidChangeNotification = @"PGPrefObjectShowsInfoDidChange";
NSString * const PGPrefObjectShowsThumbnailsDidChangeNotification =
    @"PGPrefObjectShowsThumbnailsDidChange";
NSString * const PGPrefObjectReadingDirectionDidChangeNotification =
    @"PGPrefObjectReadingDirectionDidChange";
NSString * const PGPrefObjectImageScaleDidChangeNotification = @"PGPrefObjectImageScaleDidChange";
NSString * const PGPrefObjectUpscalesToFitScreenDidChangeNotification =
    @"PGPrefObjectUpscalesToFitScreenDidChange";
NSString * const PGPrefObjectAnimatesImagesDidChangeNotification =
    @"PGPrefObjectAnimatesImagesDidChange";
NSString * const PGPrefObjectSortOrderDidChangeNotification = @"PGPrefObjectSortOrderDidChange";
NSString * const PGPrefObjectTimerIntervalDidChangeNotification =
    @"PGPrefObjectTimerIntervalDidChange";
NSString * const PGPrefObjectBaseOrientationDidChangeNotification =
    @"PGPrefObjectBaseOrientationDidChange";

// Can be removed once consolidated in Swift
NSString * const PGPrefObjectAnimateKey = @"PGPrefObjectAnimate";
NSString * const PGAntialiasWhenUpscalingKey = @"PGAntialiasWhenUpscaling";
NSString * const PGImageScaleConstraintKey = @"PGImageScaleConstraint";
NSString * const PGShowThumbnailImageNameKey = @"PGShowThumbnailImageName";
NSString * const PGShowThumbnailImageSizeKey = @"PGShowThumbnailImageSize";
NSString * const PGShowThumbnailContainerNameKey = @"PGShowThumbnailContainerName";
NSString * const PGShowThumbnailContainerChildCountKey = @"PGShowThumbnailContainerChildCount";
NSString * const PGShowThumbnailContainerChildSizeTotalKey = @"PGShowThumbnailContainerChildSizeTotal";
NSString * const PGThumbnailSizeFormatKey = @"PGThumbnailSizeFormat";

NSString *const PGDisplayControllerActiveNodeDidChangeNotification = @"PGDisplayControllerActiveNodeDidChange";
NSString *const PGDisplayControllerActiveNodeWasReadNotification = @"PGDisplayControllerActiveNodeWasRead";
NSString *const PGDisplayControllerTimerDidChangeNotification = @"PGDisplayControllerTimerDidChange";

NSString *const PGThumbnailControllerContentInsetDidChangeNotification = @"PGThumbnailControllerContentInsetDidChange";



NS_ASSUME_NONNULL_END
