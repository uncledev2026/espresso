import AppKit
import Foundation

struct IconVariant {
    let logicalSize: Int
    let scale: Int

    var pixels: Int {
        logicalSize * scale
    }

    var filename: String {
        scale == 1
            ? "icon_\(logicalSize)x\(logicalSize).png"
            : "icon_\(logicalSize)x\(logicalSize)@\(scale)x.png"
    }
}

let variants = [
    IconVariant(logicalSize: 16, scale: 1),
    IconVariant(logicalSize: 16, scale: 2),
    IconVariant(logicalSize: 32, scale: 1),
    IconVariant(logicalSize: 32, scale: 2),
    IconVariant(logicalSize: 128, scale: 1),
    IconVariant(logicalSize: 128, scale: 2),
    IconVariant(logicalSize: 256, scale: 1),
    IconVariant(logicalSize: 256, scale: 2),
    IconVariant(logicalSize: 512, scale: 1),
    IconVariant(logicalSize: 512, scale: 2)
]

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = root.appendingPathComponent("Resources/AppIcon.iconset", isDirectory: true)

try FileManager.default.createDirectory(
    at: iconsetURL,
    withIntermediateDirectories: true
)

for variant in variants {
    let image = NSImage(size: NSSize(width: variant.pixels, height: variant.pixels))

    image.lockFocus()
    drawIcon(size: CGFloat(variant.pixels))
    image.unlockFocus()

    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        fatalError("Could not render \(variant.filename)")
    }

    try png.write(to: iconsetURL.appendingPathComponent(variant.filename))
}

func drawIcon(size: CGFloat) {
    NSColor(calibratedRed: 0.07, green: 0.12, blue: 0.18, alpha: 1.0).setFill()
    NSBezierPath(
        roundedRect: NSRect(x: 0, y: 0, width: size, height: size),
        xRadius: size * 0.22,
        yRadius: size * 0.22
    ).fill()

    let circleRect = NSRect(
        x: size * 0.13,
        y: size * 0.13,
        width: size * 0.74,
        height: size * 0.74
    )
    NSColor(calibratedRed: 0.10, green: 0.42, blue: 0.68, alpha: 1.0).setFill()
    NSBezierPath(ovalIn: circleRect).fill()

    drawSteam(size: size)
    drawCup(size: size)
}

func drawSteam(size: CGFloat) {
    let strokeColor = NSColor(calibratedWhite: 1.0, alpha: 0.86)
    strokeColor.setStroke()

    let lineWidth = max(1.0, size * 0.025)
    let xOffsets = [-0.15, 0.0, 0.15]

    for offset in xOffsets {
        let path = NSBezierPath()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round

        let centerX = size * (0.5 + offset)
        path.move(to: NSPoint(x: centerX, y: size * 0.74))
        path.curve(
            to: NSPoint(x: centerX, y: size * 0.56),
            controlPoint1: NSPoint(x: centerX - size * 0.06, y: size * 0.68),
            controlPoint2: NSPoint(x: centerX + size * 0.06, y: size * 0.62)
        )
        path.stroke()
    }
}

func drawCup(size: CGFloat) {
    let white = NSColor(calibratedWhite: 0.98, alpha: 1.0)
    white.setFill()

    let cupRect = NSRect(
        x: size * 0.28,
        y: size * 0.31,
        width: size * 0.40,
        height: size * 0.22
    )
    NSBezierPath(
        roundedRect: cupRect,
        xRadius: size * 0.045,
        yRadius: size * 0.045
    ).fill()

    white.setStroke()
    let handle = NSBezierPath(ovalIn: NSRect(
        x: size * 0.62,
        y: size * 0.34,
        width: size * 0.14,
        height: size * 0.14
    ))
    handle.lineWidth = max(2.0, size * 0.035)
    handle.stroke()

    let saucerRect = NSRect(
        x: size * 0.24,
        y: size * 0.25,
        width: size * 0.50,
        height: size * 0.08
    )
    NSBezierPath(ovalIn: saucerRect).fill()
}
