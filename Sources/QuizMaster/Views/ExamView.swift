import SwiftUI
import AppKit

public struct ExamView: View {
    let project: StudyProject
    let quiz: Quiz
    let redoWrongOnly: Bool
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    
    @State private var activeQuestions: [Question] = []
    @State private var currentIndex: Int = 0
    @State private var userAnswers: [String: Int] = [:]
    @State private var wrongQuestionIds: Set<String> = []
    
    @State private var isExamFinished: Bool = false
    @State private var showFinishDialog: Bool = false
    @State private var showReviewView: Bool = false
    @State private var eventMonitor: Any? = nil
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Thoát bài thi")
                    }
                    .font(.system(size: 13 * fontScale))
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Bấm phím Delete để thoát")
                
                Spacer()
                
                VStack(spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(.orange)
                        Text("Thi thử (Exam Mode): \(quiz.title)")
                            .font(.system(size: 16 * fontScale, weight: .bold))
                            .lineLimit(1)
                    }
                    
                    if !activeQuestions.isEmpty {
                        Text("Đã trả lời \(userAnswers.count) / \(activeQuestions.count) câu")
                            .font(.system(size: 12 * fontScale, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                PrimaryButton(title: "Nộp bài thi", icon: "paperplane.fill", color: .orange) {
                    submitExam()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Progress Bar
            if !activeQuestions.isEmpty {
                ProgressBar(
                    value: Double(userAnswers.count) / Double(activeQuestions.count),
                    height: 6,
                    color: .orange
                )
            }
            
            Divider()
            
            // Question & Options Area
            if !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                let currentQuestion = activeQuestions[currentIndex]
                let selectedOption = userAnswers[currentQuestion.id]
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20 * fontScale) {
                        // Question Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10 * fontScale) {
                                HStack {
                                    BadgeView(text: "Câu \(currentIndex + 1) / \(activeQuestions.count)", color: .orange)
                                    Spacer()
                                    if selectedOption != nil {
                                        BadgeView(text: "Đã chọn đáp án", color: .blue)
                                    } else {
                                        BadgeView(text: "Chưa trả lời", color: .gray)
                                    }
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
                                optionButton(for: option, index: idx, question: currentQuestion, selectedOption: selectedOption)
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Footer Navigation
                HStack {
                    Text("Phím tắt: A/B/C/D (hoặc 1/2/3/4) chọn đáp án • ← → di chuyển • Enter nộp bài • Delete thoát")
                        .font(.system(size: 11 * fontScale))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if currentIndex > 0 {
                        SecondaryButton(title: "Câu trước", icon: "arrow.left") {
                            currentIndex -= 1
                        }
                    }
                    
                    if currentIndex + 1 < activeQuestions.count {
                        PrimaryButton(title: "Câu tiếp", icon: "arrow.right", color: .blue) {
                            currentIndex += 1
                        }
                    } else {
                        PrimaryButton(title: "Nộp bài thi thử", icon: "checkmark.seal.fill", color: .green) {
                            submitExam()
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
            examFinishDialog
        }
        .sheet(isPresented: $showReviewView) {
            ReviewView(quiz: quiz, questions: activeQuestions, userAnswers: userAnswers, wrongIds: wrongQuestionIds)
        }
        .onAppear {
            setupExamQuestions()
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
    }
    
    private func optionButton(for option: QuestionOption, index: Int, question: Question, selectedOption: Int?) -> some View {
        let isSelected = selectedOption == index
        
        let bgColor = isSelected ? Color.blue.opacity(0.18) : Color(NSColor.controlBackgroundColor)
        let borderColor = isSelected ? Color.blue : Color.gray.opacity(0.25)
        let textColor = isSelected ? Color.blue : Color.primary
        
        return Button(action: {
            userAnswers[question.id] = index
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
                
                if isSelected {
                    Image(systemName: "largecircle.fill.circle")
                        .foregroundColor(.blue)
                        .font(.system(size: 18 * fontScale))
                }
            }
            .padding(14 * fontScale)
            .background(bgColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
            
            if event.keyCode == 51 {
                dismiss()
                return nil
            }
            
            if event.keyCode == 123 && currentIndex > 0 {
                currentIndex -= 1
                return nil
            }
            
            if event.keyCode == 124 && currentIndex + 1 < activeQuestions.count {
                currentIndex += 1
                return nil
            }
            
            if event.keyCode == 36 {
                if currentIndex + 1 < activeQuestions.count {
                    currentIndex += 1
                } else {
                    submitExam()
                }
                return nil
            }
            
            if !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                let currentQuestion = activeQuestions[currentIndex]
                if chars == "a" || chars == "1" { userAnswers[currentQuestion.id] = 0; return nil }
                if chars == "b" || chars == "2" { userAnswers[currentQuestion.id] = 1; return nil }
                if chars == "c" || chars == "3" { userAnswers[currentQuestion.id] = 2; return nil }
                if chars == "d" || chars == "4" { userAnswers[currentQuestion.id] = 3; return nil }
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
    
    private func setupExamQuestions() {
        if redoWrongOnly, let prog = project.progressMap[quiz.id] {
            activeQuestions = quiz.questions.filter { prog.wrongQuestionIds.contains($0.id) }
            if activeQuestions.isEmpty { activeQuestions = quiz.questions }
        } else {
            activeQuestions = quiz.questions
        }
        currentIndex = 0
        userAnswers = [:]
        wrongQuestionIds = []
    }
    
    private func submitExam() {
        var wrongs = Set<String>()
        for q in activeQuestions {
            let ans = userAnswers[q.id]
            if ans != q.correctAnswerIndex {
                wrongs.insert(q.id)
            }
        }
        self.wrongQuestionIds = wrongs
        
        let prog = QuizProgress(
            quizId: quiz.id,
            userAnswers: userAnswers,
            wrongQuestionIds: wrongQuestionIds,
            isCompleted: true
        )
        storage.saveProgress(projectId: project.id, progress: prog)
        
        isExamFinished = true
        showFinishDialog = true
    }
    
    private var examFinishDialog: some View {
        let total = activeQuestions.count
        let correctCount = total - wrongQuestionIds.count
        let accuracyPercent = total > 0 ? Int((Double(correctCount) / Double(total)) * 100.0) : 0
        
        return VStack(spacing: 20 * fontScale) {
            Image(systemName: accuracyPercent >= 80 ? "trophy.fill" : "checkmark.seal.fill")
                .font(.system(size: 54 * fontScale))
                .foregroundColor(accuracyPercent >= 80 ? .yellow : .blue)
            
            VStack(spacing: 6) {
                Text("Kết quả Bài Thi Thử")
                    .font(.system(size: 20 * fontScale, weight: .bold))
                Text(quiz.title)
                    .font(.system(size: 14 * fontScale))
                    .foregroundColor(.secondary)
            }
            
            GlassCard {
                VStack(spacing: 14 * fontScale) {
                    HStack(spacing: 14 * fontScale) {
                        statTile(title: "Điểm số", value: "\(accuracyPercent)%", color: accuracyPercent >= 70 ? .green : .orange)
                        statTile(title: "Trả lời Đúng", value: "\(correctCount) / \(total)", color: .blue)
                        statTile(title: "Trả lời Sai", value: "\(wrongQuestionIds.count)", color: .red)
                    }
                }
            }
            
            Divider()
            
            VStack(spacing: 12 * fontScale) {
                if !wrongQuestionIds.isEmpty {
                    PrimaryButton(
                        title: "Thi lại các câu làm SAI (\(wrongQuestionIds.count) câu)",
                        icon: "arrow.triangle.2.circlepath",
                        color: .orange
                    ) {
                        showFinishDialog = false
                        let questionsToRedo = quiz.questions.filter { wrongQuestionIds.contains($0.id) }
                        activeQuestions = questionsToRedo.isEmpty ? quiz.questions : questionsToRedo
                        userAnswers.removeAll()
                        wrongQuestionIds.removeAll()
                        currentIndex = 0
                    }
                }
                
                SecondaryButton(
                    title: "Xem lại đáp án chi tiết & giải thích",
                    icon: "doc.text.magnifyingglass"
                ) {
                    showFinishDialog = false
                    showReviewView = true
                }
                
                PrimaryButton(title: "Thi lại từ đầu", icon: "arrow.clockwise", color: .purple) {
                    showFinishDialog = false
                    setupExamQuestions()
                }
                
                Button(loc.text("backToDashboard")) {
                    showFinishDialog = false
                    dismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 13 * fontScale))
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(width: 440 * fontScale)
    }
    
    @ViewBuilder
    private func statTile(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20 * fontScale, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12 * fontScale))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10 * fontScale)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
