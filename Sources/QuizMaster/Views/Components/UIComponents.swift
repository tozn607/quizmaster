import SwiftUI
import AppKit

public struct LiquidGlassPalette {
    public static let oceanBlue = Color(red: 0.12, green: 0.48, blue: 0.92)
    public static let cyanTeal = Color(red: 0.15, green: 0.58, blue: 0.65)
    public static let emeraldMint = Color(red: 0.18, green: 0.62, blue: 0.40)
    public static let sunsetOrange = Color(red: 0.88, green: 0.46, blue: 0.20)
    public static let coralRed = Color(red: 0.84, green: 0.28, blue: 0.32)
    public static let deepPurple = Color(red: 0.48, green: 0.36, blue: 0.80)
}

public struct PrimaryButton: View {
    @Environment(\.appFontScale) var fontScale
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String?
    let action: () -> Void
    var color: Color = LiquidGlassPalette.oceanBlue
    
    public init(title: String, icon: String? = nil, color: Color = LiquidGlassPalette.oceanBlue, action: @escaping () -> Void) {
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
                        .font(.system(size: 14 * fontScale, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 14 * fontScale, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16 * fontScale)
            .padding(.vertical, 9 * fontScale)
            .background(
                ZStack {
                    // Refined solid color fill
                    color.opacity(0.92)
                    
                    // Subtle specular top shine
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.75)
            )
            .shadow(color: Color.black.opacity(0.10), radius: 3, x: 0, y: 1.5)
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
                        .font(.system(size: 14 * fontScale, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 14 * fontScale, weight: .bold))
            }
            .foregroundColor(colorScheme == .light ? Color(NSColor.labelColor) : Color.white)
            .padding(.horizontal, 14 * fontScale)
            .padding(.vertical, 8 * fontScale)
            .background(
                colorScheme == .light
                ? Color.white
                : Color.white.opacity(0.15)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        colorScheme == .light
                        ? Color.black.opacity(0.25)
                        : Color.white.opacity(0.35),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1.5)
        }
        .buttonStyle(.plain)
    }
}

public struct ProgressBar: View {
    let value: Double // 0.0 to 1.0
    var height: CGFloat = 8
    var color: Color = LiquidGlassPalette.oceanBlue
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(Color.gray.opacity(0.30))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.85)],
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
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(18)
            .foregroundColor(colorScheme == .light ? Color(NSColor.labelColor) : Color.white)
            .background(
                colorScheme == .light
                ? Color.white // Solid 100% white in Light Mode to guarantee zero white-on-white text issues!
                : Color(NSColor.controlBackgroundColor) // Solid dark background in Dark Mode
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        colorScheme == .light
                        ? Color.black.opacity(0.18)
                        : Color.white.opacity(0.25),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: colorScheme == .light ? Color.black.opacity(0.10) : Color.black.opacity(0.40),
                radius: colorScheme == .light ? 8 : 12,
                x: 0,
                y: 4
            )
    }
}

public struct BadgeView: View {
    @Environment(\.appFontScale) var fontScale
    let text: String
    var icon: String? = nil
    var color: Color = LiquidGlassPalette.oceanBlue
    
    public init(text: String, icon: String? = nil, color: Color = LiquidGlassPalette.oceanBlue) {
        self.text = text
        self.icon = icon
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 4 * fontScale) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10 * fontScale, weight: .bold))
            }
            Text(text)
                .font(.system(size: 11 * fontScale, weight: .bold))
        }
        .padding(.horizontal, 10 * fontScale)
        .padding(.vertical, 4.5 * fontScale)
        .foregroundColor(.white)
        .background(
            ZStack {
                color
                LinearGradient(
                    colors: [Color.white.opacity(0.22), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.8)
        )
        .shadow(color: color.opacity(0.35), radius: 2.5, x: 0, y: 1)
    }
}
