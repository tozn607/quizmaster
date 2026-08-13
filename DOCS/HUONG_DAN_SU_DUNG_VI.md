# HƯỚNG DẪN SỬ DỤNG CHI TIẾT QUIZMASTER (v1.2.1)

Tác giả: **@tozn607**  
Nền tảng: macOS (Swift / SwiftUI Native)  
Ngày soạn: **13 Tháng 8 năm 2026**  
Dành cho phiên bản: **v1.2.1**


## CHƯƠNG 1: MÀN HÌNH HƯỚNG DẪN CẤU HÌNH BAN ĐẦU & API KEY

[![](https://img.shields.io/badge/Tải_trực_tiếp_QuizMaster.zip-Bản_Mới_Nhất-blue?style=for-the-badge&logo=apple)](https://github.com/tozn607/quizmaster/releases/latest/download/QuizMaster.zip)

0. Tải bản dựng **QuizMaster** mới nhất bằng cách nhấn nút **"Tải trực tiếp QuizMaster.zip"** (hoặc đi tới [Releases ↗](https://github.com/tozn607/quizmaster/releases/latest)). Giải nén và di chuyển **QuizMaster.app** vào thư mục **Applications**.  
Khi mở **QuizMaster.app** lần đầu tiên, ứng dụng sẽ tự động hiển thị **Màn hình Cấu hình Ban đầu** gồm 4 bước:
![Screenshot](/DOCS/SCREENSHOTS/quizmaster0.png)

1. **Bước 1:** Giới thiệu các tính năng chính của QuizMaster, nhấn nút **"Bắt đầu Cấu hình ➔"**.
2. **Bước 2: Cài đặt API Key Gemini AI**:    
   **Tại sao lại cần API Key cá nhân?:** Để đảm bảo quyền riêng tư và để ứng dụng dễ tiếp cận hơn với số đông, tác giả không tích hợp sẵn API Key mà để người dùng tự cấu hình bằng API Key miễn phí đến từ Google. Mỗi tài khoản Google của bạn được cấp một hạn mức sử dụng model Gemini 3.5 Flash Lite miễn phí, dư dả để tạo một lượng lớn đề thi và lời giải trong một ngày. Việc tự nhập API Key cá nhân giúp giữ ứng dụng miễn phí và có mã nguồn mở. Ngược lại, nếu tác giả đính kèm sẵn API Key thì lượng sử dụng từ cộng đồng sẽ vượt hạn mức và tác giả sẽ phải trả phí dịch vụ cho Google.
   - Nhấn nút **"Lấy API Key từ Google AI Studio ↗"** để đăng ký API Key miễn phí từ Google.
   - Ở góc phía trên bên phải của Website, ấn **Create API Key**, đặt tên cho Key và chọn **Default Gemini Project**, sau đó sao chép API Key.
   ![Screenshot](/DOCS/SCREENSHOTS/help1.png)
   ![Screenshot](/DOCS/SCREENSHOTS/help2.png)
   ![Screenshot](/DOCS/SCREENSHOTS/help3.png)
   - Dán API Key vào ô và nhấn **"Kiểm tra API Key"** (thông báo màu xanh `✓ API Key hợp lệ`).
   - Nhấn **"Tiếp tục ➔"**.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster1.png)
3. **Bước 3: Tùy chỉnh Giao diện, Ngôn ngữ & Hướng dẫn Nhanh**:
   - Chọn Ngôn ngữ (Tiếng Việt / English), Chủ đề (Sáng / Tối / Tự động) và Cỡ chữ hiển thị (Nhỏ, Vừa, Lớn, Rất lớn).
   - Xem tóm tắt hướng dẫn sử dụng nhanh và phím tắt.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster2.png)
4. **Bước 4: Hoàn tất Cấu hình**:
   - Bấm **"Vào sử dụng QuizMaster ngay 🚀"** để bắt đầu.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster3.png)

*(Nếu muốn thay đổi lại API Key hoặc Giao diện sau này, bạn có thể vào biểu tượng **Cài đặt (⚙️)** ở Sidebar bất kỳ lúc nào).*
<details>
  <summary>Nhấn vào đây để hiển thị</summary>

   1. Mở ứng dụng **QuizMaster** trên máy Mac của bạn.
   2. Nhấn vào biểu tượng **Cài đặt (⚙️)** ở thanh trên cùng hoặc ở Sidebar.
   3. Bấm nút **"Lấy API Key từ Google AI Studio ↗"** để mở trình duyệt đến trang đăng ký API Key miễn phí của Google.
   4. Ở góc phía trên bên phải, ấn **Create API Key**, đặt tên cho Key và chọn **Default Gemini Project**, sau đó sao chép API Key và dán vào ô **"Google AI Studio Key (Gemini API)"** của ứng dụng.
   5. Nhấn **"Kiểm tra API Key"** để chắc chắn kết nối thành công (hiển thị thông báo màu xanh `✓ API Key hợp lệ`).
   6. Tùy chỉnh Cỡ chữ (Nhỏ, Vừa, Lớn, Rất lớn), Chủ đề giao diện (Sáng / Tối / Tự động) và Ngôn ngữ ứng dụng (Tiếng Việt / English).
      - *💡 Lưu ý: Thay đổi ngôn ngữ ứng dụng sang Tiếng Anh cũng sẽ tự động yêu cầu Gemini AI sinh câu hỏi, đáp án và giải thích bằng Tiếng Anh.*
      ![Screenshot](/DOCS/SCREENSHOTS/quizmaster7.png)
</details>

### Hướng dẫn Khắc phục Lỗi Gatekeeper & Cho phép Mở ứng dụng từ Mọi nơi:

Khi mở **QuizMaster.app** lần đầu trên macOS, nếu gặp thông báo lỗi *“QuizMaster.app bị hỏng và không thể mở”* hoặc *“Ứng dụng không thể mở vì không xác minh được nhà phát triển”*, bạn hãy thực hiện theo các bước sau:

1. **Cho phép ứng dụng từ Mọi nơi**:
   - Mở ứng dụng **Terminal** trên Mac (`Command ⌘ + Space` -> gõ `Terminal`).
   - Nhập lệnh sau và nhấn `Enter`:
     ```bash
     sudo spctl --master-disable
     ```
   - Nhập mật khẩu máy Mac của bạn (khi gõ mật khẩu sẽ không hiển thị ký tự) và nhấn `Enter`.
   ![Screenshot](/DOCS/SCREENSHOTS/help0.png)

   - Mở **Cài đặt Hệ thống (System Settings)** -> **Quyền riêng tư & Bảo mật** -> cuộn xuống phần **Bảo mật**, bạn sẽ thấy tùy chọn **"Mọi nơi"** đã được bật.
   ![Screenshot](/DOCS/SCREENSHOTS/help4.png)

2. **[NẾU VẪN CHƯA MỞ ĐƯỢC ỨNG DỤNG] Xóa cờ Cách ly Quarantine**:
   - Trong **Terminal**, gõ lệnh sau để gỡ cờ bảo vệ cách ly của macOS đối với QuizMaster:
     ```bash
     xattr -cr /Applications/QuizMaster.app
     ```
3. Sau khi chạy lệnh trên, bạn có thể nhấp đúp chuột để mở và sử dụng **QuizMaster.app** bình thường.

## CHƯƠNG 2: QUÉT TÀI LIỆU & TẠO BỘ ĐỀ BẰNG GEMINI AI

1. Bấm nút **"Nhập Tài liệu / Bộ đề"**.
2. Chọn tệp bài giảng PDF, Word (`.docx`) hoặc văn bản TXT.
   - *💡 Lưu ý thời lượng quét:* Tài liệu càng dài thì Gemini AI phân tích và xử lý sẽ càng lâu. Bạn nên kiểm tra và rút gọn bớt các phần không cần thiết trước khi quét.
3. Nếu là tệp bài giảng thường: Bật toggle **"Tạo câu hỏi trắc nghiệm tự động"** và chọn chế độ phủ:
   - **Mặc định**: Cân đối theo độ dài tài liệu (~12-20 câu).
   - **Ý chính / Trọng tâm**: Tập trung vào chủ đề chính (~8-15 câu).
   - **Chi tiết toàn bộ**: Quét chuyên sâu từng định nghĩa, quy tắc và chi tiết (~35-60+ câu).   
![Screenshot](/DOCS/SCREENSHOTS/quizmaster6.png)
   **Lưu ý:** Nếu là tệp đề trắc nghiệm có sẵn: Không cần bật chế độ **"Tạo câu hỏi trắc nghiệm tự động"**, mà ứng dụng sẽ tự động trích xuất câu hỏi, câu trả lời, lời giải thích (nếu có) ở trong tài liệu.

4. Bấm **"Bắt đầu Quét với Gemini AI"** (Xác nhận trên hộp thoại kiểm tra chế độ quét).
![Screenshot](/DOCS/SCREENSHOTS/quizmaster8.png)

## CHƯƠNG 3: BA CHẾ ĐỘ ÔN TẬP VÀ THANH ĐIỀU HƯỚNG CÂU HỎI

0. Sau tạo bộ đề, nó sẽ xuất hiện ở trên màn hình chính của Dự án.
![Screenshot](/DOCS/SCREENSHOTS/quizmaster9.png)
1. **Chế độ Luyện tập**:
   - Làm trắc nghiệm có phản hồi đúng/sai tức thì.
   - **Lưu tiến độ tự động**: Tiến độ làm bài và vị trí câu đang làm được tự động lưu lại. Khi thoát ra và vào lại, bạn sẽ tiếp tục từ đúng câu dở dang.
   - **Thanh Điều hướng Câu hỏi**: Bảng bên phải hiển thị màu sắc câu hỏi (Xanh lá = Đúng, Đỏ = Sai, Xám = Chưa làm), bấm vào số câu để chuyển nhanh.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster11.png)
   - **Hỏi Gemini AI**: Bấm nút **"Hỏi Gemini AI về câu này"** để yêu cầu AI giải thích chi tiết đáp án.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster12.png)
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster13.png)

