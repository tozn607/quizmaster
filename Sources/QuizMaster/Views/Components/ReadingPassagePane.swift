import SwiftUI

public enum ReadingBoxTheme: String, CaseIterable, Identifiable {
    case standard = "Tự động"
    case sepia = "Giấy vàng (Sepia)"
    case paperWhite = "Trắng trang sách"
    case slateDark = "Tối dịu mắt"
    
    public var id: String { rawValue }
    
    public var backgroundColor: Color {
        switch self {
        case .standard: return Color.clear
        case .sepia: return Color(red: 0.96, green: 0.93, blue: 0.85)
        case .paperWhite: return Color(red: 0.99, green: 0.99, blue: 0.97)
        case .slateDark: return Color(red: 0.14, green: 0.16, blue: 0.20)
        }
    }
    
    public var textColor: Color {
        switch self {
        case .standard: return Color.primary
        case .sepia: return Color(red: 0.26, green: 0.20, blue: 0.12)
        case .paperWhite: return Color(red: 0.12, green: 0.12, blue: 0.14)
        case .slateDark: return Color(red: 0.92, green: 0.94, blue: 0.96)
        }
    }
}

public enum ReadingFontFamily: String, CaseIterable, Identifiable {
    case system = "Hệ thống (San Francisco)"
    case serif = "Có chân (New York / Georgia)"
    case rounded = "Bo tròn (Rounded)"
    case monospaced = "Đơn cách (Monospace)"
    
    public var id: String { rawValue }
    
    public var design: Font.Design {
        switch self {
        case .system: return .default
        case .serif: return .serif
        case .rounded: return .rounded
        case .monospaced: return .monospaced
        }
    }
}

public struct ReadingPassagePane: View {
    let passage: String
    
    @Environment(\.appFontScale) var fontScale
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("ReadingFontSizeDelta") private var fontSizeDelta: Double = 0 // -4 to +10
    @AppStorage("ReadingLineSpacing") private var lineSpacingValue: Double = 6 // 3 to 14
    @AppStorage("ReadingFontFamily") private var fontFamilyRaw: String = ReadingFontFamily.serif.rawValue
    @AppStorage("ReadingBoxTheme") private var readingThemeRaw: String = ReadingBoxTheme.standard.rawValue
    @AppStorage("ReadingIsBold") private var isBoldText: Bool = false
    
    @State private var showSettingsDrawer: Bool = false
    
    private var currentTheme: ReadingBoxTheme {
        ReadingBoxTheme(rawValue: readingThemeRaw) ?? .standard
    }
    
    private var currentFontFamily: ReadingFontFamily {
        ReadingFontFamily(rawValue: fontFamilyRaw) ?? .serif
    }
    
