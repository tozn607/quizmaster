# 📖 QUIZMASTER DETAILED USER GUIDE (v1.1.1)

Author: **@tozn607**  
Platform: macOS (Swift / SwiftUI Native)  
Date: **August 13, 2026**  
Target Version: **v1.1.1**


## CHAPTER 1: FIRST-TIME SETUP WIZARD & API KEY CONFIGURATION

When launching **QuizMaster.app** for the first time, the app automatically presents a 4-step **First-Time Setup Wizard**:

1. **Step 1: Welcome Screen**: Overview of QuizMaster's core features. Click **"Start Setup ➔"**.
2. **Step 2: Gemini AI API Key Setup**: 
   - Click **"Get API Key from Google AI Studio ↗"** to get a free Google API Key.
   - Paste the API Key into the field and click **"Test API Key"** (green message `✓ API Key is valid` confirms success).
   - Click **"Continue ➔"**.
   - *Why a personal API Key?:* Ensures user privacy and keeps the app 100% free and open-source without exceeding shared usage quotas.
3. **Step 3: Appearance, Language & Quick Guide**:
   - Customize App Language (Vietnamese / English), Color Theme (Light / Dark / System Default), and Font Size (Small, Medium, Large, X-Large).
   - Review the Quick Start guide summary and keyboard shortcuts.
4. **Step 4: Completion Screen 😊**:
   - Displays a cheerful completion screen with a smiley face `😊`. Click **"Get Started with QuizMaster 🚀"** to enter the main dashboard.

*(You can modify your API Key or Appearance settings anytime later by clicking **Settings (⚙️)** in the sidebar).*
1. Launch **QuizMaster** on your Mac.
2. Click the **Settings (⚙️)** icon in the top header or sidebar.
3. Click **"Get API Key from Google AI Studio ↗"** to open [Google's free API Key registration page](`https://aistudio.google.com/api-keys`).
4. In the top right corner, click **Create API Key**, name your key, select **Default Gemini Project**, copy the generated API Key, and paste it into **"Google AI Studio Key (Gemini API)"** inside the app.
5. Click **"Test API Key"** to verify connection (a green message `✓ API Key is valid` will appear).
6. Customize Font Size (Small, Medium, Large, X-Large), Color Theme (Light / Dark / System Default), and App Language (Vietnamese / English).
   - *💡 Note: Switching the app language to English will automatically instruct Gemini AI to generate all future quiz questions, options, and explanations in English.*

### 🛡️ Gatekeeper Setup & Allowing Apps from Anywhere:

When launching **QuizMaster.app** for the first time on macOS, if you encounter Gatekeeper warnings such as *“QuizMaster.app is damaged and can’t be opened”* or *“App cannot be opened because it is from an unidentified developer”*, follow these steps:

1. **Allow Apps from "Anywhere"**:
   - Open **Terminal** on your Mac (`Command ⌘ + Space` -> type `Terminal`).
   - Run the following command and press `Enter`:
     ```bash
     sudo spctl --master-disable
     ```
   - Enter your macOS admin password (characters will not appear as you type) and press `Enter`.
   - Open **System Settings** -> **Privacy & Security** -> scroll down to **Security**, and confirm that **"Anywhere"** is now enabled.

2. **[IF THE APP STILL CANNOT BE OPENED] Clear Quarantine Flags (Allow Direct Execution)**:
   - In **Terminal**, run the following command to clear macOS quarantine restrictions for QuizMaster:
     ```bash
     xattr -cr /Applications/QuizMaster.app
     ```
   - *If QuizMaster.app is located in your Downloads folder*:
     ```bash
     xattr -cr ~/Downloads/QuizMaster.app
     ```
3. After executing the command above, double-click **QuizMaster.app** to launch and run the app normally without any error messages!


## CHAPTER 2: DOCUMENT SCANNING & QUIZ CREATION WITH GEMINI AI

1. Click **"Import Document / Quiz"**.
2. Select lecture files in PDF, Word (`.docx`), or plain text (`TXT`) format.
3. For regular lecture files: Turn ON **"Auto-generate Multiple-Choice Quizzes"** and select a **Depth Mode**:
   - **Normal**: Balanced coverage based on document length (~12–20 questions).
   - **Core**: Focuses strictly on main topics and key concepts (~8–15 questions).
   - **Thorough**: In-depth scanning covering every definition, rule, and detail (~35–60+ questions).   

   **Warning:** For pre-existing quiz files: Keep **"Auto-generate Multiple-Choice Quizzes"** turned OFF. The app will automatically extract existing questions, answer keys, and explanations directly from the document.

4. Click **"Start Scanning with Gemini AI"** (Confirm on the scanning mode check dialog).


## CHAPTER 3: THREE STUDY MODES & QUESTION NAVIGATOR

0. Once created, the quiz set appears on your project dashboard.
1. **Practice Mode**:
   - Multiple-choice questions with instant correct/incorrect feedback.
   - **Checkpoint Progress Save**: Your progress and current question index are saved automatically. Returning later resumes at your exact spot.
   - **Ask Gemini AI**: Click **"Ask Gemini AI about this question"** for detailed AI explanations.
   - **Question Navigator**: The right sidebar displays question color statuses (Green = Correct, Red = Wrong, Gray = Unanswered); click any number to jump instantly.

2. **Exam Mode**:
   - Real test environment suppressing correct answers and hiding AI assistance to prevent cheating.
   - Click **"Submit Exam"** to view score summary and detailed answer breakdown.

3. **Flashcard Mode**:
   - 3D flip cards marked with V (Mastered) & X (Needs Review).
   - **"Previous Card"** button allows reviewing recently flipped cards.
   - Unmastered cards (X) are kept for review in round 2, 3 until 100% mastered.


## CHAPTER 4: PROJECT MANAGEMENT, QUIZ SETS & SHUFFLE TOGGLE

1. **Create New Project**: Click `+` on the sidebar, type project name (e.g., *History Prep*, *English B1*).
2. **Rename Quiz Set**: Click the pencil icon (✏️) on the quiz card or right-click and select **"Rename Quiz"**.
3. **Move Quiz Set**: Click the folder icon (`folder.arrow.up`) or right-click and select **"Move to Another Project..."**.
4. **Select Multiple Quizzes**: Click **"Select Multiple Quizzes"** on the main dashboard to check boxes and delete or move in bulk.
5. **Shuffle Toggle**: Click **"🔀 Shuffle Questions & Options"** on the main toolbar to turn question and option randomization ON or OFF.
6. **Reset Progress**: Right-click any Project or Quiz Set and select **"Reset Progress"** to restart learning from scratch.


## CHAPTER 5: KEYBOARD SHORTCUTS

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


## APPENDIX: EXPORTING & UPDATES

1. **Export Quiz**: Right-click a quiz card and select:
   - **Export Zip Bundle (Default - Importable)**: Exports a zip archive containing RTF and JSON files that can be re-imported into the app.
   - **Export Word (.docx)**: Exports a standard Word document suitable for printing.
2. **Check for Updates**: Go to Settings ⚙️ and click **"Check for Updates"** to view the latest version info and download directly from GitHub.
