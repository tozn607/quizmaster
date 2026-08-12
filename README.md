<p align="center">
  <img src="AppIcon.png" width="128" height="128" alt="QuizMaster App Icon">
</p>

# 🎓 QuizMaster (v1.1.0)

> **Native macOS Self-Study & AI-Powered Multiple-Choice Quiz Generator**  
> *Developed by [@tozn607](https://github.com/tozn607)*

---

### 🚀 Quick Download / Tải ứng dụng ngay:

[![](https://img.shields.io/badge/⬇️_Download_Latest_macOS_Release-v1.1.0-brightgreen?style=for-the-badge&logo=apple)](https://github.com/tozn607/quizmaster/releases/latest)

👉 **[Click here to download the latest QuizMaster.app macOS release](https://github.com/tozn607/quizmaster/releases/latest)**

---

[![macOS Supported](https://img.shields.io/badge/macOS-13.0%2B-blue.svg)](https://apple.com)
[![Language](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![AI Powered](https://img.shields.io/badge/Gemini_AI-3.5_Flash_Lite-purple.svg)](https://aistudio.google.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 📚 Complete Documentation Links / Tài liệu Hướng dẫn

### 🇻🇳 Tiếng Việt:
- 📖 [Hướng dẫn Sử dụng Chi tiết (User Guide)](DOCS/HUONG_DAN_SU_DUNG_VI.md)
- 💡 [Giới thiệu Tổng quan Ứng dụng (App Introduction)](DOCS/GIOI_THIEU_UNG_DUNG_VI.md)

### 🇬🇧 English:
- 📖 [Detailed User Guide](DOCS/USER_GUIDE_EN.md)
- 💡 [Application Introduction](DOCS/INTRODUCTION_EN.md)

---

## 🇻🇳 Tiếng Việt: Tóm tắt Tính năng v1.1.0

**QuizMaster** là ứng dụng native trên macOS được biên dịch 100% bằng **Swift** và **SwiftUI**. Ứng dụng tích hợp mô hình AI **Gemini 3.5 Flash Lite** từ Google AI Studio giúp sinh viên, học sinh và giáo viên tự động quét tài liệu bài giảng (PDF, Word `.docx`, TXT) để tạo ra các bộ đề thi trắc nghiệm chất lượng cao.

### ✨ Tính năng Nổi bật trong v1.0.3:
- 🚀 **Native macOS System Accent Theme**: Sử dụng chuẩn màu hệ thống của macOS (System Accent Color) từ máy của người dùng.
- 🔀 **Công tắc Xáo trộn (Shuffling Toggle)**: Nút bật/tắt xáo trộn vị trí câu hỏi và phương án A/B/C/D ngay trên thanh công cụ chính.
- 📍 **Thanh Điều hướng Câu hỏi (Question Navigator)**: Bảng bên phải hiển thị danh sách câu hỏi theo màu trạng thái (Đúng, Sai, Đã thuộc, Chưa làm) giúp di chuyển nhanh giữa các câu.
- 💾 **Lưu vị trí Học tự động (Practice Checkpoint)**: Tự động lưu tiến độ làm bài luyện tập, cho phép thoát ra và quay lại đúng câu đang làm dở.
- 🃏 **Thẻ ghi nhớ 3D (3D Flashcard)**: Lật thẻ 3D mượt mà với nút "Thẻ trước" (Previous Card) xem lại lịch sử thẻ.
- 🚫 **Chế độ Thi thử Chống gian lận (Anti-Cheating Exam Mode)**: Môi trường thi thật không hiện đáp án và ẩn nút Hỏi AI.
- ✨ **Lưu Giải thích Hỏi Gemini AI**: Lưu trữ và tự động khôi phục các câu trả lời giải thích của AI khi ôn tập lại.
- 📁 **Quản lý & Chuyển Bộ đề**: Hỗ trợ Chọn nhiều (Multi-select) để xóa hoặc chuyển bộ đề sang dự án khác.
- 🔄 **Đặt lại Tiến độ (Progress Reset)**: Xóa tiến độ học của cả dự án hoặc từng bộ đề thi khi muốn ôn tập lại từ đầu.
- 🚀 **Kiểm tra Cập nhật Tự động**: Tích hợp màn hình xem thông tin bản cập nhật mới và tải về trực tiếp từ GitHub.

---

## ⌨️ Phím tắt Bàn phím (Keyboard Shortcuts)

| Chế độ | Phím tắt | Thao tác |
| :--- | :--- | :--- |
| **Luyện tập & Thi thử** | `A`, `B`, `C`, `D` (hoặc `1`, `2`, `3`, `4`) | Chọn phương án A, B, C, D tương ứng |
| **Luyện tập & Thi thử** | `Enter (↵)` | Chuyển sang câu tiếp theo / Nộp bài thi |
| **Thi thử (Exam Mode)** | `Mũi tên Trái / Phải (← →)` | Di chuyển qua lại giữa các câu |
| **Thẻ ghi nhớ (Flashcard)**| `Phím Cách (Spacebar ␣)` | Lật mặt trước / mặt sau của thẻ 3D |
| **Thẻ ghi nhớ (Flashcard)**| `Mũi tên Trái (←)` | Quay lại thẻ trước (Previous Card) |
| **Thẻ ghi nhớ (Flashcard)**| `Phím V` (hoặc `1`) | Đánh dấu thẻ **V - Đã thuộc** |
| **Thẻ ghi nhớ (Flashcard)**| `Phím X` (hoặc `2`) | Đánh dấu thẻ **X - Chưa thuộc** |
| **Tất cả các chế độ** | `Delete (⌫)` | Thoát chế độ học về màn hình chính |

---

## 🛠 Building from Source (macOS)

```bash
# Clone repository
git clone https://github.com/tozn607/quizmaster.git
cd quizmaster

# Build App Bundle
./build_app.sh

# Launch App
open QuizMaster.app
```

---

## 👤 Author & License

- **Author**: [@tozn607](https://github.com/tozn607)
- **License**: Released under the MIT License.
