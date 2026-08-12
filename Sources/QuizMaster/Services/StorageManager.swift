import Foundation

public class StorageManager: ObservableObject {
    public static let shared = StorageManager()
    
    @Published public var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }
    
    @Published public var projects: [StudyProject] = [] {
        didSet {
            saveProjects()
        }
    }
    
    private let settingsKey = "QuizMasterAppSettings"
    private let projectsFileName = "quiz_master_projects.json"
    
    private var projectsFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("QuizMaster", isDirectory: true)
        if !FileManager.default.fileExists(atPath: appDir.path) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        return appDir.appendingPathComponent(projectsFileName)
    }
    
    private init() {
        // Load Settings
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = AppSettings.defaultSettings
        }
        
        // Load Projects
        self.projects = loadProjectsFromFile()
        
        // Create demo project if empty
        if self.projects.isEmpty {
            self.projects = [createDemoProject()]
        }
    }
    
    public func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    private func saveProjects() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(projects)
            try data.write(to: projectsFileURL, options: .atomic)
        } catch {
            print("Failed to save projects: \(error)")
        }
    }
    
    private func loadProjectsFromFile() -> [StudyProject] {
        let url = projectsFileURL
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([StudyProject].self, from: data) else {
            return []
        }
        return decoded
    }
    
    // MARK: - Helper Mutations
    public func addProject(name: String, description: String) -> StudyProject {
        let project = StudyProject(name: name, description: description)
        projects.append(project)
        return project
    }
    
    public func updateProject(_ project: StudyProject) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        }
    }
    
    public func deleteProject(id: String) {
        projects.removeAll { $0.id == id }
    }
    
    public func addQuiz(to projectId: String, quiz: Quiz) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].quizzes.append(quiz)
        saveProjects()
    }
    
    public var storageDirectoryURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("QuizMaster", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    public func deleteQuiz(projectId: String, quizId: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].quizzes.removeAll { $0.id == quizId }
        projects[index].progressMap.removeValue(forKey: quizId)
        saveProjects()
    }
    
    public func deleteQuizzes(quizIds: Set<String>, fromProjectId: String) {
        guard let index = projects.firstIndex(where: { $0.id == fromProjectId }) else { return }
        projects[index].quizzes.removeAll { quizIds.contains($0.id) }
        for qId in quizIds {
            projects[index].progressMap.removeValue(forKey: qId)
        }
        saveProjects()
    }
    
    public func renameQuiz(projectId: String, quizId: String, newTitle: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        if let qIndex = projects[index].quizzes.firstIndex(where: { $0.id == quizId }) {
            projects[index].quizzes[qIndex].title = newTitle
            saveProjects()
        }
    }
    
    public func moveQuiz(quizId: String, fromProjectId: String, toProjectId: String) {
        guard fromProjectId != toProjectId,
              let fromIdx = projects.firstIndex(where: { $0.id == fromProjectId }),
              let toIdx = projects.firstIndex(where: { $0.id == toProjectId }),
              let quizIdx = projects[fromIdx].quizzes.firstIndex(where: { $0.id == quizId }) else { return }
        
        let quiz = projects[fromIdx].quizzes.remove(at: quizIdx)
        let prog = projects[fromIdx].progressMap.removeValue(forKey: quizId)
        
        projects[toIdx].quizzes.append(quiz)
        if let p = prog {
            projects[toIdx].progressMap[quizId] = p
        }
        saveProjects()
    }
    
    public func moveQuizzes(quizIds: Set<String>, fromProjectId: String, toProjectId: String) {
        for qId in quizIds {
            moveQuiz(quizId: qId, fromProjectId: fromProjectId, toProjectId: toProjectId)
        }
    }
    
    public func resetProjectProgress(projectId: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].progressMap.removeAll()
        saveProjects()
    }
    
    public func resetQuizProgress(projectId: String, quizId: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].progressMap.removeValue(forKey: quizId)
        saveProjects()
    }
    
    public func saveProgress(projectId: String, progress: QuizProgress) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].progressMap[progress.quizId] = progress
        projects[index].lastStudiedAt = Date()
        saveProjects()
    }
    
    // MARK: - Demo Sample Project
    private func createDemoProject() -> StudyProject {
        let demoQuestions: [Question] = [
            Question(
                text: "Thủ đô của Việt Nam là thành phố nào?",
                options: [
                    QuestionOption(label: "A", text: "Thành phố Hồ Chí Minh"),
                    QuestionOption(label: "B", text: "Hà Nội"),
                    QuestionOption(label: "C", text: "Đà Nẵng"),
                    QuestionOption(label: "D", text: "Hải Phòng")
                ],
                correctAnswerIndex: 1,
                explanation: "Hà Nội là thủ đô, trung tâm chính trị và văn hóa của nước Cộng hòa Xã hội Chủ nghĩa Việt Nam."
            ),
            Question(
                text: "Mô hình AI nào được ứng dụng QuizMaster sử dụng để quét OCR và tạo câu hỏi trắc nghiệm?",
                options: [
                    QuestionOption(label: "A", text: "Gemini 3.5 Flash Lite"),
                    QuestionOption(label: "B", text: "GPT-3.5 Turbo"),
                    QuestionOption(label: "C", text: "Claude 2"),
                    QuestionOption(label: "D", text: "Llama 2")
                ],
                correctAnswerIndex: 0,
                explanation: "QuizMaster kết nối trực tiếp với mô hình Gemini 3.5 Flash Lite từ Google AI Studio để xử lý tài liệu tốc độ cao và chính xác."
            ),
            Question(
                text: "Khi trả lời sai một câu hỏi trong chế độ Luyện tập (Practice), câu hỏi đó sẽ được xử lý như thế nào?",
                options: [
                    QuestionOption(label: "A", text: "Bị xóa khỏi bài thi"),
                    QuestionOption(label: "B", text: "Lưu lại để người dùng làm lại hoặc ôn tập ở cuối bài"),
                    QuestionOption(label: "C", text: "Tính điểm âm ngay lập tức"),
                    QuestionOption(label: "D", text: "Tự động đổi sang câu hỏi mới")
                ],
                correctAnswerIndex: 1,
                explanation: "Ứng dụng sẽ lưu các câu làm sai để người dùng có thể làm lại riêng các câu sai hoặc xem giải thích chi tiết sau khi hoàn thành toàn bộ bài thi."
            )
        ]
        
        let demoQuiz = Quiz(
            title: "Bộ câu hỏi Mẫu - Kiến thức Cơ bản & Hướng dẫn",
            description: "Bộ câu hỏi trắc nghiệm thử nghiệm giao diện và các tính năng của QuizMaster",
            questions: demoQuestions,
            isPreMade: true
        )
        
        return StudyProject(
            name: "Dự án Mẫu (Sample Project)",
            description: "Dự án ôn tập có sẵn để trải nghiệm ứng dụng QuizMaster",
            quizzes: [demoQuiz]
        )
    }
}
