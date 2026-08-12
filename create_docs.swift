import Foundation

func createDocxPackage(bodyXml: String, outputPath: String) throws {
    let fm = FileManager.default
    let tempDocxDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try fm.createDirectory(at: tempDocxDir, withIntermediateDirectories: true)
    defer { try? fm.removeItem(at: tempDocxDir) }
    
    let relsDir = tempDocxDir.appendingPathComponent("_rels")
    let wordDir = tempDocxDir.appendingPathComponent("word")
    try fm.createDirectory(at: relsDir, withIntermediateDirectories: true)
    try fm.createDirectory(at: wordDir, withIntermediateDirectories: true)
    
    let contentTypesXml = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
        <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
        <Default Extension="xml" ContentType="application/xml"/>
        <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
    </Types>
    """
    
    let relsXml = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
    </Relationships>
    """
    
    let docXml = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
            \(bodyXml)
        </w:body>
    </w:document>
    """
    
    try contentTypesXml.write(to: tempDocxDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
    try relsXml.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
    try docXml.write(to: wordDir.appendingPathComponent("document.xml"), atomically: true, encoding: .utf8)
    
    if fm.fileExists(atPath: outputPath) {
        try fm.removeItem(atPath: outputPath)
    }
    
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
    process.currentDirectoryURL = tempDocxDir
    process.arguments = ["-r", outputPath, "[Content_Types].xml", "_rels", "word"]
    try process.run()
    process.waitUntilExit()
}

func p(_ text: String, bold: Bool = false, size: Int = 22, color: String? = nil) -> String {
    let escaped = text.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;")
    var rPr = "<w:rPr><w:sz w:val=\"\(size)\"/>"
    if bold { rPr += "<w:b/>" }
    if let c = color { rPr += "<w:color w:val=\"\(c)\"/>" }
    rPr += "</w:rPr>"
    return "<w:p><w:r>\(rPr)<w:t>\(escaped)</w:t></w:r></w:p>"
}

// 1. Generate QuizMaster_GioiThieuUngDung.docx
var introBody = ""
introBody += p("GIỚI THIỆU ỨNG DỤNG QUIZMASTER", bold: true, size: 36, color: "2B579A")
introBody += p("Ứng dụng Ôn tập & Tạo Đề thi Trắc nghiệm Nâng cao trên Native macOS", bold: true, size: 24, color: "555555")
introBody += p("-----------------------------------------------------------------------------------------", size: 18, color: "CCCCCC")
introBody += p("Tên ứng dụng: QuizMaster", bold: true, size: 22)
introBody += p("Phiên bản: v1.0.1 (Native Release)", bold: true, size: 22)
introBody += p("Tác giả / Creator: @tozn607", bold: true, size: 24, color: "2B579A")
introBody += p("")
introBody += p("1. Tổng quan Ứng dụng", bold: true, size: 28, color: "2B579A")
introBody += p("QuizMaster là giải pháp phần mềm tự học và tạo đề thi trắc nghiệm chuyên nghiệp dành cho hệ điều hành macOS. Ứng dụng được biên dịch 100% bằng ngôn ngữ Swift và nền tảng SwiftUI của Apple, cho phép chạy trực tiếp và mượt mà trên tất cả các dòng máy Mac (Apple Silicon M1/M2/M3/M4 & Intel) mà người dùng không cần cài đặt thêm môi trường lập trình.")
introBody += p("")
introBody += p("2. Tích hợp Công nghệ AI Tiên tiến (Gemini 3.5 Flash Lite)", bold: true, size: 28, color: "2B579A")
introBody += p("QuizMaster kết nối trực tiếp với dịch vụ Google AI Studio API của người dùng thông qua mô hình chuyên biệt Gemini 3.5 Flash Lite:")
introBody += p("• Quét và nhận diện OCR nội dung tài liệu học tập (PDF, Word .docx, Văn bản bài giảng .txt).")
introBody += p("• Tự động xáo trộn vị trí đáp án đúng ngẫu nhiên giữa A, B, C, D (loại bỏ hoàn toàn thiên vị đáp án A).")
introBody += p("• Chế độ điều chỉnh độ sâu câu hỏi (Depth Mode): Mặc định (Normal), Trọng tâm (Core), Chi tiết toàn bộ (Thorough - tạo đến 35-60 câu hỏi).")
introBody += p("• Tính năng 'Hỏi Gemini AI về câu hỏi này': Hỗ trợ người dùng đặt câu hỏi trực tiếp cho AI tại từng câu để nhận phân tích chuyên sâu.")
introBody += p("")
introBody += p("3. Ba Chế độ Ôn tập Thông minh", bold: true, size: 28, color: "2B579A")
introBody += p("• Chế độ Luyện tập (Practice Mode): Giao diện làm bài thi trắc nghiệm trực quan với phản hồi đáp án tức thì và câu hỏi phân tích từ Gemini AI.")
introBody += p("• Chế độ Thi thử (Exam Mode): Môi trường thi thật không hiển thị đáp án đúng/sai cho tới khi bấm Nộp bài.")
introBody += p("• Chế độ Thẻ Ghi Nhớ (Flashcard Mode): Thẻ 3D lật xem đáp án, đánh dấu V (Thuộc) & X (Chưa thuộc).")

try createDocxPackage(bodyXml: introBody, outputPath: "/Users/tozn/Misc/quiz/QuizMaster_GioiThieuUngDung.docx")
print("✅ Created QuizMaster_GioiThieuUngDung.docx")

// 2. Generate QuizMaster_HuongDanSuDung.docx
var guideBody = ""
guideBody += p("HƯỚNG DẪN SỬ DỤNG CHI TIẾT QUIZMASTER", bold: true, size: 36, color: "2B579A")
guideBody += p("Tác giả: @tozn607 | Phiên bản v1.0.1", bold: true, size: 24, color: "555555")
guideBody += p("-----------------------------------------------------------------------------------------", size: 18, color: "CCCCCC")
guideBody += p("")
guideBody += p("CHƯƠNG 1: CẤU HÌNH BAN ĐẦU & CÀI ĐẶT API KEY", bold: true, size: 28, color: "2B579A")
guideBody += p("1. Mở ứng dụng QuizMaster trên macOS.")
guideBody += p("2. Nhấn vào biểu tượng Cài đặt (Hình bánh răng) ở góc trên bên phải thanh Sidebar.")
guideBody += p("3. Bấm nút 'Lấy API Key từ Google AI Studio ↗' để mở trình duyệt và sao chép API Key miễn phí.")
guideBody += p("4. Dán Google AI Studio API Key của bạn vào ô 'Google AI Studio Key (Gemini API)'.")
guideBody += p("5. Nhấn nút 'Kiểm tra API Key' để chắc chắn kết nối thành công (Hiện dấu ✓ màu xanh).")
guideBody += p("")
guideBody += p("CHƯƠNG 2: PHÍM TẮT BÀN PHÍM VẬT LÝ", bold: true, size: 28, color: "2B579A")
guideBody += p("• Phím A, B, C, D (hoặc 1, 2, 3, 4): Chọn đáp án A, B, C, D tức thì.")
guideBody += p("• Phím Enter (↵): Chuyển sang câu tiếp theo hoặc nộp bài thi.")
guideBody += p("• Phím Mũi tên (← →): Di chuyển qua lại giữa các câu trong Chế độ Thi thử.")
guideBody += p("• Phím Cách (Spacebar ␣): Lật mặt thẻ ghi nhớ trong Chế độ Flashcard.")
guideBody += p("• Phím V (hoặc 1): Đánh dấu thẻ 'Đã thuộc (V)'.")
guideBody += p("• Phím X (hoặc 2): Đánh dấu thẻ 'Chưa thuộc (X)'.")
guideBody += p("• Phím Delete (⌫): Thoát chế độ học hiện tại.")

try createDocxPackage(bodyXml: guideBody, outputPath: "/Users/tozn/Misc/quiz/QuizMaster_HuongDanSuDung.docx")
print("✅ Created QuizMaster_HuongDanSuDung.docx")
