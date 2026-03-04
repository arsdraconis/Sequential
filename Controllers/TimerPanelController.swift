//
//  TimerPanelController.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-03.
//

import Foundation

@objc(PGTimerPanelController)
class TimerPanelController : PGFloatingPanelController
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
    
    override var isShown: Bool
    {
        didSet
        {
            update()
        }
    }
    
    @objc
    public func displayControllerTimerDidChange(_ notification: Notification)
    {
        update()
    }
    
    override func setDisplayReturningWasChanged(_ controller: PGDisplayController?) -> Bool
    {
        let oldController = self.displayController
        if !super.setDisplayReturningWasChanged(controller) { return false }
        if let oldController
        {
            NotificationCenter.default.removeObserver(self,
                                                      name: .PGDisplayControllerTimerDidChange,
                                                      object: oldController)
        }
        
        if let newController = self.displayController
        {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(displayControllerTimerDidChange(_:)),
                                                   name: .PGDisplayControllerTimerDidChange,
                                                   object: newController)
        }
        
        update()
        return true
    }
    
    // MARK: IB Actions
    @IBAction
    public func toggleTimer(_ sender: Any?)
    {
        displayController?.timerRunning.toggle()
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
        let isRunning = displayController?.timerRunning ?? false
        if (!self.isShown || !isRunning)
        {
            timer?.invalidate()
            timer = nil
        }
        else if (timer == nil)
        {
            timer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(tick(_:)), userInfo: nil, repeats: true)
        }
        toggleButton?.isEnabled = displayController != nil
        toggleButton?.buttonIcon = isRunning ? .stop : .play
        tick(nil)
    }
    
    @objc
    private func tick(_ timer: Timer?)
    {
        let interval = UserDefaults.standard.timerInterval
        let isRunning = displayController?.timerRunning ?? false
        var timeRemaining = interval
        
        if isRunning
        {
            if let fireDate = displayController?.nextTimerFireDate
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
            intervalSlider?.isEnabled = self.displayController != nil
        }
    }
}
