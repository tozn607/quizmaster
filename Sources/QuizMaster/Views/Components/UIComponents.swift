import SwiftUI

public struct GlassConfiguration {
    public var tintColor: Color? = nil
    public var isInteractive: Bool = false
    
    public static var regular: GlassConfiguration { GlassConfiguration() }
    
    public func tint(_ color: Color) -> GlassConfiguration {
        var copy = self
        copy.tintColor = color
        return copy
    }
    
    public func interactive(_ enabled: Bool = true) -> GlassConfiguration {
        var copy = self
        copy.isInteractive = enabled
        return copy
    }
}

public enum GlassShape {
    case capsule
    case rect(cornerRadius: CGFloat)
    case circle
}

extension View {
    @ViewBuilder
    public func glassEffect(_ config: GlassConfiguration = .regular, in shape: GlassShape = .rect(cornerRadius: 12.0)) -> some View {
        let tint = config.tintColor ?? Color.accentColor
        
        switch shape {
        case .capsule:
            let capsule = Capsule()
            self
                .background(
                    ZStack {
                        tint.opacity(0.18)
                    }
                    .background(.regularMaterial, in: capsule)
                )
                .clipShape(capsule)
                .overlay(
                    capsule.strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                tint.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        case .rect(let cr):
            let rect = RoundedRectangle(cornerRadius: cr, style: .continuous)
            self
                .background(
                    ZStack {
                        tint.opacity(0.18)
                    }
                    .background(.regularMaterial, in: rect)
                )
                .clipShape(rect)
                .overlay(
                    rect.strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                tint.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        case .circle:
            let circle = Circle()
            self
                .background(
                    ZStack {
                        tint.opacity(0.18)
                    }
                    .background(.regularMaterial, in: circle)
                )
                .clipShape(circle)
                .overlay(
                    circle.strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                tint.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
    }
}

public struct PrimaryButton: View {
    @Environment(\.appFontScale) var fontScale
    let title: String
    let icon: String?
    let action: () -> Void
    var color: Color = .accentColor
    
    public init(title: String, icon: String? = nil, color: Color = .accentColor, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14 * fontScale, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14 * fontScale, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16 * fontScale)
            .padding(.vertical, 9 * fontScale)
            .glassEffect(.regular.tint(color).interactive(), in: .rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

public struct SecondaryButton: View {
    @Environment(\.appFontScale) var fontScale
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14 * fontScale, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 14 * fontScale, weight: .medium))
            }
            .padding(.horizontal, 14 * fontScale)
            .padding(.vertical, 8 * fontScale)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

public struct ProgressBar: View {
    let value: Double // 0.0 to 1.0
    var height: CGFloat = 8
    var color: Color = .accentColor
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(geometry.size.width * CGFloat(value), geometry.size.width)), height: height)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
            }
        }
        .frame(height: height)
    }
}

public struct GlassCard<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(18)
            .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }
}

public struct BadgeView: View {
    @Environment(\.appFontScale) var fontScale
    let text: String
    var color: Color = .accentColor
    
    public init(text: String, color: Color = .accentColor) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(.system(size: 11 * fontScale, weight: .bold))
            .padding(.horizontal, 10 * fontScale)
            .padding(.vertical, 4 * fontScale)
            .foregroundColor(.white)
            .glassEffect(.regular.tint(color), in: .capsule)
    }
}
