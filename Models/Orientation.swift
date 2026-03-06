//
//  Orientation.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-04.
//

import Foundation

/// The orientation of an image.
public struct Orientation : OptionSet, Sendable
{
    public let rawValue: UInt
    
    public init(rawValue: UInt)
    {
        self.rawValue = rawValue
    }
    
    public static let upright: Orientation = .init(rawValue: 0)
    
    public static let flippedVertically: Orientation = .init(rawValue: 1 << 0)
    
    public static let flippedHorizontally: Orientation = .init(rawValue: 1 << 1)
    
    public static let rotated90CounterClockwise: Orientation = .init(rawValue: 1 << 2)
    
    public static let upsideDown: Orientation = [.flippedVertically, .flippedHorizontally]
    
    public static let rotated90Clockwise: Orientation = [.flippedVertically, .flippedHorizontally, .rotated90CounterClockwise]
}

// MARK: -
extension Orientation
{
    /// Initializes an `Orientation` from a TIFF orientation.
    init(tiffOrientation: Int)
    {
        switch(tiffOrientation)
        {
            case 2: self = .flippedHorizontally
            case 3: self = .upsideDown
            case 4: self = .flippedVertically
            case 5: self = [.rotated90CounterClockwise, .flippedHorizontally]
            case 6: self = .rotated90Clockwise
            case 7: self = [.rotated90CounterClockwise, .flippedVertically]
            case 8: self = .rotated90CounterClockwise
            default: self = .upright
        }
    }
}

// MARK: -
extension Orientation : CustomStringConvertible
{
    /// A description of the orientation.
    public var description: String
    {
        if self == .upright
        {
            return "Upright"
        }
        else if self == .flippedVertically
        {
            return "Flipped Vertically"
        }
        else if self == .flippedHorizontally
        {
            return "Flipped Horizontally"
        }
        else if self == .upsideDown
        {
            return "Upside Down"
        }
        else if self == .rotated90CounterClockwise
        {
            return "Rotated 90° Counter-Clockwise"
        }
        else if self == .rotated90Clockwise
        {
            return "Rotated 90° Clockwise"
        }
        else if self == [.rotated90CounterClockwise, .flippedHorizontally]
        {
            return "Rotated 90° Counter-Clockwise & Flipped Horizontally"
        }
        else if self == [.rotated90CounterClockwise, .flippedVertically]
        {
            return "Rotated 90° Counter-Clockwise & Flipped Vertically"
        }
        else
        {
            return "Unknown"
        }
    }
    
    /// A localized description of the orientation.
    public var localizedDescription: String
    {
        // TODO: Add these to the Localizable.strings files.
        if self == .upright
        {
            return NSLocalizedString("Upright", comment: "Image orientation description")
        }
        else if self == .flippedVertically
        {
            return NSLocalizedString("Flipped Vertically", comment: "Image orientation description")
        }
        else if self == .flippedHorizontally
        {
            return NSLocalizedString("Flipped Horizontally", comment: "Image orientation description")
        }
        else if self == .upsideDown
        {
            return NSLocalizedString("Upside Down", comment: "Image orientation description")
        }
        else if self == .rotated90CounterClockwise
        {
            return NSLocalizedString("Rotated 90° Counter-Clockwise", comment: "Image orientation description")
        }
        else if self == .rotated90Clockwise
        {
            return NSLocalizedString("Rotated 90° Clockwise", comment: "Image orientation description")
        }
        else if self == [.rotated90CounterClockwise, .flippedHorizontally]
        {
            return NSLocalizedString("Rotated 90° Counter-Clockwise & Flipped Horizontally", comment: "Image orientation description")
        }
        else if self == [.rotated90CounterClockwise, .flippedVertically]
        {
            return NSLocalizedString("Rotated 90° Counter-Clockwise & Flipped Vertically", comment: "Image orientation description")
        }
        else
        {
            return NSLocalizedString("Unknown", comment: "Image orientation description")
        }
    }
}
