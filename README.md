# 🎓 QuizMaster (v1.0.1)

> **Native macOS Self-Study & AI-Powered Multiple-Choice Quiz Generator**  
> *Developed by [@tozn607](https://github.com/tozn607)*

[![macOS Supported](https://img.shields.io/badge/macOS-13.0%2B-blue.svg)](https://apple.com)
[![Language](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![AI Powered](https://img.shields.io/badge/Gemini_AI-3.5_Flash_Lite-purple.svg)](https://aistudio.google.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 🌐 Readme Language Navigation / Ngôn ngữ Readme

- [🇻🇳 Tiếng Việt](#-tiếng-việt-hướng-dẫn-sử-dụng)
- [🇬🇧 English Guide](#-english-user-guide)

---

# 🇻🇳 Tiếng Việt: Hướng dẫn Sử dụng

## 1. Giới thiệu Tổng quan

**QuizMaster** là ứng dụng native trên hệ điều hành macOS được biên dịch 100% bằng **Swift** và **SwiftUI**. Ứng dụng tích hợp mô hình AI chuyên biệt **Gemini 3.5 Flash Lite** từ Google AI Studio giúp sinh viên, học sinh và giáo viên tự động quét tài liệu bài giảng (PDF, Word `.docx`, TXT) để tạo ra các bộ đề thi trắc nghiệm chất lượng cao, không thiên vị đáp án và có giải thích chi tiết.

### ✨ Các Tính năng Nổi bật:
- 🚀 **Native macOS App**: Chạy trực tiếp mượt mà trên Apple Silicon (M1/M2/M3/M4) & Intel Mac không cần Node.js/Python/Xcode setup.
- 🤖 **Tích hợp Gemini 3.5 Flash Lite**: Kết nối trực tiếp với Google AI Studio API Key cá nhân của bạn.
- 🔀 **100% Anti-Bias Option Shuffling**: Tự động xáo trộn vị trí đáp án đúng ngẫu nhiên giữa A, B, C, D (loại bỏ hoàn toàn thiên vị đáp án A).
- 🎚 **Chế độ Chi tiết (Depth Mode)**:
  - **Mặc định (Normal)**: Tạo số lượng câu hỏi cân đối theo độ dài văn bản (~12-20 câu).
  - **Ý chính / Trọng tâm (Core)**: Tập trung vào chủ đề chính và khái niệm cốt lõi (~8-15 câu).
  - **Chi tiết toàn bộ (Thorough)**: Quét chuyên sâu từng câu, từng định nghĩa và mốc thời gian để tạo bài thi chi tiết tối đa (~35-60+ câu).
- 📖 **3 Chế độ Ôn tập**:
  - **Luyện tập (Practice Mode)**: Nhận phản hồi đáp án đúng/sai tức thì + Nút "Hỏi Gemini AI về câu này".
  - **Thi thử (Exam Mode)**: Môi trường thi thật không hiện đáp án cho tới khi nộp bài.
  - **Thẻ ghi nhớ (Flashcard Mode)**: Thẻ 3D lật xem đáp án, đánh dấu V (Thuộc) & X (Chưa thuộc) với quy trình học đa vòng.
- ⌨️ **Hỗ trợ Phím tắt Bàn phím Vật lý**: Thao tác chọn đáp án, lật thẻ, chuyển câu nhanh chóng bằng bàn phím.
- 📄 **Xuất / Nhập Đa dạng**: Xuất file Zip Bundle (RTF + JSON) hoặc file Microsoft Word `.docx` chuẩn.
- 🔄 **Tự động Kiểm tra Cập nhật**: Kiểm tra phiên bản mới trực tiếp từ GitHub Releases API.

---

## 2. Bảng Phím tắt Bàn phím (Keyboard Shortcuts)

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

## 3. Hướng dẫn Cài đặt & Sử dụng

### Bước 1: Thiết lập API Key
1. Mở ứng dụng **QuizMaster**.
2. Nhấn vào biểu tượng ⚙️ **Cài đặt** ở góc trên bên phải.
3. Bấm nút **"Lấy API Key từ Google AI Studio ↗"** để lấy API Key miễn phí từ Google.
4. Dán API Key vào ô và nhấn **"Kiểm tra API Key"**.

### Bước 2: Quét Tài liệu Tạo Bộ đề thi
1. Nhấn nút **"+"** để tạo một Dự án học tập mới.
2. Bấm nút **"Nhập Tài liệu / Bộ đề"**.
3. Chọn tệp PDF, Word (`.docx`) hoặc TXT.
4. Nếu đây là tài liệu văn bản bài giảng thường: Bật toggle **"Tạo câu hỏi trắc nghiệm tự động"** và chọn **Depth Mode** (Normal / Core / Thorough).
5. Bấm **"Bắt đầu Quét với Gemini AI"** (Ứng dụng sẽ hiển thị hộp thoại xác nhận chế độ quét trước khi gửi).

---

# 🇬🇧 English User Guide

## 1. Overview

**QuizMaster** is a native macOS application built with **Swift** and **SwiftUI**. Powered by Google's **Gemini 3.5 Flash Lite** model via Google AI Studio API, QuizMaster automates document OCR scanning (PDF, Word `.docx`, TXT) to generate high-quality, un-biased multiple-choice quizzes with detailed educational explanations.

### ✨ Key Features:
- 🚀 **100% Native macOS App**: Runs natively on Apple Silicon (M1/M2/M3/M4) & Intel Macs with zero setup.
- 🤖 **Gemini 3.5 Flash Lite**: Direct integration with your personal Google AI Studio API Key.
- 🔀 **Anti-Bias Option Shuffling**: Correct choices are randomly shuffled across A, B, C, D to eliminate option A bias.
- 🎚 **Question Depth Modes**:
  - **Normal**: Balanced question count based on document length (~12–20 questions).
  - **Core**: Focuses on core concepts and main topics (~8–15 questions).
  - **Thorough**: Exhaustively covers every fact, definition, and date (~35–60+ detailed questions).
- 📖 **3 Study Modes**:
  - **Practice Mode**: Immediate answer feedback + "Ask Gemini AI About This Question" button.
  - **Exam Mode**: Realistic exam setup with no answers revealed until submission.
  - **Flashcard Mode**: 3D card flip with V (Mastered) & X (Review) multi-round deck progression.
- ⌨️ **Full Physical Keyboard Shortcuts Support**.
- 📄 **Export / Import**: Package quizzes into RTF Zip Bundles or native Microsoft Word `.docx` files.
- 🔄 **Automatic Update Checker**: Directly checks GitHub Releases for new updates.

---

## 2. Keyboard Shortcuts Reference

| Study Mode | Keyboard Shortcut | Action |
| :--- | :--- | :--- |
| **Practice & Exam Mode** | `A`, `B`, `C`, `D` (or `1`, `2`, `3`, `4`) | Select option A, B, C, or D |
| **Practice & Exam Mode** | `Enter (↵)` | Advance to next question / Submit exam |
| **Exam Mode** | `Left / Right Arrows (← →)` | Navigate between questions |
| **Flashcards** | `Spacebar (␣)` | Flip flashcard front / back |
| **Flashcards** | `Key V` (or `1`) | Mark card as **V - Mastered** |
| **Flashcards** | `Key X` (or `2`) | Mark card as **X - Need Review** |
| **All Modes** | `Delete (⌫)` | Exit current study mode |

---

## 🛠 Building from Source (macOS)

```bash
# Clone repository
git clone https://github.com/tozn607/quizmaster.git
cd quizmaster

# Build App Bundle & Documentation Word files
./build_app.sh

# Launch App
open QuizMaster.app
```

---

## 👤 Author & License

- **Author**: [@tozn607](https://github.com/tozn607)
- **License**: Released under the MIT License.
