import SwiftUI
import AppKit

public struct FlashcardView: View {
    let project: StudyProject
    let quiz: Quiz
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var allQuestions: [Question] = []
    @State private var cardQueue: [Question] = []
    @State private var historyStack: [Question] = []
    @State private var currentCard: Question? = nil
    
    // Vocabulary Flashcard Support
    @State private var allVocabs: [VocabularyCard] = []
    @State private var vocabQueue: [VocabularyCard] = []
    @State private var vocabHistory: [VocabularyCard] = []
    @State private var currentVocab: VocabularyCard? = nil
    @State private var selectedCEFRFilter: CEFRLevel = .all
    
    @State private var isFlipped: Bool = false
    @State private var studyRound: Int = 1
    @State private var masteredIds: Set<String> = []
    @State private var needReviewIds: Set<String> = []
    @State private var isCompleted: Bool = false
    @State private var showNavPane: Bool = false
    @State private var showReviewView: Bool = false
    
    @State private var eventMonitor: Any? = nil
    
    private var isLLVocabularyMode: Bool {
        (quiz.quizType == .languageLearning || project.projectType == .languageLearning) && !quiz.vocabularies.isEmpty
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
                        Text("\(quiz.title) • \(isLLVocabularyMode ? "Từ vựng Ngoại ngữ (CEFR)" : "Thẻ ghi nhớ")")
                            .font(.system(size: 16 * fontScale, weight: .bold))
                        
                        let totalRemaining = isLLVocabularyMode ? (vocabQueue.count + (currentVocab != nil ? 1 : 0)) : (cardQueue.count + (currentCard != nil ? 1 : 0))
                        Text("Vòng học thứ \(studyRound) • Còn lại \(totalRemaining) thẻ")
                            .font(.system(size: 12 * fontScale, weight: .bold))
                            .foregroundColor(LiquidGlassPalette.deepPurple)
                    }
                    
                    Spacer()
                    
