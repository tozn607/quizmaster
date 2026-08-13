<p align="center">
  <img src="AppIcon.png" width="128" height="128" alt="QuizMaster App Icon">
</p>

# QuizMaster (v1.2.2)

[![macOS Supported](https://img.shields.io/badge/macOS-13.0%2B-blue.svg)](https://apple.com)
[![Language](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![AI Powered](https://img.shields.io/badge/Gemini_AI-3.5_Flash_Lite-purple.svg)](https://aistudio.google.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> **Ứng dụng macOS tự học trắc nghiệm & tạo bộ câu hỏi với AI**  
> *Phát triển bởi [@tozn607](https://github.com/tozn607)*

---

### Tải ứng dụng ngay:

[![](https://img.shields.io/badge/Tải_trực_tiếp_QuizMaster.zip-Bản_Mới_Nhất-blue?style=for-the-badge&logo=apple)](https://github.com/tozn607/quizmaster/releases/latest/download/QuizMaster.zip)

> **Khắc phục lỗi mở ứng dụng lần đầu (Gatekeeper)**:  
> Mở **Terminal** và chạy 2 lệnh sau nếu macOS báo lỗi *"QuizMaster.app bị hỏng"*:  
> 1. Cho phép ứng dụng từ Mọi nơi: `sudo spctl --master-disable`  
> 2. Gỡ cờ cách ly: `xattr -cr /Applications/QuizMaster.app` (hoặc `xattr -cr QuizMaster.app`)

---

## Tài liệu Hướng dẫn

Nhấn vào đây: **[Hướng dẫn Sử dụng Chi tiết](DOCS/HUONG_DAN_SU_DUNG_VI.md)**

## Tổng quan & Tính năng Nổi bật

**QuizMaster** là ứng dụng native trên macOS được biên dịch 100% bằng **Swift** và **SwiftUI**. Ứng dụng tích hợp mô hình AI **Gemini 3.5 Flash Lite** từ Google AI Studio giúp sinh viên, học sinh và giáo viên tự động quét tài liệu bài giảng (PDF, Word `.docx`, TXT) để tạo ra các bộ đề thi trắc nghiệm chất lượng cao.

### Về trách nhiệm sử dụng AI tạo sinh (Generative AI):
- **QuizMaster** được hỗ trợ biên soạn mã nguồn bằng model AI tạo sinh **Gemini 3.6 Flash**. Việc chỉnh sửa và kiểm nghiệm mã nguồn đều do con người (tác giả [@tozn607](https://github.com/tozn607)) thực hiện.
- Các nội dung khác được AI tạo sinh soạn thảo bao gồm: một phần của file `README.md` (file hiện tại). Tất cả các nội dung này đều đã được tác giả kiểm nghiệm và chỉnh sửa.  
- Các nội dung được chính tác giả soạn thảo với rất ít hoặc không sử dụng AI hỗ trợ bao gồm: phần **Về trách nhiệm sử dụng AI tạo sinh (Generative AI)** và phần còn lại của file `README.md` (file hiện tại), file hướng dẫn sử dụng (`HUONG_DAN_SU_DUNG_VI.md`). 
- **Điều quan trọng nhất**, với vai trò là một sinh viên đang trong quá trình học tập, tác giả tin rằng tất cả các nội dung do AI tạo ra đều **mang tính chất tham khảo và cần được kiểm nghiệm bởi người sử dụng** để đảm bảo tính chính xác và phù hợp. Tác giả không chịu trách nhiệm về các sai sót có thể xảy ra khi người dùng sử dụng các nội dung do AI tạo ra.

### Các Tính năng Nổi bật:
- **Quét Tài liệu & Tạo Đề bằng AI**: Tự động chuyển đổi tài liệu bài giảng PDF, Word (`.docx`), TXT thành bộ đề trắc nghiệm hoàn chỉnh kèm đáp án và lời giải chi tiết.
- **Mức độ Chi tiết Câu hỏi**: 3 chế độ quét linh hoạt: **Mặc định** (~12-20 câu), **Ý chính / Trọng tâm** (~8-15 câu), **Chi tiết toàn bộ** (~35-60+ câu).
- **Thẻ ghi nhớ**: Lật thẻ mượt mà với nút "Thẻ trước" xem lại lịch sử thẻ. Khi kết thúc vòng học, màn hình tổng kết cho phép tiếp tục học các thẻ chưa thuộc hoặc học lại từ đầu.
- **Chế độ Thi thử Chống gian lận**: Môi trường thi thật không hiện đáp án và ẩn nút Hỏi AI để đảm bảo đánh giá chính xác năng lực.
- **Công tắc Xáo trộn**: Nút **"🔀 Xáo trộn câu hỏi & đáp án"** bật/tắt xáo trộn vị trí câu hỏi và các phương án A/B/C/D linh hoạt.
- **Thanh Điều hướng Câu hỏi**: Bảng bên phải hiển thị danh sách câu hỏi theo màu trạng thái (Đúng, Sai, Đã thuộc, Chưa làm) giúp di chuyển nhanh giữa các câu.
- **Lưu Vị trí Học Tự động**: Tự động lưu tiến độ làm bài luyện tập, cho phép thoát ra và quay lại đúng câu đang làm dở.
- **Đặt lại Tiến độ**: Xóa tiến độ học của cả dự án hoặc từng bộ đề thi khi muốn ôn tập lại từ đầu.
- **Kiểm tra Cập nhật Tự động**: Tích hợp màn hình xem thông tin bản cập nhật mới và tải về trực tiếp từ GitHub.

### Phím tắt Bàn phím

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

---

## Biên dịch từ Mã nguồn (macOS)

```bash
# Clone repository
git clone https://github.com/tozn607/quizmaster.git
cd quizmaster

# Biên dịch App Bundle
./build_app.sh

# Chạy ứng dụng
open QuizMaster.app
```

---

## Tác giả & Giấy phép

- **Tác giả**: [@tozn607](https://github.com/tozn607)
- **Giấy phép**: Phát hành theo giấy phép MIT.
