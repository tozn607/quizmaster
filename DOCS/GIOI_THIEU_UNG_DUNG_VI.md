# 💡 GIỚI THIỆU ỨNG DỤNG QUIZMASTER (v1.0.3)

Tác giả: **@tozn607**  
Nền tảng: macOS Native App (Swift & SwiftUI)

---

## 1. Tổng quan Ứng dụng

**QuizMaster** là phần mềm tự học và tạo đề thi trắc nghiệm chuyên nghiệp dành cho hệ điều hành macOS. Được thiết kế theo phong cách giao diện Apple hiện đại (Glassmorphism & Vibrant UI), QuizMaster hỗ trợ sinh viên và giảng viên chuyển đổi các tài liệu học tập phức tạp thành bài thi tương tác sống động.

---

## 2. Công nghệ AI & Thuật toán Nổi bật trong v1.0.3

- **Mô hình Gemini 3.5 Flash Lite**: Kết nối trực tiếp qua Google AI Studio API Key cá nhân.
- **Tùy chọn Công tắc Xáo trộn (Shuffling Toggle)**: Bật/tắt xáo trộn vị trí câu hỏi và các phương án A/B/C/D linh hoạt.
- **Depth Modes (Độ sâu câu hỏi)**: Cho phép điều chỉnh số lượng và mức độ chi tiết của câu hỏi từ Mặc định (Normal), Trọng tâm (Core) tới Chi tiết toàn bộ (Thorough - đến 35-60+ câu).
- **Hỏi AI từng câu hỏi với Markdown Chuẩn**: Cho phép người dùng trực tiếp hỏi Gemini AI giải thích chi tiết đáp án tại từng câu hỏi với trình bày Markdown đẹp mắt.
- **Thanh Điều hướng Câu hỏi (Question Navigator)**: Bảng thông minh bên phải giúp theo dõi trạng thái làm bài và di chuyển tức thì giữa các câu.
- **Lưu Checkpoint Tự động**: Tự động lưu vết tiến độ học tập trong chế độ Luyện tập để tiếp tục khi quay lại.
- **Chế độ Thi thử Chống gian lận**: Ẩn đáp án và tính năng Hỏi AI trong môi trường thi thử.

---

## 3. Các Định dạng Xuất / Nhập

- **Zip Bundle (.zip)**: Chứa file RTF đề thi, đáp án và file JSON. Định dạng duy nhất hỗ trợ nhập ngược lại vào ứng dụng.
- **Microsoft Word (.docx)**: Tạo tệp Word chuẩn phục vụ việc in ấn ra giấy hoặc lưu trữ offline.
