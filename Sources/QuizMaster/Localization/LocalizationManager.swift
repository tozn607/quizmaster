import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case vietnamese = "vi"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .vietnamese: return "Tiếng Việt (Mặc định)"
        case .english: return "English"
        }
    }
}

public class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    @Published public var currentLanguage: AppLanguage = .vietnamese {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
        }
    }
    
    private init() {
        if let savedLang = UserDefaults.standard.string(forKey: "AppLanguage"),
           let lang = AppLanguage(rawValue: savedLang) {
            self.currentLanguage = lang
        }
    }
    
    public func text(_ key: String) -> String {
        let dict = currentLanguage == .vietnamese ? vietnameseDict : englishDict
        return dict[key] ?? englishDict[key] ?? key
    }
    
    private let vietnameseDict: [String: String] = [
        "appName": "QuizMaster",
        "appTagline": "Ứng dụng Ôn tập & Tạo Đề thi Trắc nghiệm Nâng cao",
        
        // Sidebar & Projects
        "projects": "Danh sách Dự án",
        "addProject": "Thêm Dự án mới",
        "projectName": "Tên Dự án",
        "newProjectTitle": "Tạo Dự án Ôn tập Mới",
        "noProjects": "Chưa có dự án nào. Hãy tạo một dự án mới để bắt đầu!",
        "deleteProject": "Xóa Dự án",
        "deleteConfirm": "Bạn có chắc chắn muốn xóa dự án này cùng tất cả bộ đề thi?",
        "cancel": "Hủy",
        "create": "Tạo",
        "save": "Lưu",
        "delete": "Xóa",
        "questionsCount": "câu hỏi",
        "quizzesCount": "bộ đề",
        "masteryScore": "Điểm thạo",
        "lastStudied": "Ôn lần cuối",
        "neverStudied": "Chưa học",
        
        // Navigation & Actions
        "practiceMode": "Luyện tập (Trắc nghiệm)",
        "examMode": "Thi thử (Exam Mode)",
        "flashcardMode": "Thẻ ghi nhớ (Flashcard)",
        "importDoc": "Nhập Tài liệu / Bộ đề",
        "exportWord": "Xuất đề ra Word (.docx)",
        "settings": "Cài đặt",
        "backToProjects": "Về danh sách Dự án",
        
        // Settings
        "settingsTitle": "Cài đặt Ứng dụng",
        "apiKeyLabel": "Google AI Studio Key (Gemini API):",
        "apiKeyHint": "Dán API Key của bạn từ Google AI Studio vào đây",
        "testApiKey": "Kiểm tra API Key",
        "apiKeyValid": "✓ API Key hợp lệ!",
        "apiKeyInvalid": "✕ API Key không hợp lệ hoặc lỗi kết nối.",
        "modelLabel": "Mô hình AI:",
        "fixedModelInfo": "Ứng dụng sử dụng mô hình Gemini 3.5 Flash Lite tối ưu cho OCR và trắc nghiệm.",
        "defaultInputDir": "Thư mục Nhập tài liệu mặc định:",
        "defaultOutputDir": "Thư mục Xuất kết quả mặc định:",
        "selectFolder": "Chọn thư mục",
        "language": "Ngôn ngữ giao diện:",
        "appearance": "Giao diện (Chủ đề):",
        "themeLight": "Sáng (Light)",
        "themeDark": "Tối (Dark)",
        "themeSystem": "Theo Hệ thống",
        
        // Import Screen
        "importTitle": "Nhập & Quét Tài liệu Tạo Bộ đề",
        "importNoticeTitle": "Lưu ý quan trọng:",
        "importNoticeBody": "Nên ưu tiên tải lên các tệp bộ đề đã soạn sẵn (file câu hỏi & đáp án). Nếu tải lên tài liệu thông thường (bài giảng, sách, ghi chú), hãy bật tùy chọn \"Tạo câu hỏi trắc nghiệm\" bên dưới.",
        "selectFile": "Chọn tệp tài liệu (PDF, Word .docx, TXT, Quiz JSON)",
        "createMultipleChoiceToggle": "Bật \"Tạo câu hỏi trắc nghiệm\" từ nội dung tài liệu (Dùng Gemini 3.5 Flash Lite OCR)",
        "geminiProcessing": "Đang gửi tài liệu tới Gemini 3.5 Flash Lite để quét OCR & trắc nghiệm...",
        "importQuizFile": "Nhập Bộ đề có sẵn (Format Quiz JSON/TXT)",
        "importSuccess": "Đã nhập thành công bộ đề!",
        "exportSuccess": "Đã xuất thành công câu hỏi và đáp án ra Word!",
        "generateButton": "Tạo Bộ Đề Thi Ngay",
        "exportWordQuestion": "Tệp Câu hỏi (Questions.rtf/docx)",
        "exportWordAnswer": "Tệp Đáp án (AnswerKey.rtf/docx)",
        
        // Practice Mode Screen
        "questionHeader": "Câu hỏi",
        "progressFormat": "Đã làm %@ / %@ câu",
        "scoreHiddenNote": "(Kết quả và thống kê chính xác sẽ hiển thị ở cuối bài thi)",
        "correctAnswer": "Chính xác!",
        "wrongAnswer": "Chưa đúng!",
        "nextQuestion": "Câu tiếp theo",
        "finishPractice": "Hoàn tất bài ôn tập",
        "redoWrong": "Làm lại các câu sai",
        "showFullAnswers": "Xem giải thích chi tiết tất cả câu",
        "quitQuiz": "Thoát bài thi",
        
        // Practice Finish Dialog
        "quizFinishedTitle": "Bạn đã hoàn thành bài thi!",
        "quizFinishedSubtitle": "Hãy chọn bước tiếp theo để củng cố kiến thức:",
        "btnRedoWrongOnly": "Làm lại các câu trả lời SAI",
        "btnReviewWithAnswers": "Xem lại toàn bộ câu hỏi & đáp án chi tiết",
        
        // Flashcard Mode Screen
        "cardProgress": "Thẻ %@ / %@",
        "clickToFlip": "Chạm/Nhấn vào thẻ để xem đáp án",
        "questionSide": "MẶT TRƯỚC: CÂU HỎI",
        "answerSide": "MẶT SAU: ĐÁP ÁN ĐÚNG",
        "btnRemembered": "V - Đã thuộc",
        "btnReviewLater": "X - Chưa thuộc (Học lại)",
        "flashcardCompleteTitle": "Xuất sắc! Bạn đã thuộc toàn bộ thẻ ghi nhớ!",
        "restartFlashcards": "Xáo trộn & Học lại từ đầu",
        
        // Ending / Stats Screen
        "congrats": "Chúc mừng bạn đã hoàn thành!",
        "scoreSummary": "Thống kê Kết quả",
        "accuracyScore": "Tỷ lệ chính xác",
        "correctCount": "Số câu đúng ngay lần đầu",
        "wrongCount": "Số câu cần ôn lại (làm sai)",
        "timeSpent": "Thời gian làm bài",
        "masteryLevel": "Mức độ thạo kiến thức",
        "reviewDetailed": "Xem chi tiết đáp án & giải thích",
        "backToDashboard": "Quay về Danh sách Dự án",
        
        // Review Screen
        "reviewTitle": "Chi tiết Bài làm & Đáp án",
        "filterAll": "Tất cả câu hỏi",
        "filterWrong": "Chỉ xem câu làm SAI",
        "explanation": "Giải thích chi tiết:",
        "yourChoice": "Lựa chọn của bạn:",
        "correctChoice": "Đáp án đúng:"
    ]
    
    private let englishDict: [String: String] = [
        "appName": "QuizMaster",
        "appTagline": "Advanced Document OCR & Quiz Generator App",
        
        // Sidebar & Projects
        "projects": "Projects Directory",
        "addProject": "Add New Project",
        "projectName": "Project Name",
        "newProjectTitle": "Create New Study Project",
        "noProjects": "No projects available. Create a project to begin!",
        "deleteProject": "Delete Project",
        "deleteConfirm": "Are you sure you want to delete this project and all its quizzes?",
        "cancel": "Cancel",
        "create": "Create",
        "save": "Save",
        "delete": "Delete",
        "questionsCount": "questions",
        "quizzesCount": "quizzes",
        "masteryScore": "Mastery",
        "lastStudied": "Last studied",
        "neverStudied": "Never studied",
        
        // Navigation & Actions
        "practiceMode": "Practice (Multiple-Choice)",
        "examMode": "Exam Mode",
        "flashcardMode": "Flashcard Mode",
        "importDoc": "Import Document / Quiz",
        "exportWord": "Export to Word (.docx)",
        "settings": "Settings",
        "backToProjects": "Back to Projects",
        
        // Settings
        "settingsTitle": "Application Settings",
        "apiKeyLabel": "Google AI Studio Key (Gemini API):",
        "apiKeyHint": "Paste your API Key from Google AI Studio here",
        "testApiKey": "Test API Key",
        "apiKeyValid": "✓ API Key Valid!",
        "apiKeyInvalid": "✕ Invalid API Key or network error.",
        "modelLabel": "AI Model:",
        "fixedModelInfo": "App exclusively uses Gemini 3.5 Flash Lite for fast OCR & high-accuracy quiz extraction.",
        "defaultInputDir": "Default Document Input Folder:",
        "defaultOutputDir": "Default Export Output Folder:",
        "selectFolder": "Select Folder",
        "language": "UI Language:",
        "appearance": "Appearance (Theme):",
        "themeLight": "Light",
        "themeDark": "Dark",
        "themeSystem": "System Default",
        
        // Import Screen
        "importTitle": "Import & Scan Document for Quizzes",
        "importNoticeTitle": "Important Notice:",
        "importNoticeBody": "It is preferred to upload pre-made quiz files (question & answer key format). If uploading general documents (textbooks, lecture notes, papers), enable 'Create Multiple-Choice' below.",
        "selectFile": "Select Document (PDF, Word .docx, TXT, Quiz JSON)",
        "createMultipleChoiceToggle": "Enable 'Create Multiple-Choice' from document text (via Gemini 3.5 Flash Lite OCR)",
        "geminiProcessing": "Sending document to Gemini 3.5 Flash Lite for OCR & extraction...",
        "importQuizFile": "Import Existing Quiz File (Quiz JSON/TXT)",
        "importSuccess": "Quiz successfully imported!",
        "exportSuccess": "Exported Question and Answer key files to Word!",
        "generateButton": "Generate Quiz Test Now",
        "exportWordQuestion": "Question File (Questions.rtf/docx)",
        "exportWordAnswer": "Answer Key File (AnswerKey.rtf/docx)",
        
        // Practice Mode Screen
        "questionHeader": "Question",
        "progressFormat": "Completed %@ / %@ questions",
        "scoreHiddenNote": "(Detailed score breakdown will be shown at the end of the test)",
        "correctAnswer": "Correct!",
        "wrongAnswer": "Incorrect!",
        "nextQuestion": "Next Question",
        "finishPractice": "Finish Practice Session",
        "redoWrong": "Redo Wrong Questions",
        "showFullAnswers": "Show Explanations for All Questions",
        "quitQuiz": "Quit Quiz",
        
        // Practice Finish Dialog
        "quizFinishedTitle": "Quiz Completed!",
        "quizFinishedSubtitle": "Choose your next step to reinforce your learning:",
        "btnRedoWrongOnly": "Redo INCORRECT questions only",
        "btnReviewWithAnswers": "Review ALL questions & detailed answer keys",
        
        // Flashcard Mode Screen
        "cardProgress": "Card %@ / %@",
        "clickToFlip": "Tap or Click card to flip for answer",
        "questionSide": "FRONT: QUESTION",
        "answerSide": "BACK: CORRECT ANSWER",
        "btnRemembered": "V - Remembered",
        "btnReviewLater": "X - Need Review (Repeat)",
        "flashcardCompleteTitle": "Awesome! You have mastered all flashcards!",
        "restartFlashcards": "Shuffle & Restudy Cards",
        
        // Ending / Stats Screen
        "congrats": "Congratulations on completing!",
        "scoreSummary": "Performance Summary",
        "accuracyScore": "Accuracy Rate",
        "correctCount": "Correct First Try",
        "wrongCount": "Incorrect / Retried",
        "timeSpent": "Time Elapsed",
        "masteryLevel": "Mastery Level",
        "reviewDetailed": "Review Answers & Explanations",
        "backToDashboard": "Return to Projects List",
        
        // Review Screen
        "reviewTitle": "Detailed Review & Explanations",
        "filterAll": "All Questions",
        "filterWrong": "Wrong Answers Only",
        "explanation": "Detailed Explanation:",
        "yourChoice": "Your Answer:",
        "correctChoice": "Correct Answer:"
    ]
}
