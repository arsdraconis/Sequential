//
//  UserDefaults+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-16.
//

import Cocoa

let PGPrefObjectAnimateKey = "PGPrefObjectAnimate"

fileprivate let PGShowsInfoKey = "PGShowsInfo"
fileprivate let PGShowsThumbnailsKey = "PGShowsThumbnails"

fileprivate let PGBackgroundTypeKey = "PGBackgroundType"
fileprivate let PGBackgroundColorKey = "PGBackgroundColor"
fileprivate let PGBackgroundPatternKey = "PGBackgroundPattern"

fileprivate let PGReadingDirectionKey = "PGReadingDirectionRightToLeft"

fileprivate let PGShowThumbnailImageNameKey = "PGShowThumbnailImageName"
fileprivate let PGShowThumbnailImageSizeKey = "PGShowThumbnailImageSize"

fileprivate let PGShowThumbnailContainerNameKey = "PGShowThumbnailContainerName"
fileprivate let PGShowThumbnailContainerChildCountKey = "PGShowThumbnailContainerChildCount"
fileprivate let PGShowThumbnailContainerChildSizeTotalKey = "PGShowThumbnailContainerChildSizeTotal"

fileprivate let PGThumbnailSizeFormatKey = "PGThumbnailSizeFormat"

fileprivate let PGImageScaleModeKey = "PGImageScaleMode"
fileprivate let PGImageScaleFactorKey = "PGImageScaleFactor"
fileprivate let PGImageScaleConstraintKey = "PGImageScaleConstraint"
fileprivate let PGAntialiasWhenUpscalingKey = "PGAntialiasWhenUpscaling"

fileprivate let PGAnimatesImagesKey = "PGAnimatesImages"
fileprivate let PGBaseOrientationKey = "PGBaseOrientation"

fileprivate let PGFullscreenKey = "PGFullscreen"
fileprivate let PGDimOtherScreensKey = "PGDimOtherScreens"
fileprivate let PGUseEntireScreenWhenInFullScreenKey = "PGUseEntireScreenWhenInFullScreen"

fileprivate let PGSortOrderKey = "PGSortOrder2"
fileprivate let PGBackwardsInitialLocationKey = "PGBackwardsInitialLocation"

fileprivate let PGTimerIntervalKey = "PGTimerInterval"
fileprivate let PGMaxDepthKey = "PGMaxDepth"
fileprivate let PGMouseClickActionKey = "PGMouseClickAction"
fileprivate let PGEscapeKeyMappingKey = "PGEscapeKeyMapping"



@objc
extension UserDefaults
{
    class func registerAppDefaults()
    {
        let standard = UserDefaults.standard
        
        let archivedBlackColor = try! NSKeyedArchiver.archivedData(withRootObject: NSColor.black,
                                                                   requiringSecureCoding: true)
        standard.register(defaults: [
//            PGBackgroundTypeKey: ,
            PGBackgroundColorKey: archivedBlackColor,
            PGBackgroundPatternKey: PGPatternType.noPattern.rawValue,
            
            PGMaxDepthKey: 1,
            PGMouseClickActionKey: PGAction.nextPrevious.rawValue,
            PGEscapeKeyMappingKey: PGEscapeMapping.fullscreen.rawValue,
            
            PGReadingDirectionKey: PGReadingDirection.leftToRight.rawValue,
            PGBackwardsInitialLocationKey: PGPageLocation.endLocation.rawValue,

            PGImageScaleModeKey: PGImageScaleMode.constantFactor.rawValue,
            PGImageScaleFactorKey: 1.0,
            PGImageScaleConstraintKey: PGImageScaleConstraint.none.rawValue,
            PGAntialiasWhenUpscalingKey: true,
            
            PGAnimatesImagesKey: true,
            PGSortOrderKey: PGSortOrder([.byName, .repeatMask]).rawValue,
            PGTimerIntervalKey: 30.0,
            PGBaseOrientationKey: PGOrientation(rawValue: 0).rawValue,
            
            PGFullscreenKey: false,
            PGDimOtherScreensKey: false,
            PGUseEntireScreenWhenInFullScreenKey: false,
            
            PGShowsInfoKey: true,
            PGShowsThumbnailsKey: true,

            PGShowThumbnailImageNameKey: false,
            PGShowThumbnailImageSizeKey: false,
            
            PGShowThumbnailContainerNameKey: true,
            PGShowThumbnailContainerChildCountKey: false,
            PGShowThumbnailContainerChildSizeTotalKey: false,
            
            PGThumbnailSizeFormatKey: 0
        ]);
        
