//
//  UserDefaults+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-16.
//

import Cocoa

let PGPrefObjectAnimateKey = "PGPrefObjectAnimate"

fileprivate let PGRecentItemsKey = "PGRecentItems2"
fileprivate let PGDisplayScreenIndexKey = "PGDisplayScreenIndex"
fileprivate let PGShowsInfoInspectorKey = "PGShowsInfo"
fileprivate let PGMaxRecursionDepthKey = "PGMaxDepth"
fileprivate let PGMouseClickActionKey = "PGMouseClickAction"
fileprivate let PGEscapeKeyMappingKey = "PGEscapeKeyMapping"
fileprivate let PGTimerIntervalKey = "PGTimerInterval"

fileprivate let PGBackgroundPatternKey = "PGBackgroundPattern"
public let PGWindowBackgroundTypeKey = "PGWindowBackgroundType"
public let PGWindowBackgroundColorKey = "PGWindowBackgroundColor"
public let PGFullScreenBackgroundTypeKey = "PGFullScreenBackgroundType"
public let PGFullScreenBackgroundColorKey = "PGFullScreenBackgroundColor"

fileprivate let PGDimOtherScreensWhenFullScreenKey = "PGDimOtherScreens"
fileprivate let PGUseEntireScreenWhenInFullScreenKey = "PGUseEntireScreenWhenInFullScreen"

fileprivate let PGShowsThumbnailSidebarKey = "PGShowsThumbnails"
fileprivate let PGShowThumbnailImageNameKey = "PGShowThumbnailImageName"
fileprivate let PGShowThumbnailImageSizeKey = "PGShowThumbnailImageSize"
fileprivate let PGShowThumbnailContainerNameKey = "PGShowThumbnailContainerName"
fileprivate let PGShowThumbnailContainerChildCountKey = "PGShowThumbnailContainerChildCount"
fileprivate let PGShowThumbnailContainerChildSizeTotalKey = "PGShowThumbnailContainerChildSizeTotal"
fileprivate let PGThumbnailSizeFormatKey = "PGThumbnailSizeFormat"

fileprivate let PGBaseOrientationKey = "PGBaseOrientation"
fileprivate let PGBackwardsInitialLocationKey = "PGBackwardsInitialLocation"
fileprivate let PGDefaultReadingDirectionKey = "PGReadingDirectionRightToLeft"
fileprivate let PGAnimatesImagesKey = "PGAnimatesImages"

// static NSString *const PGSortOrderDeprecatedKey = @"PGSortOrder"; // Deprecated after 1.3.2.
fileprivate let PGSortOrderKey = "PGSortOrder2"

fileprivate let PGImageScaleModeKey = "PGImageScaleMode"
fileprivate let PGImageScaleFactorKey = "PGImageScaleFactor"
fileprivate let PGImageScaleConstraintKey = "PGImageScaleConstraint"
fileprivate let PGAntialiasWhenUpscalingKey = "PGAntialiasWhenUpscaling"

extension Notification.Name
{
    public static let displayScreenDidChange = Notification.Name(rawValue: __PGDisplayScreenDidChange.rawValue)
    public static let showsInfoDidChange = Notification.Name(rawValue: __PGPrefObjectShowsInfoDidChange.rawValue)
    public static let timerIntervalDidChange = Notification.Name(rawValue: __PGPrefObjectTimerIntervalDidChange.rawValue)

    public static let windowBackgroundDidChange = Notification.Name(rawValue: __PGWindowBackgroundDidChange.rawValue)
    public static let fullScreenBackgroundDidChange = Notification.Name(rawValue: __PGFullScreenBackgroundDidChange.rawValue)
    
    public static let showsThumbnailsSidebarDidChange = Notification.Name(rawValue: __PGPrefObjectShowsThumbnailsDidChange.rawValue)
    public static let baseOrientationDidChange = Notification.Name(rawValue: __PGPrefObjectBaseOrientationDidChange.rawValue)
    public static let readingDirectionDidChange = Notification.Name(rawValue: __PGPrefObjectReadingDirectionDidChange.rawValue)
    public static let animatesImagesDidChange = Notification.Name(rawValue: __PGPrefObjectAnimatesImagesDidChange.rawValue)
    
    public static let sortOrderDidChange = Notification.Name(rawValue: __PGPrefObjectSortOrderDidChange.rawValue)
    
    public static let imageScaleDidChange = Notification.Name(rawValue: __PGPrefObjectImageScaleDidChange.rawValue)
    public static let upscalesToFitScreenDidChange = Notification.Name(rawValue: __PGPrefObjectUpscalesToFitScreenDidChange.rawValue)
}

@objc(PGWindowBackgroundType)
public enum WindowBackgroundType : Int
{
    case systemAppearance
    case customColor
    case pattern
    case stretchAndBlur
}

