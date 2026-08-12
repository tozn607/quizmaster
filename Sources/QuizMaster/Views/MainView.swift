import SwiftUI

public struct MainView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    
    @StateObject private var updateChecker = UpdateChecker.shared
    
    @State private var selectedProject: StudyProject? = nil
    @State private var showSettingsSheet: Bool = false
    @State private var showImportSheet: Bool = false
    @State private var activePracticeQuiz: Quiz? = nil
    @State private var activeExamQuiz: Quiz? = nil
    @State private var activeFlashcardQuiz: Quiz? = nil
    @State private var activeEndingQuiz: (quiz: Quiz, progress: QuizProgress)? = nil
    @State private var exportNotificationMessage: String? = nil
    
    // Quiz Rename State
    @State private var quizToRename: Quiz? = nil
    @State private var renameTitleInput: String = ""
    
    public var body: some View {
        NavigationSplitView {
            SidebarView(selectedProject: $selectedProject, showSettingsSheet: $showSettingsSheet)
                .frame(minWidth: 260, idealWidth: 280)
        } detail: {
            VStack(spacing: 0) {
                // GitHub Update Banner
                if updateChecker.hasUpdateAvailable {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .font(.title3)
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Phiên bản mới \(updateChecker.latestVersionTag) đã có sẵn trên GitHub!")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            Text("Hãy cập nhật ứng dụng để trải nghiệm các tính năng và sửa lỗi mới nhất.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        PrimaryButton(title: "Cập nhật ngay ↗", icon: "square.and.arrow.up", color: .purple) {
                            updateChecker.openReleasePage()
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.12))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.purple.opacity(0.3)),
                        alignment: .bottom
                    )
                }
                
                if let project = currentSelectedProject {
                    projectDetailView(project: project)
                } else {
                    emptyDetailView
                }
            }
        }
        .environment(\.appFontScale, storage.settings.fontSize.scaleFactor)
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
        }
        .sheet(isPresented: $showImportSheet) {
            if let proj = currentSelectedProject {
                DocumentImportView(project: proj)
            }
        }
        .sheet(item: $activePracticeQuiz) { quiz in
            if let proj = currentSelectedProject {
                PracticeView(project: proj, quiz: quiz, redoWrongOnly: false)
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
        .sheet(item: $quizToRename) { quiz in
            VStack(spacing: 16) {
                Text("Đổi tên Bộ đề thi")
                    .font(.headline)
                    .fontWeight(.bold)
                
                TextField("Nhập tên bộ đề thi mới...", text: $renameTitleInput)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    SecondaryButton(title: "Hủy", icon: "xmark") {
                        quizToRename = nil
                    }
                    
                    PrimaryButton(title: "Lưu tên mới", icon: "checkmark", color: .blue) {
                        if let proj = currentSelectedProject, !renameTitleInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            storage.renameQuiz(projectId: proj.id, quizId: quiz.id, newTitle: renameTitleInput.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                        quizToRename = nil
                    }
                }
            }
            .padding(24)
            .frame(width: 400)
        }
        .sheet(item: $activeExamQuiz) { quiz in
            if let proj = currentSelectedProject {
                ExamView(project: proj, quiz: quiz, redoWrongOnly: false)
                    .frame(minWidth: 820, minHeight: 620)
            }
        }
        .sheet(item: $activeFlashcardQuiz) { quiz in
            if let proj = currentSelectedProject {
                FlashcardView(project: proj, quiz: quiz)
                    .frame(minWidth: 700, minHeight: 560)
            }
        }
        .onAppear {
            if selectedProject == nil {
                selectedProject = storage.projects.first
            }
        }
    }
    
    private var currentSelectedProject: StudyProject? {
        if let sel = selectedProject, let updated = storage.projects.first(where: { $0.id == sel.id }) {
            return updated
        }
        return storage.projects.first
    }
    
    // MARK: - Project Detail Dashboard
    @ViewBuilder
    private func projectDetailView(project: StudyProject) -> some View {
        VStack(spacing: 0) {
            // Dashboard Top Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    if !project.description.isEmpty {
                        Text(project.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                PrimaryButton(
                    title: loc.text("importDoc"),
                    icon: "doc.badge.plus",
                    color: .blue
                ) {
                    showImportSheet = true
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Export notification banner
            if let msg = exportNotificationMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(msg)
                    Spacer()
                    Button("OK") { exportNotificationMessage = nil }
                        .buttonStyle(.plain)
                }
                .foregroundColor(.green)
                .padding()
                .background(Color.green.opacity(0.12))
            }
            
            // Quizzes Grid
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if project.quizzes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.blue.opacity(0.6))
                            Text("Chưa có bộ đề thi nào trong dự án này.")
                                .font(.headline)
                            Text("Nhấn nút \"Nhập Tài liệu / Bộ đề\" để quét tệp PDF/Word/Text bằng Gemini 3.5 Flash Lite OCR.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 400)
                            
                            PrimaryButton(title: loc.text("importDoc"), icon: "doc.badge.plus") {
                                showImportSheet = true
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 420), spacing: 20)], spacing: 20) {
                            ForEach(project.quizzes) { quiz in
                                quizCard(quiz: quiz, project: project)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Quiz Card Widget
    @ViewBuilder
    private func quizCard(quiz: Quiz, project: StudyProject) -> some View {
        let progress = project.progressMap[quiz.id]
        
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    BadgeView(text: "\(quiz.questions.count) \(loc.text("questionsCount"))", color: .purple)
                    if quiz.isPreMade {
                        BadgeView(text: "Bộ đề có sẵn", color: .gray)
                    }
                    Spacer()
                    
                    // Rename Quiz Button
                    Button(action: {
                        quizToRename = quiz
                        renameTitleInput = quiz.title
                    }) {
                        Image(systemName: "pencil")
                            .font(.subheadline)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Đổi tên bộ đề thi này")
                    
                    // Delete Quiz Set Button
                    Button(action: {
                        storage.deleteQuiz(projectId: project.id, quizId: quiz.id)
                    }) {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .help("Xóa bộ đề thi này")
                }
                
                Text(quiz.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                if !quiz.description.isEmpty {
                    Text(quiz.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Divider()
                
                // Progress stats if available
                if let prog = progress {
                    let totalQ = quiz.questions.count
                    let correctCount = prog.userAnswers.filter { qId, ansIdx in
                        if let q = quiz.questions.first(where: { $0.id == qId }) {
                            return q.correctAnswerIndex == ansIdx
                        }
                        return false
                    }.count
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.secondary)
                        Text(prog.isCompleted ? "Đã hoàn thành" : "Đang dở dang")
                        Spacer()
                        Text("Đúng: \(correctCount)/\(totalQ)")
                            .fontWeight(.bold)
                            .foregroundColor(correctCount == totalQ ? .green : .blue)
                    }
                    .font(.caption2)
                }
                
                // Action Buttons (Spacious 2-Row Layout)
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        PrimaryButton(title: loc.text("practiceMode"), icon: "pencil.and.outline", color: .blue) {
                            activePracticeQuiz = quiz
                        }
                        
                        PrimaryButton(title: loc.text("examMode"), icon: "timer", color: .orange) {
                            activeExamQuiz = quiz
                        }
                    }
                    
                    HStack(spacing: 10) {
                        SecondaryButton(title: loc.text("flashcardMode"), icon: "rectangle.on.rectangle.angled") {
                            activeFlashcardQuiz = quiz
                        }
                        
                        Spacer()
                        
                        // Export Word Zip button
                        Button(action: { exportToWord(quiz: quiz) }) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Xuất Zip / Word")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .help(loc.text("exportWord"))
                    }
                }
            }
        }
        .contextMenu {
            Button {
                quizToRename = quiz
                renameTitleInput = quiz.title
            } label: {
                Label("Đổi tên bộ đề thi", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                storage.deleteQuiz(projectId: project.id, quizId: quiz.id)
            } label: {
                Label("Xóa bộ đề này", systemImage: "trash")
            }
        }
    }
    
    private var emptyDetailView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sidebar.left")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Chọn hoặc tạo một Dự án ở bên trái để bắt đầu ôn tập.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if selectedProject == nil {
                selectedProject = storage.projects.first
            }
            Task {
                await updateChecker.checkForUpdates()
            }
        }
    }
    
    private func exportToWord(quiz: Quiz) {
        do {
            let zipPath = try WordExporter.shared.exportQuizToWordDocxZip(quiz: quiz, outputDirectory: storage.settings.defaultOutputDirectory)
            let fileName = URL(fileURLWithPath: zipPath).lastPathComponent
            exportNotificationMessage = "\(loc.text("exportSuccess"))\n• Tệp Zip Word (.docx): \(fileName)\n• Đường dẫn: \(zipPath)"
        } catch {
            exportNotificationMessage = "Lỗi xuất Word Docx: \(error.localizedDescription)"
        }
    }
}