    public init(passage: String) {
        self.passage = passage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Bar with Quick Controls
            HStack {
                HStack(spacing: 6 * fontScale) {
                    Image(systemName: "book.closed.fill")
                        .foregroundColor(LiquidGlassPalette.deepPurple)
                    Text("ĐOẠN VĂN ĐỌC HIỂU")
                        .font(.system(size: 12 * fontScale, weight: .bold))
                        .foregroundColor(LiquidGlassPalette.deepPurple)
                }
                
                Spacer()
                
                // Font Size Quick Adjusters
                HStack(spacing: 6) {
                    Button(action: {
                        if fontSizeDelta > -4 { fontSizeDelta -= 1 }
                    }) {
                        Text("A-")
                            .font(.system(size: 11 * fontScale, weight: .bold))
                            .padding(.horizontal, 7 * fontScale)
                            .padding(.vertical, 3 * fontScale)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Giảm cỡ chữ")
                    
                    Button(action: {
                        if fontSizeDelta < 12 { fontSizeDelta += 1 }
                    }) {
                        Text("A+")
                            .font(.system(size: 11 * fontScale, weight: .bold))
                            .padding(.horizontal, 7 * fontScale)
                            .padding(.vertical, 3 * fontScale)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Tăng cỡ chữ")
                    
                    // Toggle Inline Drawer Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSettingsDrawer.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                            Text("Tùy chỉnh")
                        }
                        .font(.system(size: 11 * fontScale, weight: .semibold))
                        .foregroundColor(showSettingsDrawer ? .white : LiquidGlassPalette.deepPurple)
                        .padding(.horizontal, 8 * fontScale)
                        .padding(.vertical, 4 * fontScale)
                        .background(showSettingsDrawer ? LiquidGlassPalette.deepPurple : LiquidGlassPalette.deepPurple.opacity(0.12))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Mở bảng tùy chỉnh font chữ, màu nền, giãn dòng")
                }
            }
            .padding(.horizontal, 14 * fontScale)
            .padding(.vertical, 10 * fontScale)
            .background(.thinMaterial)
            
            // Collapsible Inline Settings Drawer
            if showSettingsDrawer {
                VStack(alignment: .leading, spacing: 10 * fontScale) {
                    // Theme row
                    HStack(spacing: 8 * fontScale) {
                        Text("Màu nền:")
                            .font(.system(size: 11 * fontScale, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 65 * fontScale, alignment: .leading)
                        
                        themeChip(theme: .standard, label: "Tự động")
                        themeChip(theme: .sepia, label: "Sepia 📖")
                        themeChip(theme: .paperWhite, label: "Trắng 📄")
                        themeChip(theme: .slateDark, label: "Tối 🌙")
                    }
                    
                    // Font Family row
                    HStack(spacing: 8 * fontScale) {
                        Text("Kiểu chữ:")
                            .font(.system(size: 11 * fontScale, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 65 * fontScale, alignment: .leading)
                        
                        fontChip(font: .serif, label: "Có chân")
                        fontChip(font: .system, label: "Mặc định")
                        fontChip(font: .rounded, label: "Bo tròn")
                        fontChip(font: .monospaced, label: "Đơn cách")
                    }
                    
                    // Spacing & Bold row
                    HStack(spacing: 16 * fontScale) {
                        HStack(spacing: 6 * fontScale) {
                            Text("Giãn dòng:")
                                .font(.system(size: 11 * fontScale, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 65 * fontScale, alignment: .leading)
                            
                            Slider(value: $lineSpacingValue, in: 3...16, step: 1)
                                .frame(width: 100 * fontScale)
                            
                            Text("\(Int(lineSpacingValue))pt")
                                .font(.system(size: 10 * fontScale))
                                .foregroundColor(.secondary)
                        }
                        
                        Toggle("In đậm", isOn: $isBoldText)
                            .font(.system(size: 11 * fontScale))
                        
                        Spacer()
                        
                        Button("Mặc định") {
                            fontSizeDelta = 0
                            lineSpacingValue = 6
                            fontFamilyRaw = ReadingFontFamily.serif.rawValue
                            readingThemeRaw = ReadingBoxTheme.standard.rawValue
                            isBoldText = false
                        }
                        .font(.system(size: 10 * fontScale))
                        .buttonStyle(.plain)
                        .foregroundColor(LiquidGlassPalette.oceanBlue)
                    }
                }
                .padding(12 * fontScale)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.90))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.secondary.opacity(0.2)),
                    alignment: .bottom
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Divider()
            
            // Passage Scrollable Content
            ScrollView {
                Text(formattedMarkdown(passage))
                    .font(.system(size: (14 + fontSizeDelta) * fontScale, weight: isBoldText ? .semibold : .regular, design: currentFontFamily.design))
                    .lineSpacing(lineSpacingValue)
                    .foregroundColor(currentTheme == .standard ? (colorScheme == .light ? Color(NSColor.labelColor) : Color.white) : currentTheme.textColor)
                    .padding(16 * fontScale)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(currentTheme == .standard ? Color.clear : currentTheme.backgroundColor)
        }
        .frame(minWidth: 320 * fontScale, idealWidth: 400 * fontScale, maxWidth: 500 * fontScale)
        .background(.ultraThinMaterial)
    }
    
    private func themeChip(theme: ReadingBoxTheme, label: String) -> some View {
        Button(action: {
            readingThemeRaw = theme.rawValue
        }) {
            Text(label)
                .font(.system(size: 10 * fontScale, weight: .semibold))
                .foregroundColor(readingThemeRaw == theme.rawValue ? .white : .primary)
                .padding(.horizontal, 8 * fontScale)
                .padding(.vertical, 4 * fontScale)
                .background(readingThemeRaw == theme.rawValue ? LiquidGlassPalette.deepPurple : Color.gray.opacity(0.18))
                .cornerRadius(5)
        }
        .buttonStyle(.plain)
    }
    
    private func fontChip(font: ReadingFontFamily, label: String) -> some View {
        Button(action: {
            fontFamilyRaw = font.rawValue
        }) {
            Text(label)
                .font(.system(size: 10 * fontScale, weight: .semibold, design: font.design))
                .foregroundColor(fontFamilyRaw == font.rawValue ? .white : .primary)
                .padding(.horizontal, 8 * fontScale)
                .padding(.vertical, 4 * fontScale)
                .background(fontFamilyRaw == font.rawValue ? LiquidGlassPalette.oceanBlue : Color.gray.opacity(0.18))
                .cornerRadius(5)
        }
        .buttonStyle(.plain)
    }
    
    private func formattedMarkdown(_ rawText: String) -> LocalizedStringKey {
        var str = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("```markdown") { str = String(str.dropFirst(11)) }
        if str.hasPrefix("```") { str = String(str.dropFirst(3)) }
        if str.hasSuffix("```") { str = String(str.dropLast(3)) }
        return LocalizedStringKey(str)
    }
}
