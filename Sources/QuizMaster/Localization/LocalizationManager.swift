import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case vietnamese = "vi"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .vietnamese: return "Tiếng Việt"
        case .english: return "English"
        }
    }
}

public class LocalizationManager: ObservableObject {
    @Published public var currentLanguage: AppLanguage = .vietnamese
    
    private let viDictionary: [String: String] = [
        "appName": "QuizMaster",
        "appTagline": "Ứng dụng Ôn tập & Tạo Đề thi Trắc nghiệm",
        "newProject": "Thêm Dự án mới",
        "projectNamePlaceholder": "Tên dự án mới...",
        "createProject": "Tạo Dự án",
        "deleteProject": "Xóa Dự án",
        "deleteQuiz": "Xóa Bộ đề",
        "renameQuiz": "Đổi tên Bộ đề",
        "showInFinder": "Hiển thị trong Finder",
        "noProjectsYet": "Chưa có dự án nào",
        "createFirstProjectPrompt": "Hãy bấm nút '+' để tạo dự án học tập đầu tiên.",
        "projectQuizzesHeader": "Các Bộ đề thi trong Dự án",
        "importDoc": "Nhập Tài liệu / Bộ đề",
        "exportWord": "Xuất đề ra Word (.docx)",
        "practiceMode": "Luyện tập (Trắc nghiệm)",
        "examMode": "Thi thử (Exam Mode)",
        "flashcardMode": "Thẻ ghi nhớ (Flashcard)",
        "settings": "Cài đặt",
        "settingsTitle": "Cài đặt Ứng dụng",
        "apiKeyLabel": "Google AI Studio Key (Gemini API)",
        "apiKeyHint": "Dán API Key của bạn từ Google AI Studio tại đây...",
        "testApiKey": "Kiểm tra API Key",
        "apiKeyValid": "✓ API Key hợp lệ và hoạt động bình thường!",
        "apiKeyInvalid": "✕ API Key không hợp lệ hoặc hết hạn ngạch.",
        "modelLabel": "Mô hình AI sử dụng",
        "modelFixedNote": "Mô hình cố định Gemini 3.5 Flash Lite cho độ chính xác cao.",
        "directoriesHeader": "Thư mục Mặc định",
        "inputDirLabel": "Thư mục Nhập tài liệu mặc định:",
        "outputDirLabel": "Thư mục Xuất kết quả mặc định:",
        "selectFolder": "Chọn thư mục",
        "languageLabel": "Ngôn ngữ ứng dụng:",
        "saveSettings": "Lưu Cài đặt",
        "questionsCount": "câu hỏi",
        "masteryLevel": "Mức độ thuộc bài",
        "quitQuiz": "Thoát bài thi",
        "progressFormat": "Câu %@ / %@",
        "scoreHiddenNote": "Đáp án hiển thị ngay sau khi chọn",
        "questionHeader": "Câu hỏi",
        "correctAnswer": "ĐÚNG RỒI!",
        "wrongAnswer": "CHƯA CHÍNH XÁC",
        "nextQuestion": "Câu tiếp theo",
        "finishPractice": "Hoàn thành bài luyện tập",
        "quizFinishedTitle": "Hoàn thành bài Luyện tập!",
        "quizFinishedSubtitle": "Bạn đã duyệt qua toàn bộ câu hỏi trong bộ đề.",
        "btnRedoWrongOnly": "Làm lại các câu làm SAI",
        "btnReviewWithAnswers": "Xem lại toàn bộ đáp án & giải thích",
        "backToDashboard": "Về màn hình chính",
        "backToProjects": "Về danh sách Dự án",
        "questionSide": "MẶT CÂU HỎI",
        "answerSide": "MẶT ĐÁP ÁN ĐÚNG",
        "confirmScanTitle": "Xác nhận Chế độ Quét Tài liệu",
        "confirmScanMsgToggleOn": "⚠️ Bạn đang BẬT 'Tạo câu hỏi trắc nghiệm tự động'. Hãy chắc chắn đây là TÀI LIỆU BÀI GIẢNG / VĂN BẢN THƯỜNG (không phải đề thi có sẵn). AI sẽ tự động phân tích và tạo câu hỏi.",
        "confirmScanMsgToggleOff": "⚠️ Bạn đang TẮT 'Tạo câu hỏi trắc nghiệm tự động'. Ứng dụng sẽ trích xuất ĐỀ THI CÓ SẴN từ file. Hãy chắc chắn tài liệu đã có sẵn các câu hỏi và đáp án."
    ]
    
