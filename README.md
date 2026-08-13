<p align="center">
  <img src="AppIcon.png" width="128" height="128" alt="QuizMaster App Icon">
</p>

# 🎓 QuizMaster (v1.2.1)

[![macOS Supported](https://img.shields.io/badge/macOS-13.0%2B-blue.svg)](https://apple.com)
[![Language](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![AI Powered](https://img.shields.io/badge/Gemini_AI-3.5_Flash_Lite-purple.svg)](https://aistudio.google.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
> **Ứng dụng macOS tự học trắc nghiệm & tạo bộ câu hỏi với AI**  
> **Native macOS Self-Study & AI-Powered Multiple-Choice Quiz Generator**  
> *Phát triển bởi / Developed by [@tozn607](https://github.com/tozn607)*

---

### 🚀 Quick Download / Tải ứng dụng ngay:

[![](https://img.shields.io/badge/⬇️_Download_Latest_macOS_Release-v1.2.1-brightgreen?style=for-the-badge&logo=apple)](https://github.com/tozn607/quizmaster/releases/latest)

> 💡 **Khắc phục lỗi Mở ứng dụng lần đầu / Fix Gatekeeper Launch Warnings**:
> Mở **Terminal** và chạy 2 lệnh sau nếu macOS báo lỗi *"QuizMaster.app bị hỏng / damaged"*:
> 1. Bật tùy chọn Anywhere trong Quyền riêng tư & Bảo mật: `sudo spctl --master-disable`
> 2. Gỡ cờ cách ly: `xattr -cr /Applications/QuizMaster.app` (hoặc `xattr -cr QuizMaster.app`)

---

## 📚 Complete Documentation Links / Tài liệu Hướng dẫn

### 🇻🇳 Tiếng Việt:
- 📖 [Hướng dẫn Sử dụng Chi tiết (User Guide)](DOCS/HUONG_DAN_SU_DUNG_VI.md)
- 💡 [Giới thiệu Tổng quan Ứng dụng (App Introduction)](DOCS/GIOI_THIEU_UNG_DUNG_VI.md)

### 🇬🇧 English:
- 📖 [Detailed User Guide](DOCS/USER_GUIDE_EN.md)
- 💡 [Application Introduction](DOCS/INTRODUCTION_EN.md)


## 🇻🇳 Tiếng Việt: Tổng quan & Tính năng Nổi bật

**QuizMaster** là ứng dụng native trên macOS được biên dịch 100% bằng **Swift** và **SwiftUI**. Ứng dụng tích hợp mô hình AI **Gemini 3.5 Flash Lite** từ Google AI Studio giúp sinh viên, học sinh và giáo viên tự động quét tài liệu bài giảng (PDF, Word `.docx`, TXT) để tạo ra các bộ đề thi trắc nghiệm chất lượng cao.

### 🛡️ Về trách nhiệm sử dụng AI tạo sinh (Generative AI):
- **QuizMaster** được hỗ trợ biên soạn mã nguồn bằng model AI tạo sinh **Gemini 3.6 Flash**. Việc chỉnh sửa và kiểm nghiệm mã nguồn đều do con người (tác giả [@tozn607](https://github.com/tozn607)) thực hiện.
- Các nội dung khác được AI tạo sinh soạn thảo bao gồm: một phần của file README.md (file hiện tại), toàn bộ file giới thiệu (INTRODUTION_EN.md, GIOI_THIEU_UNG_DUNG_VI.md - được tạo tự động trong mỗi lần biên dịch ứng dụng). Tất cả các nội dung này đều đã được tác giả kiểm nghiệm, chỉnh sửa và chịu hoàn toàn trách nhiệm.  
- Các nội dung được chính tác giả soạn thảo với rất ít hoặc không sử dụng AI hỗ trợ bao gồm: phần **Về trách nhiệm sử dụng AI tạo sinh (Generative AI)** và phần còn lại của file README.md (file hiện tại), file hướng dẫn sử dụng (USER_GUIDE_EN.md, HUONG_DAN_SU_DUNG_VI.md) và tài liệu phát triển (DEVLOPER_GUIDE_EN.md, TÀI_LIỆU_PHÁT_TRIỂN_VI.md). 
- **Điều quan trọng nhất**, với vai trò là một sinh viên đang trong quá trình học tập, tất cả các nội dung do AI tạo ra đều **mang tính chất tham khảo và cần được kiểm nghiệm bởi người sử dụng** để đảm bảo tính chính xác và phù hợp.

### ✨ Các Tính năng Nổi bật của QuizMaster:
- 🤖 **Quét Tài liệu & Tạo Đề bằng AI**: Tự động chuyển đổi tài liệu bài giảng PDF, Word (`.docx`), TXT thành bộ đề trắc nghiệm hoàn chỉnh kèm đáp án và lời giải chi tiết.
- 🚀 **Giao diện Hướng dẫn Cấu hình 4 Bước (First-Time Setup Wizard)**: Hướng dẫn người dùng mới từ màn hình Chào mừng -> Cài đặt API Key Gemini AI -> Tùy chỉnh Giao diện/Ngôn ngữ & Hướng dẫn sử dụng -> Màn hình Hoàn tất 😊.
- 🎚️ **Mức độ Chi tiết Câu hỏi (Depth Modes)**: 3 chế độ quét linh hoạt: **Mặc định (Normal)** (~12-20 câu), **Ý chính / Trọng tâm (Core)** (~8-15 câu), **Chi tiết toàn bộ (Thorough)** (~35-60+ câu).
- 📝 **Định dạng Markdown Giải thích Gemini AI**: Lời giải AI trình bày chuẩn Markdown (`###`, `**bôi đậm**`, `---`, danh sách) trực tiếp trong hộp giải thích của màn hình Luyện tập.
- 🔀 **Công tắc Xáo trộn (Shuffling Toggle)**: Nút **"🔀 Xáo trộn câu hỏi & đáp án"** bật/tắt xáo trộn vị trí câu hỏi và các phương án A/B/C/D linh hoạt.
- 📍 **Thanh Điều hướng Câu hỏi (Question Navigator)**: Bảng bên phải hiển thị danh sách câu hỏi theo màu trạng thái (Đúng, Sai, Đã thuộc, Chưa làm) giúp di chuyển nhanh giữa các câu.
- 💾 **Lưu vị trí Học tự động (Practice Checkpoint)**: Tự động lưu tiến độ làm bài luyện tập, cho phép thoát ra và quay lại đúng câu đang làm dở.
- 🃏 **Thẻ ghi nhớ 3D (3D Flashcard)**: Lật thẻ 3D mượt mà với nút "Thẻ trước" (Previous Card) xem lại lịch sử thẻ. Khi kết thúc vòng học, màn hình tổng kết cho phép tiếp tục học các thẻ chưa thuộc hoặc học lại từ đầu.
- 🚫 **Chế độ Thi thử Chống gian lận (Anti-Cheating Exam Mode)**: Môi trường thi thật không hiện đáp án và ẩn nút Hỏi AI để đảm bảo đánh giá chính xác năng lực.
- ☀️ **Giao diện Liquid Glass & Tương phản Cao**: Nền kính mờ `NSVisualEffectView` chìm đắm xuyên qua hình nền macOS kết hợp nền thẻ 100% trắng mịn và chữ tối rõ nét trong Chế độ Sáng.
- 📁 **Quản lý & Chuyển Bộ đề**: Hỗ trợ Chọn nhiều (Multi-select) để xóa hoặc chuyển bộ đề sang dự án khác.
- 🔄 **Đặt lại Tiến độ (Progress Reset)**: Xóa tiến độ học của cả dự án hoặc từng bộ đề thi khi muốn ôn tập lại từ đầu.
- 🚀 **Kiểm tra Cập nhật Tự động**: Tích hợp màn hình xem thông tin bản cập nhật mới và tải về trực tiếp từ GitHub.

### ⌨️ Phím tắt Bàn phím (Keyboard Shortcuts)

| Chế độ | Phím tắt | Thao tác |
| :--- | :--- | :--- |
| **Luyện tập & Thi thử** | `A`, `B`, `C`, `D` (hoặc `1`, `2`, `3`, `4`) | Chọn phương án A, B, C, D |
| **Luyện tập & Thi thử** | `Enter (↵)` | Sang câu tiếp theo / Nộp bài |
| **Thi thử** | `Mũi tên Trái / Phải (← →)` | Di chuyển qua lại giữa các câu |
| **Thẻ ghi nhớ**| `Phím Cách (Spacebar ␣)` | Lật mặt trước / mặt sau của thẻ 3D |
| **Thẻ ghi nhớ**| `Mũi tên Trái (←)` | Quay lại thẻ trước |
| **Thẻ ghi nhớ**| `Phím V` (hoặc `1`) | Đánh dấu thẻ **V - Đã thuộc** |
| **Thẻ ghi nhớ**| `Phím X` (hoặc `2`) | Đánh dấu thẻ **X - Chưa thuộc** |
| **Tất cả các chế độ** | `Delete (⌫)` | Thoát chế độ học về màn hình chính |

---

## 🇬🇧 English: Overview & Key Features

**QuizMaster** is a native macOS application compiled 100% in **Swift** and **SwiftUI**. Powered by Google AI Studio's **Gemini 3.5 Flash Lite** model, QuizMaster automatically scans lecture materials (PDF, Word `.docx`, TXT) to create high-quality, interactive multiple-choice test sets.

### 🛡️ On Generative AI Responsibility & Transparency:
- **QuizMaster** was developed with codebase assistance from the **Gemini 3.6 Flash** generative AI model. All code modifications, review, and testing were performed by a human (author [@tozn607](https://github.com/tozn607)).
- Other content drafted with generative AI assistance includes: part of this `README.md` file, and the application overview files (`INTRODUCTION_EN.md`, `GIOI_THIEU_UNG_DUNG_VI.md`). All of this content has been thoroughly audited, edited, and is fully taken responsibility for by the author.
- Content written directly by the author with minimal or no AI assistance includes: the **On Generative AI Responsibility & Transparency** section and the remainder of this `README.md` file, the user guides (`USER_GUIDE_EN.md`, `HUONG_DAN_SU_DUNG_VI.md`), and development documentation (`DEVELOPER_GUIDE_EN.md`, `TAI_LIEU_PHAT_TRIEN_VI.md`).
- **Most importantly**, as a student in the learning process, all content generated by AI is intended **for reference purposes and should be verified by the user** to ensure accuracy and suitability.

### ✨ Key Features of QuizMaster:
- 🤖 **AI Document Scanning & Quiz Generation**: Automatically converts PDF, Word (`.docx`), and TXT lecture documents into complete multiple-choice quizzes with answer keys and detailed explanations.
- 🚀 **4-Step First-Time Setup Wizard**: Welcomes new users through Welcome -> Gemini AI API Key setup -> Appearance/Language & Quick User Guide -> Cheerful Completion Screen 😊.
- 🎚️ **Question Depth Modes**: 3 flexible scanning modes: **Normal** (~12–20 questions), **Core** (~8–15 questions), and **Thorough** (~35–60+ in-depth questions).
- 📝 **Markdown Formatted AI Explanations**: Gemini AI explanations render cleanly formatted headers (`###`), bold text (`**...**`), section dividers (`---`), and lists directly in the Practice Mode explanation box.
- 🔀 **Question & Option Shuffling Toggle**: Dedicated toolbar button to toggle question and option (A/B/C/D) randomization on or off.
- 📍 **Question Navigator Sidebar**: Color-coded right sidebar displaying question statuses (Green = Correct, Red = Wrong, Gray = Unanswered) for instant question navigation.
- 💾 **Automatic Practice Checkpoint Resume**: Automatically saves your practice progress and question index so you can exit and resume exactly where you left off.
- 🃏 **3D Flashcards with Round Summary**: 3D card flip animation with a Previous Card history button. When a round finishes, a summary screen prompts you to continue with unmastered cards or restart.
- 🚫 **Anti-Cheating Exam Mode**: Simulates real test conditions by suppressing correct answers and hiding AI assistance.
- ☀️ **Liquid Glass & High-Contrast Design**: Translucent `NSVisualEffectView` window backdrop with 100% solid card fills and dark high-contrast typography in Light Mode.
- 📁 **Multi-Select & Quiz Management**: Supports multi-select checkboxes to delete or move quiz sets across projects in bulk.
- 🔄 **Progress Reset**: Reset study progress for an entire project or specific quiz sets whenever you want a fresh start.
- 🚀 **Auto Update Checker**: Built-in update checker to view release notes and download new releases directly from GitHub.

### ⌨️ Physical Keyboard Shortcuts

| Study Mode | Keyboard Shortcut | Action |
| :--- | :--- | :--- |
| **Practice & Exam Mode** | `A`, `B`, `C`, `D` (or `1`, `2`, `3`, `4`) | Select option A, B, C, or D |
| **Practice & Exam Mode** | `Enter (↵)` | Next question / Submit exam |
| **Exam Mode** | `Left / Right Arrow (← →)` | Navigate between questions |
| **Flashcard Mode** | `Spacebar (␣)` | Flip front / back of 3D card |
| **Flashcard Mode** | `Left Arrow (←)` | Go back to previous card |
| **Flashcard Mode** | `V Key` (or `1`) | Mark card as **V - Mastered** |
| **Flashcard Mode** | `X Key` (or `2`) | Mark card as **X - Needs Review** |
| **All Modes** | `Delete (⌫)` | Exit study mode to dashboard |

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
