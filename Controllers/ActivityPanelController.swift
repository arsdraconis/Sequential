//
//  ActivityPanelController.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-07.
//

import Cocoa

@objc(PGActivityPanelController)
class ActivityPanelController : FloatingPanelController
{
    @IBOutlet
    var activityOutline: NSOutlineView!
    
    @IBOutlet
    var identifierColumn: NSTableColumn!
    
    @IBOutlet
    var progressColumn: NSTableColumn!
    
    @IBOutlet
    var cancelButton: NSButton!
    
    var updateTimer: Timer?
    
    override var windowNibName: NSNib.Name? { "PGActivity" }
    
    @MainActor
    deinit
    {
        updateTimer?.invalidate()
        updateTimer = nil
    }
        
    // MARK: Window Lifecycle
    override func windowDidLoad()
    {
        super.windowDidLoad()
        enableCancelButton()
    }
    
    override func windowWillShow()
    {
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(update),
                                           userInfo: nil,
                                           repeats: true)
        update()
    }
    
    override func windowWillHide()
    {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: Updating the UI
    @objc
    func update()
    {
        activityOutline?.reloadData()
        activityOutline?.expandItem(nil, expandChildren: true)
    }
    
    func enableCancelButton()
    {
        cancelButton?.isEnabled = activityOutline?.selectedRowIndexes.count ?? 0 > 0
    }
    
    // MARK: Actions
    @IBAction
    func cancelLoad(_ sender: Any)
    {
        let indexes = activityOutline.selectedRowIndexes
        for i in indexes
        {
            let item = activityOutline.item(atRow: i) as! PGActivity
            item.cancel(sender)
        }
    }
}

// MARK: -
extension ActivityPanelController : NSOutlineViewDataSource
{
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        if let item = item as? PGActivity
        {
            return item.childActivities(true).count
        }
        else
        {
            return PGActivity.application().childActivities(true).count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        if let item = item as? PGActivity
        {
            return item.childActivities(true)[index]
        }
        else
        {
            return PGActivity.application().childActivities(true)[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        if let item = item as? PGActivity
        {
            return item.childActivities(true).count > 0
        }
        return true
    }
}

// MARK: -
extension ActivityPanelController : NSOutlineViewDelegate
{
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any?
    {
        guard let item = item as? PGActivity else { return nil }
        
        if tableColumn == identifierColumn
        {
            return item.activityDescription
        }
        else if tableColumn == progressColumn
        {
            return item.progress as NSNumber
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        if tableColumn == identifierColumn
        {
            return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActivityDescriptionView"), owner: self)
        }
        else if tableColumn == progressColumn, let item = item as? PGActivity
        {
            if item.progress <= 0 || item.childActivities(true).count > 0
            {
                return nil
            }
            else
            {
                return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActivityProgressView"), owner: self)
            }
        }
        return nil
    }
}
