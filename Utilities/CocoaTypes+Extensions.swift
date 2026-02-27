//
//  CocoaTypes+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-26.
//

import Cocoa

extension NSRect
{
    init(size: NSSize, centeredIn rect: NSRect)
    {
        self.init(x: rect.midX - size.width / 2.0,
                  y: rect.midY - size.height / 2.0,
                  width: size.width,
                  height: size.height)
    }
}
