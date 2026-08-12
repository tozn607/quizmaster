import SwiftUI
import AppKit

public struct GlassVisualEffectView: NSViewRepresentable {
    public var material: NSVisualEffectView.Material = .hudWindow
    public var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    
    public init(material: NSVisualEffectView.Material = .hudWindow, blendingMode: NSVisualEffectView.BlendingMode = .withinWindow) {
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

public struct LiquidGlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 14
    var isInteractive: Bool = false
    var accentColor: Color = .accentColor
    
    public func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                ZStack {
                    GlassVisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                    Color(NSColor.controlBackgroundColor).opacity(colorScheme == .dark ? 0.35 : 0.6)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.3 : 0.6),
                                accentColor.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 8, x: 0, y: 4)
    }
}

extension View {
    public func liquidGlassCard(cornerRadius: CGFloat = 14, accentColor: Color = .accentColor) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, accentColor: accentColor))
    }
}
