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
introBody += p("Phiên bản: v1.0.0 (Native Release)", bold: true, size: 22)
introBody += p("Ngày phát hành: 12/08/2026", size: 22)
introBody += p("Tác giả / Creator: @tozn607 (Anh Vinh)", bold: true, size: 24, color: "2B579A")
introBody += p("")
introBody += p("1. Tổng quan Ứng dụng", bold: true, size: 28, color: "2B579A")
introBody += p("QuizMaster là giải pháp phần mềm tự học và tạo đề thi trắc nghiệm chuyên nghiệp dành cho hệ điều hành macOS. Ứng dụng được biên dịch 100% bằng ngôn ngữ Swift và nền tảng SwiftUI của Apple, cho phép chạy trực tiếp và mượt mà trên tất cả các dòng máy Mac (Apple Silicon M1/M2/M3/M4 & Intel) mà người dùng không cần cài đặt thêm môi trường lập trình (Node.js, Python, Xcode framework).")
introBody += p("")
introBody += p("2. Tích hợp Công nghệ AI Tiên tiến (Gemini 3.5 Flash Lite)", bold: true, size: 28, color: "2B579A")
introBody += p("QuizMaster kết nối trực tiếp với dịch vụ Google AI Studio API của người dùng thông qua mô hình chuyên biệt Gemini 3.5 Flash Lite:")
introBody += p("• Quét và nhận diện OCR nội dung tài liệu học tập (PDF, Word .docx, Văn bản bài giảng .txt).")
introBody += p("• Tự động quét toàn bộ văn bản và sinh ra từ 15 đến 30 câu hỏi trắc nghiệm chất lượng cao phủ kín các chủ đề trong tài liệu.")
introBody += p("• Thuật toán Anti-bias Equalization: Đảm bảo cả 4 đáp án (A, B, C, D) có độ dài, độ phức tạp tương đương nhau, loại bỏ hoàn toàn tình trạng đáp án đúng bị dài hoặc lộ liễu.")
introBody += p("• Tính năng 'Hỏi Gemini AI về câu hỏi này': Hỗ trợ người dùng đặt câu hỏi trực tiếp cho AI tại từng câu để nhận phân tích chuyên sâu.")
introBody += p("")
introBody += p("3. Hai Chế độ Ôn tập Thông minh", bold: true, size: 28, color: "2B579A")
introBody += p("• Chế độ Luyện tập (Practice Mode): Giao diện làm bài thi trắc nghiệm trực quan, hiển thị tiến độ bài thi, lưu trữ danh sách câu sai và cho phép làm lại riêng các câu làm sai qua từng vòng.")
introBody += p("• Chế độ Thẻ Ghi Nhớ (Flashcard Mode): Thẻ 3D lật xem đáp án, đánh dấu V (Thuộc) & X (Chưa thuộc). Thẻ X sẽ được tự động giữ lại để ôn tập nối tiếp ở các vòng 2, vòng 3 cho đến khi người dùng thuộc 100%.")
introBody += p("")
introBody += p("4. Định dạng Xuất / Nhập Đa dạng", bold: true, size: 28, color: "2B579A")
introBody += p("• Gói Zip RTF (Mặc định): Xuất bộ đề dưới dạng file Zip chứa tệp Câu hỏi, tệp Đáp án & file JSON. Đây là gói mặc định có thể nhập (re-import) ngược lại vào ứng dụng.")
introBody += p("• Gói Zip Microsoft Word (.docx): Xuất tệp Word chuẩn (.docx) phục vụ việc in ấn hoặc xem offline.")

try createDocxPackage(bodyXml: introBody, outputPath: "/Users/tozn/Misc/quiz/QuizMaster_GioiThieuUngDung.docx")
print("✅ Created QuizMaster_GioiThieuUngDung.docx")

