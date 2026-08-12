# 🎓 QuizMaster (v1.0.1)

> **Native macOS Self-Study & AI-Powered Multiple-Choice Quiz Generator**  
> *Developed by [@tozn607](https://github.com/tozn607)*

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

## 🇻🇳 Tiếng Việt: Tóm tắt Tính năng

**QuizMaster** là ứng dụng native trên macOS được biên dịch 100% bằng **Swift** và **SwiftUI**. Ứng dụng tích hợp mô hình AI **Gemini 3.5 Flash Lite** từ Google AI Studio giúp sinh viên, học sinh và giáo viên tự động quét tài liệu bài giảng (PDF, Word `.docx`, TXT) để tạo ra các bộ đề thi trắc nghiệm chất lượng cao.

### ✨ Tính năng Nổi bật:
- 🚀 **Native macOS App**: Chạy mượt mà trên Apple Silicon (M1/M2/M3/M4) & Intel Mac.
- 🔀 **100% Anti-Bias Choice Shuffling**: Tự động xáo trộn vị trí đáp án đúng ngẫu nhiên giữa A, B, C, D.
- 🎚 **Chế độ Chi tiết (Depth Mode)**: Normal, Core, Thorough (sinh từ 35 đến 60+ câu hỏi chi tiết).
- 📖 **3 Chế độ Ôn tập**: Luyện tập (Practice), Thi thử (Exam), Thẻ ghi nhớ (Flashcard 3D).
- 📁 **Quản lý & Chuyển Bộ đề**: Hỗ trợ Chọn nhiều (Multi-select) để xóa hoặc chuyển bộ đề sang dự án khác.
- 📁 **Hiển thị trong Finder**: Mở trực tiếp thư mục lưu trữ dữ liệu thực tế trên macOS.

---

## ⌨️ Phím tắt Bàn phím (Keyboard Shortcuts)

| Chế độ | Phím tắt | Thao tác |
| :--- | :--- | :--- |
| **Luyện tập & Thi thử** | `A`, `B`, `C`, `D` (hoặc `1`, `2`, `3`, `4`) | Chọn phương án A, B, C, D tương ứng |
| **Luyện tập & Thi thử** | `Enter (↵)` | Chuyển sang câu tiếp theo / Nộp bài thi |
| **Thi thử (Exam Mode)** | `Mũi tên Trái / Phải (← →)` | Di chuyển qua lại giữa các câu |
| **Thẻ ghi nhớ (Flashcard)**| `Phím Cách (Spacebar ␣)` | Lật mặt trước / mặt sau của thẻ |
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