@objc(PGFullScreenBackgroundType)
public enum FullScreenBackgroundType : Int
{
    case sameAsWindow
    case systemAppearance
    case customColor
    case pattern
    case stretchAndBlur
}

@objc(PGPatternType)
public enum PatternType: Int
{
    case noPattern
    case checkerboard
}

@objc(PGImageScaleMode)
public enum ImageScaleMode: Int
{
    /// "Actual size". Formerly known as PGNoScale.
    case constantFactor
    /// "Automatic fit".
    case automatic
    /// Deprecated after 1.0.3.
    case deprecatedVerticalFit
    /// "Fit To Window". Fits the entire image inside the screen/window.
    case fitToView
    /// Depcrecated after 2.1.2.
    case deprecatedActualSizeWithDPI
}

@objc(PGSortOrder)
public enum SortOrder: Int, Sendable
{
    case unspecified = 0
    case byName = 1
    case byDateModified = 2
    case byDateCreated = 3
    case bySize = 4
    case byKind = 5
    case shuffle = 100
    case innate = 200
}

@objc
extension UserDefaults
{
    class func registerAppDefaults()
    {
        let standard = UserDefaults.standard
        
        let archivedBlackColor = try! NSKeyedArchiver.archivedData(withRootObject: NSColor.black,
                                                                   requiringSecureCoding: true)
        standard.register(defaults: [
            PGBackgroundColorKey: archivedBlackColor,
            PGBackgroundPatternKey: PatternType.noPattern.rawValue,
            
            PGMaxRecursionDepthKey: 1,
            PGMouseClickActionKey: PGAction.nextPrevious.rawValue,
            PGEscapeKeyMappingKey: PGEscapeMapping.fullscreen.rawValue,
            
            PGDefaultReadingDirectionKey: PGReadingDirection.leftToRight.rawValue,
            PGBackwardsInitialLocationKey: PGPageLocation.end.rawValue,

            PGImageScaleModeKey: ImageScaleMode.constantFactor.rawValue,
            PGImageScaleFactorKey: 1.0,
            PGImageScaleConstraintKey: PGImageScaleConstraint.none.rawValue,
            PGAntialiasWhenUpscalingKey: true,
            
            PGAnimatesImagesKey: true,
            PGSortOrderKey: SortOrder.byName.rawValue,
            PGTimerIntervalKey: 30.0,
            PGBaseOrientationKey: PGOrientation(rawValue: 0).rawValue,
            
            PGDimOtherScreensWhenFullScreenKey: false,
            PGUseEntireScreenWhenInFullScreenKey: false,
            
            PGShowsInfoInspectorKey: true,
            PGShowsThumbnailSidebarKey: true,

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
        
        // 2026/02/22 Transition to new background settings
        if let o = standard.object(forKey: "PGBackgroundColorSourceKey")
        {
            let i = (o as! NSNumber).intValue
            if i == 1
            {
                standard.set(WindowBackgroundType.customColor, forKey: PGWindowBackgroundTypeKey as String)
                standard.set(FullScreenBackgroundType.customColor, forKey: PGFullScreenBackgroundTypeKey as String)
            }
            else
            {
                standard.set(WindowBackgroundType.systemAppearance, forKey: PGWindowBackgroundTypeKey as String)
                standard.set(FullScreenBackgroundType.systemAppearance, forKey: PGFullScreenBackgroundTypeKey as String)
            }
            standard.removeObject(forKey: "PGBackgroundColorSourceKey")
        }
        
        // 2026/02/22 Transition older saved resent items
        if let d = standard.object(forKey: "PGRecentItems")
        {
            standard.set(d, forKey: PGRecentItemsKey)
            standard.removeObject(forKey: "PGRecentItems")
        }
        if let d = standard.object(forKey: "PGRecentDocuments")
        {
            standard.set(d, forKey: PGRecentItemsKey)
            standard.removeObject(forKey: "PGRecentDocuments")
        }
    }
    
    // MARK: App-Wide Settings
    @objc
    var recentItems: Data?
    {
        get
        {
            self.data(forKey: PGRecentItemsKey)
        }
        set
        {
            self.set(newValue, forKey: PGRecentItemsKey)
        }
    }
    
    @objc
    var displayScreenIndex: Int
    {
        get
        {
            let result = self.integer(forKey: PGDisplayScreenIndexKey)
            return max(result, 0)
        }
        set
        {
            if (newValue != displayScreenIndex)
            {
                self.set(max(newValue, 0), forKey: PGDisplayScreenIndexKey)
                NotificationCenter.default.post(name: .settingsWindowControllerDisplayScreenDidChange, object: self)
            }
        }
    }
    
    @objc
    var displayScreen: NSScreen?
    {
        get
        {
            let index = displayScreenIndex
            let screens = NSScreen.screens
            return index < screens.count ? screens[index] : NSScreen.primaryScreen
        }
    }
    
    @objc
    var showsInfo: Bool
    {
        get
        {
            self.bool(forKey: PGShowsInfoInspectorKey)
        }
        set
        {
            if newValue != self.showsInfo
            {
                self.set(newValue, forKey: PGShowsInfoInspectorKey)
                NotificationCenter.default.post(name: .showsInfoDidChange, object: self)
            }
        }
    }
    
    @objc
    var maximumRecursionDepth: Int
    {
        get
        {
            self.integer(forKey: PGMaxRecursionDepthKey)
        }
        set
        {
            self.set(newValue, forKey: PGMaxRecursionDepthKey)
        }
    }
    
    @objc
    var mouseClickAction: PGAction
    {
        get
        {
            let raw = UInt(self.integer(forKey: PGMouseClickActionKey))
            return PGAction(rawValue: raw) ?? .nextPrevious
        }
        set
        {
            self.set(Int(newValue.rawValue), forKey: PGMouseClickActionKey)
        }
    }
    
    @objc
    var escapeKeyMapping: PGEscapeMapping
    {
        get
        {
            let raw = UInt(self.integer(forKey: PGEscapeKeyMappingKey))
            return PGEscapeMapping(rawValue: raw) ?? .fullscreen
        }
        set
        {
            self.set(Int(newValue.rawValue), forKey: PGEscapeKeyMappingKey)
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
                NotificationCenter.default.post(name: .timerIntervalDidChange, object: self)
            }
        }
    }

