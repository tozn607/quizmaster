import SwiftUI
import AppKit

@main
struct QuizMasterApp: App {
    @StateObject private var storage = StorageManager.shared
    @StateObject private var loc = LocalizationManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(storage)
                .environmentObject(loc)
                .environment(\.appFontScale, storage.settings.fontSize.scaleFactor)
                .preferredColorScheme(colorScheme(for: storage.settings.theme))
                .frame(minWidth: 1120, minHeight: 720)
        }
        .windowStyle(.titleBar)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .appInfo) {
                Button("Giới thiệu QuizMaster") {
                    let alert = NSAlert()
                    alert.messageText = "QuizMaster - Ứng dụng Ôn tập Native macOS"
                    alert.informativeText = "Ứng dụng tự học và quét OCR tài liệu tạo bộ đề thi trắc nghiệm & Flashcard kết nối Google AI Studio (Gemini 3.5 Flash Lite API).\nPhiên bản 1.0.0 Natively Compiled."
                    alert.runModal()
                }
            }
        }
    }
    
    private func colorScheme(for theme: AppTheme) -> ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
