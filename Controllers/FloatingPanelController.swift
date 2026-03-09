//
//  FloatingPanelController.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-08.
//

import Cocoa

typealias DocumentWindowController = PGDisplayController

@objc(PGFloatingPanelToggleInstruction)
enum FloatingPanelToggleInstruction: Int
{
    case hide = 0
    case doNothing = 1
    case showAtStatusWindowLevel = 2
}

@objc(PGFloatingPanelController)
class FloatingPanelController : NSWindowController
{
    @objc
    private(set) var isShown: Bool = false
    
    private var _documentWindowController: DocumentWindowController?
    
    var documentWindowController: DocumentWindowController? { _documentWindowController }
    
    override var windowFrameAutosaveName: NSWindow.FrameAutosaveName
    {
        get
        {
            guard let nibName = windowNibName else { return "" }
            return nibName + "PanelFrame"
        }
        set {}
    }
    
    override var shouldCascadeWindows: Bool
    {
        get { false }
        set {}
    }
    
    override init(window: NSWindow?)
    {
        super.init(window: window)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(windowDidBecomeMain(_:)), name: NSWindow.didBecomeMainNotification, object: nil)
        nc.addObserver(self, selector: #selector(windowDidResignMain(_:)), name: NSWindow.didResignMainNotification, object: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(windowDidBecomeMain(_:)), name: NSWindow.didBecomeMainNotification, object: nil)
        nc.addObserver(self, selector: #selector(windowDidResignMain(_:)), name: NSWindow.didResignMainNotification, object: nil)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        
        setDisplayControllerReturningWasChanged(nil)
        if let panel = window as? NSPanel
        {
            panel.becomesKeyOnlyIfNeeded = true
        }
        
        self.window?.setFrameUsingName(self.windowFrameAutosaveName)
    }
    
    // MARK: Window Lifecycle Events
    func windowWillShow() {}
    func windowWillHide() {}
    
    // MARK: Properties
    @objc
    @discardableResult
    func setDisplayControllerReturningWasChanged(_ displayController: DocumentWindowController?) -> Bool
    {
        let controller = displayController != nil
            ? displayController
            : (NSApplication.shared.mainWindow?.windowController as? DocumentWindowController)
        guard _documentWindowController != controller else { return false }
        _documentWindowController = controller
        return true
    }
    
    private func setIsShown(_ shown: Bool, forFullScreenTransition fullscreen: Bool)
    {
        guard (shown != isShown) else { return }
        
        isShown = shown
        
        if (shown)
        {
            windowWillShow()
            super.showWindow(self)
        }
        else
        {
            windowWillHide()
            if fullscreen
            {
                window?.orderOut(self)
            }
            else
            {
                window?.performClose(self)
            }
        }
    }
    
    @objc
    func toggleShown()
    {
        setIsShown(!isShown, forFullScreenTransition: false)
    }
    
    @objc
    func toggleShown(using i: FloatingPanelToggleInstruction)
    {
        if i == .showAtStatusWindowLevel
        {
            window?.level = .statusBar
        }
        setIsShown(!isShown, forFullScreenTransition: true)
    }
    
    // MARK: Actions
    @IBAction
    override func showWindow(_ sender: Any?)
    {
        setIsShown(true, forFullScreenTransition: false)
    }
}

extension FloatingPanelController : NSWindowDelegate
{
    func windowDidResize(_ notification: Notification)
    {
        window?.saveFrame(usingName: windowFrameAutosaveName)
    }
    
    func windowDidMove(_ notification: Notification)
    {
        window?.saveFrame(usingName: windowFrameAutosaveName)
    }
    
    func windowWillClose(_ notification: Notification)
    {
        isShown = false
        windowWillHide()
    }
    
    @objc
    func windowDidBecomeMain(_ notification: Notification)
    {
        setDisplayControllerReturningWasChanged(notification.object as? DocumentWindowController)
    }
    
    @objc
    func windowDidResignMain(_ notification: Notification)
    {
        setDisplayControllerReturningWasChanged(nil)
    }
}
