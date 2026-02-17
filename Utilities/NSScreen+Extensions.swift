//
//  NSScreen+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-16.
//

import Cocoa

@objc
extension NSScreen
{
    /// Returns the primary screen (the screen containing the menu bar).
    @objc(PG_mainScreen)
    class var primaryScreen: NSScreen?
    {
        screens.first
    }
}
