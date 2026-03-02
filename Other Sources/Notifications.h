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

// From PGDocument.h
extern NSString * const PGDocumentWillRemoveNodesNotification;
extern NSString * const PGDocumentSortedNodesDidChangeNotification;
extern NSString * const PGDocumentNodeIsViewableDidChangeNotification;
extern NSString * const PGDocumentNodeThumbnailDidChangeNotification;
extern NSString * const PGDocumentNodeDisplayNameDidChangeNotification;

extern NSString * const PGDocumentNodeKey;
extern NSString * const PGDocumentRemovedChildrenKey;
extern NSString * const PGDocumentUpdateRecursivelyKey;

// From PGResourceIdentifier.h
extern NSString *const PGDisplayableIdentifierIconDidChangeNotification;
extern NSString *const PGDisplayableIdentifierDisplayNameDidChangeNotification;

// From PGSubscription.h
extern NSString *const PGSubscriptionEventDidOccurNotification;

extern NSString *const PGSubscriptionPathKey;
extern NSString *const PGSubscriptionRootFlagsKey; // Only included when the subscription root changes.

// From PGBookmark.h
extern NSString *const PGBookmarkDidUpdateNotification;

// From PGDocumentController.h
// general prefs pane
extern NSString * const PGAntialiasWhenUpscalingKey;
extern NSString * const PGImageScaleConstraintKey;

// thumbnail prefs pane
extern NSString * const PGShowThumbnailImageNameKey;
extern NSString * const PGShowThumbnailImageSizeKey;
extern NSString * const PGShowThumbnailContainerNameKey;
extern NSString * const PGShowThumbnailContainerChildCountKey;
extern NSString * const PGShowThumbnailContainerChildSizeTotalKey;
extern NSString * const PGThumbnailSizeFormatKey;

// extern NSString *const PGShowFileNameOnImageThumbnailKey;    //    2022/10/15 added; 2023/10/01
// removed extern NSString *const PGShowCountsAndSizesOnContainerThumbnailKey;    //    2022/10/15
// added; 2023/09/11 removed extern NSString *const PGThumbnailContainerLabelTypeKey;    //
// 2023/09/11

// From PGDisplayController.h
extern NSString *const PGDisplayControllerActiveNodeDidChangeNotification;
extern NSString *const PGDisplayControllerActiveNodeWasReadNotification;
extern NSString *const PGDisplayControllerTimerDidChangeNotification;

// From PGThumbnailController.h
extern NSString *const PGThumbnailControllerContentInsetDidChangeNotification;


NS_ASSUME_NONNULL_END