        // 2023/10/01 transition value of the old PGShowFileNameOnImageThumbnail
        // default to the new PGShowThumbnailImageName default
        if let o = standard.object(forKey: "PGShowFileNameOnImageThumbnail")
        {
            let b = (o as! NSNumber).boolValue
            standard.set(b, forKey: PGShowThumbnailImageNameKey)
            standard.removeObject(forKey: "PGShowFileNameOnImageThumbnail")
        }
        
        // 2023/09/11 transition value of the old PGShowCountsAndSizesOnContainerThumbnail
        // default to the new PGThumbnailContainerLabelType default
        if let o = standard.object(forKey: "PGShowCountsAndSizesOnContainerThumbnail")
        {
            let b = (o as! NSNumber).boolValue
            standard.set(b, forKey: PGShowThumbnailContainerChildCountKey)
            standard.set(b, forKey: PGShowThumbnailContainerChildSizeTotalKey)
            standard.removeObject(forKey: "PGShowCountsAndSizesOnContainerThumbnail")
        }
    }
    
    @objc
    var maximumRecursionDepth: Int
    {
        get
        {
            self.integer(forKey: PGMaxDepthKey)
        }
        set
        {
            self.set(newValue, forKey: PGMaxDepthKey)
        }
    }
    
    @nonobjc
    private static let validImageScaleModes: [PGImageScaleMode] = [
        .constantFactor, .automatic, .fitToView
    ]
    
    @objc
    var showsInfo: Bool
    {
        get
        {
            self.bool(forKey: PGShowsInfoKey)
        }
        set
        {
            if newValue != self.showsInfo
            {
                self.set(newValue, forKey: PGShowsInfoKey)
                NotificationCenter.default.post(name: .PGPrefObjectShowsInfoDidChange, object: self)
            }
        }
    }
    
    @objc
    var showsThumbnails: Bool
    {
        get
        {
            self.bool(forKey: PGShowsThumbnailsKey)
        }
        set
        {
            if newValue != self.showsThumbnails
            {
                self.set(newValue, forKey: PGShowsThumbnailsKey)
                NotificationCenter.default.post(name: .PGPrefObjectShowsThumbnailsDidChange, object: self)
            }
        }
    }
    
    @objc
    var readingDirection: PGReadingDirection
    {
        get
        {
            let raw = self.integer(forKey: PGReadingDirectionKey)
            return PGReadingDirection(rawValue: raw) ?? .leftToRight
        }
        set
        {
            if newValue != self.readingDirection
            {
                self.set(newValue.rawValue, forKey: PGReadingDirectionKey)
                NotificationCenter.default.post(name: .PGPrefObjectReadingDirectionDidChange, object: self)
            }
        }
    }
    
    @objc
    var imageScaleMode: PGImageScaleMode
    {
        get
        {
            let raw = self.integer(forKey: PGImageScaleModeKey)
            return PGImageScaleMode(rawValue: raw) ?? .constantFactor
        }
        set
        {
            if newValue != self.imageScaleMode
            {
                self.set(newValue.rawValue, forKey: PGImageScaleModeKey)
                self.set(1.0, forKey: PGImageScaleFactorKey)
                let userInfo = [ PGPrefObjectAnimateKey : true ]
                NotificationCenter.default.post(name: .PGPrefObjectImageScaleDidChange, object: self, userInfo: userInfo)
            }
        }
    }
    
    @objc
    var imageScaleFactor: CGFloat
    {
        get
        {
            return self.double(forKey: PGImageScaleFactorKey)
        }
        set
        {
            if newValue != self.imageScaleFactor
            {
                // Avoid negatives
                var newValue = newValue < 0 ? 1.0 : newValue
                // If it's close to 1, fudge it.
                newValue = abs(1.0 - newValue) < 0.01 ? 1.0 : newValue
                self.set(PGImageScaleMode.constantFactor.rawValue, forKey: PGImageScaleModeKey)
                self.set(newValue, forKey: PGImageScaleFactorKey)
                let userInfo = [ PGPrefObjectAnimateKey : true ]
                NotificationCenter.default.post(name: .PGPrefObjectImageScaleDidChange, object: self, userInfo: userInfo)
            }
        }
    }
    
    @objc
    var animatesImages: Bool
    {
        get
        {
            self.bool(forKey: PGAnimatesImagesKey)
        }
        set
        {
            if newValue != self.animatesImages
            {
                self.set(newValue, forKey: PGAnimatesImagesKey)
                NotificationCenter.default.post(name: .PGPrefObjectAnimatesImagesDidChange, object: self)
            }
        }
    }
    
