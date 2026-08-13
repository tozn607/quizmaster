import SwiftUI
import AppKit

public struct ExamView: View {
    let project: StudyProject
    let quiz: Quiz
    let redoWrongOnly: Bool
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var activeQuestions: [Question] = []
    @State private var currentIndex: Int = 0
    @State private var userAnswers: [String: Int] = [:] // questionId -> selectedOptionIndex
    @State private var showEndingView: Bool = false
    @State private var showNavPane: Bool = false
    @State private var askingGeminiQuestion: Question? = nil
    @State private var eventMonitor: Any? = nil
    
    @State private var isTimerEnabled: Bool = false
    @State private var timeRemainingSeconds: Int = 1800 // default 30 mins
    @State private var isTimeUp: Bool = false
    @State private var showCustomTimerSheet: Bool = false
    @State private var customTimerInputMinutes: String = "20"
    @State private var timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                        Text("\(quiz.title) • Thi thử")
                            .font(.system(size: 16 * fontScale, weight: .bold))

                        
                        if !activeQuestions.isEmpty {
                            Text(String(format: loc.text("progressFormat"), "\(currentIndex + 1)", "\(activeQuestions.count)"))
                                .font(.system(size: 12 * fontScale, weight: .bold))
                                .foregroundColor(LiquidGlassPalette.sunsetOrange)
                        }
                    }
                    
                    Spacer()
                    
                    // Togglable Exam Timer Control Menu
                    Menu {
                        Button(isTimerEnabled ? loc.text("disableTimer") : loc.text("enableTimer")) {
                            withAnimation { isTimerEnabled.toggle() }
                        }
                        
                        Divider()
                        
                        Button(loc.text("timer15m")) { setTimerDuration(minutes: 15) }
                        Button(loc.text("timer45m")) { setTimerDuration(minutes: 45) }
                        Button(loc.text("timerPomodoro")) { setTimerDuration(minutes: 25) }
                        Button(loc.text("timerCustom")) { showCustomTimerSheet = true }
                    } label: {
                        HStack(spacing: 4 * fontScale) {
                            Image(systemName: isTimerEnabled ? "timer.circle.fill" : "timer")
                                .font(.system(size: 14 * fontScale))
                                .foregroundColor(isTimerEnabled ? (timeRemainingSeconds <= 300 ? LiquidGlassPalette.coralRed : LiquidGlassPalette.sunsetOrange) : .secondary)
                            
                            if isTimerEnabled {
                                Text(formattedTimeString)
                                    .font(.system(size: 13 * fontScale, weight: .bold))
                                    .foregroundColor(timeRemainingSeconds <= 300 ? LiquidGlassPalette.coralRed : LiquidGlassPalette.sunsetOrange)
                            } else {
                                Text(loc.text("examTimerLabel"))
                                    .font(.system(size: 12 * fontScale, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 8 * fontScale)
                        .padding(.vertical, 4 * fontScale)
                        .background(isTimerEnabled ? (timeRemainingSeconds <= 300 ? LiquidGlassPalette.coralRed.opacity(0.12) : LiquidGlassPalette.sunsetOrange.opacity(0.12)) : Color.clear)
                        .cornerRadius(6)
                    }
                    .menuStyle(.borderlessButton)
                    .help(loc.text("examTimerHelp"))
                    
                    // Toggle Question Navigator Sidebar
                    Button(action: { withAnimation { showNavPane.toggle() } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sidebar.right")
                            Text(loc.text("questionNavPane"))
                        }
                        .font(.system(size: 12 * fontScale, weight: .medium))
                        .foregroundColor(showNavPane ? LiquidGlassPalette.sunsetOrange : .secondary)
                        .padding(.horizontal, 8 * fontScale)
                        .padding(.vertical, 4 * fontScale)
                        .background(showNavPane ? LiquidGlassPalette.sunsetOrange.opacity(0.12) : Color.clear)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(.thinMaterial)
                
                // Progress Bar
                if !activeQuestions.isEmpty {
                    ProgressBar(
                        value: Double(userAnswers.count) / Double(activeQuestions.count),
                        height: 6,
                        color: LiquidGlassPalette.sunsetOrange
                    )
                }
                
                Divider()
                
                // Main Question & Right Navigation Split View
                HStack(spacing: 0) {
                    // Left Question Area
                    if !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                        let currentQuestion = activeQuestions[currentIndex]
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20 * fontScale) {
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 10 * fontScale) {
                                        HStack {
                                            BadgeView(text: "\(loc.text("questionHeader")) \(currentIndex + 1)", color: LiquidGlassPalette.sunsetOrange)
                                            Spacer()
                                        }
                                        
                                        Text(currentQuestion.text)
                                            .font(.system(size: 19 * fontScale, weight: .bold))
                                            .lineSpacing(4)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                VStack(spacing: 12 * fontScale) {
                                    ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { idx, option in
                                        optionButton(for: option, index: idx, question: currentQuestion)
                                    }
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
                    HStack(spacing: 12 * fontScale) {
                        SecondaryButton(title: "Câu trước (←)", icon: "arrow.left") {
                            if currentIndex > 0 { currentIndex -= 1 }
                        }
                        .disabled(currentIndex == 0)
                        
                        SecondaryButton(title: "Câu sau (→)", icon: "arrow.right") {
                            if currentIndex + 1 < activeQuestions.count { currentIndex += 1 }
                        }
                        .disabled(currentIndex + 1 >= activeQuestions.count)
                    }
                    
                    Spacer()
                    
                    PrimaryButton(
                        title: "Nộp bài thi (\(userAnswers.count)/\(activeQuestions.count) câu)",
                        icon: "checkmark.seal.fill",
                        color: LiquidGlassPalette.sunsetOrange
                    ) {
                        submitExam()
                    }
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .sheet(isPresented: $showEndingView) {
            if let prog = project.progressMap[quiz.id] {
                EndingView(project: project, quiz: quiz, progress: prog)
            }
        }
        .sheet(item: $askingGeminiQuestion) { q in
            AskGeminiSheet(question: q)
        }
        .sheet(isPresented: $showCustomTimerSheet) {
            VStack(spacing: 16 * fontScale) {
                Text(loc.text("customTimerTitle"))
                    .font(.system(size: 16 * fontScale, weight: .bold))
                
                Text(loc.text("customTimerSubtitle"))
                    .font(.system(size: 12 * fontScale))
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("20", text: $customTimerInputMinutes)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .frame(width: 80)
                    Text("phút")
                        .font(.system(size: 13 * fontScale))
                }
                
                HStack(spacing: 12 * fontScale) {
                    SecondaryButton(title: loc.text("cancel"), icon: "xmark") {
                        showCustomTimerSheet = false
                    }
                    
                    PrimaryButton(title: loc.text("confirm"), icon: "checkmark", color: LiquidGlassPalette.sunsetOrange) {
                        if let mins = Int(customTimerInputMinutes.trimmingCharacters(in: .whitespacesAndNewlines)), mins > 0 {
                            setTimerDuration(minutes: mins)
                        }
                        showCustomTimerSheet = false
                    }
                }
            }
            .padding(20 * fontScale)
            .frame(width: 320)
        }
        .onAppear {
            setupExamQuestions()
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
        .onChange(of: showCustomTimerSheet) { isShowing in
            if isShowing {
                removeKeyboardMonitor()
            } else {
                setupKeyboardMonitor()
            }
        }
        .onReceive(timerPublisher) { _ in
            guard isTimerEnabled && !showEndingView else { return }
            if timeRemainingSeconds > 0 {
                timeRemainingSeconds -= 1
            } else if !isTimeUp {
                isTimeUp = true
                submitExam()
            }
        }
    }
    
    private var formattedTimeString: String {
        let minutes = timeRemainingSeconds / 60
        let seconds = timeRemainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func setTimerDuration(minutes: Int) {
        timeRemainingSeconds = minutes * 60
        isTimerEnabled = true
    }
    
    private func setupExamQuestions() {
        let wrongIds = project.progressMap[quiz.id]?.wrongQuestionIds ?? []
        let hasWrongOnlyFilter = redoWrongOnly && !wrongIds.isEmpty
        
        if storage.settings.isShuffleEnabled {
            if let existingShuffled = project.progressMap[quiz.id]?.shuffledQuestions, !existingShuffled.isEmpty {
                if hasWrongOnlyFilter {
                    activeQuestions = existingShuffled.filter { wrongIds.contains($0.id) }
                } else {
                    activeQuestions = existingShuffled
                }
            } else {
                let newShuffled = quiz.questions.shuffled().map { $0.shuffledWithRelabeledOptions() }
                var prog = project.progressMap[quiz.id] ?? QuizProgress(quizId: quiz.id)
                prog.shuffledQuestions = newShuffled
                storage.saveProgress(projectId: project.id, progress: prog)
                
                if hasWrongOnlyFilter {
                    activeQuestions = newShuffled.filter { wrongIds.contains($0.id) }
                } else {
                    activeQuestions = newShuffled
                }
            }
        } else {
            if hasWrongOnlyFilter {
                activeQuestions = quiz.questions.filter { wrongIds.contains($0.id) }
            } else {
                activeQuestions = quiz.questions
            }
        }
    }
    
    // MARK: - Navigation Button Renderer
    @ViewBuilder
    private func navButton(index: Int, question: Question) -> some View {
        let isCurrent = index == currentIndex
        let isAnswered = userAnswers[question.id] != nil
        let btnColor: Color = isCurrent ? LiquidGlassPalette.sunsetOrange : (isAnswered ? LiquidGlassPalette.sunsetOrange.opacity(0.7) : .gray.opacity(0.4))
        
        Button(action: {
            currentIndex = index
        }) {
            Text("\(index + 1)")
                .font(.system(size: 13 * fontScale, weight: .bold))
                .foregroundColor(isCurrent || isAnswered ? .white : .primary)
                .frame(width: 38 * fontScale, height: 38 * fontScale)
                .background(btnColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCurrent ? LiquidGlassPalette.sunsetOrange : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func optionButton(for option: QuestionOption, index: Int, question: Question) -> some View {
        let isSelected = userAnswers[question.id] == index
        
        let bgColor = isSelected ? LiquidGlassPalette.sunsetOrange.opacity(0.20) : (colorScheme == .light ? Color.white : Color(NSColor.controlBackgroundColor))
        let borderColor = isSelected ? LiquidGlassPalette.sunsetOrange : (colorScheme == .light ? Color.black.opacity(0.18) : Color.white.opacity(0.20))
        let textColor = isSelected ? LiquidGlassPalette.sunsetOrange : (colorScheme == .light ? Color(NSColor.labelColor) : Color.white)
        
        return Button(action: {
            userAnswers[question.id] = index
        }) {
            HStack(spacing: 14 * fontScale) {
                ZStack {
                    Circle()
                        .fill(isSelected ? LiquidGlassPalette.sunsetOrange.opacity(0.3) : Color.gray.opacity(0.15))
                        .frame(width: 32 * fontScale, height: 32 * fontScale)
                    Text(option.label)
                        .font(.system(size: 14 * fontScale, weight: .bold))
                        .foregroundColor(textColor)
                }
                
                Text(option.text)
                    .font(.system(size: 15 * fontScale))
                    .foregroundColor(colorScheme == .light ? Color(NSColor.labelColor) : Color.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(LiquidGlassPalette.sunsetOrange)
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
    
    private func submitExam() {
        var wrongIds: Set<String> = []
        for q in activeQuestions {
            if let ans = userAnswers[q.id] {
                if ans != q.correctAnswerIndex {
                    wrongIds.insert(q.id)
                }
            } else {
                wrongIds.insert(q.id)
            }
        }
        
        let prog = QuizProgress(
            quizId: quiz.id,
            currentIndex: currentIndex,
            userAnswers: userAnswers,
            wrongQuestionIds: wrongIds,
            isCompleted: true
        )
        
        storage.saveProgress(projectId: project.id, progress: prog)
        showEndingView = true
    }
    
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Immediately bypass keyboard shortcuts if user is typing in ANY textfield/editor!
            if let responder = event.window?.firstResponder,
               (responder is NSTextView || responder is NSTextField || responder is NSText) {
                return event
            }
            
            guard askingGeminiQuestion == nil && !showEndingView && !showCustomTimerSheet else { return event }
            
            let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
            
            if event.keyCode == 51 {
                dismiss()
                return nil
            }
            
            if event.keyCode == 123 {
                if currentIndex > 0 { currentIndex -= 1 }
                return nil
            }
            
            if event.keyCode == 124 {
                if currentIndex + 1 < activeQuestions.count { currentIndex += 1 }
                return nil
            }
            
            if !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                let q = activeQuestions[currentIndex]
                if chars == "a" || chars == "1" { userAnswers[q.id] = 0; return nil }
                if chars == "b" || chars == "2" { userAnswers[q.id] = 1; return nil }
                if chars == "c" || chars == "3" { userAnswers[q.id] = 2; return nil }
                if chars == "d" || chars == "4" { userAnswers[q.id] = 3; return nil }
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
}
