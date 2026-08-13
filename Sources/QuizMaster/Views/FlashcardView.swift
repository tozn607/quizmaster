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
    
    @State private var isFlipped: Bool = false
    @State private var studyRound: Int = 1
    @State private var masteredIds: Set<String> = []
    @State private var needReviewIds: Set<String> = []
    @State private var isCompleted: Bool = false
    @State private var showNavPane: Bool = true
    @State private var showReviewView: Bool = false
    
    @State private var eventMonitor: Any? = nil
    
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
                        Text("\(quiz.title) • Thẻ ghi nhớ")
                            .font(.system(size: 16 * fontScale, weight: .bold))
                        
                        Text("Vòng học thứ \(studyRound) • Còn lại \(cardQueue.count + (currentCard != nil ? 1 : 0)) thẻ")
                            .font(.system(size: 12 * fontScale, weight: .bold))
                            .foregroundColor(LiquidGlassPalette.deepPurple)
                    }
                    
                    Spacer()
                    
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
                        } else if let card = currentCard {
                            Spacer()
                            
                            // 3D Flip Card Container
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
                    if showNavPane && !allQuestions.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12 * fontScale) {
                            Text(loc.text("questionNavPane"))
                                .font(.system(size: 13 * fontScale, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.top, 12 * fontScale)
                                .padding(.horizontal, 12 * fontScale)
                            
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40 * fontScale), spacing: 8 * fontScale)], spacing: 8 * fontScale) {
                                    ForEach(0..<allQuestions.count, id: \.self) { idx in
                                        navButton(index: idx, question: allQuestions[idx])
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
    private func navButton(index: Int, question: Question) -> some View {
        let isCurrent = currentCard?.id == question.id
        let isMastered = masteredIds.contains(question.id)
        let isNeedReview = needReviewIds.contains(question.id)
        
        let btnColor: Color = isCurrent ? LiquidGlassPalette.deepPurple : (isMastered ? LiquidGlassPalette.emeraldMint : (isNeedReview ? LiquidGlassPalette.coralRed : .gray.opacity(0.4)))
        
        Button(action: {
            jumpToCard(question: question)
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
        var rawQuestions = quiz.questions
        if storage.settings.isShuffleEnabled {
            rawQuestions = rawQuestions.shuffled().map { $0.shuffledWithRelabeledOptions() }
        }
        allQuestions = rawQuestions
        cardQueue = allQuestions
        masteredIds.removeAll()
        needReviewIds.removeAll()
        historyStack.removeAll()
        studyRound = 1
        isCompleted = false
        
        if !cardQueue.isEmpty {
            currentCard = cardQueue.removeFirst()
        } else {
            currentCard = nil
        }
    }
    
    private func jumpToCard(question: Question) {
        if let curr = currentCard {
            historyStack.append(curr)
        }
        currentCard = question
        cardQueue.removeAll(where: { $0.id == question.id })
        isFlipped = false
    }
    
    private func goPreviousCard() {
        guard let prev = historyStack.popLast() else { return }
        if let curr = currentCard {
            cardQueue.insert(curr, at: 0)
        }
        currentCard = prev
        isFlipped = false
    }
    
    private func markCard(mastered: Bool) {
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
    
    private var completionView: some View {
        GlassCard {
            VStack(spacing: 20 * fontScale) {
                Image(systemName: needReviewIds.isEmpty ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 56 * fontScale))
                    .foregroundColor(needReviewIds.isEmpty ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.sunsetOrange)
                
                VStack(spacing: 6 * fontScale) {
                    Text(loc.text("roundCompleted"))
                        .font(.system(size: 22 * fontScale, weight: .bold))
                    
                    if needReviewIds.isEmpty {
                        Text("Chúc mừng! Bạn đã ghi nhớ 100% (\(allQuestions.count)/\(allQuestions.count) câu hỏi) trong bộ đề thi!")
                            .font(.system(size: 14 * fontScale))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Kết thúc Vòng \(studyRound): Thuộc \(masteredIds.count)/\(allQuestions.count) thẻ. Còn lại \(needReviewIds.count) thẻ chưa thuộc.")
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
                            var nextQueue = allQuestions.filter { needReviewIds.contains($0.id) }
                            if storage.settings.isShuffleEnabled {
                                nextQueue.shuffle()
                            }
                            cardQueue = nextQueue
                            isCompleted = false
                            if !cardQueue.isEmpty {
                                currentCard = cardQueue.removeFirst()
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
                    
                    SecondaryButton(
                        title: loc.text("btnReviewWithAnswers"),
                        icon: "doc.text.magnifyingglass"
                    ) {
                        showReviewView = true
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
    
    private func setupKeyboardMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 49 { // Spacebar
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isFlipped.toggle()
                }
                return nil
            } else if event.keyCode == 123 { // Left arrow
                goPreviousCard()
                return nil
            } else if event.charactersIgnoringModifiers == "1" || event.charactersIgnoringModifiers == "v" || event.charactersIgnoringModifiers == "V" {
                markCard(mastered: true)
                return nil
            } else if event.charactersIgnoringModifiers == "2" || event.charactersIgnoringModifiers == "x" || event.charactersIgnoringModifiers == "X" {
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
