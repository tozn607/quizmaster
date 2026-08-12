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
    
    // Gradient fill (Ocean Blue to Cyan Teal & Emerald Mint)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(calibratedRed: 0.0, green: 0.48, blue: 1.0, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.0, green: 0.78, blue: 0.75, alpha: 1.0).cgColor
    ] as CFArray
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])
    }
    
    // Draw Graduation Cap symbol
    if let capSymbol = NSImage(systemSymbolName: "graduationcap.fill", accessibilityDescription: nil) {
        let symbolSize = size * 0.55
        let symbolRect = NSRect(
            x: (size - symbolSize) / 2,
            y: (size - symbolSize) / 2,
            width: symbolSize,
            height: symbolSize
        )
        NSColor.white.set()
        capSymbol.draw(in: symbolRect)
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

print("AppIcon.iconset generated with Ocean Blue & Cyan Teal gradient!")
