import SwiftUI
import AppKit

public struct FirstTimeSetupView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: Int = 1
    
    // Step 2 State
    @State private var apiKeyInput: String = ""
    @State private var isTestingKey: Bool = false
    @State private var apiKeyTestResult: String? = nil
    @State private var isKeyValid: Bool = false
    
    public var body: some View {
        LiquidGlassWindowBackdrop {
            VStack(spacing: 0) {
                // Header Wizard Stepper Bar
                HStack(spacing: 12 * fontScale) {
                    stepTab(step: 1, title: loc.text("setupStep1"))
                    stepTab(step: 2, title: loc.text("setupStep2"))
                    stepTab(step: 3, title: loc.text("setupStep3"))
                    stepTab(step: 4, title: loc.text("setupStep4"))
                }
                .padding()
                .background(.thinMaterial)
                
                Divider()
                
                // Step Content Container
                VStack {
                    switch currentStep {
                    case 1:
                        welcomeStepView
                    case 2:
                        apiKeyStepView
                    case 3:
                        appearanceAndGuideStepView
                    case 4:
                        completionStepView
                    default:
                        welcomeStepView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 620 * fontScale, height: 580 * fontScale)
        .onAppear {
            apiKeyInput = storage.settings.apiKey
            if !apiKeyInput.isEmpty {
                isKeyValid = true
            }
        }
    }
    
    // MARK: - Stepper Bar Tab Helper
    @ViewBuilder
    private func stepTab(step: Int, title: String) -> some View {
        let isActive = currentStep == step
        let isPassed = currentStep > step
        
        HStack(spacing: 6 * fontScale) {
            ZStack {
                Circle()
                    .fill(isActive ? LiquidGlassPalette.oceanBlue : (isPassed ? LiquidGlassPalette.emeraldMint : Color.secondary.opacity(0.2)))
                    .frame(width: 22 * fontScale, height: 22 * fontScale)
                
                if isPassed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11 * fontScale, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step)")
                        .font(.system(size: 11 * fontScale, weight: .bold))
                        .foregroundColor(isActive ? .white : .primary)
                }
            }
            
            Text(title)
                .font(.system(size: 12 * fontScale, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? LiquidGlassPalette.oceanBlue : (isPassed ? .primary : .secondary))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Step 1: Welcome View
    private var welcomeStepView: some View {
        VStack(spacing: 24 * fontScale) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LiquidGlassPalette.oceanBlue.opacity(0.12))
                    .frame(width: 100 * fontScale, height: 100 * fontScale)
                
                Text("🎓")
                    .font(.system(size: 54 * fontScale))
            }
            
            VStack(spacing: 8 * fontScale) {
                Text(loc.text("welcomeTitle"))
                    .font(.system(size: 24 * fontScale, weight: .bold))
                
                Text(loc.text("welcomeSubtitle"))
                    .font(.system(size: 14 * fontScale))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            GlassCard {
                VStack(alignment: .leading, spacing: 12 * fontScale) {
                    featureRow(icon: "sparkles", color: LiquidGlassPalette.deepPurple, title: "Tạo Đề thi bằng Gemini AI", desc: "Tự động quét bài giảng PDF, Word, TXT thành câu hỏi & giải thích.")
                    featureRow(icon: "doc.text.magnifyingglass", color: LiquidGlassPalette.oceanBlue, title: "3 Chế độ Ôn tập Thông minh", desc: "Luyện tập tức thì, Thi thử chống gian lận & Thẻ ghi nhớ 3D.")
                    featureRow(icon: "lock.shield.fill", color: LiquidGlassPalette.emeraldMint, title: "Bảo mật & Mã nguồn mở", desc: "Dữ liệu lưu offline trên máy, dùng API Key cá nhân hoàn toàn miễn phí.")
                }
                .padding(16 * fontScale)
            }
            .padding(.horizontal, 32 * fontScale)
            
            Spacer()
            
            PrimaryButton(title: loc.text("startSetupBtn"), icon: "arrow.right.circle.fill", color: LiquidGlassPalette.oceanBlue) {
                withAnimation { currentStep = 2 }
            }
            .padding(.bottom, 28 * fontScale)
        }
    }
    
    @ViewBuilder
    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12 * fontScale) {
            Image(systemName: icon)
                .font(.system(size: 18 * fontScale))
                .foregroundColor(color)
                .frame(width: 24 * fontScale)
            
            VStack(alignment: .leading, spacing: 2 * fontScale) {
                Text(title)
                    .font(.system(size: 13 * fontScale, weight: .bold))
                Text(desc)
                    .font(.system(size: 12 * fontScale))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Step 2: API Key Setup View
    private var apiKeyStepView: some View {
        VStack(spacing: 20 * fontScale) {
            Spacer()
            
            Image(systemName: "key.fill")
                .font(.system(size: 46 * fontScale))
                .foregroundColor(LiquidGlassPalette.deepPurple)
            
            VStack(spacing: 6 * fontScale) {
                Text(loc.text("setupApiKeyPrompt"))
                    .font(.system(size: 22 * fontScale, weight: .bold))
                
                Text(loc.text("setupApiKeyNotice"))
                    .font(.system(size: 13 * fontScale))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28 * fontScale)
            }
            
            GlassCard {
                VStack(spacing: 16 * fontScale) {
                    Button(action: {
                        if let url = URL(string: "https://aistudio.google.com/api-keys") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Lấy API Key từ Google AI Studio ↗")
                        }
                        .font(.system(size: 13 * fontScale, weight: .semibold))
                        .foregroundColor(LiquidGlassPalette.oceanBlue)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 6 * fontScale) {
                        Text("Google AI Studio Key (Gemini API)")
                            .font(.system(size: 12 * fontScale, weight: .bold))
                        
                        SecureField("Dán API Key tại đây (AIzaSy...)", text: $apiKeyInput)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13 * fontScale))
                    }
                    
                    HStack {
                        PrimaryButton(title: isTestingKey ? "Đang kiểm tra..." : "Kiểm tra API Key", icon: "checkmark.shield", color: LiquidGlassPalette.deepPurple) {
                            testKey()
                        }
                        .disabled(apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTestingKey)
                        
                        Spacer()
                        
                        if let res = apiKeyTestResult {
                            Text(res)
                                .font(.system(size: 12 * fontScale, weight: .bold))
                                .foregroundColor(isKeyValid ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.coralRed)
                        }
                    }
                }
                .padding(18 * fontScale)
            }
            .padding(.horizontal, 28 * fontScale)
            
            Spacer()
            
            // Bottom Bar
            HStack {
                SecondaryButton(title: "Quay lại", icon: "arrow.left") {
                    withAnimation { currentStep = 1 }
                }
                Spacer()
                PrimaryButton(title: "Tiếp tục ➔", icon: "arrow.right", color: LiquidGlassPalette.oceanBlue) {
                    saveApiKeyAndNext()
                }
            }
            .padding(.horizontal, 28 * fontScale)
            .padding(.bottom, 24 * fontScale)
        }
    }
    
    private func testKey() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        
        isTestingKey = true
        apiKeyTestResult = nil
        
        Task {
            let success = await GeminiAPIService.shared.validateAPIKey(key)
            await MainActor.run {
                isTestingKey = false
                isKeyValid = success
                if success {
                    apiKeyTestResult = "✓ API Key hợp lệ!"
                    storage.settings.apiKey = key
                    storage.saveSettings()
                } else {
                    apiKeyTestResult = "❌ API Key không hợp lệ."
                }
            }
        }
    }
    
    private func saveApiKeyAndNext() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !key.isEmpty {
            storage.settings.apiKey = key
            storage.saveSettings()
        }
        withAnimation { currentStep = 3 }
    }
    
    // MARK: - Step 3: Appearance & Guide View
    private var appearanceAndGuideStepView: some View {
        VStack(spacing: 16 * fontScale) {
            HStack {
                Text(loc.text("setupAppearanceTitle"))
                    .font(.system(size: 18 * fontScale, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 28 * fontScale)
            .padding(.top, 12 * fontScale)
            
            GlassCard {
                VStack(spacing: 14 * fontScale) {
                    // Language
                    HStack {
                        Text("Ngôn ngữ ứng dụng:")
                            .font(.system(size: 13 * fontScale, weight: .semibold))
                        Spacer()
                        Picker("", selection: $loc.currentLanguage) {
                            Text("🇻🇳 Tiếng Việt").tag(AppLanguage.vietnamese)
                            Text("🇬🇧 English").tag(AppLanguage.english)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180 * fontScale)
                    }
                    
                    Divider()
                    
                    // Theme
                    HStack {
                        Text("Chủ đề Giao diện:")
                            .font(.system(size: 13 * fontScale, weight: .semibold))
                        Spacer()
                        Picker("", selection: $storage.settings.theme) {
                            Text("Mặc định").tag(AppTheme.system)
                            Text("Sáng ☀️").tag(AppTheme.light)
                            Text("Tối 🌙").tag(AppTheme.dark)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 220 * fontScale)
                    }
                    
                    Divider()
                    
                    // Font Size
                    HStack {
                        Text("Cỡ chữ hiển thị:")
                            .font(.system(size: 13 * fontScale, weight: .semibold))
                        Spacer()
                        Picker("", selection: $storage.settings.fontSize) {
                            Text("Nhỏ").tag(AppFontSize.small)
                            Text("Vừa").tag(AppFontSize.medium)
                            Text("Lớn").tag(AppFontSize.large)
                            Text("Rất lớn").tag(AppFontSize.xLarge)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 240 * fontScale)
                    }
                }
                .padding(14 * fontScale)
            }
            .padding(.horizontal, 28 * fontScale)
            
            // Quick Guide Box
            GlassCard {
                VStack(alignment: .leading, spacing: 8 * fontScale) {
                    Text(loc.text("setupGuideTitle"))
                        .font(.system(size: 13 * fontScale, weight: .bold))
                        .foregroundColor(LiquidGlassPalette.oceanBlue)
                    
                    VStack(alignment: .leading, spacing: 6 * fontScale) {
                        guideBullet(text: "1. Bấm nút '+' ở Sidebar để tạo Dự án môn học mới.")
                        guideBullet(text: "2. Chọn 'Nhập Tài liệu / Bộ đề' để quét tự động với Gemini AI.")
                        guideBullet(text: "3. Phím tắt: Spacebar (Lật thẻ 3D) • 1,2,3,4 (Chọn phương án) • Enter (Next).")
                    }
                }
                .padding(14 * fontScale)
            }
            .padding(.horizontal, 28 * fontScale)
            
            Spacer()
            
            // Bottom Bar
            HStack {
                SecondaryButton(title: "Quay lại", icon: "arrow.left") {
                    withAnimation { currentStep = 2 }
                }
                Spacer()
                PrimaryButton(title: "Tiếp tục ➔", icon: "arrow.right", color: LiquidGlassPalette.oceanBlue) {
                    storage.saveSettings()
                    withAnimation { currentStep = 4 }
                }
            }
            .padding(.horizontal, 28 * fontScale)
            .padding(.bottom, 24 * fontScale)
        }
    }
    
    @ViewBuilder
    private func guideBullet(text: String) -> some View {
        HStack(alignment: .top, spacing: 6 * fontScale) {
            Text("•")
                .font(.system(size: 12 * fontScale, weight: .bold))
                .foregroundColor(LiquidGlassPalette.oceanBlue)
            Text(text)
                .font(.system(size: 12 * fontScale))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Step 4: Completion & Smiley Face View
    private var completionStepView: some View {
        VStack(spacing: 24 * fontScale) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LiquidGlassPalette.emeraldMint.opacity(0.15))
                    .frame(width: 110 * fontScale, height: 110 * fontScale)
                
                Text("😊")
                    .font(.system(size: 64 * fontScale))
            }
            
            VStack(spacing: 8 * fontScale) {
                Text(loc.text("setupFinishTitle"))
                    .font(.system(size: 24 * fontScale, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(loc.text("setupFinishSubtitle"))
                    .font(.system(size: 14 * fontScale))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32 * fontScale)
            }
            
            Spacer()
            
            PrimaryButton(title: loc.text("enterAppBtn"), icon: "rocket.fill", color: LiquidGlassPalette.emeraldMint) {
                storage.settings.hasCompletedFirstTimeSetup = true
                storage.saveSettings()
                dismiss()
            }
            .padding(.bottom, 32 * fontScale)
        }
    }
}
