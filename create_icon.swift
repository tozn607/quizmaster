import AppKit

func renderIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    // Background squircle rounded rect
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = size * 0.225
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    context.addPath(path)
    context.clip()
    
    // Vibrant Rainbow Gradient (Red -> Orange -> Yellow -> Green -> Cyan -> Blue -> Purple)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(calibratedRed: 0.98, green: 0.28, blue: 0.42, alpha: 1.0).cgColor, // Coral Red
        NSColor(calibratedRed: 1.00, green: 0.58, blue: 0.16, alpha: 1.0).cgColor, // Vibrant Orange
        NSColor(calibratedRed: 0.98, green: 0.82, blue: 0.18, alpha: 1.0).cgColor, // Golden Yellow
        NSColor(calibratedRed: 0.18, green: 0.82, blue: 0.48, alpha: 1.0).cgColor, // Emerald Green
        NSColor(calibratedRed: 0.10, green: 0.72, blue: 0.95, alpha: 1.0).cgColor, // Cyan Blue
        NSColor(calibratedRed: 0.55, green: 0.32, blue: 0.95, alpha: 1.0).cgColor  // Royal Purple
    ] as CFArray
    let locations: [CGFloat] = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
    
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: size),
            end: CGPoint(x: size, y: 0),
            options: []
        )
    }
    
    // Subtle glass shine overlay on top half
    let shinePath = CGMutablePath()
    shinePath.move(to: CGPoint(x: 0, y: size))
    shinePath.addLine(to: CGPoint(x: size, y: size))
    shinePath.addLine(to: CGPoint(x: size, y: size * 0.45))
    shinePath.addCurve(
        to: CGPoint(x: 0, y: size * 0.55),
        control1: CGPoint(x: size * 0.65, y: size * 0.35),
        control2: CGPoint(x: size * 0.35, y: size * 0.65)
    )
    shinePath.closeSubpath()
    
    context.setFillColor(NSColor.white.withAlphaComponent(0.14).cgColor)
    context.addPath(shinePath)
    context.fillPath()
    
    // Draw pure white main graduation cap icon with shadow for legibility & depth
    if let capSymbol = NSImage(systemSymbolName: "graduationcap.fill", accessibilityDescription: nil) {
        let symbolSize = size * 0.55
        let symbolRect = NSRect(
            x: (size - symbolSize) / 2,
            y: (size - symbolSize) / 2,
            width: symbolSize,
            height: symbolSize
        )
        
        // Draw shadow
        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: -size * 0.03),
            blur: size * 0.06,
            color: NSColor.black.withAlphaComponent(0.35).cgColor
        )
        
        // Render pure white SF Symbol
        let config = NSImage.SymbolConfiguration(pointSize: symbolSize, weight: .semibold)
            .applying(.init(paletteColors: [.white]))
        if let whiteCap = capSymbol.withSymbolConfiguration(config) {
            whiteCap.draw(in: symbolRect)
        } else {
            NSColor.white.set()
            capSymbol.draw(in: symbolRect)
        }
        
        context.restoreGState()
    }
    
    image.unlockFocus()
    return image
}

func savePNG(image: NSImage, path: String) {
    if let tiff = image.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        try? png.write(to: URL(fileURLWithPath: path))
    }
}

let iconsetDir = "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (filename, sz) in sizes {
    let img = renderIcon(size: sz)
    savePNG(image: img, path: "\(iconsetDir)/\(filename)")
}

let mainIcon = renderIcon(size: 256)
savePNG(image: mainIcon, path: "AppIcon.png")

print("AppIcon.iconset and AppIcon.png generated successfully with rainbow gradient and white main icon!")
