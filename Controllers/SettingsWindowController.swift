//
//  SettingsWindowController.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-22.
//

import Foundation

extension Notification.Name
{
    public static let settingsWindowControllerDisplayScreenDidChange = Notification.Name(rawValue: __PGDisplayScreenDidChange.rawValue)
    public static let settingsWindowControllerFullScreenBackgroundDidChange = Notification.Name(rawValue: __PGFullScreenBackgroundDidChange.rawValue)
    public static let settingsWindowControllerWindowBackgroundDidChange = Notification.Name(rawValue: __PGWindowBackgroundDidChange.rawValue)
}

fileprivate extension NSToolbarItem.Identifier
{
    static let generalPane = NSToolbarItem.Identifier(rawValue: "PGGeneralPane")
    static let thumbnailsPane = NSToolbarItem.Identifier(rawValue: "PGThumbnailPaneIdentifier")
    static let navigationPane = NSToolbarItem.Identifier(rawValue: "PGNavigationPaneIdentifier")
}

fileprivate struct SettingsPaneDefinition
{
    let identifier: NSToolbarItem.Identifier
    let title: String
    let localizationComment: String
    let iconImageName: String
    var localizedTitle: String
    {
        NSLocalizedString(title, comment: "")
    }
}

fileprivate let settingsPanes: [SettingsPaneDefinition] = [
    .init(identifier: .generalPane,
          title: "General",
          localizationComment: "Title of the general pref pane.",
          iconImageName: "gearshape"),
    .init(identifier: .thumbnailsPane,
          title: "Thumbnails",
          localizationComment: "Title of thumbnail pref pane.",
          iconImageName: "photo"),
    .init(identifier: .navigationPane,
          title: "Navigation",
          localizationComment: "Title of navigation pref pane.",
          iconImageName: "safari")
]

nonisolated(unsafe) fileprivate var observationContext = 0 // Dummy value, we only care about pointer comparison

@MainActor
fileprivate var _shared: SettingsWindowController?

// MARK: -

@objc
public class SettingsWindowController : NSWindowController
{
    @IBOutlet
    var generalView: NSView!
    @IBOutlet
    var windowBackgroundColorWell: NSColorWell!
    @IBOutlet
    var fullScreenBackgroundColorWell: NSColorWell!
    @IBOutlet
    var screensPopUp: NSPopUpButton!

    @IBOutlet
    var thumbnailsView: NSView!
    
    @IBOutlet
    var navigationView: NSView!
    @IBOutlet
    var secondaryMouseActionLabel: NSTextField!
    
    
    var displayScreen: NSScreen?
    {
        didSet
        {
            if let displayScreen
            {
                UserDefaults.standard.displayScreenIndex = NSScreen.screens.firstIndex(of: displayScreen) ?? 0
            }
        }
    }
    
    override public var windowNibName: NSNib.Name?
    {
        NSNib.Name("PGPreference")
    }
    
    @MainActor
    @objc(sharedSettingsWindowController)
    public class var shared: SettingsWindowController
    {
        if _shared == nil
        {
            _shared = SettingsWindowController()
        }
        return _shared!
    }
    
    init()
    {
        super.init(window: nil)
        _ = self.window
        
        registerObservation()
        _shared = self
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        registerObservation()
        _shared = self
    }
    
    @MainActor
    deinit
    {
        unregisterObservation()
    }
    