2. **Chế độ Thi thử**:
   - Môi trường thi thật không hiện đáp án đúng/sai và ẩn nút Hỏi AI để đảm bảo chống gian lận.
   - **Đồng hồ đếm giờ làm bài (Togglable Timer)**: Nhấn vào menu **"Đồng hồ"** ở góc phải thanh trên cùng để bật/tắt đếm ngược (tùy chọn 15, 30, 45, 60 phút). Khi hết giờ, bài thi sẽ tự động nộp.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster14.png)
   - Bấm **"Nộp bài thi"** để xem tổng kết điểm số và bảng phân tích đáp án chi tiết.
![Screenshot](/DOCS/SCREENSHOTS/quizmaster15.png)
![Screenshot](/DOCS/SCREENSHOTS/quizmaster16.png)
3. **Chế độ Thẻ ghi nhớ**:
   - Thẻ lật đánh dấu V (Thuộc) & X (Chưa thuộc).
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster17.png)
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster18.png)
   - Nút **"Thẻ trước"** cho phép quay lại thẻ vừa duyệt.
   - Các thẻ X được giữ lại để học lại ở các vòng 2, 3 cho tới khi thuộc 100%.
![Screenshot](/DOCS/SCREENSHOTS/quizmaster19.png)

## CHƯƠNG 4: QUẢN LÝ DỰ ÁN, BỘ ĐỀ THI & CÔNG TẮC XÁO TRỘN

