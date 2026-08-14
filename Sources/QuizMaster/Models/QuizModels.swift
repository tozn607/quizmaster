import Foundation
import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
}

public enum AppFontSize: String, CaseIterable, Identifiable, Codable {
    case smaller = "smaller"
    case standard = "default"
    case larger = "larger"
    case extraLarge = "extraLarge"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .smaller: return "Nhỏ hơn"
        case .standard: return "Mặc định"
        case .larger: return "Lớn hơn"
        case .extraLarge: return "Rất lớn"
        }
    }
    
    public var localizationKey: String {
        switch self {
        case .smaller: return "scaleSmaller"
        case .standard: return "scaleDefault"
        case .larger: return "scaleLarger"
        case .extraLarge: return "scaleExtraLarge"
        }
    }
    
    public var scaleFactor: CGFloat {
        switch self {
        case .smaller: return 0.80
        case .standard: return 1.0
        case .larger: return 1.20
        case .extraLarge: return 1.45
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self)) ?? "default"
        switch raw {
        case "smaller", "small":
            self = .smaller
        case "extraLarge", "xLarge":
            self = .extraLarge
        case "larger", "large":
            self = .larger
        case "default", "standard", "medium":
            self = .standard
        default:
            self = .standard
        }
    }
}

public enum AppUIScale: String, CaseIterable, Identifiable, Codable {
    case smaller = "smaller"
    case standard = "default"
    case larger = "larger"
    case extraLarge = "extraLarge"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .smaller: return "Nhỏ hơn"
        case .standard: return "Mặc định"
        case .larger: return "Lớn hơn"
        case .extraLarge: return "Rất lớn"
        }
    }
    
    public var localizationKey: String {
        switch self {
        case .smaller: return "scaleSmaller"
        case .standard: return "scaleDefault"
        case .larger: return "scaleLarger"
        case .extraLarge: return "scaleExtraLarge"
        }
    }
    
    public var scaleFactor: CGFloat {
        switch self {
        case .smaller: return 0.85
        case .standard: return 1.0
        case .larger: return 1.18
        case .extraLarge: return 1.35
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self)) ?? "default"
        switch raw {
        case "smaller", "small":
            self = .smaller
        case "extraLarge", "xLarge":
            self = .extraLarge
        case "larger", "large":
            self = .larger
        case "default", "standard", "medium":
            self = .standard
        default:
            self = .standard
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

public enum ProjectType: String, CaseIterable, Identifiable, Codable {
    case general = "general"
    case languageLearning = "languageLearning"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .general: return "Dự án Ôn tập Chung"
        case .languageLearning: return "Dự án Học Ngoại ngữ"
        }
    }
    
    public var iconName: String {
        switch self {
        case .general: return "folder.fill"
        case .languageLearning: return "character.book.closed.fill"
        }
    }
}

public enum QuizType: String, CaseIterable, Identifiable, Codable {
    case general = "general"
    case languageLearning = "languageLearning"
    
    public var id: String { rawValue }
}

public enum CEFRLevel: String, CaseIterable, Identifiable, Codable {
    case all = "ALL"
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .all: return "Tất cả trình độ (A1 - C2)"
        case .a1: return "A1 - Căn bản (Beginner)"
        case .a2: return "A2 - Sơ cấp (Elementary)"
        case .b1: return "B1 - Trung cấp (Intermediate)"
        case .b2: return "B2 - Trung cấp trên (Upper Intermediate)"
        case .c1: return "C1 - Cao cấp (Advanced)"
        case .c2: return "C2 - Thành thạo (Proficiency)"
        }
    }
    
    public var badgeLabel: String {
        switch self {
        case .all: return "CEFR All"
        default: return "CEFR \(rawValue)"
        }
    }
}

public enum LanguageSkill: String, CaseIterable, Identifiable, Codable {
    case reading = "reading"
    case listening = "listening"
    case lexical = "lexical" // Grammar, Vocabulary, Pronunciation, Stress
    case general = "general"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .reading: return "Đọc hiểu (Reading)"
        case .listening: return "Nghe hiểu (Listening)"
        case .lexical: return "Ngữ pháp & Từ vựng (Lexical)"
        case .general: return "Tổng hợp"
        }
    }
    
    public var iconName: String {
        switch self {
        case .reading: return "book.closed.fill"
        case .listening: return "headphones"
        case .lexical: return "character.cursor.ibeam"
        case .general: return "pencil.and.outline"
        }
    }
}

