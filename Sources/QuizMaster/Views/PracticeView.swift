import SwiftUI
import AppKit

public struct PracticeView: View {
    let project: StudyProject
    let quiz: Quiz
    let redoWrongOnly: Bool
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.colorScheme) var colorScheme
    
    @State private var activeQuestions: [Question] = []
    @State private var currentIndex: Int = 0
    @State private var selectedOptionIndex: Int? = nil
    @State private var isAnswered: Bool = false
    
    // User progress state
    @State private var userAnswers: [String: Int] = [:]
    @State private var wrongQuestionIds: Set<String> = []
    @State private var isQuizFinished: Bool = false
    @State private var showFinishDialog: Bool = false
    @State private var showReviewView: Bool = false
    @State private var isRedoingWrong: Bool = false
    @State private var askingGeminiQuestion: Question? = nil
    @State private var showNavPane: Bool = true
    @State private var eventMonitor: Any? = nil
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        LiquidGlassWindowBackdrop {
            VStack(spacing: 0) {
                // Header Bar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(loc.text("quitQuiz"))
                        }
                        .font(.system(size: 13 * fontScale))
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(quiz.title)
                            .font(.system(size: 16 * fontScale, weight: .bold))
                            .lineLimit(1)
                        
                        if !activeQuestions.isEmpty {
                            Text(String(format: loc.text("progressFormat"), "\(currentIndex + 1)", "\(activeQuestions.count)"))
                                .font(.system(size: 12 * fontScale, weight: .bold))
                                .foregroundColor(LiquidGlassPalette.oceanBlue)
                        }
                    }
                    
                    Spacer()
                    
                    // Toggle Question Navigator Sidebar
                    Button(action: { withAnimation { showNavPane.toggle() } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sidebar.right")
                            Text(loc.text("questionNavPane"))
                        }
                        .font(.system(size: 12 * fontScale, weight: .medium))
                        .foregroundColor(showNavPane ? LiquidGlassPalette.oceanBlue : .secondary)
                        .padding(.horizontal, 8 * fontScale)
                        .padding(.vertical, 4 * fontScale)
                        .background(showNavPane ? LiquidGlassPalette.oceanBlue.opacity(0.12) : Color.clear)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(.thinMaterial)
                
                // Progress Bar (Progresses based on completed questions count)
                if !activeQuestions.isEmpty {
                    ProgressBar(
                        value: Double(userAnswers.count) / Double(activeQuestions.count),
                        height: 6,
                        color: LiquidGlassPalette.oceanBlue
                    )
                }
                
                Divider()
                
                // Main Question & Right Navigation Split View
                HStack(spacing: 0) {
                    // Left Question & Options Area
                    if !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                        let currentQuestion = activeQuestions[currentIndex]
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20 * fontScale) {
                                // Question Card
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 10 * fontScale) {
                                        HStack {
                                            BadgeView(text: "\(loc.text("questionHeader")) \(currentIndex + 1)", color: LiquidGlassPalette.oceanBlue)
                                            Spacer()
                                            
                                            Button(action: { askingGeminiQuestion = currentQuestion }) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "sparkles")
                                                    Text("Hỏi Gemini AI về câu này")
                                                }
                                                .font(.system(size: 12 * fontScale, weight: .semibold))
                                                .foregroundColor(LiquidGlassPalette.deepPurple)
                                                .padding(.horizontal, 10 * fontScale)
                                                .padding(.vertical, 5 * fontScale)
                                                .background(LiquidGlassPalette.deepPurple.opacity(0.12))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        Text(currentQuestion.text)
                                            .font(.system(size: 19 * fontScale, weight: .bold))
                                            .lineSpacing(4)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                // Option Buttons
                                VStack(spacing: 12 * fontScale) {
                                    ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { idx, option in
                                        optionButton(for: option, index: idx, question: currentQuestion)
                                    }
                                }
                                
                                // Explanation Banner (when answered)
                                if isAnswered {
                                    VStack(alignment: .leading, spacing: 8 * fontScale) {
                                        HStack {
                                            Image(systemName: selectedOptionIndex == currentQuestion.correctAnswerIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .font(.system(size: 18 * fontScale))
                                            Text(selectedOptionIndex == currentQuestion.correctAnswerIndex ? loc.text("correctAnswer") : loc.text("wrongAnswer"))
                                                .font(.system(size: 16 * fontScale, weight: .bold))
                                        }
                                        .foregroundColor(selectedOptionIndex == currentQuestion.correctAnswerIndex ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.coralRed)
                                        
                                        if !currentQuestion.explanation.isEmpty {
                                            Text(formattedMarkdownKey(currentQuestion.explanation))
                                                .font(.system(size: 14 * fontScale))
                                                .foregroundColor(colorScheme == .light ? Color(NSColor.labelColor) : Color.white)
                                                .padding(.top, 4 * fontScale)
                                        }
                                    }
                                    .padding(14 * fontScale)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        (selectedOptionIndex == currentQuestion.correctAnswerIndex ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.coralRed).opacity(0.18)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke((selectedOptionIndex == currentQuestion.correctAnswerIndex ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.coralRed), lineWidth: 1.5)
                                    )
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                                }
                            }
                            .padding()
                        }
                    } else {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    
                    // Right Navigation Pane Sidebar
                    if showNavPane && !activeQuestions.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12 * fontScale) {
                            Text(loc.text("questionNavPane"))
                                .font(.system(size: 13 * fontScale, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.top, 12 * fontScale)
                                .padding(.horizontal, 12 * fontScale)
                            
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40 * fontScale), spacing: 8 * fontScale)], spacing: 8 * fontScale) {
                                    ForEach(0..<activeQuestions.count, id: \.self) { idx in
                                        navButton(index: idx, question: activeQuestions[idx])
                                    }
                                }
                                .padding(.horizontal, 12 * fontScale)
                            }
                        }
                        .frame(width: 180 * fontScale)
                        .background(.ultraThinMaterial)
                    }
                }
                
                Divider()
                
                // Footer Navigation
                HStack {
                    Text("Phím tắt: A/B/C/D chọn đáp án • Enter tiếp tục • Delete thoát")
                        .font(.system(size: 11 * fontScale))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if isAnswered {
                        PrimaryButton(
                            title: currentIndex + 1 < activeQuestions.count ? loc.text("nextQuestion") : loc.text("finishPractice"),
                            icon: currentIndex + 1 < activeQuestions.count ? "arrow.right" : "checkmark.seal.fill",
                            color: currentIndex + 1 < activeQuestions.count ? LiquidGlassPalette.oceanBlue : LiquidGlassPalette.emeraldMint
                        ) {
                            advanceToNextQuestion()
                        }
                    }
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .sheet(isPresented: $showFinishDialog) {
            quizFinishDialog
        }
        .sheet(isPresented: $showReviewView) {
            ReviewView(quiz: quiz, questions: activeQuestions, userAnswers: userAnswers, wrongIds: wrongQuestionIds)
        }
        .sheet(item: $askingGeminiQuestion) { q in
            AskGeminiSheet(question: q)
        }
        .onAppear {
            setupQuizQuestions()
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
    }
    
    // MARK: - Option & Nav Button Renderers
    @ViewBuilder
    private func navButton(index: Int, question: Question) -> some View {
        let isCurrent = index == currentIndex
        let userAns = userAnswers[question.id]
        let btnColor: Color = isCurrent ? LiquidGlassPalette.oceanBlue : (userAns != nil ? (userAns == question.correctAnswerIndex ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.coralRed) : .gray.opacity(0.4))
        
        Button(action: {
            jumpToQuestion(index: index)
        }) {
            Text("\(index + 1)")
                .font(.system(size: 13 * fontScale, weight: .bold))
                .foregroundColor(isCurrent || userAns != nil ? .white : .primary)
                .frame(width: 38 * fontScale, height: 38 * fontScale)
                .background(btnColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCurrent ? LiquidGlassPalette.oceanBlue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func formattedMarkdownKey(_ rawText: String) -> LocalizedStringKey {
        var str = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("```markdown") { str = String(str.dropFirst(11)) }
        if str.hasPrefix("```") { str = String(str.dropFirst(3)) }
        if str.hasSuffix("```") { str = String(str.dropLast(3)) }
        
        let lines = str.components(separatedBy: "\n")
        let cleanedLines = lines.map { line -> String in
            var l = line.trimmingCharacters(in: .whitespaces)
            if l.hasPrefix("### ") { l = "**" + l.dropFirst(4) + "**" }
            else if l.hasPrefix("## ") { l = "**" + l.dropFirst(3) + "**" }
            else if l.hasPrefix("# ") { l = "**" + l.dropFirst(2) + "**" }
            if l == "---" || l == "***" || l == "___" { return "───────────────" }
            if l.hasPrefix("> ") { l = "💡 " + l.dropFirst(2) }
            return l
        }
        return LocalizedStringKey(cleanedLines.joined(separator: "\n"))
    }
    
    private func optionButton(for option: QuestionOption, index: Int, question: Question) -> some View {
        let isSelected = selectedOptionIndex == index
        let isCorrect = index == question.correctAnswerIndex
        
        let bgColor: Color
        let borderColor: Color
        let textColor: Color
        
        if isAnswered {
            if isCorrect {
                bgColor = LiquidGlassPalette.emeraldMint.opacity(0.22)
                borderColor = LiquidGlassPalette.emeraldMint
                textColor = LiquidGlassPalette.emeraldMint
            } else if isSelected && !isCorrect {
                bgColor = LiquidGlassPalette.coralRed.opacity(0.22)
                borderColor = LiquidGlassPalette.coralRed
                textColor = LiquidGlassPalette.coralRed
            } else {
                bgColor = colorScheme == .light ? Color.white : Color(NSColor.controlBackgroundColor)
                borderColor = colorScheme == .light ? Color.black.opacity(0.18) : Color.white.opacity(0.20)
                textColor = colorScheme == .light ? Color(NSColor.labelColor) : Color.white
            }
        } else if isSelected {
            bgColor = LiquidGlassPalette.oceanBlue.opacity(0.20)
            borderColor = LiquidGlassPalette.oceanBlue
            textColor = LiquidGlassPalette.oceanBlue
        } else {
            bgColor = colorScheme == .light ? Color.white : Color(NSColor.controlBackgroundColor)
            borderColor = colorScheme == .light ? Color.black.opacity(0.18) : Color.white.opacity(0.20)
            textColor = colorScheme == .light ? Color(NSColor.labelColor) : Color.white
        }
        
        return Button(action: {
            guard !isAnswered else { return }
            selectOption(index: index, question: question)
        }) {
            HStack(spacing: 14 * fontScale) {
                ZStack {
                    Circle()
                        .fill(borderColor.opacity(0.3))
                        .frame(width: 32 * fontScale, height: 32 * fontScale)
                    Text(option.label)
                        .font(.system(size: 14 * fontScale, weight: .bold))
                        .foregroundColor(textColor)
                }
                
                Text(option.text)
                    .font(.system(size: 15 * fontScale))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isAnswered {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 18 * fontScale))
                    } else if isSelected && !isCorrect {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 18 * fontScale))
                    }
                }
            }
            .padding(14 * fontScale)
            .background(bgColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isAnswered && (isCorrect || isSelected) ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }
    
    // MARK: - Keyboard Monitor (Disabled when AskGemini sheet is active!)
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Temporarily disable shortcuts if Ask Gemini sheet is open!
            guard askingGeminiQuestion == nil && !showFinishDialog && !showReviewView else {
                return event
            }
            
            let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
            
            if event.keyCode == 51 {
                dismiss()
                return nil
            }
            
            if event.keyCode == 36 {
                if isAnswered {
                    advanceToNextQuestion()
                }
                return nil
            }
            
            if !isAnswered && !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                let currentQuestion = activeQuestions[currentIndex]
                if chars == "a" || chars == "1" { selectOption(index: 0, question: currentQuestion); return nil }
                if chars == "b" || chars == "2" { selectOption(index: 1, question: currentQuestion); return nil }
                if chars == "c" || chars == "3" { selectOption(index: 2, question: currentQuestion); return nil }
                if chars == "d" || chars == "4" { selectOption(index: 3, question: currentQuestion); return nil }
            }
            
            return event
        }
    }
    
    private func removeKeyboardMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    // MARK: - Logic & Checkpoint Progress Restore
    private func setupQuizQuestions() {
        var rawQuestions: [Question]
        if redoWrongOnly, let prog = project.progressMap[quiz.id], !prog.wrongQuestionIds.isEmpty {
            rawQuestions = quiz.questions.filter { prog.wrongQuestionIds.contains($0.id) }
        } else {
            rawQuestions = quiz.questions
        }
        
        if storage.settings.isShuffleEnabled {
            rawQuestions = rawQuestions.shuffled().map { $0.shuffledWithRelabeledOptions() }
        }
        activeQuestions = rawQuestions
        
        // Restore checkpoint progress if exists!
        if let prog = project.progressMap[quiz.id] {
            self.userAnswers = prog.userAnswers
            self.wrongQuestionIds = prog.wrongQuestionIds
            
            // Checkpoint index restore
            if prog.currentIndex >= 0 && prog.currentIndex < activeQuestions.count {
                self.currentIndex = prog.currentIndex
            } else {
                self.currentIndex = 0
            }
        } else {
            self.currentIndex = 0
            self.userAnswers = [:]
            self.wrongQuestionIds = []
        }
        
        loadCurrentQuestionState()
    }
    
    private func loadCurrentQuestionState() {
        guard currentIndex < activeQuestions.count else { return }
        let currentQuestion = activeQuestions[currentIndex]
        if let ansIndex = userAnswers[currentQuestion.id] {
            selectedOptionIndex = ansIndex
            isAnswered = true
        } else {
            selectedOptionIndex = nil
            isAnswered = false
        }
    }
    
    private func jumpToQuestion(index: Int) {
        guard index >= 0 && index < activeQuestions.count else { return }
        currentIndex = index
        loadCurrentQuestionState()
        saveCurrentProgress(isCompleted: false)
    }
    
    private func selectOption(index: Int, question: Question) {
        guard index >= 0 && index < question.options.count else { return }
        selectedOptionIndex = index
        isAnswered = true
        userAnswers[question.id] = index
        
        if index != question.correctAnswerIndex {
            wrongQuestionIds.insert(question.id)
        }
        
        saveCurrentProgress(isCompleted: false)
    }
    
    private func advanceToNextQuestion() {
        if currentIndex + 1 < activeQuestions.count {
            currentIndex += 1
            loadCurrentQuestionState()
            saveCurrentProgress(isCompleted: false)
        } else {
            isQuizFinished = true
            saveCurrentProgress(isCompleted: true)
            showFinishDialog = true
        }
    }
    
    private func saveCurrentProgress(isCompleted: Bool) {
        let prog = QuizProgress(
            quizId: quiz.id,
            currentIndex: currentIndex,
            userAnswers: userAnswers,
            wrongQuestionIds: wrongQuestionIds,
            isCompleted: isCompleted
        )
        storage.saveProgress(projectId: project.id, progress: prog)
    }
    
    private var quizFinishDialog: some View {
        VStack(spacing: 20 * fontScale) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 48 * fontScale))
                .foregroundColor(.yellow)
            
            VStack(spacing: 6) {
                Text(loc.text("quizFinishedTitle"))
                    .font(.system(size: 20 * fontScale, weight: .bold))
                Text(loc.text("quizFinishedSubtitle"))
                    .font(.system(size: 14 * fontScale))
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(spacing: 12 * fontScale) {
                if !wrongQuestionIds.isEmpty {
                    PrimaryButton(
                        title: loc.text("btnRedoWrongOnly") + " (\(wrongQuestionIds.count) câu)",
                        icon: "arrow.triangle.2.circlepath",
                        color: .orange
                    ) {
                        showFinishDialog = false
                        let questionsToRedo = quiz.questions.filter { wrongQuestionIds.contains($0.id) }
                        activeQuestions = questionsToRedo.isEmpty ? quiz.questions : questionsToRedo
                        wrongQuestionIds.removeAll()
                        currentIndex = 0
                        isAnswered = false
                        selectedOptionIndex = nil
                    }
                }
                
                SecondaryButton(
                    title: loc.text("btnReviewWithAnswers"),
                    icon: "doc.text.magnifyingglass"
                ) {
                    showFinishDialog = false
                    showReviewView = true
                }
                
                PrimaryButton(title: "Thi lại từ đầu (Reset Quiz)", icon: "arrow.clockwise", color: LiquidGlassPalette.cyanTeal) {
                    showFinishDialog = false
                    storage.resetQuizProgress(projectId: project.id, quizId: quiz.id)
                    setupQuizQuestions()
                }
                
                Button(loc.text("backToDashboard")) {
                    showFinishDialog = false
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.system(size: 13 * fontScale))
                .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(width: 440 * fontScale)
    }
}