1. **Tạo Dự án mới**: Nhấn nút `+` ở thanh Sidebar, nhập tên dự án (Ví dụ: *Ôn thi Lịch Sử*, *Tiếng Anh B1*).
![Screenshot](/DOCS/SCREENSHOTS/quizmaster5.png)
2. **Đổi tên Bộ đề**: Nhấn vào biểu tượng cây bút (✏️) trên thẻ bộ đề hoặc nhấp chuột phải chọn **"Đổi tên bộ đề"**.
3. **Chuyển Bộ đề sang Dự án khác**: Nhấn biểu tượng thư mục hoặc nhấp chuột phải chọn **"Chuyển sang Dự án khác..."**.
4. **Chọn nhiều Bộ đề**: Bấm nút **"Chọn nhiều bộ đề"** trên màn hình chính để đánh dấu checkbox và thực hiện xóa / chuyển hàng loạt.
5. **Công tắc Xáo trộn**: Bấm nút **"🔀 Xáo trộn câu hỏi & đáp án"** ở thanh công cụ chính để bật/tắt xáo trộn vị trí câu hỏi và phương án A/B/C/D.
6. **Đặt lại Tiến độ học**: Nhấp chuột phải vào Dự án hoặc Bộ đề thi chọn **"Đặt lại Tiến độ học"** để học lại từ đầu.


## CHƯƠNG 5: PHÍM TẮT BÀN PHÍM

| Chế độ | Phím tắt | Thao tác |
| :--- | :--- | :--- |
| **Luyện tập & Thi thử** | `A`, `B`, `C`, `D` (hoặc `1`, `2`, `3`, `4`) | Chọn phương án A, B, C, D |
| **Luyện tập & Thi thử** | `Enter (↵)` | Sang câu tiếp theo / Nộp bài |
| **Thi thử** | `Mũi tên Trái / Phải (← →)` | Di chuyển qua lại giữa các câu |
| **Thẻ ghi nhớ**| `Phím Cách (Spacebar ␣)` | Lật mặt trước / mặt sau của thẻ |
| **Thẻ ghi nhớ**| `Mũi tên Trái (←)` | Quay lại thẻ trước |
| **Thẻ ghi nhớ**| `Phím V` (hoặc `1`) | Đánh dấu thẻ **V - Đã thuộc** |
| **Thẻ ghi nhớ**| `Phím X` (hoặc `2`) | Đánh dấu thẻ **X - Chưa thuộc** |
| **Tất cả các chế độ** | `Delete (⌫)` | Thoát chế độ học về màn hình chính |


## CHƯƠNG PHỤ: XUẤT ĐỀ VÀ KIỂM TRA CẬP NHẬT

1. **Xuất Đề thi**: Nhấp chuột phải vào thẻ bộ đề thi để chọn:
   - **Xuất gói Zip (Mặc định - Hỗ trợ nhập lại)**: Xuất file zip chứa RTF và JSON có thể nạp lại vào ứng dụng.
   - **Xuất tệp Word (.docx)**: Xuất file Word chuẩn để in ấn ra giấy.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster21.png)
2. **Kiểm tra Cập nhật**: Vào Cài đặt ⚙️ bấm **"Kiểm tra Cập nhật"** để xem thông tin phiên bản mới nhất và tải về trực tiếp từ GitHub.
   ![Screenshot](/DOCS/SCREENSHOTS/quizmaster22.png)
