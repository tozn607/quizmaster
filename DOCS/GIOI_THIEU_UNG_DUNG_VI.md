# 💡 GIỚI THIỆU ỨNG DỤNG QUIZMASTER (v1.1.0)

Tác giả: **@tozn607**  
Nền tảng: macOS (Swift / SwiftUI Native)  
Ngày soạn: **13 Tháng 8 năm 2026**  
Dành cho phiên bản: **v1.1.0**

## 1. Tổng quan Ứng dụng

**QuizMaster** là phần mềm tự học và tạo đề thi trắc nghiệm chuyên nghiệp dành cho hệ điều hành macOS. Được thiết kế theo phong cách giao diện **Liquid Glass** và được biên dịch 100% bằng ngôn ngữ **Swift** của Apple, QuizMaster hỗ trợ sinh viên, học sinh và giảng viên chuyển đổi các tài liệu học tập thành bài thi, bài kiểm tra tương tác sống động với độ mượt mà vượt trội.


## 2. Tính năng mới trong v1.1.0

- **Định dạng Markdown Lời giải Gemini AI**: Trình bày đẹp mắt các tiêu đề (`###`), văn bản bôi đậm (`**...**`), dải ngăn (`---`) và danh sách ghi chú trong hộp giải thích của màn hình Luyện tập.
- **Tối ưu Độ tương phản Light Mode**: Nền thẻ 100% trắng mịn kết hợp chữ tối rõ nét, loại bỏ triệt để hiện tượng chữ trắng trên nền sáng.
- **Bảng màu Solid Rực rỡ (LiquidGlassPalette)**: Tông màu sắc nét, ấn tượng (Ocean Blue, Sunset Orange, Deep Purple, Emerald Mint, Coral Red, Cyan Teal) giúp phân biệt các chế độ học.
- **Giao diện Nền kính macOS Translucent (`NSVisualEffectView`)**: Lớp nền kính mờ chìm đắm xuyên qua hình nền hệ thống macOS.
- **Mô hình Gemini 3.5 Flash Lite**: Kết nối trực tiếp qua Google AI Studio API Key cá nhân.
- **Tùy chọn Công tắc Xáo trộn (Shuffling Toggle)**: Bật/tắt xáo trộn vị trí câu hỏi và các phương án A/B/C/D linh hoạt.
- **Thanh Điều hướng Câu hỏi (Question Navigator)**: Bảng thông minh bên phải giúp theo dõi trạng thái làm bài và di chuyển tức thì giữa các câu.
- **Lưu Checkpoint Tự động**: Tự động lưu vết tiến độ học tập trong chế độ Luyện tập để tiếp tục khi quay lại.
- **Chế độ Thi thử Chống gian lận**: Ẩn đáp án và tính năng Hỏi AI trong môi trường thi thử.


## 3. Các Định dạng Xuất / Nhập

- **Zip Bundle (.zip)**: Chứa file RTF đề thi, đáp án và file JSON. Định dạng duy nhất hỗ trợ nhập ngược lại vào ứng dụng.
- **Microsoft Word (.docx)**: Tạo tệp Word chuẩn phục vụ việc in ấn ra giấy hoặc lưu trữ offline.
