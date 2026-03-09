//
//  TimerPanelController.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-03.
//

import Foundation

@objc(PGTimerPanelController)
class TimerPanelController : FloatingPanelController
{
    @IBOutlet
    public var toggleButton: TimerButton!
    
    @IBOutlet
    public var remainingField: NSTextField!
    
    @IBOutlet
    public var totalField: NSTextField!
    
    @IBOutlet
    public var intervalSlider: NSSlider!
    
    private var timer: Timer?
    
    override var windowNibName: NSNib.Name? { "PGTimer" }
    
    @MainActor
    deinit
    {
        NotificationCenter.default.removeObserver(self,
                                                  name: .PGDisplayControllerTimerDidChange,
                                                  object: nil)
        timer?.invalidate()
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        tick(nil)
    }
        
    @objc
    public func displayControllerTimerDidChange(_ notification: Notification)
    {
        update()
    }
    
    override func setDisplayControllerReturningWasChanged(_ controller: DocumentWindowController?) -> Bool
    {
        let oldController = self.documentWindowController
        if !super.setDisplayControllerReturningWasChanged(controller) { return false }
        if let oldController
        {
            NotificationCenter.default.removeObserver(self,
                                                      name: .PGDisplayControllerTimerDidChange,
                                                      object: oldController)
        }
        
        if let newController = self.documentWindowController
        {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(displayControllerTimerDidChange(_:)),
                                                   name: .PGDisplayControllerTimerDidChange,
                                                   object: newController)
        }
        
        update()
        return true
    }
    
    override func windowWillShow()
    {
        update()
    }
    
    // MARK: IB Actions
    @IBAction
    public func toggleTimer(_ sender: Any?)
    {
        documentWindowController?.timerRunning.toggle()
    }
    
    @IBAction
    public func changeTimerInterval(_ sender: NSSlider!)
    {
        let newInterval = TimeInterval(sender.doubleValue.rounded())
        UserDefaults.standard.timerInterval = newInterval
        tick(nil)
    }
        
    // MARK: Internal Implementation
    private func update()
    {
        // FIXME: When the timer is running, timerRunning returns false?!?!
        let isRunning = documentWindowController?.timerRunning ?? false
        if (!self.isShown || !isRunning)
        {
            timer?.invalidate()
            timer = nil
        }
        else if (timer == nil)
        {
            timer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(tick(_:)), userInfo: nil, repeats: true)
        }
        toggleButton?.isEnabled = documentWindowController != nil
        toggleButton?.buttonIcon = isRunning ? .stop : .play
        tick(nil)
    }
    
    @objc
    private func tick(_ timer: Timer?)
    {
        let interval = UserDefaults.standard.timerInterval
        let isRunning = documentWindowController?.timerRunning ?? false
        var timeRemaining = interval
        
        if isRunning
        {
            if let fireDate = documentWindowController?.nextTimerFireDate
            {
                timeRemaining = max(0, fireDate.timeIntervalSinceNow)
            }
            else
            {
                timeRemaining = 0
            }
        }
        
        toggleButton?.progress = isRunning ? ((interval - timeRemaining) / interval) : 0.0
        let formatString = NSLocalizedString("%.1f seconds", comment: "Display string for timer intervals. %.1f is replaced with the remaining seconds and tenths of seconds.")
        remainingField?.stringValue = String.localizedStringWithFormat(formatString, timeRemaining)
        
        if (timer == nil)
        {
            totalField?.stringValue = String.localizedStringWithFormat(formatString, interval)
            intervalSlider?.doubleValue = interval
            intervalSlider?.isEnabled = self.documentWindowController != nil
        }
    }
}