                    // CEFR Level filter picker if in vocabulary mode
                    if isLLVocabularyMode {
                        Picker("", selection: $selectedCEFRFilter) {
                            ForEach(CEFRLevel.allCases) { lvl in
                                Text(lvl.badgeLabel).tag(lvl)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120 * fontScale)
                        .onChange(of: selectedCEFRFilter) { _ in
                            setupFlashcards()
                        }
                    }
                    
                    // Toggle Question Navigator Sidebar
                    Button(action: { withAnimation { showNavPane.toggle() } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sidebar.right")
                            Text(loc.text("questionNavPane"))
                        }
                        .font(.system(size: 12 * fontScale, weight: .medium))
                        .foregroundColor(showNavPane ? LiquidGlassPalette.deepPurple : .secondary)
                        .padding(.horizontal, 10 * fontScale)
                        .padding(.vertical, 5 * fontScale)
                        .background(showNavPane ? LiquidGlassPalette.deepPurple.opacity(0.12) : Color.clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(.thinMaterial)
                
                Divider()
                
                // Main Flashcard & Right Navigation Split View
                HStack(spacing: 0) {
                    // Flashcard Interactive Center Area
                    VStack(spacing: 24 * fontScale) {
                        if isCompleted {
                            completionView
                        } else if isLLVocabularyMode, let vocab = currentVocab {
                            Spacer()
                            
                            // 3D Flip Card Container for Vocabulary
                            ZStack {
                                if !isFlipped {
                                    // Front: Vocabulary Word + Word Type + Phonetic
                                    GlassCard {
                                        VStack(spacing: 16 * fontScale) {
                                            HStack {
                                                let typeLower = vocab.wordType.lowercased()
                                                let badgeTitle = typeLower.contains("idiom") ? "THÀNH NGỮ" : (typeLower.contains("phr") ? "CỤM ĐỘNG TỪ" : "TỪ VỰNG")
                                                let badgeColor = typeLower.contains("idiom") ? LiquidGlassPalette.sunsetOrange : (typeLower.contains("phr") ? LiquidGlassPalette.cyanTeal : LiquidGlassPalette.deepPurple)
                                                
                                                BadgeView(text: badgeTitle, color: badgeColor)
                                                Spacer()
                                                BadgeView(text: vocab.cefrLevel.badgeLabel, color: LiquidGlassPalette.oceanBlue)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(spacing: 8 * fontScale) {
                                                HStack(alignment: .firstTextBaseline, spacing: 8 * fontScale) {
                                                    Text(vocab.word)
                                                        .font(.system(size: 30 * fontScale, weight: .bold))
                                                        .multilineTextAlignment(.center)
                                                    
                                                    if !vocab.wordType.isEmpty {
                                                        Text("(\(vocab.wordType))")
                                                            .font(.system(size: 17 * fontScale, weight: .semibold))
                                                            .foregroundColor(LiquidGlassPalette.deepPurple)
                                                    }
                                                }
                                                
                                                if !vocab.phonetic.isEmpty {
                                                    Text(vocab.phonetic)
                                                        .font(.system(size: 16 * fontScale))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .multilineTextAlignment(.center)
                                            .padding()
                                            
                                            Spacer()
                                            
                                            Text("💡 Nhấn phím Cách (Spacebar) hoặc chạm để xem nghĩa tiếng Việt & câu ví dụ")
                                                .font(.system(size: 12 * fontScale))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                } else {
                                    // Back: Vietnamese Meaning + Example Sentence in Bold
                                    GlassCard {
                                        VStack(spacing: 16 * fontScale) {
                                            HStack {
                                                BadgeView(text: "NGHĨA & VÍ DỤ", color: LiquidGlassPalette.emeraldMint)
                                                Spacer()
                                                BadgeView(text: vocab.cefrLevel.badgeLabel, color: LiquidGlassPalette.oceanBlue)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(spacing: 14 * fontScale) {
                                                Text(vocab.vietnameseMeaning)
                                                    .font(.system(size: 22 * fontScale, weight: .bold))
                                                    .foregroundColor(LiquidGlassPalette.emeraldMint)
                                                    .multilineTextAlignment(.center)
                                                
                                                if !vocab.exampleSentence.isEmpty {
                                                    Divider()
                                                        .frame(width: 200 * fontScale)
                                                    
                                                    VStack(spacing: 4 * fontScale) {
                                                        Text("Ví dụ minh họa:")
                                                            .font(.system(size: 11 * fontScale, weight: .semibold))
                                                            .foregroundColor(.secondary)
                                                        
                                                        Text(formattedMarkdown(vocab.exampleSentence))
                                                            .font(.system(size: 15 * fontScale))
                                                            .multilineTextAlignment(.center)
                                                            .padding(.horizontal)
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Text("💡 Chọn Đã thuộc hoặc Chưa thuộc (1/2)")
                                                .font(.system(size: 12 * fontScale))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                }
                            }
                            .frame(width: 580 * fontScale, height: 360 * fontScale)
                            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isFlipped)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    isFlipped.toggle()
                                }
                            }
                            
                            Spacer()
                            
                            // Card Action Buttons
                            HStack(spacing: 18 * fontScale) {
                                SecondaryButton(title: loc.text("prevCard"), icon: "arrow.left") {
                                    goPreviousCard()
                                }
                                .disabled(isLLVocabularyMode ? vocabHistory.isEmpty : historyStack.isEmpty)
                                
                                PrimaryButton(title: "Chưa thuộc", icon: "xmark", color: LiquidGlassPalette.coralRed) {
                                    markCard(mastered: false)
                                }
                                
                                PrimaryButton(title: "Đã thuộc bài", icon: "checkmark", color: LiquidGlassPalette.emeraldMint) {
                                    markCard(mastered: true)
                                }
                            }
                            .padding(.bottom, 20 * fontScale)
                            
                        } else if let card = currentCard {
                            Spacer()
                            
                            // 3D Flip Card Container for Regular Quiz
                            ZStack {
                                if !isFlipped {
                                    // Front: Question Side
                                    GlassCard {
                                        VStack(spacing: 16 * fontScale) {
                                            BadgeView(text: loc.text("questionSide"), color: LiquidGlassPalette.deepPurple)
                                            
                                            Spacer()
                                            
                                            Text(card.text)
                                                .font(.system(size: 22 * fontScale, weight: .bold))
                                                .multilineTextAlignment(.center)
                                                .lineSpacing(6)
                                                .padding()
                                            
                                            Spacer()
                                            
                                            Text("💡 Nhấn phím Cách (Spacebar) hoặc chạm để lật đáp án")
                                                .font(.system(size: 12 * fontScale))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                } else {
                                    // Back: Answer Side
                                    GlassCard {
                                        VStack(spacing: 16 * fontScale) {
                                            BadgeView(text: loc.text("answerSide"), color: LiquidGlassPalette.emeraldMint)
                                            
                                            Spacer()
                                            
                                            let correctOpt = card.options.first(where: { $0.label == card.correctAnswerLabel }) ?? card.options.first
                                            
                                            VStack(spacing: 10 * fontScale) {
                                                Text("Đáp án đúng: \(card.correctAnswerLabel)")
                                                    .font(.system(size: 16 * fontScale, weight: .bold))
                                                    .foregroundColor(LiquidGlassPalette.emeraldMint)
                                                
                                                Text(correctOpt?.text ?? "")
                                                    .font(.system(size: 20 * fontScale, weight: .bold))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            if !card.explanation.isEmpty {
                                                Text(card.explanation)
                                                    .font(.system(size: 14 * fontScale))
                                                    .foregroundColor(.secondary)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("💡 Chọn Đã thuộc hoặc Chưa thuộc")
                                                .font(.system(size: 12 * fontScale))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                }
                            }
                            .frame(width: 560 * fontScale, height: 360 * fontScale)
                            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isFlipped)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    isFlipped.toggle()
                                }
                            }
                            
                            Spacer()
                            
                            // Card Action Buttons (Previous Card, Flashcard V, Flashcard X)
                            HStack(spacing: 18 * fontScale) {
                                SecondaryButton(title: loc.text("prevCard"), icon: "arrow.left") {
                                    goPreviousCard()
                                }
                                .disabled(historyStack.isEmpty)
                                
                                PrimaryButton(title: "Chưa thuộc", icon: "xmark", color: LiquidGlassPalette.coralRed) {
                                    markCard(mastered: false)
                                }
                                
                                PrimaryButton(title: "Đã thuộc bài", icon: "checkmark", color: LiquidGlassPalette.emeraldMint) {
                                    markCard(mastered: true)
                                }
                            }
                            .padding(.bottom, 20 * fontScale)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right Navigation Pane Sidebar
                    let totalCount = isLLVocabularyMode ? allVocabs.count : allQuestions.count
                    if showNavPane && totalCount > 0 {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12 * fontScale) {
                            Text(isLLVocabularyMode ? "Danh sách từ vựng" : loc.text("questionNavPane"))
                                .font(.system(size: 13 * fontScale, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.top, 12 * fontScale)
                                .padding(.horizontal, 12 * fontScale)
                            
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40 * fontScale), spacing: 8 * fontScale)], spacing: 8 * fontScale) {
                                    ForEach(0..<totalCount, id: \.self) { idx in
                                        navButton(index: idx)
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
                
                // Footer Navigation Bar
                HStack {
                    Text("Phím tắt: Spacebar (Lật thẻ) • V hoặc 1 (Thuộc) • X hoặc 2 (Chưa thuộc) • Mũi tên trái (Thẻ trước)")
                        .font(.system(size: 11 * fontScale))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .sheet(isPresented: $showReviewView) {
            ReviewView(quiz: quiz, questions: allQuestions, userAnswers: [:], wrongIds: needReviewIds)
        }
        .onAppear {
            setupFlashcards()
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
    }
    
    // MARK: - Navigation & Card Logic
    @ViewBuilder
    private func navButton(index: Int) -> some View {
        let cardId: String = isLLVocabularyMode ? (index < allVocabs.count ? allVocabs[index].id : "") : (index < allQuestions.count ? allQuestions[index].id : "")
        let isCurrent = isLLVocabularyMode ? currentVocab?.id == cardId : currentCard?.id == cardId
        let isMastered = masteredIds.contains(cardId)
        let isNeedReview = needReviewIds.contains(cardId)
        
        let btnColor: Color = isCurrent ? LiquidGlassPalette.deepPurple : (isMastered ? LiquidGlassPalette.emeraldMint : (isNeedReview ? LiquidGlassPalette.coralRed : .gray.opacity(0.4)))
        
        Button(action: {
            if isLLVocabularyMode {
                if index < allVocabs.count { jumpToVocab(allVocabs[index]) }
            } else {
                if index < allQuestions.count { jumpToCard(allQuestions[index]) }
            }
        }) {
            Text("\(index + 1)")
                .font(.system(size: 13 * fontScale, weight: .bold))
                .foregroundColor(isCurrent || isMastered || isNeedReview ? .white : .primary)
                .frame(width: 38 * fontScale, height: 38 * fontScale)
                .background(btnColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCurrent ? LiquidGlassPalette.deepPurple : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func setupFlashcards() {
        masteredIds.removeAll()
        needReviewIds.removeAll()
        studyRound = 1
        isCompleted = false
        isFlipped = false
        
        if isLLVocabularyMode {
            var rawVocabs = quiz.vocabularies
            if selectedCEFRFilter != .all {
                let filtered = rawVocabs.filter { $0.cefrLevel == selectedCEFRFilter }
                if !filtered.isEmpty {
                    rawVocabs = filtered
                }
            }
            
            if storage.settings.isShuffleEnabled {
                rawVocabs.shuffle()
            }
            
            allVocabs = rawVocabs
            vocabQueue = rawVocabs
            vocabHistory.removeAll()
            
            if !vocabQueue.isEmpty {
                currentVocab = vocabQueue.removeFirst()
            } else {
                currentVocab = nil
            }
        } else {
            var rawQuestions: [Question]
            if storage.settings.isShuffleEnabled {
                if let existingShuffled = project.progressMap[quiz.id]?.shuffledQuestions, !existingShuffled.isEmpty {
                    rawQuestions = existingShuffled
                } else {
                    let newShuffled = quiz.questions.shuffled().map { $0.shuffledWithRelabeledOptions() }
                    var prog = project.progressMap[quiz.id] ?? QuizProgress(quizId: quiz.id)
                    prog.shuffledQuestions = newShuffled
                    storage.saveProgress(projectId: project.id, progress: prog)
                    rawQuestions = newShuffled
                }
            } else {
                rawQuestions = quiz.questions
            }
            
            allQuestions = rawQuestions
            cardQueue = allQuestions
            historyStack.removeAll()
            
            if !cardQueue.isEmpty {
                currentCard = cardQueue.removeFirst()
            } else {
                currentCard = nil
            }
        }
    }
    
    private func jumpToCard(_ question: Question) {
        if let curr = currentCard {
            historyStack.append(curr)
        }
        currentCard = question
        cardQueue.removeAll(where: { $0.id == question.id })
        isFlipped = false
    }
    
    private func jumpToVocab(_ vocab: VocabularyCard) {
        if let curr = currentVocab {
            vocabHistory.append(curr)
        }
        currentVocab = vocab
        vocabQueue.removeAll(where: { $0.id == vocab.id })
        isFlipped = false
    }
    
    private func goPreviousCard() {
        if isLLVocabularyMode {
            guard let prev = vocabHistory.popLast() else { return }
            if let curr = currentVocab {
                vocabQueue.insert(curr, at: 0)
            }
            currentVocab = prev
            isFlipped = false
        } else {
            guard let prev = historyStack.popLast() else { return }
            if let curr = currentCard {
                cardQueue.insert(curr, at: 0)
            }
            currentCard = prev
            isFlipped = false
        }
    }
    
    private func markCard(mastered: Bool) {
        if isLLVocabularyMode {
            guard let card = currentVocab else { return }
            vocabHistory.append(card)
            
            if mastered {
                masteredIds.insert(card.id)
                needReviewIds.remove(card.id)
            } else {
                needReviewIds.insert(card.id)
            }
            
            isFlipped = false
            
            if !vocabQueue.isEmpty {
                currentVocab = vocabQueue.removeFirst()
            } else {
                isCompleted = true
                currentVocab = nil
            }
        } else {
            guard let card = currentCard else { return }
            historyStack.append(card)
            
            if mastered {
                masteredIds.insert(card.id)
                needReviewIds.remove(card.id)
            } else {
                needReviewIds.insert(card.id)
            }
            
            isFlipped = false
            
            if !cardQueue.isEmpty {
                currentCard = cardQueue.removeFirst()
            } else {
                isCompleted = true
                currentCard = nil
            }
        }
    }
    
    private var completionView: some View {
        let totalCount = isLLVocabularyMode ? allVocabs.count : allQuestions.count
        
        return GlassCard {
            VStack(spacing: 20 * fontScale) {
                Image(systemName: needReviewIds.isEmpty ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 56 * fontScale))
                    .foregroundColor(needReviewIds.isEmpty ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.sunsetOrange)
                
                VStack(spacing: 6 * fontScale) {
                    Text(loc.text("roundCompleted"))
                        .font(.system(size: 22 * fontScale, weight: .bold))
                    
                    if needReviewIds.isEmpty {
                        Text("Chúc mừng! Bạn đã ghi nhớ 100% (\(totalCount)/\(totalCount) thẻ) trong bộ đề thi!")
                            .font(.system(size: 14 * fontScale))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Kết thúc Vòng \(studyRound): Thuộc \(masteredIds.count)/\(totalCount) thẻ. Còn lại \(needReviewIds.count) thẻ chưa thuộc.")
                            .font(.system(size: 14 * fontScale))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                VStack(spacing: 12 * fontScale) {
                    if !needReviewIds.isEmpty {
                        PrimaryButton(
                            title: "Tiếp tục học Vòng \(studyRound + 1) (\(needReviewIds.count) thẻ chưa thuộc)",
                            icon: "arrow.right.circle.fill",
                            color: LiquidGlassPalette.sunsetOrange
                        ) {
                            studyRound += 1
                            if isLLVocabularyMode {
                                var nextQueue = allVocabs.filter { needReviewIds.contains($0.id) }
                                if storage.settings.isShuffleEnabled { nextQueue.shuffle() }
                                vocabQueue = nextQueue
                                isCompleted = false
                                if !vocabQueue.isEmpty { currentVocab = vocabQueue.removeFirst() }
                            } else {
                                var nextQueue = allQuestions.filter { needReviewIds.contains($0.id) }
                                if storage.settings.isShuffleEnabled { nextQueue.shuffle() }
                                cardQueue = nextQueue
                                isCompleted = false
                                if !cardQueue.isEmpty { currentCard = cardQueue.removeFirst() }
                            }
                        }
                    }
                    
                    PrimaryButton(
                        title: loc.text("studyAgain"),
                        icon: "arrow.clockwise",
                        color: LiquidGlassPalette.oceanBlue
                    ) {
                        setupFlashcards()
                    }
                    
                    if !isLLVocabularyMode {
                        SecondaryButton(
                            title: loc.text("btnReviewWithAnswers"),
                            icon: "doc.text.magnifyingglass"
                        ) {
                            showReviewView = true
                        }
                    }
                    
                    Button(loc.text("backToDashboard")) {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .font(.system(size: 13 * fontScale))
                    .padding(.top, 4)
                }
            }
            .padding(28 * fontScale)
            .frame(width: 460 * fontScale)
        }
    }
    
    private func formattedMarkdown(_ rawText: String) -> LocalizedStringKey {
        return LocalizedStringKey(rawText)
    }
    
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Delete / Backspace (51) or Escape (53) -> Quit Flashcards
            if event.keyCode == 51 || event.keyCode == 53 {
                dismiss()
                WindowManager.shared.closeCurrentKeyWindow()
                return nil
            }
            
            // Spacebar (49) or Return (36) -> Flip Flashcard
            if event.keyCode == 49 || event.keyCode == 36 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isFlipped.toggle()
                }
                return nil
            }
            
            // Left arrow (123) -> Previous card
            if event.keyCode == 123 {
                goPreviousCard()
                return nil
            }
            
            let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
            let code = event.keyCode
            
            // 1 / V / Keypad 1 (18, 9, 83) -> Thuộc (Mastered)
            if code == 18 || code == 9 || code == 83 || chars == "1" || chars == "v" {
                markCard(mastered: true)
                return nil
            }
            
            // 2 / X / Keypad 2 (19, 7, 84) -> Chưa thuộc (Need Review)
            if code == 19 || code == 7 || code == 84 || chars == "2" || chars == "x" {
                markCard(mastered: false)
                return nil
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
