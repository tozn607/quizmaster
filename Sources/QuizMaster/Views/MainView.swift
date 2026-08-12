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
    @State private var exportNotificationMessage: String? = nil
    
    // Quiz Rename State
    @State private var quizToRename: Quiz? = nil
    @State private var renameTitleInput: String = ""
    
    // Quiz Single/Multi Move State
    @State private var quizToMove: Quiz? = nil
    @State private var isMultiSelectMode: Bool = false
    @State private var selectedQuizIds: Set<String> = []
    @State private var showMoveModal: Bool = false
    @State private var targetMoveProjectId: String = ""
    
    private var currentSelectedProject: StudyProject? {
        if let sel = selectedProject, let updated = storage.projects.first(where: { $0.id == sel.id }) {
            return updated
        }
        return storage.projects.first
    }
    
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
                Text(loc.text("renameQuiz"))
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
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
        .sheet(isPresented: $showMoveModal) {
            moveQuizSheet
        }
    }
    
    // MARK: - Project Detail View
    private func projectDetailView(project: StudyProject) -> some View {
        VStack(spacing: 0) {
            // Dashboard Top Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("\(project.quizzes.count) bộ đề thi • \(project.totalQuestions) câu hỏi trắc nghiệm")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Multi-select toggle button
                Button(action: {
                    isMultiSelectMode.toggle()
                    if !isMultiSelectMode {
                        selectedQuizIds.removeAll()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isMultiSelectMode ? "checkmark.circle.fill" : "checklist")
                        Text(isMultiSelectMode ? "Thoát Chọn nhiều" : "Chọn nhiều bộ đề")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isMultiSelectMode ? .purple : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isMultiSelectMode ? Color.purple.opacity(0.15) : Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                PrimaryButton(title: loc.text("importDoc"), icon: "plus.circle.fill", color: .purple) {
                    showImportSheet = true
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Multi-select Action Toolbar (Delete Selected / Move Selected)
            if isMultiSelectMode && !selectedQuizIds.isEmpty {
                HStack(spacing: 12) {
                    Text("Đã chọn \(selectedQuizIds.count) bộ đề thi")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    PrimaryButton(title: "Chuyển sang Dự án khác...", icon: "folder.arrow.up", color: .blue) {
                        targetMoveProjectId = storage.projects.first(where: { $0.id != project.id })?.id ?? ""
                        showMoveModal = true
                    }
                    
                    PrimaryButton(title: "Xóa các bộ đề đã chọn (\(selectedQuizIds.count))", icon: "trash.fill", color: .red) {
                        storage.deleteQuizzes(quizIds: selectedQuizIds, fromProjectId: project.id)
                        selectedQuizIds.removeAll()
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .border(Color.purple.opacity(0.3), width: 1)
            }
            
            Divider()
            
            // Export Notification Toast
            if let note = exportNotificationMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(note)
                        .font(.subheadline)
                    Spacer()
                    Button("Đóng") { exportNotificationMessage = nil }
                        .buttonStyle(.plain)
                }
                .padding()
                .background(Color.green.opacity(0.12))
            }
            
            // Quizzes Grid
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if project.quizzes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 54))
                                .foregroundColor(.gray.opacity(0.6))
                            Text("Dự án này chưa có bộ đề thi nào.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            PrimaryButton(title: loc.text("importDoc"), icon: "plus", color: .purple) {
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
    
    // MARK: - Quiz Card Renderer
    private func quizCard(quiz: Quiz, project: StudyProject) -> some View {
        let isSelectedInMulti = selectedQuizIds.contains(quiz.id)
        
        return GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                // Header & Badges
                HStack {
                    if isMultiSelectMode {
                        Button(action: {
                            if isSelectedInMulti {
                                selectedQuizIds.remove(quiz.id)
                            } else {
                                selectedQuizIds.insert(quiz.id)
                            }
                        }) {
                            Image(systemName: isSelectedInMulti ? "checkmark.square.fill" : "square")
                                .font(.title2)
                                .foregroundColor(isSelectedInMulti ? .purple : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    BadgeView(text: "\(quiz.questions.count) \(loc.text("questionsCount"))", color: .purple)
                    if quiz.isPreMade {
                        BadgeView(text: "Bộ đề có sẵn", color: .gray)
                    }
                    Spacer()
                    
                    // Move Quiz Button
                    Button(action: {
                        quizToMove = quiz
                        targetMoveProjectId = storage.projects.first(where: { $0.id != project.id })?.id ?? ""
                        showMoveModal = true
                    }) {
                        Image(systemName: "folder.arrow.up")
                            .font(.subheadline)
                            .foregroundColor(.purple.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Chuyển bộ đề sang Dự án khác")
                    
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
                
                // Quiz Title
                Text(quiz.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                // Progress Bar if taken
                if let prog = project.progressMap[quiz.id] {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Đã luyện tập (\(prog.userAnswers.count) / \(quiz.questions.count) câu)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(prog.wrongQuestionIds.isEmpty ? 100 : Int(Double(quiz.questions.count - prog.wrongQuestionIds.count) / Double(quiz.questions.count) * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        ProgressBar(value: Double(prog.userAnswers.count) / Double(quiz.questions.count), height: 4, color: .green)
                    }
                }
                
                Divider()
                
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
                quizToMove = quiz
                targetMoveProjectId = storage.projects.first(where: { $0.id != project.id })?.id ?? ""
                showMoveModal = true
            } label: {
                Label("Chuyển sang Dự án khác...", systemImage: "folder.arrow.up")
            }
            
            Button {
                quizToRename = quiz
                renameTitleInput = quiz.title
            } label: {
                Label(loc.text("renameQuiz"), systemImage: "pencil")
            }
            
            Button {
                let url = storage.storageDirectoryURL
                NSWorkspace.shared.open(url)
            } label: {
                Label(loc.text("showInFinder"), systemImage: "folder")
            }
            
            Divider()
            
            Button(role: .destructive) {
                storage.deleteQuiz(projectId: project.id, quizId: quiz.id)
            } label: {
                Label(loc.text("deleteQuiz"), systemImage: "trash")
            }
        }
    }
    
    // MARK: - Move Quiz Sheet Modal
    private var moveQuizSheet: some View {
        let otherProjects = storage.projects.filter { $0.id != currentSelectedProject?.id }
        
        return VStack(spacing: 18) {
            HStack {
                Image(systemName: "folder.arrow.up")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text(quizToMove != nil ? "Chuyển Bộ đề thi" : "Chuyển \(selectedQuizIds.count) Bộ đề thi")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Divider()
            
            if otherProjects.isEmpty {
                Text("Chưa có dự án nào khác. Hãy tạo một dự án mới ở Sidebar trước khi chuyển.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chọn Dự án đích muốn chuyển bộ đề tới:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Picker("", selection: $targetMoveProjectId) {
                        ForEach(otherProjects) { proj in
                            Text(proj.name).tag(proj.id)
                        }
                    }
                    .pickerStyle(.radioGroup)
                }
            }
            
            Divider()
            
            HStack {
                SecondaryButton(title: "Hủy", icon: "xmark") {
                    showMoveModal = false
                    quizToMove = nil
                }
                
                Spacer()
                
                PrimaryButton(title: "Xác nhận Chuyển", icon: "checkmark", color: .purple) {
                    if let proj = currentSelectedProject, !targetMoveProjectId.isEmpty {
                        if let q = quizToMove {
                            storage.moveQuiz(quizId: q.id, fromProjectId: proj.id, toProjectId: targetMoveProjectId)
                        } else if !selectedQuizIds.isEmpty {
                            storage.moveQuizzes(quizIds: selectedQuizIds, fromProjectId: proj.id, toProjectId: targetMoveProjectId)
                            selectedQuizIds.removeAll()
                        }
                    }
                    showMoveModal = false
                    quizToMove = nil
                }
                .disabled(otherProjects.isEmpty || targetMoveProjectId.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 440)
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
        let outputDir = storage.settings.defaultOutputDirectory
        do {
            let zipPath = try WordExporter.shared.exportQuizToWordDocxZip(quiz: quiz, outputDirectory: outputDir)
            exportNotificationMessage = "Đã xuất thành công gói đề thi Word (.docx) tại: \(zipPath)"
        } catch {
            exportNotificationMessage = "Lỗi xuất đề thi Word: \(error.localizedDescription)"
        }
    }
}
