# 📖 QUIZMASTER DETAILED USER GUIDE (v1.0.3)

Author: **@tozn607**  
Platform: macOS (Native Swift / SwiftUI)

---

## CHAPTER 1: INITIAL SETUP & API KEY CONFIGURATION

1. Launch **QuizMaster** on your Mac.
2. Click the **Settings (⚙️)** icon on the top header or sidebar.
3. Click **"Get API Key from Google AI Studio ↗"** to open your browser and generate a free API key (`https://aistudio.google.com/api-keys`).
4. Copy the API Key and paste it into **"Google AI Studio Key (Gemini API)"**.
5. Click **"Test API Key"** to verify connection (displays `✓ API Key is valid and active!`).
6. Customize App Font Size (Small, Medium, Large, X-Large), Color Theme (Light / Dark / System), and App Language (Vietnamese / English).
   - *💡 Note: Changing the app language to English will automatically instruct Gemini AI to generate all future quiz questions, options, and explanations in English.*

---

## CHAPTER 2: PHYSICAL KEYBOARD SHORTCUTS

| Study Mode | Keyboard Shortcut | Action |
| :--- | :--- | :--- |
| **Practice & Exam Mode** | `A`, `B`, `C`, `D` (or `1`, `2`, `3`, `4`) | Select option A, B, C, or D |
| **Practice & Exam Mode** | `Enter (↵)` | Advance to next question / Submit exam |
| **Exam Mode** | `Left / Right Arrows (← →)` | Navigate between questions |
| **Flashcard Mode** | `Spacebar (␣)` | Flip 3D flashcard front / back |
| **Flashcard Mode** | `Left Arrow (←)` | Navigate to previous card (Previous Card) |
| **Flashcard Mode** | `Key V` (or `1`) | Mark card as **V - Mastered** |
| **Flashcard Mode** | `Key X` (or `2`) | Mark card as **X - Need Review** |
| **All Modes** | `Delete (⌫)` | Exit study mode back to dashboard |

---

## CHAPTER 3: MANAGING PROJECTS, QUIZZES & SHUFFLING TOGGLE

1. **New Project**: Click `+` on the sidebar and enter a project name.
2. **Rename Quiz Set**: Click the pencil icon (✏️) on a quiz card or right-click and select **"Rename Quiz"**.
3. **Move Quiz Set**: Click the folder icon (`folder.arrow.up`) or right-click and select **"Move Quiz..."**.
4. **Select Multiple Quizzes (Multi-select)**: Click **"Select Multiple"** on the dashboard to select checkboxes and perform bulk delete or bulk move operations.
5. **Shuffling Toggle**: Click **"🔀 Shuffle Questions & Options"** on the main top toolbar to toggle question and option randomization on or off.
6. **Reset Progress**: Right-click any Project or Quiz set and choose **"Reset Progress"** to restart learning from zero.

---

## CHAPTER 4: DOCUMENT SCANNING WITH GEMINI AI

1. Click **"Import Document / Quiz"**.
2. Select a PDF, Word (`.docx`), or TXT file.
3. For regular lecture materials: Enable **"Auto-generate Multiple-Choice Quizzes"** and select **Depth Mode**:
   - **Normal**: Balanced question count (~12–20 questions).
   - **Core**: Focuses on main key ideas (~8–15 questions).
   - **Thorough**: In-depth coverage of every detail, rule, and definition (~35–60+ questions).
4. Click **"Start Scanning with Gemini AI"**.

---

## CHAPTER 5: THREE STUDY MODES & QUESTION NAVIGATOR

1. **Practice Mode**:
   - Multiple-choice testing with instant correct/incorrect feedback.
   - **Checkpoint Progress Save**: Your question index and answers are continuously saved. Exiting and returning resumes at your exact question checkpoint.
   - **Ask Gemini AI**: Click **"Ask Gemini AI about this question"** to get detailed AI explanations in clean formatted Markdown.
   - **Question Navigator**: The right-side sidebar displays color-coded status buttons (Green = Correct, Red = Wrong, Gray = Unanswered) for instant question jumping.

2. **Exam Mode**:
   - Real test environment with zero immediate feedback and AI assistance hidden to prevent cheating.
   - Click **"Submit Exam"** to view overall score breakdown and detailed answer review.

3. **Flashcard Mode**:
   - Smooth 3D flip cards with Mastered (V) and Need Review (X) tracking.
   - Click **"Previous Card"** (`Left Arrow ←`) to navigate backward through reviewed card history.
   - Un-mastered cards are recycled into study rounds 2 and 3 until 100% mastery is achieved.

---

## CHAPTER 6: EXPORTING & SOFTWARE UPDATES

1. **Exporting Quizzes**: Right-click any quiz set card to choose:
   - **Export Zip Bundle (Default - Importable)**: Exports a zip archive containing RTF and JSON files that can be imported back into QuizMaster.
   - **Export Word (.docx)**: Exports a formatted Microsoft Word document for paper printing.
2. **Software Updates**: Go to Settings ⚙️ and click **"Check for Updates"** to view release notes and download new releases directly from GitHub.
