# 📖 HƯỚNG DẪN SỬ DỤNG CHI TIẾT QUIZMASTER (v1.0.1)

Tác giả: **@tozn607**  
Nền tảng: macOS (Swift / SwiftUI Native)

---

## CHƯƠNG 1: CẤU HÌNH BAN ĐẦU & CÀI ĐẶT API KEY

1. Mở ứng dụng **QuizMaster** trên máy Mac của bạn.
2. Nhấn vào biểu tượng **Cài đặt (⚙️)** ở thanh trên cùng hoặc ở Sidebar.
3. Bấm nút **"Lấy API Key từ Google AI Studio ↗"** để mở trình duyệt đến trang đăng ký API Key miễn phí của Google (`https://aistudio.google.com/api-keys`).
4. Sao chép API Key và dán vào ô **"Google AI Studio Key (Gemini API)"**.
5. Nhấn **"Kiểm tra API Key"** để chắc chắn kết nối thành công (hiển thị thông báo màu xanh `✓ API Key hợp lệ`).
6. Tùy chỉnh Cỡ chữ (Nhỏ, Vừa, Lớn, Rất lớn), Chủ đề giao diện (Sáng / Tối / Tự động) và Ngôn ngữ ứng dụng (Tiếng Việt / English).

---

## CHƯƠNG 2: PHÍM TẮT BÀN PHÍM VẬT LÝ

| Chế độ | Phím tắt | Thao tác |
| :--- | :--- | :--- |
| **Luyện tập & Thi thử** | `A`, `B`, `C`, `D` (hoặc `1`, `2`, `3`, `4`) | Chọn phương án A, B, C, D |
| **Luyện tập & Thi thử** | `Enter (↵)` | Sang câu tiếp theo / Nộp bài |
| **Thi thử (Exam Mode)** | `Mũi tên Trái / Phải (← →)` | Chuyển qua lại giữa các câu |
| **Thẻ ghi nhớ (Flashcard)**| `Phím Cách (Spacebar ␣)` | Lật mặt trước / mặt sau của thẻ 3D |
| **Thẻ ghi nhớ (Flashcard)**| `Phím V` (hoặc `1`) | Đánh dấu thẻ **V - Đã thuộc** |
| **Thẻ ghi nhớ (Flashcard)**| `Phím X` (hoặc `2`) | Đánh dấu thẻ **X - Chưa thuộc** |
| **Tất cả các chế độ** | `Delete (⌫)` | Thoát chế độ học về màn hình chính |

---

## CHƯƠNG 3: QUẢN LÝ DỰ ÁN & BỘ ĐỀ THI

1. **Tạo Dự án mới**: Nhấn nút `+` ở thanh Sidebar, nhập tên dự án (Ví dụ: *Ôn thi Lịch Sử*, *Tiếng Anh B1*).
2. **Đổi tên Bộ đề**: Nhấn vào biểu tượng cây bút (✏️) trên thẻ bộ đề hoặc nhấp chuột phải chọn **"Đổi tên bộ đề"**.
3. **Chuyển Bộ đề sang Dự án khác**: Nhấn biểu tượng thư mục (`folder.arrow.up`) hoặc nhấp chuột phải chọn **"Chuyển sang Dự án khác..."**.
4. **Chọn nhiều Bộ đề**: Bấm nút **"Chọn nhiều bộ đề"** trên màn hình chính để đánh dấu checkbox và thực hiện xóa / chuyển hàng loạt.
5. **Hiển thị trong Finder**: Nhấp chuột phải vào dự án hoặc bộ đề thi và chọn **"Hiển thị trong Finder"** để mở thư mục lưu trữ dữ liệu thực tế trên máy Mac.

---

## CHƯƠNG 4: CHẾ ĐỘ QUÉT TÀI LIỆU VỚI GEMINI AI

1. Bấm nút **"Nhập Tài liệu / Bộ đề"**.
2. Chọn tệp bài giảng PDF, Word (`.docx`) hoặc văn bản TXT.
3. Nếu là tệp bài giảng thường: Bật toggle **"Tạo câu hỏi trắc nghiệm tự động"** và chọn **Depth Mode**:
   - **Mặc định (Normal)**: Cân đối theo độ dài tài liệu (~12-20 câu).
   - **Ý chính / Trọng tâm (Core)**: Tập trung vào chủ đề chính (~8-15 câu).
   - **Chi tiết toàn bộ (Thorough)**: Quét chuyên sâu từng định nghĩa, quy tắc và chi tiết (~35-60+ câu).
4. Bấm **"Bắt đầu Quét với Gemini AI"** (Xác nhận trên hộp thoại kiểm tra chế độ quét).

---

## CHƯƠNG 5: BA CHẾ ĐỘ ÔN TẬP THÔNG MINH

1. **Chế độ Luyện tập (Practice Mode)**: Làm trắc nghiệm có phản hồi đúng/sai tức thì. Tại mỗi câu, bấm nút **"Hỏi Gemini AI về câu này"** để yêu cầu AI giải thích chuyên sâu.
2. **Chế độ Thi thử (Exam Mode)**: Môi trường thi thật không hiện đáp án đúng/sai cho tới khi bấm Nộp bài.
3. **Chế độ Thẻ ghi nhớ (Flashcard Mode)**: Thẻ lật 3D đánh dấu V (Thuộc) & X (Chưa thuộc). Các thẻ X sẽ được giữ lại để học lại ở vòng 2, vòng 3 cho tới khi thuộc 100%.