    // MARK: Backgound Settings
    @objc
    var windowBackgroundType: WindowBackgroundType
    {
        get
        {
            let raw = self.integer(forKey: PGWindowBackgroundTypeKey as String)
            return WindowBackgroundType(rawValue: raw) ?? .systemAppearance
        }
        set
        {
            self.set(newValue.rawValue, forKey: PGWindowBackgroundTypeKey as String)
        }
    }
    
    @objc
    var savedWindowBackgroundColor: NSColor?
    {
        get
        {
            if let data = self.data(forKey: PGWindowBackgroundColorKey as String)
            {
                return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
            }
            else
            {
                return nil
            }
        }
        set
        {
            if let newValue
            {
                let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
                self.set(data, forKey: PGWindowBackgroundColorKey as String)
            }
        }
    }
    
    @objc
    var windowBackgroundColor: NSColor
    {
        switch windowBackgroundType
        {
            case .systemAppearance: return NSColor.windowBackgroundColor
            case .customColor: return savedWindowBackgroundColor ?? NSColor.black
            case .pattern: return NSColor.windowBackgroundColor.checkboardPatternColor
            case .stretchAndBlur: return NSColor.windowBackgroundColor
        }
    }
    
    @objc
    var fullscreenBackgroundType: FullScreenBackgroundType
    {
        get
        {
            let raw = self.integer(forKey: PGFullScreenBackgroundTypeKey as String)
            return FullScreenBackgroundType(rawValue: raw) ?? .sameAsWindow
        }
        set
        {
            self.set(newValue.rawValue, forKey: PGFullScreenBackgroundTypeKey as String)
        }
    }
    
    @objc
    var savedFullscreenBackgroundColor: NSColor?
    {
        get
        {
            if let data = self.data(forKey: PGFullScreenBackgroundColorKey as String)
            {
                return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
            }
            else
            {
                return nil
            }
        }
        set
        {
            if let newValue
            {
                let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
                self.set(data, forKey: PGFullScreenBackgroundColorKey as String)
            }
        }
    }
    
    @objc
    var fullScreenBackgroundColor: NSColor
    {
        switch fullscreenBackgroundType
        {
            case .sameAsWindow: return windowBackgroundColor
            case .systemAppearance: return NSColor.windowBackgroundColor
            case .customColor: return savedFullscreenBackgroundColor ?? NSColor.black
            case .pattern: return NSColor.windowBackgroundColor.checkboardPatternColor
            case .stretchAndBlur: return NSColor.windowBackgroundColor
        }
    }
    
    // MARK: Fullscreen Settings
    @objc
    var dimOtherScreensInFullScreen: Bool
    {
        get
        {
            self.bool(forKey: PGDimOtherScreensWhenFullScreenKey)
        }
        set
        {
            self.set(newValue, forKey: PGDimOtherScreensWhenFullScreenKey)
        }
    }
    
    @objc
    var useEntireScreenWhenInFullScreen: Bool
    {
        get
        {
            self.bool(forKey: PGUseEntireScreenWhenInFullScreenKey)
        }
        set
        {
            self.set(newValue, forKey: PGUseEntireScreenWhenInFullScreenKey)
        }
    }
    
