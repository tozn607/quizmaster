import SwiftUI

/// Custom App Logo combining a polished Liquid Glass icon backdrop, Graduation Hat, and playful tilted Smiley SF icon
public struct AppLogoView: View {
    let size: CGFloat
    
    public init(size: CGFloat = 48) {
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // Liquid Glass Specular Orb Container
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            LiquidGlassPalette.oceanBlue.opacity(0.85),
                            LiquidGlassPalette.cyanTeal.opacity(0.95),
                            LiquidGlassPalette.deepPurple.opacity(0.80)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1, size * 0.035)
                        )
                )
                .shadow(color: LiquidGlassPalette.oceanBlue.opacity(0.35), radius: size * 0.15, x: 0, y: size * 0.08)
            
            // Specular glass reflection highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.35), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .clipShape(Circle())
            
            // Graduation Cap Main Icon (Centered)
            Image(systemName: "graduationcap.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.54, height: size * 0.54)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
    }
}