public struct VocabularyCard: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var word: String
    public var wordType: String // e.g. "n", "v", "adj", "adv", "idiom", "phr v"
    public var phonetic: String // IPA pronunciation e.g. "/ˈæp.əl/"
    public var vietnameseMeaning: String
    public var exampleSentence: String // sentence with target word in bold: **word**
    public var cefrLevel: CEFRLevel
    
    public init(
        id: String = UUID().uuidString,
        word: String,
        wordType: String = "",
        phonetic: String = "",
        vietnameseMeaning: String,
        exampleSentence: String = "",
        cefrLevel: CEFRLevel = .b1
    ) {
        self.id = id
        self.word = word
        self.wordType = wordType
        self.phonetic = phonetic
        self.vietnameseMeaning = vietnameseMeaning
        self.exampleSentence = exampleSentence
        self.cefrLevel = cefrLevel
    }
    
    public var frontText: String {
        let typeFormatted = wordType.isEmpty ? "" : " (\(wordType))"
        let ipaFormatted = phonetic.isEmpty ? "" : " \(phonetic)"
        return "\(word)\(typeFormatted)\(ipaFormatted)"
    }
}

public struct AppVersionInfo {
    public static let currentVersion = "v2.0.1"
    
    public static var buildNumber: String {
        if let path = Bundle.main.path(forResource: "build_number", ofType: "txt"),
           let str = try? String(contentsOfFile: path, encoding: .utf8) {
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "174"
    }
}

// SwiftUI Environment Key for App Font Scaling
private struct AppFontScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

// SwiftUI Environment Key for App UI / Window Scaling
private struct AppUiScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

extension EnvironmentValues {
    public var appFontScale: CGFloat {
        get { self[AppFontScaleKey.self] }
        set { self[AppFontScaleKey.self] = newValue }
    }
    
