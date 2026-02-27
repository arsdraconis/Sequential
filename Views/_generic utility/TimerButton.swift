//
//  TimerButton.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-25.
//

import Cocoa

@objc(PGTimerButton)
public class TimerButton: NSButton
{
    @objc
    var buttonIcon: IconType
    {
        get
        {
            (self.cell as! TimerButtonCell).buttonIcon
        }
        set
        {
            (self.cell as! TimerButtonCell).buttonIcon = newValue
        }
    }
    
    @objc
    var progress: CGFloat
    {
        get
        {
            (self.cell as! TimerButtonCell).progress
        }
        set
        {
            (self.cell as! TimerButtonCell).progress = newValue
            self.needsDisplay = true
        }
    }

    public override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        self.buttonIcon = .play
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.buttonIcon = .play
    }
    
    public override class var cellClass: AnyClass?
    {
        get { TimerButtonCell.self }
        set {}
    }
}


public class TimerButtonCell : NSButtonCell
{
    var buttonIcon: IconType = .play
    
    var progress: CGFloat = 0.0
    
    public override var isOpaque: Bool { false }
    
    public override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        NSColor.bezelForegroundColor.set()
        NSBezierPath(ovalIn: cellFrame.insetBy(dx: 0.5, dy: 0.5)).stroke()
        drawInterior(withFrame: cellFrame, in: controlView)
    }
    
    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView)
    {
        if progress > 0.001
        {
            NSGraphicsContext.saveGraphicsState()
            
            let center = NSPoint(x: cellFrame.midX, y: cellFrame.midY)
            let path = NSBezierPath()
            path.move(to: center)
            path.appendArc(withCenter: center,
                           radius: cellFrame.width / 2.0 - 2.0,
                           startAngle: 270.0,
                           endAngle: progress * 360.0 + 270.0,
                           clockwise: false)
            path.addClip()
            
            NSColor(deviceWhite: 0.85, alpha: 0.8).set()
            NSBezierPath(rect: cellFrame).fill()
            
            NSColor(deviceWhite: 1.0, alpha: 0.2).set()
            NSBezierPath(ovalIn: NSRect(x: cellFrame.minX,
                                        y: cellFrame.minY - cellFrame.height * 0.25,
                                        width: cellFrame.width,
                                        height: cellFrame.height * 0.75)).fill()
            
            NSGraphicsContext.restoreGraphicsState()
        }
        
        if (buttonIcon != .noIcon)
        {
            var color = isHighlighted ? NSColor(deviceWhite: 0.8, alpha: 0.9) : NSColor.white
            color = isEnabled ? color : color.withAlphaComponent(0.33)
            color.set()
            
            let shadow = NSShadow()
            shadow.shadowOffset = NSSize(width: 0, height: -1)
            shadow.shadowBlurRadius = 2
            shadow.shadowColor = NSColor(deviceWhite: 0, alpha: isEnabled ? 1 : 0.33)
            shadow.set()
            NSBezierPath.drawIcon(buttonIcon, in: NSRect(size: .init(width: 20, height: 20), centeredIn: cellFrame))
            shadow.shadowColor = nil
            shadow.set()
        }
    }
}

