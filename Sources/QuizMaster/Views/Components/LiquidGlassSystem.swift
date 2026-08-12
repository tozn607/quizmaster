import SwiftUI
import AppKit

public struct GlassVisualEffectView: NSViewRepresentable {
    public var material: NSVisualEffectView.Material = .underWindowBackground
    public var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    
    public init(material: NSVisualEffectView.Material = .underWindowBackground, blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

public struct LiquidGlassWindowBackdrop<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            // Native Window Backdrop Blur (Desktop wallpaper bleeds through)
            GlassVisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            // Light Mode / Dark Mode Contrast Backing
            if colorScheme == .light {
                Color(NSColor.windowBackgroundColor)
                    .opacity(0.45)
                    .ignoresSafeArea()
            }
            
            // Dynamic Vibrant Ambient Liquid Glass Mesh Glow
            LinearGradient(
                colors: [
                    LiquidGlassPalette.oceanBlue.opacity(colorScheme == .dark ? 0.15 : 0.08),
                    Color.clear,
                    LiquidGlassPalette.deepPurple.opacity(colorScheme == .dark ? 0.10 : 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

public struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    public init(spacing: CGFloat = 16.0, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: spacing) {
            content
        }
    }
}
