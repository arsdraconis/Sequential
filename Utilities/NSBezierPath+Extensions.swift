//
//  NSBezierPath+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-16.
//

import Cocoa

@objc(AEIconType)
public enum IconType: Int
{
    case noIcon
    case play
    case pause
    case stop
}

@objc
extension NSBezierPath
{
    @objc(PG_drawIcon:inRect:)
    class func drawIcon(_ icon: IconType, in rect: NSRect)
    {
        let path = Self.init()
        let scale = min(rect.width, rect.height)
        switch icon
        {
            case .noIcon: break
                
            case .play:
                let radius = round(scale / 10.0)
                path.appendArc(withCenter: .init(x: round(rect.maxX - radius), y: round(rect.midY)),
                               radius: radius,
                               startAngle: 60.0,
                               endAngle: -60.0,
                               clockwise: true)
                path.appendArc(withCenter: .init(x: round(rect.minX + rect.width * 0.1 + radius), y: round(rect.minY + rect.height * 0.05 + radius + 1.0)),
                               radius: radius,
                               startAngle: -60.0,
                               endAngle: 180.0,
                               clockwise: true)
                path.appendArc(withCenter: .init(x: round(rect.minX + rect.width * 0.1 + radius), y: round(rect.minY + rect.height * 0.95 - radius + 1.0)),
                               radius: radius,
                               startAngle: 180.0,
                               endAngle: 60.0,
                               clockwise: true)
                path.fill()

            case .pause:
                path.lineWidth = scale / 4.0
                path.lineCapStyle = .round
                path.move(to: .init(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.85))
                path.line(to: .init(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.15))
                path.move(to: .init(x: rect.minX + rect.width * 0.75, y: rect.minY + rect.height * 0.85))
                path.line(to: .init(x: rect.minX + rect.width * 0.75, y: rect.minY + rect.height * 0.15))
                path.stroke()
                
            case .stop:
                rect.insetBy(dx: rect.width * 0.15, dy: rect.height * 0.15)
                    .fill(using: .sourceOver)
                
            @unknown default: break
        }
    }
    
    @objc(PG_drawSpinnerInRect:startAtPetal:)
    class func drawSpinner(in rect: NSRect, startAt petal: Int)
    {
        NSBezierPath.defaultLineWidth = min(rect.width, rect.height) / 11.0
        NSBezierPath.defaultLineCapStyle = .round
        let pi2 = CGFloat.pi * 2.0
        for i in 0..<12
        {
            let alpha: CGFloat = petal < 0 ? 0.1 : CGFloat((petal + i) % 12) / -12.0 + 1.0
            let angle: CGFloat = pi2 * CGFloat(i) / 12.0
            NSColor.bezelBackgroundColor.withAlphaComponent(alpha).set()
            NSBezierPath.strokeLine(from: .init(x: rect.midX + cos(angle) * rect.width / 4.0,
                                                y: rect.midY + sin(angle) * rect.height / 4.0),
                                    to: .init(x: rect.midX + cos(angle) * rect.width / 2.0,
                                              y: rect.midY + sin(angle) * rect.height / 2.0))
        }
        NSBezierPath.defaultLineWidth = 1.0
        NSBezierPath.defaultLineCapStyle = .butt
    }
}
