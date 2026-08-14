import SwiftUI
import AppKit

/// Manager to present independent, free-floating and resizable NSWindows for Study Modes and Editors
public class WindowManager: NSObject, NSWindowDelegate {
    public static let shared = WindowManager()
    
    private var openWindows: [String: NSWindowController] = [:]
    
    private override init() {
        super.init()
    }
    
    public func windowWillClose(_ notification: Notification) {
        guard let closedWindow = notification.object as? NSWindow else { return }
        for (key, controller) in openWindows {
            if controller.window == closedWindow {
                openWindows.removeValue(forKey: key)
                break
            }
        }
    }
    
    public func openPracticeWindow(project: StudyProject, quiz: Quiz, storage: StorageManager, loc: LocalizationManager, fontScale: CGFloat, uiScale: CGFloat = 1.0) {
        let windowKey = "practice:\(quiz.id)"
        
        if let existing = openWindows[windowKey], let win = existing.window, win.isVisible {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let practiceView = PracticeView(project: project, quiz: quiz, redoWrongOnly: false)
            .environmentObject(storage)
            .environmentObject(loc)
            .environment(\.appFontScale, fontScale)
            .environment(\.appUiScale, uiScale)
        
        let hostingController = NSHostingController(rootView: practiceView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "\(quiz.title) - Luyện tập"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.minSize = NSSize(width: 900 * uiScale, height: 650 * uiScale)
        window.setContentSize(NSSize(width: 1200 * uiScale, height: 820 * uiScale))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        let controller = NSWindowController(window: window)
        openWindows[windowKey] = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func openExamWindow(project: StudyProject, quiz: Quiz, storage: StorageManager, loc: LocalizationManager, fontScale: CGFloat, uiScale: CGFloat = 1.0) {
        let windowKey = "exam:\(quiz.id)"
        
        if let existing = openWindows[windowKey], let win = existing.window, win.isVisible {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let examView = ExamView(project: project, quiz: quiz, redoWrongOnly: false)
            .environmentObject(storage)
            .environmentObject(loc)
            .environment(\.appFontScale, fontScale)
            .environment(\.appUiScale, uiScale)
        
        let hostingController = NSHostingController(rootView: examView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "\(quiz.title) - Thi thử"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.minSize = NSSize(width: 900 * uiScale, height: 650 * uiScale)
        window.setContentSize(NSSize(width: 1200 * uiScale, height: 820 * uiScale))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        let controller = NSWindowController(window: window)
        openWindows[windowKey] = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func openFlashcardWindow(project: StudyProject, quiz: Quiz, storage: StorageManager, loc: LocalizationManager, fontScale: CGFloat, uiScale: CGFloat = 1.0) {
        let windowKey = "flashcard:\(quiz.id)"
        
        if let existing = openWindows[windowKey], let win = existing.window, win.isVisible {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let flashcardView = FlashcardView(project: project, quiz: quiz)
            .environmentObject(storage)
            .environmentObject(loc)
            .environment(\.appFontScale, fontScale)
            .environment(\.appUiScale, uiScale)
        
        let hostingController = NSHostingController(rootView: flashcardView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "\(quiz.title) - Thẻ ghi nhớ"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.minSize = NSSize(width: 850 * uiScale, height: 600 * uiScale)
        window.setContentSize(NSSize(width: 1080 * uiScale, height: 750 * uiScale))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        let controller = NSWindowController(window: window)
        openWindows[windowKey] = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func openEditorWindow(projectId: String, quizBinding: Binding<Quiz>, storage: StorageManager, loc: LocalizationManager, fontScale: CGFloat, uiScale: CGFloat = 1.0) {
        let quiz = quizBinding.wrappedValue
        let windowKey = "editor:\(quiz.id)"
        
        if let existing = openWindows[windowKey], let win = existing.window, win.isVisible {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let editorView = QuizEditorView(projectId: projectId, quiz: quizBinding)
            .environmentObject(storage)
            .environmentObject(loc)
            .environment(\.appFontScale, fontScale)
            .environment(\.appUiScale, uiScale)
        
        let hostingController = NSHostingController(rootView: editorView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Chỉnh sửa câu hỏi & đáp án - \(quiz.title)"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.minSize = NSSize(width: 850 * uiScale, height: 600 * uiScale)
        window.setContentSize(NSSize(width: 1050 * uiScale, height: 720 * uiScale))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        let controller = NSWindowController(window: window)
        openWindows[windowKey] = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func closeWindow(key: String) {
        if let controller = openWindows[key] {
            controller.close()
            openWindows.removeValue(forKey: key)
        }
    }
    
    public func closeCurrentKeyWindow() {
        if let keyWindow = NSApp.keyWindow {
            keyWindow.close()
        }
    }
}
