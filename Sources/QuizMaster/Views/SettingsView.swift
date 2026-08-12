import SwiftUI
import AppKit

public struct SettingsView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var apiKey: String = ""
    @State private var inputDir: String = ""
    @State private var outputDir: String = ""
    @State private var isTestingKey: Bool = false
    @State private var keyValidationResult: Bool? = nil
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text(loc.text("settingsTitle"))
                    .font(.system(size: 20 * fontScale, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20 * fontScale))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20 * fontScale) {
                    
                    // API Key Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12 * fontScale) {
                            HStack {
                                Text(loc.text("apiKeyLabel"))
                                    .font(.system(size: 14 * fontScale, weight: .semibold))
                                
                                Spacer()
                                
                                Button(action: openAIStudioURL) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "key.fill")
                                            .foregroundColor(.purple)
                                        Text("Lấy API Key từ Google AI Studio ↗")
                                            .font(.system(size: 12 * fontScale, weight: .semibold))
                                            .foregroundColor(.purple)
                                    }
                                    .padding(.horizontal, 10 * fontScale)
                                    .padding(.vertical, 5 * fontScale)
                                    .background(Color.purple.opacity(0.12))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .help("Mở trang https://aistudio.google.com/api-keys để lấy API Key miễn phí")
                            }
                            
                            HStack {
                                SecureField(loc.text("apiKeyHint"), text: $apiKey)
                                    .textFieldStyle(.roundedBorder)
                                
                                Button(action: testKey) {
                                    HStack {
                                        if isTestingKey {
                                            ProgressView()
                                                .scaleEffect(0.6)
                                        }
                                        Text(loc.text("testApiKey"))
                                            .font(.system(size: 13 * fontScale))
                                    }
                                }
                                .disabled(isTestingKey || apiKey.isEmpty)
                            }
                            
                            if let isValid = keyValidationResult {
                                HStack {
                                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    Text(isValid ? loc.text("apiKeyValid") : loc.text("apiKeyInvalid"))
                                }
                                .font(.system(size: 12 * fontScale))
                                .foregroundColor(isValid ? .green : .red)
                            }
                        }
                    }
                    
                    // Model Locked Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8 * fontScale) {
                            Text(loc.text("modelLabel"))
                                .font(.system(size: 14 * fontScale, weight: .semibold))
                            
                            HStack {
                                BadgeView(text: "gemini-3.5-flash-lite", color: .purple)
                                Spacer()
                                Text(loc.text("modelFixedNote"))
                                    .font(.system(size: 12 * fontScale))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Directories Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14 * fontScale) {
                            Text(loc.text("directoriesHeader"))
                                .font(.system(size: 16 * fontScale, weight: .bold))
                            
                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                Text(loc.text("inputDirLabel"))
                                    .font(.system(size: 13 * fontScale))
                                HStack {
                                    TextField("", text: $inputDir)
                                        .textFieldStyle(.roundedBorder)
                                    Button(loc.text("selectFolder")) {
                                        selectFolder { inputDir = $0 }
                                    }
                                    .font(.system(size: 13 * fontScale))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                Text(loc.text("outputDirLabel"))
                                    .font(.system(size: 13 * fontScale))
                                HStack {
                                    TextField("", text: $outputDir)
                                        .textFieldStyle(.roundedBorder)
                                    Button(loc.text("selectFolder")) {
                                        selectFolder { outputDir = $0 }
                                    }
                                    .font(.system(size: 13 * fontScale))
                                }
                            }
                        }
                    }
                    
                    // Display, Theme & Font Size Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14 * fontScale) {
                            Text("Giao diện & Cỡ chữ (Display & Theme)")
                                .font(.system(size: 16 * fontScale, weight: .bold))
                            
                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                Text(loc.text("themeLabel"))
                                    .font(.system(size: 13 * fontScale))
                                
                                Picker("", selection: $storage.settings.theme) {
                                    Text(loc.text("themeSystem")).tag(AppTheme.system)
                                    Text(loc.text("themeLight")).tag(AppTheme.light)
                                    Text(loc.text("themeDark")).tag(AppTheme.dark)
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                Text("Cỡ chữ hiển thị ứng dụng:")
                                    .font(.system(size: 13 * fontScale))
                                
                                Picker("", selection: $storage.settings.fontSize) {
                                    ForEach(AppFontSize.allCases) { size in
                                        Text(size.displayName).tag(size)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                Text(loc.text("languageLabel"))
                                    .font(.system(size: 13 * fontScale))
                                
                                Picker("", selection: $loc.currentLanguage) {
                                    Text("Tiếng Việt").tag(AppLanguage.vietnamese)
                                    Text("English").tag(AppLanguage.english)
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    
                    // About & App Info Footer Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12 * fontScale) {
                            Text("Thông tin Ứng dụng / About QuizMaster")
                                .font(.system(size: 16 * fontScale, weight: .bold))
                            
                            Divider()
                            
                            HStack(spacing: 16 * fontScale) {
                                Image(systemName: "graduationcap.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 52 * fontScale, height: 52 * fontScale)
                                    .foregroundColor(.purple)
                                
                                VStack(alignment: .leading, spacing: 4 * fontScale) {
                                    HStack {
                                        Text("QuizMaster")
                                            .font(.system(size: 18 * fontScale, weight: .bold))
                                        
                                        BadgeView(text: "\(AppVersionInfo.currentVersion) (Build \(AppVersionInfo.buildNumber))", color: .purple)
                                    }
                                    
                                    Text("Tác giả / Creator: @tozn607 (Anh Vinh)")
                                        .font(.system(size: 12 * fontScale, weight: .semibold))
                                        .foregroundColor(.blue)
                                    
                                    Text("Ứng dụng tự học & tạo đề thi trắc nghiệm bằng Gemini 3.5 Flash Lite trên macOS.")
                                        .font(.system(size: 11 * fontScale))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    Task {
                                        await UpdateChecker.shared.checkForUpdates()
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Kiểm tra Cập nhật")
                                    }
                                    .font(.system(size: 12 * fontScale, weight: .medium))
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.purple)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer Bar
            HStack {
                Spacer()
                PrimaryButton(title: loc.text("saveSettings"), icon: "checkmark") {
                    saveAndClose()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 620 * fontScale, height: 720 * fontScale)
        .onAppear {
            apiKey = storage.settings.apiKey
            inputDir = storage.settings.defaultInputDirectory
            outputDir = storage.settings.defaultOutputDirectory
        }
    }
    
    private func testKey() {
        isTestingKey = true
        keyValidationResult = nil
        
        Task {
            let result = await GeminiAPIService.shared.validateAPIKey(apiKey)
            await MainActor.run {
                keyValidationResult = result
                isTestingKey = false
            }
        }
    }
    
    private func saveAndClose() {
        storage.settings.apiKey = apiKey
        storage.settings.defaultInputDirectory = inputDir
        storage.settings.defaultOutputDirectory = outputDir
        storage.settings.language = loc.currentLanguage
        storage.saveSettings()
        dismiss()
    }
    
    private func openAIStudioURL() {
        if let url = URL(string: "https://aistudio.google.com/api-keys") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func selectFolder(completion: @escaping (String) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = loc.text("selectFolder")
        
        if panel.runModal() == .OK, let url = panel.url {
            completion(url.path)
        }
    }
}