    // MARK: Managing KVO
    func registerObservation()
    {
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: PGWindowBackgroundTypeKey,
                                          context: &observationContext)
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: PGWindowBackgroundColorKey,
                                          context: &observationContext)
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: PGFullScreenBackgroundTypeKey,
                                          context: &observationContext)
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: PGFullScreenBackgroundColorKey,
                                          context: &observationContext)
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: PGMouseClickActionKey,
                                          context: &observationContext)
    }
    
    func unregisterObservation()
    {
        UserDefaults.standard.removeObserver(self, forKeyPath: PGWindowBackgroundTypeKey)
        UserDefaults.standard.removeObserver(self, forKeyPath: PGWindowBackgroundColorKey)
        UserDefaults.standard.removeObserver(self, forKeyPath: PGFullScreenBackgroundTypeKey)
        UserDefaults.standard.removeObserver(self, forKeyPath: PGFullScreenBackgroundColorKey)
        UserDefaults.standard.removeObserver(self, forKeyPath: PGMouseClickActionKey)
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?)
    {
        guard context == &observationContext else
        {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == PGMouseClickActionKey
        {
            Task
            {
                await updateSecondaryMouseActionLabel()
            }
        }
        else if keyPath == PGWindowBackgroundTypeKey
        {
            Task
            {
                await enableWindowBackgroundColorWellIfNecessary()
                NotificationCenter.default.post(name: .settingsWindowControllerWindowBackgroundDidChange, object: self)
            }
        }
        else if keyPath == PGFullScreenBackgroundTypeKey
        {
            Task
            {
                await enableFullScreenBackgroundColorWellIfNecessary()
                NotificationCenter.default.post(name: .settingsWindowControllerFullScreenBackgroundDidChange, object: self)
            }
        }
    }
    
    // MARK: NSWindowController Overrides
    override public func windowDidLoad()
    {
        super.windowDidLoad()
        
        let toolbar = NSToolbar(identifier: "PGPreferenceWindowControllerToolbar")
        toolbar.delegate = self
        self.window?.toolbar = toolbar
        
        setPane(.generalPane)
        self.window?.center()
        
        updateSecondaryMouseActionLabel()
        screenParametersDidChange()
        enableWindowBackgroundColorWellIfNecessary()
        enableFullScreenBackgroundColorWellIfNecessary()
    }
    
    // MARK: Updating UI Elements
    func enableWindowBackgroundColorWellIfNecessary()
    {
        windowBackgroundColorWell.isEnabled = UserDefaults.standard.windowBackgroundType == .customColor
    }
    
    func enableFullScreenBackgroundColorWellIfNecessary()
    {
        fullScreenBackgroundColorWell.isEnabled = UserDefaults.standard.fullscreenBackgroundType == .customColor
    }
    
    func updateSecondaryMouseActionLabel()
    {
        let label = switch UserDefaults.standard.mouseClickAction
        {
            case .nextPrevious: "Secondary click goes to the previous page."
            case .leftRight: "Secondary click goes right."
            case .rightLeft: "Secondary click goes left."
            @unknown default: fatalError()
        }
        secondaryMouseActionLabel.stringValue = NSLocalizedString(label, comment: "Informative string for secondary mouse button action.")
    }
    
    func setPane(_ identifier: NSToolbarItem.Identifier)
    {
        let newView = if identifier == .generalPane
        {
            generalView
        }
        else if identifier == .thumbnailsPane
        {
            thumbnailsView
        }
        else if identifier == .navigationPane
        {
            navigationView
        }
        else
        {
            fatalError("Invalid identifier for toolbar item: \(identifier.rawValue)")
        }
        
        let window = self.window!
        window.title = settingsPanes.first(where: { $0.identifier == identifier })!.localizedTitle
        window.toolbar?.selectedItemIdentifier = identifier
        let contentView = window.contentView!
        let oldView = contentView.subviews.last
        if oldView != newView
        {
            if oldView != nil
            {
                // We don't let oldView fade out because CoreAnimation
                // insists on pinning it to the bottom of the resizing
                // window (regardless of its autoresizing mask), which
                // looks awful.
                // Even if oldView is removed, if we don't force it to
                // redisplay, it still shows up during the transition.
                oldView!.removeFromSuperview()
                contentView.display()
            }
            
            NSAnimationContext.beginGrouping()
            if NSApplication.shared.currentEvent?.modifierFlags.contains(.shift) ?? false
            {
                NSAnimationContext.current.duration = 1.0
            }
            
            let bounds = contentView.bounds
            newView!.setFrameOrigin(.init(x: bounds.minX, y: bounds.height - newView!.frame.size.height))
            if oldView != nil
            {
                contentView.animator().addSubview(newView!)
            }
            else
            {
                contentView.addSubview(newView!)
            }
            
            var frame = window.contentRect(forFrameRect: window.frame)
            let frameHeight = newView!.frame.height
            frame.origin.y += frame.size.height - frameHeight
            frame.size.height = frameHeight
            if oldView != nil
            {
                window.animator().setFrame(window.frameRect(forContentRect: frame), display: true)
            }
            else
            {
                window.setFrame(window.frameRect(forContentRect: frame), display: true)
            }
            
            NSAnimationContext.endGrouping()
        }
    }
    
    // MARK: Actions
    @IBAction
    func changeDisplayScreen(_ sender: NSMenuItem)
    {
        self.displayScreen = sender.representedObject as? NSScreen
    }
    
    @IBAction
    func showHelp(_ sender: Any)
    {
        let book = Bundle.main.object(forInfoDictionaryKey: "CFBundleHelpBookName") as! String
        NSHelpManager.shared.openHelpAnchor("preferences", inBook: book)
    }

    
    public func screenParametersDidChange()
    {
        screensPopUp.removeAllItems()
        
        let screens = NSScreen.screens
        screensPopUp.isEnabled = !screens.isEmpty
        
        guard !screens.isEmpty else
        {
            displayScreen = nil
            return
        }
        
        // FIXME: What
        if let currentScreen = displayScreen, let currentScreenIndex = screens.firstIndex(of: currentScreen)
        {
            displayScreen = screens[currentScreenIndex]
        }
        else
        {
            // FIXME: Client code should not rely on this notification if the screen hasn't changed.
            // Post change notification.
            let newScreen = displayScreen
            displayScreen = newScreen
        }
        
        let screensMenu = screensPopUp.menu!
        for i in 0 ..< screens.count
        {
            let screen = screens[i]
            let label = i == 0
                ? NSLocalizedString("Main Screen", comment: "The primary screen.")
                : NSLocalizedString("Screen \(i + 1) (\(Int(screen.frame.width))x\(Int(screen.frame.height))", comment: "Non-primary screens. %lu is replaced with the screen number.")
            let item = NSMenuItem(title: label, action: #selector(changeDisplayScreen), keyEquivalent: "")
            item.representedObject = screen
            item.target = self
            screensMenu.addItem(item)
            if displayScreen == screen
            {
                screensPopUp.select(item)
            }
        }
    }
}

// MARK: -
extension SettingsWindowController : NSToolbarDelegate
{
    @objc
    func changePane(_ sender: NSToolbarItem)
    {
        setPane(sender.itemIdentifier)
    }
    
    public func toolbar(_ toolbar: NSToolbar,
                        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                        willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
    {
        let paneDef = settingsPanes.first(where: { $0.identifier == itemIdentifier })!
        
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.target = self
        item.action = #selector(changePane)
        item.label = paneDef.localizedTitle
        item.image = NSImage(systemSymbolName: paneDef.iconImageName, accessibilityDescription: nil)
        return item
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        return settingsPanes.map { $0.identifier }
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
}