// 2. Generate QuizMaster_HuongDanSuDung.docx
var guideBody = ""
guideBody += p("HƯỚNG DẪN SỬ DỤNG CHI TIẾT QUIZMASTER", bold: true, size: 36, color: "2B579A")
guideBody += p("Tác giả: @tozn607 (Anh Vinh) | Phiên bản v1.0.0", bold: true, size: 24, color: "555555")
guideBody += p("-----------------------------------------------------------------------------------------", size: 18, color: "CCCCCC")
guideBody += p("")
guideBody += p("CHƯƠNG 1: CẤU HÌNH BAN ĐẦU & CÀI ĐẶT API KEY", bold: true, size: 28, color: "2B579A")
guideBody += p("1. Mở ứng dụng QuizMaster trên macOS.")
guideBody += p("2. Nhấn vào biểu tượng Cài đặt (Hình bánh răng) ở góc trên bên phải thanh Sidebar.")
guideBody += p("3. Dán Google AI Studio API Key của bạn vào ô 'Google AI Studio Key (Gemini API)'.")
guideBody += p("4. Nhấn nút 'Kiểm tra API Key' để chắc chắn kết nối thành công (Hiện dấu ✓ màu xanh).")
guideBody += p("5. Tùy chọn thiết lập thư mục Nhập/Xuất mặc định, Cỡ chữ hiển thị (Nhỏ, Vừa, Lớn, Rất lớn), Chủ đề giao diện (Sáng/Tối) và Ngôn ngữ (Tiếng Việt/Tiếng Anh).")
guideBody += p("")
guideBody += p("CHƯƠNG 2: QUẢN LÝ DỰ ÁN ÔN TẬP (PROJECTS)", bold: true, size: 28, color: "2B579A")
guideBody += p("1. Nhấn nút 'Thêm Dự án mới' (+), nhập tên dự án (ví dụ: 'Ôn thi Lịch Sử', 'Tiếng Anh B1').")
guideBody += p("2. Mỗi dự án có thể chứa nhiều bộ đề thi trắc nghiệm khác nhau.")
guideBody += p("3. Để xóa một dự án hoặc bộ đề thi, nhấp chuột phải vào tên dự án/bộ đề và chọn 'Xóa' (hoặc bấm biểu tượng thùng rác).")
guideBody += p("")
guideBody += p("CHƯƠNG 3: NHẬP & QUÉT TÀI LIỆU TẠO BỘ ĐỀ", bold: true, size: 28, color: "2B579A")
guideBody += p("Giao diện Nhập tài liệu được chia làm 2 Phần riêng biệt:")
guideBody += p("• PHẦN 1: QUÉT TÀI LIỆU VỚI GEMINI 3.5 FLASH LITE:")
guideBody += p("  - Chọn tệp tài liệu bài giảng (PDF, Word .docx, TXT).")
guideBody += p("  - Bật tùy chọn 'Tạo câu hỏi trắc nghiệm tự động'.")
guideBody += p("  - Bấm 'Bắt đầu Quét với Gemini AI'. AI sẽ tự động phân tích và tạo bài thi 15-30 câu.")
guideBody += p("  - Sau khi quét xong, bạn có thể bấm nút 'Xuất ngay tệp Zip' để lưu về máy.")
guideBody += p("• PHẦN 2: NHẬP BỘ ĐỀ CÓ SẴN (FILE / ZIP BUNDLE):")
guideBody += p("  - Chọn tệp Zip Bundle (.zip) hoặc JSON (.json) đã được xuất/soạn từ trước.")
guideBody += p("  - Bấm 'Nhập Bộ Đề Có Sẵn' để nạp ngay bài thi vào dự án mà không tốn chi phí API.")
guideBody += p("")
guideBody += p("CHƯƠNG 4: CHẾ ĐỘ LUYỆN TẬP (PRACTICE MODE)", bold: true, size: 28, color: "2B579A")
guideBody += p("1. Chọn bộ đề thi và nhấn 'Luyện tập (Trắc nghiệm)'.")
guideBody += p("2. Chọn phương án trả lời A, B, C, D. Hệ thống hiển thị ngay lập tức đáp án đúng (Màu xanh) hoặc sai (Màu đỏ).")
guideBody += p("3. Tại mỗi câu hỏi, bạn có thể nhấn nút 'Hỏi Gemini AI về câu này' (biểu tượng ngôi sao) để yêu cầu AI giải thích chi tiết hơn.")
guideBody += p("   (Lưu ý: Chỉ nên đặt câu hỏi cho những câu thực sự quan trọng để tiết kiệm hạn ngạch API).")
guideBody += p("4. Khi kết thúc bài thi, bạn có thể chọn 'Làm lại các câu trả lời SAI' hoặc 'Xem lại toàn bộ câu hỏi & giải thích'.")
guideBody += p("")
guideBody += p("CHƯƠNG 5: CHẾ ĐỘ THẺ GHI NHỚ (FLASHCARD MODE)", bold: true, size: 28, color: "2B579A")
guideBody += p("1. Chọn bộ đề và nhấn 'Thẻ ghi nhớ (Flashcard)'.")
guideBody += p("2. Nhấn/Chạm vào thẻ để xem mặt sau chứa đáp án đúng và phần giải thích.")
guideBody += p("3. Bấm V (Thuộc) nếu bạn đã nhớ, hoặc bấm X (Chưa thuộc) nếu cần ôn lại.")
guideBody += p("4. Khi kết thúc vòng 1, ứng dụng hiển thị bảng thống kê. Bạn có thể bấm 'Tiếp tục học lại các thẻ Chưa thuộc (X)' để sang Vòng 2, Vòng 3 cho đến khi thuộc 100%.")
guideBody += p("")
guideBody += p("CHƯƠNG 6: XUẤT ĐỀ THI RA MICROSOFT WORD (.DOCX) VÀ ZIP", bold: true, size: 28, color: "2B579A")
guideBody += p("• Xuất Gói Zip RTF (Mặc định): Chứa file Đề thi, file Đáp án và file JSON. Đây là gói duy nhất hỗ trợ nhập ngược lại vào QuizMaster.")
guideBody += p("• Xuất Tệp Microsoft Word (.docx): Tạo file .docx chuẩn của Microsoft Word đựng trong file Zip, phục vụ việc in ấn ra giấy hoặc gửi cho học sinh/đồng nghiệp.")

try createDocxPackage(bodyXml: guideBody, outputPath: "/Users/tozn/Misc/quiz/QuizMaster_HuongDanSuDung.docx")
print("✅ Created QuizMaster_HuongDanSuDung.docx")
