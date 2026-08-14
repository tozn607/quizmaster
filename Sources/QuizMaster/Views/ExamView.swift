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
    @State private var userSelectedOptionIds: [String: String] = [:] // questionId -> chosen Option ID
    @State private var showEndingView: Bool = false
    @State private var showNavPane: Bool = false
    @State private var askingGeminiQuestion: Question? = nil
    @State private var eventMonitor: Any? = nil
    
    @State private var isTimerConfigured: Bool = false
    @State private var showMandatoryTimerDialog: Bool = false
    @State private var timeRemainingSeconds: Int = 1800 // default 30 mins
    @State private var isTimeUp: Bool = false
    @State private var showCustomTimerSheet: Bool = false
    @State private var customTimerInputMinutes: String = "45"
    @State private var timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Section Locking Confirmation
    @State private var showSectionChangeAlert: Bool = false
    @State private var pendingTargetIndex: Int? = nil
    @State private var completedSections: Set<LanguageSkill> = []
    
    private var hasLanguageSkills: Bool {
        activeQuestions.contains(where: { $0.skill != nil })
    }
    
    private var groupedSkills: [LanguageSkill] {
        var seen = Set<LanguageSkill>()
        var result: [LanguageSkill] = []
        for q in activeQuestions {
            if let skill = q.skill, !seen.contains(skill) {
                seen.insert(skill)
                result.append(skill)
            }
        }
        return result
    }
    
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
                    
                    // Exam Timer Display
                    HStack(spacing: 4 * fontScale) {
                        Image(systemName: "timer.circle.fill")
                            .font(.system(size: 14 * fontScale))
                            .foregroundColor(timeRemainingSeconds <= 300 ? LiquidGlassPalette.coralRed : LiquidGlassPalette.sunsetOrange)
                        
                        Text(formattedTimeString)
                            .font(.system(size: 13 * fontScale, weight: .bold))
                            .foregroundColor(timeRemainingSeconds <= 300 ? LiquidGlassPalette.coralRed : LiquidGlassPalette.sunsetOrange)
                    }
                    .padding(.horizontal, 10 * fontScale)
                    .padding(.vertical, 5 * fontScale)
                    .background(timeRemainingSeconds <= 300 ? LiquidGlassPalette.coralRed.opacity(0.12) : LiquidGlassPalette.sunsetOrange.opacity(0.12))
                    .cornerRadius(6)
                    
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
                    // Left Reading Passage Side (for Reading questions with readingPassage)
                    if !activeQuestions.isEmpty && currentIndex < activeQuestions.count,
                       let passage = activeQuestions[currentIndex].readingPassage, !passage.isEmpty {
                        ReadingPassagePane(passage: passage)
                        
                        Divider()
                    }
                    
                    // Question Area
                    if !activeQuestions.isEmpty && currentIndex < activeQuestions.count {
                        let currentQuestion = activeQuestions[currentIndex]
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20 * fontScale) {
                                // Question Card
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 10 * fontScale) {
                                        HStack(spacing: 8 * fontScale) {
                                            BadgeView(text: "\(loc.text("questionHeader")) \(currentIndex + 1)", color: LiquidGlassPalette.sunsetOrange)
                                            
                                            Spacer()
                                        }
                                        
                                        Text(formattedMarkdownKey(currentQuestion.text))
                                            .font(.system(size: 17 * fontScale, weight: .regular))
                                            .lineSpacing(5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                // Skill & SubTopic labels outside box and right above answer grid
                                if currentQuestion.skill != nil || (currentQuestion.subTopic != nil && !currentQuestion.subTopic!.isEmpty) {
                                    HStack(spacing: 12 * fontScale) {
                                        if let skill = currentQuestion.skill {
                                            HStack(spacing: 4 * fontScale) {
                                                Image(systemName: "book.fill")
                                                Text(skill.displayName.uppercased())
                                            }
                                            .font(.system(size: 11 * fontScale, weight: .bold))
                                            .foregroundColor(LiquidGlassPalette.deepPurple)
                                        }
                                        
                                        if let sub = currentQuestion.subTopic, !sub.isEmpty {
                                            HStack(spacing: 4 * fontScale) {
                                                Image(systemName: "tag.fill")
                                                Text(sub.uppercased())
                                            }
                                            .font(.system(size: 11 * fontScale, weight: .bold))
                                            .foregroundColor(LiquidGlassPalette.cyanTeal)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4 * fontScale)
                                    .padding(.top, -6 * fontScale)
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
                                VStack(alignment: .leading, spacing: 14 * fontScale) {
                                    if hasLanguageSkills {
                                        ForEach(groupedSkills, id: \.self) { skill in
                                            let skillIndices = activeQuestions.indices.filter { activeQuestions[$0].skill == skill }
                                            if !skillIndices.isEmpty {
                                                VStack(alignment: .leading, spacing: 6 * fontScale) {
                                                    HStack(spacing: 4 * fontScale) {
                                                        Image(systemName: "book.fill")
                                                            .font(.system(size: 9 * fontScale))
                                                        Text(skill.displayName.uppercased())
                                                            .font(.system(size: 10 * fontScale, weight: .bold))
                                                        
                                                        if completedSections.contains(skill) {
                                                            Image(systemName: "lock.fill")
                                                                .font(.system(size: 9 * fontScale))
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                    .foregroundColor(LiquidGlassPalette.deepPurple)
                                                    
                                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 36 * fontScale), spacing: 6 * fontScale)], spacing: 6 * fontScale) {
                                                        ForEach(skillIndices, id: \.self) { idx in
                                                            navButton(index: idx, question: activeQuestions[idx])
                                                        }
                                                    }
                                                }
                                                .padding(.bottom, 6 * fontScale)
                                            }
                                        }
                                        
                                        // Non-skill questions if any
                                        let otherIndices = activeQuestions.indices.filter { activeQuestions[$0].skill == nil }
                                        if !otherIndices.isEmpty {
                                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                                Text("CÂU HỎI KHÁC")
                                                    .font(.system(size: 10 * fontScale, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                
                                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 36 * fontScale), spacing: 6 * fontScale)], spacing: 6 * fontScale) {
                                                    ForEach(otherIndices, id: \.self) { idx in
                                                        navButton(index: idx, question: activeQuestions[idx])
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40 * fontScale), spacing: 8 * fontScale)], spacing: 8 * fontScale) {
                                            ForEach(0..<activeQuestions.count, id: \.self) { idx in
                                                navButton(index: idx, question: activeQuestions[idx])
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 12 * fontScale)
                            }
                        }
                        .frame(width: 200 * fontScale)
                        .background(.ultraThinMaterial)
                    }
                }
                
                Divider()
                
                // Footer Navigation
                HStack {
                    HStack(spacing: 12 * fontScale) {
                        SecondaryButton(title: "Câu trước (←)", icon: "arrow.left") {
                            attemptNavigate(to: currentIndex - 1)
                        }
                        .disabled(currentIndex == 0 || isPreviousSectionLocked(currentIndex - 1))
                        
                        SecondaryButton(title: "Câu sau (→)", icon: "arrow.right") {
                            attemptNavigate(to: currentIndex + 1)
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
        .sheet(isPresented: $showMandatoryTimerDialog) {
            mandatoryTimerSheet
        }
        .sheet(isPresented: $showEndingView) {
            if let prog = project.progressMap[quiz.id] {
                EndingView(project: project, quiz: quiz, progress: prog)
            }
        }
        .confirmationDialog(
            loc.text("sectionLockedWarningTitle"),
            isPresented: $showSectionChangeAlert,
            titleVisibility: .visible
        ) {
            Button("Xác nhận chuyển phần thi", role: .none) {
                if let target = pendingTargetIndex {
                    // Lock current section
                    if let currentSkill = activeQuestions[currentIndex].skill {
                        completedSections.insert(currentSkill)
                    }
                    currentIndex = target
                    pendingTargetIndex = nil
                }
            }
            Button("Ở lại kiểm tra tiếp", role: .cancel) {
                pendingTargetIndex = nil
            }
        } message: {
            Text(loc.text("sectionLockedWarningMsg"))
        }
        .onAppear {
            if let duration = quiz.durationMinutes, duration > 0 {
                setTimerDuration(minutes: duration)
                showMandatoryTimerDialog = false
            } else {
                showMandatoryTimerDialog = true
            }
            setupExamQuestions()
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
        .onReceive(timerPublisher) { _ in
            guard isTimerConfigured && !showEndingView else { return }
            if timeRemainingSeconds > 0 {
                timeRemainingSeconds -= 1
            } else if !isTimeUp {
                isTimeUp = true
                submitExam()
            }
        }
    }
    
    // MARK: - Mandatory Timer Setup Sheet
    private var mandatoryTimerSheet: some View {
        VStack(spacing: 20 * fontScale) {
            Image(systemName: "timer")
                .font(.system(size: 48 * fontScale))
                .foregroundColor(LiquidGlassPalette.sunsetOrange)
            
            VStack(spacing: 6 * fontScale) {
                Text(loc.text("mandatoryTimerTitle"))
                    .font(.system(size: 18 * fontScale, weight: .bold))
                
                Text(loc.text("mandatoryTimerSubtitle"))
                    .font(.system(size: 13 * fontScale))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10 * fontScale) {
                HStack(spacing: 12 * fontScale) {
                    timerPresetButton(title: "15 phút", minutes: 15)
                    timerPresetButton(title: "30 phút", minutes: 30)
                    timerPresetButton(title: "45 phút", minutes: 45)
                    timerPresetButton(title: "60 phút", minutes: 60)
                }
                
                HStack {
                    Text("Hoặc thời gian tùy chỉnh:")
                        .font(.system(size: 12 * fontScale))
                        .foregroundColor(.secondary)
                    
                    TextField("45", text: $customTimerInputMinutes)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .frame(width: 60 * fontScale)
                    
                    Text("phút")
                        .font(.system(size: 12 * fontScale))
                }
                .padding(.top, 4 * fontScale)
            }
            
            HStack(spacing: 16 * fontScale) {
                SecondaryButton(title: loc.text("quitQuiz"), icon: "xmark") {
                    showMandatoryTimerDialog = false
                    dismiss()
                }
                
                PrimaryButton(title: "Bắt đầu làm bài thi", icon: "play.fill", color: LiquidGlassPalette.sunsetOrange) {
                    if let mins = Int(customTimerInputMinutes.trimmingCharacters(in: .whitespacesAndNewlines)), mins > 0 {
                        setTimerDuration(minutes: mins)
                    } else {
                        setTimerDuration(minutes: 45)
                    }
                    showMandatoryTimerDialog = false
                }
            }
        }
        .padding(28 * fontScale)
        .frame(width: 440 * fontScale)
    }
    
    private func timerPresetButton(title: String, minutes: Int) -> some View {
        Button(action: {
            customTimerInputMinutes = "\(minutes)"
        }) {
            Text(title)
                .font(.system(size: 12 * fontScale, weight: .semibold))
                .foregroundColor(customTimerInputMinutes == "\(minutes)" ? .white : .primary)
                .padding(.horizontal, 12 * fontScale)
                .padding(.vertical, 8 * fontScale)
                .background(customTimerInputMinutes == "\(minutes)" ? LiquidGlassPalette.sunsetOrange : Color.gray.opacity(0.15))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var formattedTimeString: String {
        let minutes = timeRemainingSeconds / 60
        let seconds = timeRemainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func setTimerDuration(minutes: Int) {
        timeRemainingSeconds = minutes * 60
        isTimerConfigured = true
    }
    
    // MARK: - Section Locking Navigation Control
    private func attemptNavigate(to targetIndex: Int) {
        guard targetIndex >= 0 && targetIndex < activeQuestions.count else { return }
        
        let currentSkill = activeQuestions[currentIndex].skill
        let targetSkill = activeQuestions[targetIndex].skill
        
        // If moving backwards to a locked section
        if targetIndex < currentIndex, let targetSkill = targetSkill, completedSections.contains(targetSkill) {
            return
        }
        
        // If switching to a new skill/section forward
        if targetIndex > currentIndex, let cur = currentSkill, let tgt = targetSkill, cur != tgt {
            pendingTargetIndex = targetIndex
            showSectionChangeAlert = true
            return
        }
        
        currentIndex = targetIndex
    }
    
    private func isPreviousSectionLocked(_ index: Int) -> Bool {
        guard index >= 0 && index < activeQuestions.count else { return false }
        if let skill = activeQuestions[index].skill {
            return completedSections.contains(skill)
        }
        return false
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
        let isLocked = isPreviousSectionLocked(index)
        let btnColor: Color = isCurrent ? LiquidGlassPalette.sunsetOrange : (isAnswered ? LiquidGlassPalette.sunsetOrange.opacity(0.7) : (isLocked ? Color.gray.opacity(0.2) : .gray.opacity(0.4)))
        
        Button(action: {
            attemptNavigate(to: index)
        }) {
            Text("\(index + 1)")
                .font(.system(size: 13 * fontScale, weight: .bold))
                .foregroundColor(isCurrent || isAnswered ? .white : (isLocked ? .secondary.opacity(0.5) : .primary))
                .frame(width: 38 * fontScale, height: 38 * fontScale)
                .background(btnColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCurrent ? LiquidGlassPalette.sunsetOrange : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }
    
    private func optionButton(for option: QuestionOption, index: Int, question: Question) -> some View {
        let isSelected: Bool
        if let chosenId = userSelectedOptionIds[question.id] {
            isSelected = chosenId == option.id
        } else {
            isSelected = userAnswers[question.id] == index
        }
        
        let bgColor = isSelected ? LiquidGlassPalette.sunsetOrange.opacity(0.20) : (colorScheme == .light ? Color.white : Color(NSColor.controlBackgroundColor))
        let borderColor = isSelected ? LiquidGlassPalette.sunsetOrange : (colorScheme == .light ? Color.black.opacity(0.18) : Color.white.opacity(0.20))
        let textColor = isSelected ? LiquidGlassPalette.sunsetOrange : (colorScheme == .light ? Color(NSColor.labelColor) : Color.white)
        
        return Button(action: {
            userAnswers[question.id] = index
            userSelectedOptionIds[question.id] = option.id
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
                
                Text(formattedMarkdownKey(option.text))
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
    
    private func formattedMarkdownKey(_ rawText: String) -> LocalizedStringKey {
        let lines = rawText.components(separatedBy: "\n")
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
    
    private func submitExam() {
        var wrongIds: Set<String> = []
        for q in activeQuestions {
            let correctOptionId = (q.correctAnswerIndex >= 0 && q.correctAnswerIndex < q.options.count) ? q.options[q.correctAnswerIndex].id : ""
            
            if let chosenId = userSelectedOptionIds[q.id] {
                if chosenId != correctOptionId {
                    wrongIds.insert(q.id)
                }
            } else if let ans = userAnswers[q.id] {
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
            userSelectedOptionIds: userSelectedOptionIds,
            wrongQuestionIds: wrongIds,
            isCompleted: true,
            shuffledQuestions: storage.settings.isShuffleEnabled ? project.progressMap[quiz.id]?.shuffledQuestions : nil
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
