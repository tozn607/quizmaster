# 📖 HƯỚNG DẪN SỬ DỤNG CHI TIẾT QUIZMASTER (v1.1.0)

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
   - *💡 Lưu ý: Thay đổi ngôn ngữ ứng dụng sang Tiếng Anh cũng sẽ tự động yêu cầu Gemini AI sinh câu hỏi, đáp án và giải thích bằng Tiếng Anh.*

---

## CHƯƠNG 2: PHÍM TẮT BÀN PHÍM VẬT LÝ

| Chế độ | Phím tắt | Thao tác |
| :--- | :--- | :--- |
| **Luyện tập & Thi thử** | `A`, `B`, `C`, `D` (hoặc `1`, `2`, `3`, `4`) | Chọn phương án A, B, C, D |
| **Luyện tập & Thi thử** | `Enter (↵)` | Sang câu tiếp theo / Nộp bài |
| **Thi thử (Exam Mode)** | `Mũi tên Trái / Phải (← →)` | Di chuyển qua lại giữa các câu |
| **Thẻ ghi nhớ (Flashcard)**| `Phím Cách (Spacebar ␣)` | Lật mặt trước / mặt sau của thẻ 3D |
| **Thẻ ghi nhớ (Flashcard)**| `Mũi tên Trái (←)` | Quay lại thẻ trước (Previous Card) |
| **Thẻ ghi nhớ (Flashcard)**| `Phím V` (hoặc `1`) | Đánh dấu thẻ **V - Đã thuộc** |
| **Thẻ ghi nhớ (Flashcard)**| `Phím X` (hoặc `2`) | Đánh dấu thẻ **X - Chưa thuộc** |
| **Tất cả các chế độ** | `Delete (⌫)` | Thoát chế độ học về màn hình chính |

---

## CHƯƠNG 3: QUẢN LÝ DỰ ÁN, BỘ ĐỀ THI & CÔNG TẮC XÁO TRỘN

1. **Tạo Dự án mới**: Nhấn nút `+` ở thanh Sidebar, nhập tên dự án (Ví dụ: *Ôn thi Lịch Sử*, *Tiếng Anh B1*).
2. **Đổi tên Bộ đề**: Nhấn vào biểu tượng cây bút (✏️) trên thẻ bộ đề hoặc nhấp chuột phải chọn **"Đổi tên bộ đề"**.
3. **Chuyển Bộ đề sang Dự án khác**: Nhấn biểu tượng thư mục (`folder.arrow.up`) hoặc nhấp chuột phải chọn **"Chuyển sang Dự án khác..."**.
4. **Chọn nhiều Bộ đề (Multi-select)**: Bấm nút **"Chọn nhiều bộ đề"** trên màn hình chính để đánh dấu checkbox và thực hiện xóa / chuyển hàng loạt.
5. **Công tắc Xáo trộn (Shuffling Toggle)**: Bấm nút **"🔀 Xáo trộn câu hỏi & đáp án"** ở thanh công cụ chính để bật/tắt xáo trộn vị trí câu hỏi và phương án A/B/C/D.
6. **Đặt lại Tiến độ học (Reset Progress)**: Nhấp chuột phải vào Dự án hoặc Bộ đề thi chọn **"Đặt lại Tiến độ học"** để học lại từ đầu.

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

## CHƯƠNG 5: BA CHẾ ĐỘ ÔN TẬP VÀ THANH ĐIỀU HƯỚNG CÂU HỎI

1. **Chế độ Luyện tập (Practice Mode)**:
   - Làm trắc nghiệm có phản hồi đúng/sai tức thì.
   - **Lưu điểm Checkpoint**: Tiến độ làm bài và vị trí câu đang làm được tự động lưu lại. Khi thoát ra và vào lại, bạn sẽ tiếp tục từ đúng câu dở dang.
   - **Hỏi Gemini AI**: Bấm nút **"Hỏi Gemini AI về câu này"** để yêu cầu AI giải thích chi tiết đáp án.
   - **Thanh Điều hướng Câu hỏi (Question Navigator)**: Bảng bên phải hiển thị màu sắc câu hỏi (Xanh lá = Đúng, Đỏ = Sai, Xám = Chưa làm), bấm vào số câu để chuyển nhanh.

2. **Chế độ Thi thử (Exam Mode)**:
   - Môi trường thi thật không hiện đáp án đúng/sai và ẩn nút Hỏi AI để đảm bảo chống gian lận.
   - Bấm **"Nộp bài thi"** để xem tổng kết điểm số và bảng phân tích đáp án chi tiết.

3. **Chế độ Thẻ ghi nhớ (Flashcard Mode)**:
   - Thẻ lật 3D đánh dấu V (Thuộc) & X (Chưa thuộc).
   - Nút **"Thẻ trước" (Previous Card)** cho phép quay lại thẻ vừa duyệt.
   - Các thẻ X được giữ lại để học lại ở các vòng 2, 3 cho tới khi thuộc 100%.

---

## CHƯƠNG 6: XUẤT ĐỀ VÀ KIỂM TRA CẬP NHẬT

1. **Xuất Đề thi**: Nhấp chuột phải vào thẻ bộ đề thi để chọn:
   - **Xuất gói Zip Bundle (Mặc định - Hỗ trợ nhập lại)**: Xuất file zip chứa RTF và JSON có thể nạp lại vào ứng dụng.
   - **Xuất tệp Word (.docx)**: Xuất file Word chuẩn để in ấn ra giấy.
2. **Kiểm tra Cập nhật**: Vào Cài đặt ⚙️ bấm **"Kiểm tra Cập nhật"** để xem thông tin phiên bản mới nhất và tải về trực tiếp từ GitHub.
