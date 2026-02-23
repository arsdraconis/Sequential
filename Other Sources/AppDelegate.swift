//
//  AppDelegate.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-16.
//

import Cocoa

@objc
class AppDelegate: NSObject, NSApplicationDelegate
{
    func application(_ application: NSApplication, open urls: [URL])
    {
        for url in urls
        {
            _ = PGDocumentController.shared().openDocument(withContentsOf: url, display: true)
        }
        application.reply(toOpenOrPrint: .success)
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool
    {
        let fileURL = URL(fileURLWithPath: filename)
        let result = PGDocumentController.shared().openDocument(withContentsOf: fileURL, display: true)
        return result != nil
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String])
    {
        for filename in filenames
        {
            let fileURL = URL(fileURLWithPath: filename)
            _ = PGDocumentController.shared().openDocument(withContentsOf: fileURL, display: true)
        }
        sender.reply(toOpenOrPrint: .success)
    }
    
    func applicationDidChangeScreenParameters(_ notification: Notification)
    {
        SettingsWindowController.shared.screenParametersDidChange()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
    {
        // Explicitly opt into secure coding to silence warning message on launch.
        return true
    }
    
    func applicationWillFinishLaunching(_ notification: Notification)
    {
        // FIXME: Is this really necessary?
        // This was moved here from +[PGApplication initialize]. The only
        // comment on the original was, "We use a lot of file descriptors."
        //
        // The RLIM_INFINITY macro does not appear to be picked up by Swift. It's
        // defined as (((__uint64_t)1 << 63) - 1)
        var rlim = rlimit(rlim_cur: rlim_t.max, rlim_max: rlim_t.max)
        setrlimit(RLIMIT_NOFILE, &rlim)
    }

}