    @objc
    var timerInterval: TimeInterval
    {
        get
        {
            return self.double(forKey: PGTimerIntervalKey)
        }
        set
        {
            if newValue != self.timerInterval
            {
                self.set(newValue, forKey: PGTimerIntervalKey)
                NotificationCenter.default.post(name: .PGPrefObjectTimerIntervalDidChange, object: self)
            }
        }
    }
    
    @objc
    var baseOrientation: PGOrientation
    {
        get
        {
            let raw = self.integer(forKey: PGBaseOrientationKey)
            return PGOrientation(rawValue: UInt(raw))
        }
        set
        {
            if newValue != self.baseOrientation
            {
                self.set(newValue.rawValue, forKey: PGBaseOrientationKey)
                NotificationCenter.default.post(name: .PGPrefObjectBaseOrientationDidChange, object: self)
            }
        }
    }
    
    // MARK: Sorting
    @objc
    var oldSortOrder: PGSortOrder
    {
        get
        {
            let raw = self.integer(forKey: PGSortOrderKey)
            return PGSortOrder(rawValue: UInt(raw))
        }
        set
        {
            if newValue != self.oldSortOrder
            {
                self.set(newValue.rawValue, forKey: PGSortOrderKey)
                NotificationCenter.default.post(name: .PGPrefObjectSortOrderDidChange, object: self)
            }
        }
    }
    
    @nonobjc
    var sortOrder: SortOrder
    {
        get
        {
            let raw = self.integer(forKey: PGSortOrderKey)
            let adapter = SortOrderAdapter(rawValue: raw)
            return adapter.sortOrder
        }
        set
        {
            var adapter = SortOrderAdapter(rawValue: self.integer(forKey: PGSortOrderKey))
            if newValue != adapter.sortOrder
            {
                adapter.sortOrder = newValue
                self.set(adapter.rawValue, forKey: PGSortOrderKey)
                NotificationCenter.default.post(name: .PGPrefObjectSortOrderDidChange, object: self)
            }
        }
    }
    
    @objc
    var isRepeatEnabled: Bool
    {
        get
        {
            let raw = self.integer(forKey: PGSortOrderKey)
            let adapter = SortOrderAdapter(rawValue: raw)
            return adapter.isRepeat
        }
        set
        {
            var adapter = SortOrderAdapter(rawValue: self.integer(forKey: PGSortOrderKey))
            if newValue != adapter.isRepeat
            {
                adapter.isRepeat = newValue
                self.set(adapter.rawValue, forKey: PGSortOrderKey)
                NotificationCenter.default.post(name: .PGPrefObjectSortOrderDidChange, object: self)
            }
        }
    }
    
    @objc
    var sortDescending: Bool
    {
        get
        {
            let raw = self.integer(forKey: PGSortOrderKey)
            let adapter = SortOrderAdapter(rawValue: raw)
            return adapter.isDescending
        }
        set
        {
            var adapter = SortOrderAdapter(rawValue: self.integer(forKey: PGSortOrderKey))
            if newValue != adapter.isDescending
            {
                adapter.isDescending = newValue
                self.set(adapter.rawValue, forKey: PGSortOrderKey)
                NotificationCenter.default.post(name: .PGPrefObjectSortOrderDidChange, object: self)
            }
        }
    }
}

// MARK: -

/// Reads the old sort order raw values and derives Swift types from them.
fileprivate struct SortOrderAdapter : RawRepresentable
{
    var rawValue: Int
    
    init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
    
    var sortOrder: SortOrder
    {
        get
        {
            let enumRawValue = rawValue & 0x0000_FFFF
            return SortOrder(rawValue: Int(enumRawValue)) ?? .unspecified
        }
        set
        {
            rawValue = rawValue & ~(0x0000_FFFF)
            rawValue = (rawValue | (newValue.rawValue & 0x0000_FFFF))
        }
    }
    
    var isDescending: Bool
    {
        get
        {
            return (rawValue & (1 << 16)) != 0
        }
        set
        {
            rawValue = newValue ? (rawValue | (1 << 16)) : (rawValue & ~(1 << 16))
        }
    }
    
    var isRepeat: Bool
    {
        get
        {
            return (rawValue & (1 << 17)) != 0
        }
        set
        {
            rawValue = newValue ? (rawValue | (1 << 17)) : (rawValue & ~(1 << 17))
        }
    }
}