    private let enDictionary: [String: String] = [
        "appName": "QuizMaster",
        "appTagline": "Study & Multiple-Choice Test Generator",
        "newProject": "New Project",
        "projectNamePlaceholder": "New project name...",
        "createProject": "Create Project",
        "deleteProject": "Delete Project",
        "deleteQuiz": "Delete Quiz",
        "renameQuiz": "Rename Quiz",
        "showInFinder": "Show in Finder",
        "noProjectsYet": "No projects yet",
        "createFirstProjectPrompt": "Click '+' to create your first study project.",
        "projectQuizzesHeader": "Project Quiz Sets",
        "importDoc": "Import Document / Quiz",
        "exportWord": "Export to Word (.docx)",
        "practiceMode": "Practice (Multiple-Choice)",
        "examMode": "Exam Mode",
        "flashcardMode": "Flashcard Mode",
        "settings": "Settings",
        "settingsTitle": "App Settings",
        "apiKeyLabel": "Google AI Studio Key (Gemini API)",
        "apiKeyHint": "Paste your Google AI Studio API Key here...",
        "testApiKey": "Test API Key",
        "apiKeyValid": "✓ API Key is valid and active!",
        "apiKeyInvalid": "✕ Invalid API Key or rate limit exceeded.",
        "modelLabel": "AI Model",
        "modelFixedNote": "Model locked to Gemini 3.5 Flash Lite for high accuracy.",
        "directoriesHeader": "Default Directories",
        "inputDirLabel": "Default Document Input Folder:",
        "outputDirLabel": "Default Result Output Folder:",
        "selectFolder": "Browse...",
        "languageLabel": "App Language:",
        "saveSettings": "Save Settings",
        "questionsCount": "questions",
        "masteryLevel": "Mastery Level",
        "quitQuiz": "Quit Quiz",
        "progressFormat": "Question %@ of %@",
        "scoreHiddenNote": "Feedback shown immediately after selection",
        "questionHeader": "Question",
        "correctAnswer": "CORRECT!",
        "wrongAnswer": "INCORRECT",
        "nextQuestion": "Next Question",
        "finishPractice": "Finish Practice",
        "quizFinishedTitle": "Practice Completed!",
        "quizFinishedSubtitle": "You have reviewed all questions in this set.",
        "btnRedoWrongOnly": "Redo Wrong Questions Only",
        "btnReviewWithAnswers": "Review All Answers & Explanations",
        "backToDashboard": "Back to Main Dashboard",
        "backToProjects": "Back to Projects List",
        "questionSide": "QUESTION SIDE",
        "answerSide": "CORRECT ANSWER SIDE",
        "confirmScanTitle": "Confirm Document Scanning Mode",
        "confirmScanMsgToggleOn": "⚠️ You ENABLED 'Create Multiple-Choice'. Please confirm your file is a REGULAR LECTURE / TEXT DOCUMENT (not a pre-made quiz). Gemini will generate test questions automatically.",
        "confirmScanMsgToggleOff": "⚠️ You DISABLED 'Create Multiple-Choice'. The app will extract PRE-EXISTING QUIZ QUESTIONS from the file. Please confirm the file already contains quiz questions and answers."
    ]
    
    public init() {}
    
    public func text(_ key: String) -> String {
        let dict = currentLanguage == .vietnamese ? viDictionary : enDictionary
        return dict[key] ?? key
    }
}
