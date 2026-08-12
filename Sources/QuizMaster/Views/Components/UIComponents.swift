import SwiftUI

public struct LiquidGlassPalette {
    public static let oceanBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    public static let cyanTeal = Color(red: 0.0, green: 0.78, blue: 0.75)
    public static let emeraldMint = Color(red: 0.06, green: 0.73, blue: 0.51)
    public static let crimsonRed = Color(red: 0.95, green: 0.26, blue: 0.35)
}

public struct PrimaryButton: View {
    @Environment(\.appFontScale) var fontScale
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
                        .font(.system(size: 14 * fontScale, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14 * fontScale, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16 * fontScale)
            .padding(.vertical, 10 * fontScale)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
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
            .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
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
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
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
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.7))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

public struct BadgeView: View {
    @Environment(\.appFontScale) var fontScale
    let text: String
    var color: Color = LiquidGlassPalette.oceanBlue
    
    public init(text: String, color: Color = LiquidGlassPalette.oceanBlue) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(.system(size: 11 * fontScale, weight: .bold))
            .padding(.horizontal, 10 * fontScale)
            .padding(.vertical, 5 * fontScale)
            .foregroundColor(.white)
            .background(color.opacity(0.88))
            .cornerRadius(12)
            .shadow(color: color.opacity(0.25), radius: 2, x: 0, y: 1)
    }
}
