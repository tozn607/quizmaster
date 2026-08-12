import SwiftUI
import AppKit

public struct PracticeView: View {
    let project: StudyProject
    let quiz: Quiz
    let redoWrongOnly: Bool
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    
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
    @State private var eventMonitor: Any? = nil
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
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
                .help("Bấm phím Delete để thoát")
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(quiz.title)
                        .font(.system(size: 16 * fontScale, weight: .bold))
                        .lineLimit(1)
                    
                    if !activeQuestions.isEmpty {
                        Text(String(format: loc.text("progressFormat"), "\(currentIndex + 1)", "\(activeQuestions.count)"))
                            .font(.system(size: 12 * fontScale, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Text(loc.text("scoreHiddenNote"))
                    .font(.system(size: 11 * fontScale))
                    .foregroundColor(.secondary)
                    .italic()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Progress Bar
            if !activeQuestions.isEmpty {
                ProgressBar(
                    value: Double(currentIndex + (isAnswered ? 1 : 0)) / Double(activeQuestions.count),
                    height: 6,
                    color: .blue
                )
            }
            
            Divider()
            
            // Question & Options Area
            if !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                let currentQuestion = activeQuestions[currentIndex]
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20 * fontScale) {
                        // Question Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10 * fontScale) {
                                HStack {
                                    BadgeView(text: "\(loc.text("questionHeader")) \(currentIndex + 1)", color: .blue)
                                    Spacer()
                                    
                                    Button(action: { askingGeminiQuestion = currentQuestion }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "sparkles")
                                            Text("Hỏi Gemini AI về câu này")
                                        }
                                        .font(.system(size: 12 * fontScale, weight: .semibold))
                                        .foregroundColor(.purple)
                                        .padding(.horizontal, 10 * fontScale)
                                        .padding(.vertical, 5 * fontScale)
                                        .background(Color.purple.opacity(0.12))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Hỏi Gemini 3.5 Flash Lite để nhận giải thích sâu hơn")
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
                                .foregroundColor(selectedOptionIndex == currentQuestion.correctAnswerIndex ? .green : .red)
                                
                                if !currentQuestion.explanation.isEmpty {
                                    Text(currentQuestion.explanation)
                                        .font(.system(size: 14 * fontScale))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 2)
                                }
                            }
                            .padding(14 * fontScale)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                (selectedOptionIndex == currentQuestion.correctAnswerIndex ? Color.green : Color.red).opacity(0.12)
                            )
                            .cornerRadius(12)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Footer Navigation
                HStack {
                    Text("Phím tắt: A/B/C/D (hoặc 1/2/3/4) chọn đáp án • Enter tiếp tục • Delete thoát")
                        .font(.system(size: 11 * fontScale))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if isAnswered {
                        PrimaryButton(
                            title: currentIndex + 1 < activeQuestions.count ? loc.text("nextQuestion") : loc.text("finishPractice"),
                            icon: currentIndex + 1 < activeQuestions.count ? "arrow.right" : "checkmark.seal.fill",
                            color: currentIndex + 1 < activeQuestions.count ? .blue : .green
                        ) {
                            advanceToNextQuestion()
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
            } else {
                Spacer()
                ProgressView()
                Spacer()
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
    
    // MARK: - Option Button Renderer (Clean A, B, C, D without brackets)
    private func optionButton(for option: QuestionOption, index: Int, question: Question) -> some View {
        let isSelected = selectedOptionIndex == index
        let isCorrect = index == question.correctAnswerIndex
        
        let bgColor: Color
        let borderColor: Color
        let textColor: Color
        
        if isAnswered {
            if isCorrect {
                bgColor = Color.green.opacity(0.2)
                borderColor = Color.green
                textColor = .green
            } else if isSelected && !isCorrect {
                bgColor = Color.red.opacity(0.2)
                borderColor = Color.red
                textColor = .red
            } else {
                bgColor = Color(NSColor.controlBackgroundColor)
                borderColor = Color.gray.opacity(0.25)
                textColor = .primary
            }
        } else if isSelected {
            bgColor = Color.blue.opacity(0.15)
            borderColor = Color.blue
            textColor = .primary
        } else {
            bgColor = Color(NSColor.controlBackgroundColor)
            borderColor = Color.gray.opacity(0.25)
            textColor = .primary
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
    
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
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
    
    private func setupQuizQuestions() {
        if redoWrongOnly, let prog = project.progressMap[quiz.id] {
            activeQuestions = quiz.questions.filter { prog.wrongQuestionIds.contains($0.id) }
            if activeQuestions.isEmpty { activeQuestions = quiz.questions }
            isRedoingWrong = true
            self.wrongQuestionIds.removeAll()
        } else {
            activeQuestions = quiz.questions
            isRedoingWrong = false
            if let prog = project.progressMap[quiz.id] {
                self.userAnswers = prog.userAnswers
                self.wrongQuestionIds = prog.wrongQuestionIds
            }
        }
        
        currentIndex = 0
        isAnswered = false
        selectedOptionIndex = nil
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
            isAnswered = false
            selectedOptionIndex = nil
        } else {
            isQuizFinished = true
            saveCurrentProgress(isCompleted: true)
            showFinishDialog = true
        }
    }
    
    private func saveCurrentProgress(isCompleted: Bool) {
        let prog = QuizProgress(
            quizId: quiz.id,
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
