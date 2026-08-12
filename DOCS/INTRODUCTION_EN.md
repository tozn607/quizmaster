# 💡 QUIZMASTER APPLICATION INTRODUCTION (v1.1.0)

Author: **@tozn607**  
Platform: Native macOS App (Swift & SwiftUI)

---

## 1. Executive Summary

**QuizMaster** is a native macOS application designed for self-study and automated multiple-choice quiz creation. Built with Apple's native Swift and SwiftUI frameworks, QuizMaster seamlessly transforms complex lecture materials into interactive practice tests, exam simulations, and 3D flashcards using authentic macOS Liquid Glass translucent window backdrops and vivid high-contrast aesthetics.

---

## 2. AI Technology & Core Algorithms in v1.1.0

- **Markdown Formatted Gemini AI Explanations**: Saved AI explanations in Practice Mode parse headers (`###`), bold text (`**...**`), section dividers (`---`), bullet points, and quotes (`> ...`) into formatted markdown text inside the explanation box.
- **Guaranteed Light Mode Readability**: 100% solid white card backgrounds with high-contrast dark label typography in Light Mode, eliminating white-on-white text glare.
- **100% Solid & Saturated `LiquidGlassPalette` Colors**: Vivid solid color fills for primary buttons, badges, and study modes (Ocean Blue, Sunset Orange, Deep Purple, Emerald Mint, Coral Red, Cyan Teal).
- **Authentic macOS Liquid Glass Window Backdrop**: Native `NSVisualEffectView` translucent behind-window backdrop with ambient light gradient mesh.
- **Rainbow Gradient App Icon**: Vibrant 6-color rainbow gradient background with a pure white graduation cap icon.
- **Gemini 3.5 Flash Lite Model**: Direct API integration via personal Google AI Studio API Keys.
- **Question & Option Shuffling Toggle**: User-controlled option and question randomization via a dedicated dashboard toggle.
- **Question Navigator Sidebar**: Color-coded right-side sidebar for instant question jumping and status visualization.
- **Automatic Practice Checkpoint Save**: Continuously saves question index and selected options so users can exit and resume practice tests smoothly.
- **Anti-Cheating Exam Mode**: Suppresses correct answers and AI assistance during test simulations.

---

## 3. Export & Import Capabilities

- **Zip Bundle (.zip)**: Packages RTF test files, answer keys, and JSON schemas. The only format supported for re-importing into QuizMaster.
- **Microsoft Word (.docx)**: Generates standard formatted Word documents suitable for offline printing and archiving.
