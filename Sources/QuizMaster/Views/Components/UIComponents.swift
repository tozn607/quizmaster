import SwiftUI

public struct LiquidGlassPalette {
    public static var oceanBlue: Color { .accentColor }
    public static var cyanTeal: Color { .accentColor }
    public static var emeraldMint: Color { .green }
    public static var crimsonRed: Color { .red }
}

public struct PrimaryButton: View {
    @Environment(\.appFontScale) var fontScale
    @Environment(\.colorScheme) var colorScheme
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
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.88)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.35), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

public struct SecondaryButton: View {
    @Environment(\.appFontScale) var fontScale
    @Environment(\.colorScheme) var colorScheme
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
            .background(
                ZStack {
                    GlassVisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                    Color(NSColor.controlBackgroundColor).opacity(colorScheme == .dark ? 0.4 : 0.6)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.2 : 0.4), lineWidth: 1)
            )
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
            .liquidGlassCard(cornerRadius: 14, accentColor: .accentColor)
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
            .background(color.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: color.opacity(0.25), radius: 2, x: 0, y: 1)
    }
}
