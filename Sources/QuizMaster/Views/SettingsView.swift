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
    @State private var showUpdateModal: Bool = false
    
    public var body: some View {
        LiquidGlassWindowBackdrop {
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
                .background(.thinMaterial)
                
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
                                            .foregroundColor(.accentColor)
                                        Text(loc.text("getApiKeyFromStudio"))
                                            .font(.system(size: 12 * fontScale, weight: .semibold))
                                            .foregroundColor(.accentColor)
                                    }
                                    .padding(.horizontal, 10 * fontScale)
                                    .padding(.vertical, 5 * fontScale)
                                    .background(Color.accentColor.opacity(0.12))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .help("https://aistudio.google.com/api-keys")
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
                                        Text(isTestingKey ? loc.text("testingKey") : loc.text("testApiKey"))
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
                                BadgeView(text: "gemini-3.5-flash-lite", color: .accentColor)
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
                            Text(loc.text("displayAndThemeHeader"))
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
                                Text(loc.text("fontSizeLabel"))
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
                                
                                Text(loc.text("geminiLangNote"))
                                    .font(.system(size: 11 * fontScale))
                                    .foregroundColor(.accentColor)
                                    .padding(.top, 4 * fontScale)
                            }
                        }
                    }
                    
                    // About & App Info Footer Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12 * fontScale) {
                            Text(loc.text("authorHeader"))
                                .font(.system(size: 16 * fontScale, weight: .bold))
                            
                            Divider()
                            
                            HStack(spacing: 16 * fontScale) {
                                AppLogoView(size: 54 * fontScale)
                                
                                VStack(alignment: .leading, spacing: 4 * fontScale) {
                                    HStack {
                                        Text("QuizMaster")
                                            .font(.system(size: 18 * fontScale, weight: .bold))
                                        
                                        BadgeView(text: "\(AppVersionInfo.currentVersion) (Build \(AppVersionInfo.buildNumber))", color: .accentColor)
                                    }
                                    
                                    Text(loc.text("authorInfo"))
                                        .font(.system(size: 12 * fontScale, weight: .semibold))
                                        .foregroundColor(.accentColor)
                                    
                                    Text(loc.text("appDescInfo"))
                                        .font(.system(size: 11 * fontScale))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showUpdateModal = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text(loc.text("checkUpdates"))
                                    }
                                    .font(.system(size: 12 * fontScale, weight: .medium))
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.accentColor)
                            }
                            
                            Divider()
                            
                            HStack {
                                Button(action: {
                                    storage.settings.hasCompletedFirstTimeSetup = false
                                    storage.saveSettings()
                                    dismiss()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                        Text(loc.text("reopenSetupWizard"))
                                    }
                                    .font(.system(size: 12 * fontScale, weight: .medium))
                                    .foregroundColor(LiquidGlassPalette.oceanBlue)
                                }
                                .buttonStyle(.plain)
                                Spacer()
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
            .background(.thinMaterial)
        }
        }
        .frame(width: 680 * fontScale, height: 760 * fontScale)
        .sheet(isPresented: $showUpdateModal) {
            SoftwareUpdateView()
        }
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
        storage.settings.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        storage.settings.defaultInputDirectory = inputDir
        storage.settings.defaultOutputDirectory = outputDir
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
