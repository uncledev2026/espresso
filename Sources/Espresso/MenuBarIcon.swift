import AppKit

enum MenuBarIcon {
    static func makeImage(isEnabled: Bool) -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            draw(in: rect, isEnabled: isEnabled)
            return true
        }

        image.isTemplate = true
        return image
    }

    private static func draw(in rect: NSRect, isEnabled: Bool) {
        let bounds = rect.insetBy(dx: 2.5, dy: 2.0)
        NSColor.black.setStroke()
        NSColor.black.setFill()

        if isEnabled {
            drawSteam(in: bounds)
        }

        let cupRect = NSRect(
            x: bounds.minX + bounds.width * 0.12,
            y: bounds.minY + bounds.height * 0.24,
            width: bounds.width * 0.58,
            height: bounds.height * 0.34
        )

        let cup = NSBezierPath(
            roundedRect: cupRect,
            xRadius: 1.8,
            yRadius: 1.8
        )

        if isEnabled {
            cup.fill()
        } else {
            cup.lineWidth = 1.6
            cup.stroke()
        }

        let handle = NSBezierPath(ovalIn: NSRect(
            x: cupRect.maxX - 0.3,
            y: cupRect.minY + cupRect.height * 0.18,
            width: bounds.width * 0.22,
            height: cupRect.height * 0.62
        ))
        handle.lineWidth = 1.6
        handle.stroke()

        let saucer = NSBezierPath()
        saucer.lineCapStyle = .round
        saucer.lineWidth = 1.5
        saucer.move(to: NSPoint(x: bounds.minX + bounds.width * 0.15, y: bounds.minY + bounds.height * 0.17))
        saucer.line(to: NSPoint(x: bounds.minX + bounds.width * 0.78, y: bounds.minY + bounds.height * 0.17))
        saucer.stroke()
    }

    private static func drawSteam(in bounds: NSRect) {
        for offset in [0.30, 0.50, 0.70] {
            let path = NSBezierPath()
            path.lineCapStyle = .round
            path.lineWidth = 1.25
            let x = bounds.minX + bounds.width * offset
            path.move(to: NSPoint(x: x, y: bounds.minY + bounds.height * 0.86))
            path.curve(
                to: NSPoint(x: x, y: bounds.minY + bounds.height * 0.66),
                controlPoint1: NSPoint(x: x - 1.4, y: bounds.minY + bounds.height * 0.80),
                controlPoint2: NSPoint(x: x + 1.4, y: bounds.minY + bounds.height * 0.72)
            )
            path.stroke()
        }
    }
}