    // MARK: Thumbnail Settings
    @objc
    var showsThumbnailSidebar: Bool
    {
        get
        {
            self.bool(forKey: PGShowsThumbnailSidebarKey)
        }
        set
        {
            if newValue != self.showsThumbnailSidebar
            {
                self.set(newValue, forKey: PGShowsThumbnailSidebarKey)
                NotificationCenter.default.post(name: .showsThumbnailsSidebarDidChange, object: self)
            }
        }
    }
    
    @objc
    var showThumbnailImageName: Bool
    {
        get
        {
            self.bool(forKey: PGShowThumbnailImageNameKey)
        }
        set
        {
            if newValue != self.showThumbnailImageName
            {
                self.set(newValue, forKey: PGShowThumbnailImageNameKey)
                NotificationCenter.default.post(name: .showsThumbnailsSidebarDidChange, object: self)
            }
        }
    }
    
    @objc
    var showThumbnailImageSize: Bool
    {
        get
        {
            self.bool(forKey: PGShowThumbnailImageSizeKey)
        }
        set
        {
            if newValue != self.showThumbnailImageSize
            {
                self.set(newValue, forKey: PGShowThumbnailImageSizeKey)
                NotificationCenter.default.post(name: .showsThumbnailsSidebarDidChange, object: self)
            }
        }
    }
    
    @objc
    var thumbnailSizeFormat: Int
    {
        get
        {
            self.integer(forKey: PGThumbnailSizeFormatKey)
        }
        set
        {
            self.set(newValue, forKey: PGThumbnailSizeFormatKey)
        }
    }

    // MARK: Default Document Settings
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
                NotificationCenter.default.post(name: .baseOrientationDidChange, object: self)
            }
        }
    }
    
    @objc
    var initialLocationWhenNavigatingBackwards: PGPageLocation
    {
        get
        {
            let raw = self.integer(forKey: PGBackwardsInitialLocationKey)
            return PGPageLocation(rawValue: raw) ?? .home
        }
        set
        {
            self.set(newValue.rawValue, forKey: PGBackwardsInitialLocationKey)
        }
    }
    
    @objc
    var defaultReadingDirection: PGReadingDirection
    {
        get
        {
            let raw = self.integer(forKey: PGDefaultReadingDirectionKey)
            return PGReadingDirection(rawValue: raw) ?? .leftToRight
        }
        set
        {
            if newValue != self.defaultReadingDirection
            {
                self.set(newValue.rawValue, forKey: PGDefaultReadingDirectionKey)
                NotificationCenter.default.post(name: .readingDirectionDidChange, object: self)
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
                NotificationCenter.default.post(name: .animatesImagesDidChange, object: self)
            }
        }
    }
    
    // MARK: Default Sort Settings
    @objc
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
                NotificationCenter.default.post(name: .sortOrderDidChange, object: self)
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
                NotificationCenter.default.post(name: .sortOrderDidChange, object: self)
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
                NotificationCenter.default.post(name: .sortOrderDidChange, object: self)
            }
        }
    }
    
    // MARK: Default Scaling Settings
    @objc
    var imageScaleMode: ImageScaleMode
    {
        get
        {
            let raw = self.integer(forKey: PGImageScaleModeKey)
            return ImageScaleMode(rawValue: raw) ?? .constantFactor
        }
        set
        {
            if newValue != self.imageScaleMode
            {
                self.set(newValue.rawValue, forKey: PGImageScaleModeKey)
                self.set(1.0, forKey: PGImageScaleFactorKey)
                let userInfo = [ PGPrefObjectAnimateKey : true ]
                NotificationCenter.default.post(name: .imageScaleDidChange, object: self, userInfo: userInfo)
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
                self.set(ImageScaleMode.constantFactor.rawValue, forKey: PGImageScaleModeKey)
                self.set(newValue, forKey: PGImageScaleFactorKey)
                let userInfo = [ PGPrefObjectAnimateKey : true ]
                NotificationCenter.default.post(name: .imageScaleDidChange, object: self, userInfo: userInfo)
            }
        }
    }
    
    @objc
    var imageScaleConstraint: PGImageScaleConstraint
    {
        get
        {
            let raw = UInt(self.integer(forKey: PGImageScaleConstraintKey))
            return PGImageScaleConstraint(rawValue: raw) ?? .none
        }
        set
        {
            self.set(newValue.rawValue, forKey: PGImageScaleConstraintKey)
        }
    }
    
    @objc
    var antialiasWhenUpscaling: Bool
    {
        get
        {
            return self.bool(forKey: PGAntialiasWhenUpscalingKey)
        }
        set
        {
            self.set(newValue, forKey: PGAntialiasWhenUpscalingKey)
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
