import SwiftUI
import AppKit

public struct SettingsView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
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
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // API Key Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(loc.text("apiKeyLabel"))
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button(action: openAIStudioURL) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "key.fill")
                                            .foregroundColor(.purple)
                                        Text("Lấy API Key từ Google AI Studio ↗")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.purple)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
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
                                    }
                                }
                                .disabled(isTestingKey || apiKey.isEmpty)
                            }
                            
                            if let isValid = keyValidationResult {
                                HStack {
                                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    Text(isValid ? loc.text("apiKeyValid") : loc.text("apiKeyInvalid"))
                                }
                                .font(.caption)
                                .foregroundColor(isValid ? .green : .red)
                            }
                        }
                    }
                    
                    // Model Locked Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.text("modelLabel"))
                                .fontWeight(.semibold)
                            
                            HStack {
                                BadgeView(text: "gemini-3.5-flash-lite", color: .purple)
                                Spacer()
                                Text(loc.text("modelFixedNote"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Directories Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(loc.text("directoriesHeader"))
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(loc.text("inputDirLabel"))
                                    .font(.subheadline)
                                HStack {
                                    TextField("", text: $inputDir)
                                        .textFieldStyle(.roundedBorder)
                                    Button(loc.text("selectFolder")) {
                                        selectFolder { inputDir = $0 }
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(loc.text("outputDirLabel"))
                                    .font(.subheadline)
                                HStack {
                                    TextField("", text: $outputDir)
                                        .textFieldStyle(.roundedBorder)
                                    Button(loc.text("selectFolder")) {
                                        selectFolder { outputDir = $0 }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Display & Font Size Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Giao diện & Cỡ chữ (Display & Font Size)")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Cỡ chữ hiển thị ứng dụng:")
                                    .font(.subheadline)
                                
                                Picker("", selection: $storage.settings.fontSize) {
                                    ForEach(AppFontSize.allCases) { size in
                                        Text(size.displayName).tag(size)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(loc.text("languageLabel"))
                                    .font(.subheadline)
                                
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Thông tin Ứng dụng / About QuizMaster")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Divider()
                            
                            HStack(spacing: 16) {
                                Image(systemName: "graduationcap.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 52, height: 52)
                                    .foregroundColor(.purple)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("QuizMaster")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        
                                        BadgeView(text: "\(AppVersionInfo.currentVersion) (Build \(AppVersionInfo.buildNumber))", color: .purple)
                                    }
                                    
                                    Text("Tác giả / Creator: @tozn607 (Anh Vinh)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    
                                    Text("Ứng dụng tự học & tạo đề thi trắc nghiệm bằng Gemini 3.5 Flash Lite trên macOS.")
                                        .font(.caption2)
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
                                    .font(.caption)
                                    .fontWeight(.medium)
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
        .frame(width: 580, height: 680)
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