    public var appUiScale: CGFloat {
        get { self[AppUiScaleKey.self] }
        set { self[AppUiScaleKey.self] = newValue }
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
    public var uiScale: AppUIScale
    public var isShuffleEnabled: Bool
    public var hasCompletedFirstTimeSetup: Bool
    
    public init(
        apiKey: String = "",
        defaultInputDirectory: String = (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? ""),
        defaultOutputDirectory: String = (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? ""),
        theme: AppTheme = .system,
        fontSize: AppFontSize = .standard,
        uiScale: AppUIScale = .standard,
        isShuffleEnabled: Bool = true,
        hasCompletedFirstTimeSetup: Bool = false
    ) {
        self.apiKey = apiKey
        self.defaultInputDirectory = defaultInputDirectory
        self.defaultOutputDirectory = defaultOutputDirectory
        self.theme = theme
        self.fontSize = fontSize
        self.uiScale = uiScale
        self.isShuffleEnabled = isShuffleEnabled
        self.hasCompletedFirstTimeSetup = hasCompletedFirstTimeSetup
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apiKey = (try? container.decode(String.self, forKey: .apiKey)) ?? ""
        self.defaultInputDirectory = (try? container.decode(String.self, forKey: .defaultInputDirectory)) ?? (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? "")
        self.defaultOutputDirectory = (try? container.decode(String.self, forKey: .defaultOutputDirectory)) ?? (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? "")
        self.theme = (try? container.decode(AppTheme.self, forKey: .theme)) ?? .system
        self.fontSize = (try? container.decode(AppFontSize.self, forKey: .fontSize)) ?? .standard
        self.uiScale = (try? container.decode(AppUIScale.self, forKey: .uiScale)) ?? .standard
        self.isShuffleEnabled = (try? container.decode(Bool.self, forKey: .isShuffleEnabled)) ?? true
        self.hasCompletedFirstTimeSetup = (try? container.decode(Bool.self, forKey: .hasCompletedFirstTimeSetup)) ?? false
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
    
    // Language Learning Attributes
    public var skill: LanguageSkill?
    public var readingPassage: String?
    public var subTopic: String? // e.g. "Phát âm", "Trọng âm", "Điền từ", "Đọc hiểu", "Tìm lỗi sai"
    public var sectionIndex: Int? // 0, 1, 2 for section sequencing
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        options: [QuestionOption],
        correctAnswerIndex: Int,
        explanation: String = "",
        skill: LanguageSkill? = nil,
        readingPassage: String? = nil,
        subTopic: String? = nil,
        sectionIndex: Int? = nil
    ) {
        self.id = id
        self.text = text
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.skill = skill
        self.readingPassage = readingPassage
        self.subTopic = subTopic
        self.sectionIndex = sectionIndex
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
        let safeCorrectIndex = (correctAnswerIndex >= 0 && correctAnswerIndex < options.count) ? correctAnswerIndex : 0
        let correctOpt = options.indices.contains(safeCorrectIndex) ? options[safeCorrectIndex] : options[0]
        let shuffledOpts = options.shuffled()
        let newIndex = shuffledOpts.firstIndex(where: { $0.id == correctOpt.id }) ?? 0
        let labels = ["A", "B", "C", "D", "E", "F", "G", "H"]
        let relabeled = shuffledOpts.enumerated().map { idx, opt in
            let label = idx < labels.count ? labels[idx] : "\(idx + 1)"
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
    public var quizType: QuizType
    public var targetCEFR: CEFRLevel?
    public var vocabularies: [VocabularyCard]
    public var durationMinutes: Int?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        questions: [Question],
        createdAt: Date = Date(),
        isPreMade: Bool = false,
        quizType: QuizType = .general,
        targetCEFR: CEFRLevel? = nil,
        vocabularies: [VocabularyCard] = [],
        durationMinutes: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
        self.createdAt = createdAt
        self.isPreMade = isPreMade
        self.quizType = quizType
        self.targetCEFR = targetCEFR
        self.vocabularies = vocabularies
        self.durationMinutes = durationMinutes
    }
    
    /// Sections grouping based on language skills or sectionIndex
    public var detectedSkills: [LanguageSkill] {
        var skills: [LanguageSkill] = []
        for q in questions {
            if let sk = q.skill, !skills.contains(sk) {
                skills.append(sk)
            }
        }
        return skills.isEmpty ? [.general] : skills
    }
}

public struct QuizProgress: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var quizId: String
    public var currentIndex: Int
    public var userAnswers: [String: Int] // Kept for legacy integer index compatibility
    public var userSelectedOptionIds: [String: String] // questionId -> chosen Option ID (Rock-solid across all shuffles!)
    public var wrongQuestionIds: Set<String>
    public var flashcardMasteredIds: Set<String>
    public var isCompleted: Bool
    public var startTime: Date
    public var endTime: Date?
    public var shuffledQuestions: [Question]?
    public var completedSectionIndices: Set<Int>
    
    public init(
        id: String = UUID().uuidString,
        quizId: String,
        currentIndex: Int = 0,
        userAnswers: [String: Int] = [:],
        userSelectedOptionIds: [String: String] = [:],
        wrongQuestionIds: Set<String> = [],
        flashcardMasteredIds: Set<String> = [],
        isCompleted: Bool = false,
        startTime: Date = Date(),
        endTime: Date? = nil,
        shuffledQuestions: [Question]? = nil,
        completedSectionIndices: Set<Int> = []
    ) {
        self.id = id
        self.quizId = quizId
        self.currentIndex = currentIndex
        self.userAnswers = userAnswers
        self.userSelectedOptionIds = userSelectedOptionIds
        self.wrongQuestionIds = wrongQuestionIds
        self.flashcardMasteredIds = flashcardMasteredIds
        self.isCompleted = isCompleted
        self.startTime = startTime
        self.endTime = endTime
        self.shuffledQuestions = shuffledQuestions
        self.completedSectionIndices = completedSectionIndices
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.quizId = try container.decode(String.self, forKey: .quizId)
        self.currentIndex = try container.decodeIfPresent(Int.self, forKey: .currentIndex) ?? 0
        self.userAnswers = try container.decodeIfPresent([String: Int].self, forKey: .userAnswers) ?? [:]
        self.userSelectedOptionIds = try container.decodeIfPresent([String: String].self, forKey: .userSelectedOptionIds) ?? [:]
        self.wrongQuestionIds = try container.decodeIfPresent(Set<String>.self, forKey: .wrongQuestionIds) ?? []
        self.flashcardMasteredIds = try container.decodeIfPresent(Set<String>.self, forKey: .flashcardMasteredIds) ?? []
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        self.startTime = try container.decodeIfPresent(Date.self, forKey: .startTime) ?? Date()
        self.endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        self.shuffledQuestions = try container.decodeIfPresent([Question].self, forKey: .shuffledQuestions)
        self.completedSectionIndices = try container.decodeIfPresent(Set<Int>.self, forKey: .completedSectionIndices) ?? []
    }
}

public struct StudyProject: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var description: String
    public var projectType: ProjectType
    public var quizzes: [Quiz]
    public var progressMap: [String: QuizProgress]
    public var createdAt: Date
    public var lastStudiedAt: Date?
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        projectType: ProjectType = .general,
        quizzes: [Quiz] = [],
        progressMap: [String: QuizProgress] = [:],
        createdAt: Date = Date(),
        lastStudiedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.projectType = projectType
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
