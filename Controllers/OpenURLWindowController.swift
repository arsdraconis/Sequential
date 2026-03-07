//
//  OpenURLWindowController.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-07.
//

import Cocoa

@objc
class OpenURLWindowController: NSWindowController
{
    override var windowNibName: NSNib.Name? { "PGURL" }
    
    @IBOutlet
    var urlField: NSTextField?
    
    @IBOutlet
    var okButton: NSButton?
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        enableOKButton()
    }
    
    func enableOKButton()
    {
        okButton?.isEnabled = URL(string: urlField?.stringValue ?? "") != nil
    }
    
    @objc
    public func runModal() -> URL?
    {
        let isCanceled = NSApplication.shared.runModal(for: window!) == .cancel
        window?.close()
        return isCanceled ? nil : URL(string: urlField!.stringValue)
    }
    
    // MARK: Action methods
    @IBAction
    func ok(_ sender: NSButton?)
    {
        NSApplication.shared.stopModal(withCode: .OK)
    }
    
    @IBAction
    func cancel(_ sender: NSButton?)
    {
        NSApplication.shared.stopModal(withCode: .cancel)
    }

}

extension OpenURLWindowController : NSControlTextEditingDelegate
{
    func controlTextDidChange(_ obj: Notification)
    {
        enableOKButton()
    }
}
