//
//  NSColor+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-16.
//

import Cocoa

@objc
extension NSColor
{
    @objc(PG_bezelBackgroundColor)
    class var bezelBackgroundColor: NSColor
    {
        Self.init(deviceWhite: 48.0 / 255.0, alpha: 0.75)
    }
    
    @objc(PG_bezelForegroundColor)
    class var bezelForegroundColor: NSColor
    {
        Self.init(deviceWhite: 0.95, alpha: 0.9)
    }
    
    @objc(PG_checkerboardPatternColor)
    var checkboardPatternColor: NSColor
    {
        let image = NSImage(named: NSImage.Name("Checkerboard"))!
        let pattern = NSImage(size: image.size, flipped: false)
        { dstRect in
            self.setFill()
            dstRect.fill()
            image.draw(in: dstRect, from: .zero, operation: .sourceAtop, fraction: 0.05)
            return true
        }
        return Self.init(patternImage: pattern)
    }
}
