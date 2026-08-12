# 💡 GIỚI THIỆU ỨNG DỤNG QUIZMASTER (v1.1.0)

Tác giả: **@tozn607**  
Nền tảng: macOS Native App (Swift & SwiftUI)

---

## 1. Tổng quan Ứng dụng

**QuizMaster** là phần mềm tự học và tạo đề thi trắc nghiệm chuyên nghiệp dành cho hệ điều hành macOS. Được thiết kế theo phong cách giao diện Apple hiện đại (macOS Liquid Glass Translucent Backdrop & Solid Vibrant UI), QuizMaster hỗ trợ sinh viên, học sinh và giảng viên chuyển đổi các tài liệu học tập phức tạp thành bài thi tương tác sống động.

---

## 2. Công nghệ AI & Thuật toán Nổi bật trong v1.1.0

- **Định dạng Markdown Lời giải Gemini AI**: Trình bày đẹp mắt các tiêu đề (`###`), văn bản bôi đậm (`**...**`), dải ngăn (`---`) và danh sách ghi chú trong hộp giải thích của màn hình Luyện tập.
- **Tối ưu Độ tương phản Light Mode**: Nền thẻ 100% trắng mịn kết hợp chữ tối rõ nét, loại bỏ triệt để hiện tượng chữ trắng trên nền sáng.
- **Bảng màu Solid Rực rỡ (LiquidGlassPalette)**: Tông màu sắc nét, ấn tượng (Ocean Blue, Sunset Orange, Deep Purple, Emerald Mint, Coral Red, Cyan Teal) giúp phân biệt các chế độ học.
- **Giao diện Nền kính macOS Translucent (`NSVisualEffectView`)**: Lớp nền kính mờ chìm đắm xuyên qua hình nền hệ thống macOS.
- **Mô hình Gemini 3.5 Flash Lite**: Kết nối trực tiếp qua Google AI Studio API Key cá nhân.
- **Tùy chọn Công tắc Xáo trộn (Shuffling Toggle)**: Bật/tắt xáo trộn vị trí câu hỏi và các phương án A/B/C/D linh hoạt.
- **Thanh Điều hướng Câu hỏi (Question Navigator)**: Bảng thông minh bên phải giúp theo dõi trạng thái làm bài và di chuyển tức thì giữa các câu.
- **Lưu Checkpoint Tự động**: Tự động lưu vết tiến độ học tập trong chế độ Luyện tập để tiếp tục khi quay lại.
- **Chế độ Thi thử Chống gian lận**: Ẩn đáp án và tính năng Hỏi AI trong môi trường thi thử.

---

## 3. Các Định dạng Xuất / Nhập

- **Zip Bundle (.zip)**: Chứa file RTF đề thi, đáp án và file JSON. Định dạng duy nhất hỗ trợ nhập ngược lại vào ứng dụng.
- **Microsoft Word (.docx)**: Tạo tệp Word chuẩn phục vụ việc in ấn ra giấy hoặc lưu trữ offline.
