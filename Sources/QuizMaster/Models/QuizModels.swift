import Foundation
import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
}

public enum AppFontSize: String, CaseIterable, Identifiable, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case xLarge = "xLarge"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .small: return "Nhỏ"
        case .medium: return "Vừa"
        case .large: return "Lớn"
        case .xLarge: return "Rất lớn"
        }
    }
    
    public var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.88
        case .medium: return 1.0
        case .large: return 1.18
        case .xLarge: return 1.35
        }
    }
}

public enum QuestionDepthMode: String, CaseIterable, Identifiable, Codable {
    case normal = "normal"
    case core = "core"
    case thorough = "thorough"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .normal: return "Mặc định"
        case .core: return "Ý chính & Trọng tâm"
        case .thorough: return "Chi tiết toàn bộ"
        }
    }

    
    public var description: String {
        switch self {
        case .normal: return "Tự động tạo số câu hỏi cân đối theo độ dài tài liệu."
        case .core: return "Tập trung vào các ý chính, khái niệm và chủ đề trọng tâm."
        case .thorough: return "Tạo câu hỏi chi tiết về từng thông tin, định nghĩa và chi tiết trong tài liệu."
        }
    }
}

public struct AppVersionInfo {
    public static let currentVersion = "v1.2.1"
    
    public static var buildNumber: String {
        if let path = Bundle.main.path(forResource: "build_number", ofType: "txt"),
           let str = try? String(contentsOfFile: path, encoding: .utf8) {
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "101"
    }
}

// SwiftUI Environment Key for App Font Scaling
private struct AppFontScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

extension EnvironmentValues {
    public var appFontScale: CGFloat {
        get { self[AppFontScaleKey.self] }
        set { self[AppFontScaleKey.self] = newValue }
    }
}

public struct ScaledFontModifier: ViewModifier {
    @Environment(\.appFontScale) var fontScale
    let baseSize: CGFloat
    let weight: Font.Weight
    
    public func body(content: Content) -> some View {
        content.font(.system(size: baseSize * fontScale, weight: weight))
    }
}

extension View {
    public func appFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.modifier(ScaledFontModifier(baseSize: size, weight: weight))
    }
}

public struct AppSettings: Codable, Equatable {
    public var apiKey: String
    public var defaultInputDirectory: String
    public var defaultOutputDirectory: String
    public var theme: AppTheme
    public var fontSize: AppFontSize
    public var isShuffleEnabled: Bool
    public var hasCompletedFirstTimeSetup: Bool
    
    public init(
        apiKey: String = "",
        defaultInputDirectory: String = (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? ""),
        defaultOutputDirectory: String = (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? ""),
        theme: AppTheme = .system,
        fontSize: AppFontSize = .medium,
        isShuffleEnabled: Bool = true,
        hasCompletedFirstTimeSetup: Bool = false
    ) {
        self.apiKey = apiKey
        self.defaultInputDirectory = defaultInputDirectory
        self.defaultOutputDirectory = defaultOutputDirectory
        self.theme = theme
        self.fontSize = fontSize
        self.isShuffleEnabled = isShuffleEnabled
        self.hasCompletedFirstTimeSetup = hasCompletedFirstTimeSetup
    }
    
    public static var defaultSettings: AppSettings {
        return AppSettings()
    }
}

public struct QuestionOption: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var label: String // e.g. "A", "B", "C", "D"
    public var text: String
    
    public init(id: String = UUID().uuidString, label: String, text: String) {
        self.id = id
        self.label = label
        self.text = text
    }
}

public struct Question: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var text: String
    public var options: [QuestionOption]
    public var correctAnswerIndex: Int
    public var explanation: String
    
    public init(id: String = UUID().uuidString, text: String, options: [QuestionOption], correctAnswerIndex: Int, explanation: String = "") {
        self.id = id
        self.text = text
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
    }
    
    public var correctAnswerLabel: String {
        guard correctAnswerIndex >= 0 && correctAnswerIndex < options.count else { return "" }
        return options[correctAnswerIndex].label
    }
    
    public var correctAnswerText: String {
        guard correctAnswerIndex >= 0 && correctAnswerIndex < options.count else { return "" }
        return options[correctAnswerIndex].text
    }
    
    public func shuffledWithRelabeledOptions() -> Question {
        guard options.count > 1 else { return self }
        let correctOpt = options[correctAnswerIndex]
        let shuffledOpts = options.shuffled()
        let newIndex = shuffledOpts.firstIndex(where: { $0.id == correctOpt.id }) ?? 0
        let relabeled = shuffledOpts.enumerated().map { idx, opt in
            let label = String(UnicodeScalar(65 + idx)!)
            return QuestionOption(id: opt.id, label: label, text: opt.text)
        }
        var copy = self
        copy.options = relabeled
        copy.correctAnswerIndex = newIndex
        return copy
    }
}

public struct Quiz: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var title: String
    public var description: String
    public var questions: [Question]
    public var createdAt: Date
    public var isPreMade: Bool
    
    public init(id: String = UUID().uuidString, title: String, description: String = "", questions: [Question], createdAt: Date = Date(), isPreMade: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
        self.createdAt = createdAt
        self.isPreMade = isPreMade
    }
}

public struct QuizProgress: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var quizId: String
    public var currentIndex: Int
    public var userAnswers: [String: Int]
    public var wrongQuestionIds: Set<String>
    public var flashcardMasteredIds: Set<String>
    public var isCompleted: Bool
    public var startTime: Date
    public var endTime: Date?
    public var shuffledQuestions: [Question]?
    
    public init(
        id: String = UUID().uuidString,
        quizId: String,
        currentIndex: Int = 0,
        userAnswers: [String: Int] = [:],
        wrongQuestionIds: Set<String> = [],
        flashcardMasteredIds: Set<String> = [],
        isCompleted: Bool = false,
        startTime: Date = Date(),
        endTime: Date? = nil,
        shuffledQuestions: [Question]? = nil
    ) {
        self.id = id
        self.quizId = quizId
        self.currentIndex = currentIndex
        self.userAnswers = userAnswers
        self.wrongQuestionIds = wrongQuestionIds
        self.flashcardMasteredIds = flashcardMasteredIds
        self.isCompleted = isCompleted
        self.startTime = startTime
        self.endTime = endTime
        self.shuffledQuestions = shuffledQuestions
    }
}

public struct StudyProject: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var description: String
    public var quizzes: [Quiz]
    public var progressMap: [String: QuizProgress]
    public var createdAt: Date
    public var lastStudiedAt: Date?
    
    public init(id: String = UUID().uuidString, name: String, description: String = "", quizzes: [Quiz] = [], progressMap: [String: QuizProgress] = [:], createdAt: Date = Date(), lastStudiedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.quizzes = quizzes
        self.progressMap = progressMap
        self.createdAt = createdAt
        self.lastStudiedAt = lastStudiedAt
    }
    
    public var totalQuestions: Int {
        quizzes.reduce(0) { $0 + $1.questions.count }
    }
    
    public var overallMasteryPercentage: Int {
        guard totalQuestions > 0 else { return 0 }
        var totalMastered = 0
        for quiz in quizzes {
            if let prog = progressMap[quiz.id] {
                let correctInQuiz = prog.userAnswers.filter { qId, ansIdx in
                    if let q = quiz.questions.first(where: { $0.id == qId }) {
                        return q.correctAnswerIndex == ansIdx
                    }
                    return false
                }.count
                totalMastered += max(correctInQuiz, prog.flashcardMasteredIds.count)
            }
        }
        return min(100, Int(Double(totalMastered) / Double(totalQuestions) * 100.0))
    }
}
