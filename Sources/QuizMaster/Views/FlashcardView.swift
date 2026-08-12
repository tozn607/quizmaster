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
    
    @State private var eventMonitor: Any? = nil
    
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
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("\(quiz.title) (Thẻ ghi nhớ 3D)")
                        .font(.system(size: 16 * fontScale, weight: .bold))
                    
                    Text("Vòng học thứ \(studyRound) • Còn lại \(cardQueue.count + (currentCard != nil ? 1 : 0)) thẻ")
                        .font(.system(size: 12 * fontScale, weight: .bold))
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                // Toggle Question Navigator Sidebar
                Button(action: { withAnimation { showNavPane.toggle() } }) {
                    HStack(spacing: 4) {
                        Image(systemName: "sidebar.right")
                        Text(loc.text("questionNavPane"))
                    }
                    .font(.system(size: 12 * fontScale, weight: .medium))
                    .foregroundColor(showNavPane ? .purple : .secondary)
                    .padding(.horizontal, 8 * fontScale)
                    .padding(.vertical, 4 * fontScale)
                    .background(showNavPane ? Color.purple.opacity(0.12) : Color.clear)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
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
                                        BadgeView(text: loc.text("questionSide"), color: .blue)
                                        
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
                                // Back: Answer Side (Rotated 180 so text is upright during 3D flip)
                                GlassCard {
                                    VStack(spacing: 16 * fontScale) {
                                        BadgeView(text: loc.text("answerSide"), color: .green)
                                        
                                        Spacer()
                                        
                                        let correctOpt = card.options.first(where: { $0.label == card.correctAnswerLabel }) ?? card.options.first
                                        
                                        VStack(spacing: 10 * fontScale) {
                                            Text("Đáp án đúng: \(card.correctAnswerLabel)")
                                                .font(.system(size: 16 * fontScale, weight: .bold))
                                                .foregroundColor(.green)
                                            
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
                                        
                                        Text("💡 Chọn V (Thuộc) hoặc X (Chưa thuộc)")
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
                            
                            PrimaryButton(title: "X - Chưa thuộc (Cần học lại)", icon: "xmark", color: .red) {
                                markCard(mastered: false)
                            }
                            
                            PrimaryButton(title: "V - Đã thuộc bài", icon: "checkmark", color: .green) {
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
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
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
            .background(Color(NSColor.controlBackgroundColor))
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
        
        let btnColor: Color = isCurrent ? .purple : (isMastered ? .green : (isNeedReview ? .red : .gray.opacity(0.4)))
        
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
                        .stroke(isCurrent ? Color.purple : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func setupFlashcards() {
        allQuestions = quiz.questions
        cardQueue = quiz.questions
        historyStack.removeAll()
        masteredIds.removeAll()
        needReviewIds.removeAll()
        studyRound = 1
        isCompleted = false
        currentCard = cardQueue.first
        if !cardQueue.isEmpty {
            cardQueue.removeFirst()
        }
    }
    
    private func jumpToCard(question: Question) {
        if let card = currentCard {
            historyStack.append(card)
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
            masteredIds.remove(card.id)
        }
        
        if !cardQueue.isEmpty {
            currentCard = cardQueue.removeFirst()
            isFlipped = false
        } else {
            // Check if there are un-mastered cards to study in round 2
            if !needReviewIds.isEmpty {
                studyRound += 1
                cardQueue = allQuestions.filter { needReviewIds.contains($0.id) }
                currentCard = cardQueue.removeFirst()
                isFlipped = false
            } else {
                currentCard = nil
                isCompleted = true
            }
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 20 * fontScale) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 64 * fontScale))
                .foregroundColor(.green)
            
            Text("Chúc mừng! Bạn đã thuộc 100% các thẻ ghi nhớ!")
                .font(.system(size: 20 * fontScale, weight: .bold))
            
            Text("Đã vượt qua \(studyRound) vòng ôn tập thẻ ghi nhớ.")
                .font(.system(size: 14 * fontScale))
                .foregroundColor(.secondary)
            
            PrimaryButton(title: "Học lại từ đầu (Vòng 1)", icon: "arrow.clockwise", color: .purple) {
                setupFlashcards()
            }
        }
        .padding(40)
    }
    
    // MARK: - Keyboard Monitor
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard !isCompleted else { return event }
            
            let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
            
            if event.keyCode == 51 {
                dismiss()
                return nil
            }
            
            // Left arrow key for Previous Card!
            if event.keyCode == 123 {
                goPreviousCard()
                return nil
            }
            
            // Spacebar flips card
            if event.keyCode == 49 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isFlipped.toggle()
                }
                return nil
            }
            
            if chars == "v" || chars == "1" {
                markCard(mastered: true)
                return nil
            }
            
            if chars == "x" || chars == "2" {
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
