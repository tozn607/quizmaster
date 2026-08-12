import SwiftUI
import AppKit

public struct FlashcardView: View {
    let project: StudyProject
    let quiz: Quiz
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var cardQueue: [Question] = []
    @State private var activeDeck: [Question] = []
    @State private var totalInitialCards: Int = 0
    @State private var reviewedCount: Int = 0
    @State private var currentRound: Int = 1
    
    @State private var isFlipped: Bool = false
    @State private var masteredIds: Set<String> = []
    @State private var needRepeatQuestionIds: Set<String> = []
    @State private var isCompleted: Bool = false
    @State private var showReviewSheet: Bool = false
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
                .help("Bấm phím Delete để thoát")
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("\(loc.text("flashcardMode")): \(quiz.title)")
                        .font(.system(size: 16 * fontScale, weight: .bold))
                        .lineLimit(1)
                    
                    if currentRound > 1 {
                        Text("Vòng ôn tập thứ \(currentRound) • Thẻ \(min(reviewedCount + 1, activeDeck.count)) / \(activeDeck.count)")
                            .font(.system(size: 12 * fontScale, weight: .bold))
                            .foregroundColor(.orange)
                    } else {
                        Text("Thẻ \(min(reviewedCount + 1, totalInitialCards)) / \(totalInitialCards)")
                            .font(.system(size: 12 * fontScale, weight: .bold))
                            .foregroundColor(.purple)
                    }
                }
                
                Spacer()
                
                Button(action: shuffleCards) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 14 * fontScale))
                }
                .buttonStyle(.plain)
                .help("Xáo trộn thẻ")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Progress Bar
            let deckCount = activeDeck.isEmpty ? 1 : activeDeck.count
            ProgressBar(
                value: Double(reviewedCount) / Double(deckCount),
                height: 6,
                color: currentRound > 1 ? .orange : .purple
            )
            
            Divider()
            
            // Main Flashcard Area
            if isCompleted || cardQueue.isEmpty {
                // Round / Mastery Completion Summary Screen
                let masteredCount = masteredIds.count
                let repeatCount = needRepeatQuestionIds.count
                
                ScrollView {
                    VStack(spacing: 22 * fontScale) {
                        Image(systemName: repeatCount == 0 ? "star.circle.fill" : "arrow.triangle.2.circlepath.circle.fill")
                            .font(.system(size: 64 * fontScale))
                            .foregroundColor(repeatCount == 0 ? .yellow : .orange)
                        
                        Text(repeatCount == 0 ? "Xuất sắc! Bạn đã thuộc toàn bộ thẻ ghi nhớ!" : "Hoàn thành Vòng học \(currentRound)!")
                            .font(.system(size: 20 * fontScale, weight: .bold))
                        
                        GlassCard {
                            VStack(spacing: 16 * fontScale) {
                                Text("Kết quả Vòng học thứ \(currentRound)")
                                    .font(.system(size: 16 * fontScale, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 14 * fontScale) {
                                    statTile(title: "Tổng số thẻ", value: "\(totalInitialCards)", color: .purple)
                                    statTile(title: "Đã thuộc (V)", value: "\(masteredCount)", color: .green)
                                    statTile(title: "Cần ôn lại (X)", value: "\(repeatCount)", color: .red)
                                }
                            }
                        }
                        .frame(maxWidth: 520 * fontScale)
                        
                        VStack(spacing: 12 * fontScale) {
                            if repeatCount > 0 {
                                PrimaryButton(
                                    title: "Tiếp tục học lại \(repeatCount) thẻ \"Chưa thuộc (X)\" (Vòng \(currentRound + 1))",
                                    icon: "arrow.triangle.2.circlepath",
                                    color: .orange
                                ) {
                                    startNextRoundForRepeatCards()
                                }
                            }
                            
                            SecondaryButton(
                                title: loc.text("btnReviewWithAnswers"),
                                icon: "doc.text.magnifyingglass"
                            ) {
                                showReviewSheet = true
                            }
                            
                            PrimaryButton(
                                title: "Xáo trộn & Học lại từ đầu (Vòng 1)",
                                icon: "arrow.clockwise",
                                color: .purple
                            ) {
                                setupFlashcards()
                            }
                            
                            Button(loc.text("backToDashboard")) {
                                dismiss()
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 13 * fontScale))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        }
                    }
                    .padding(24)
                }
            } else {
                let currentCard = cardQueue[0]
                
                VStack(spacing: 20 * fontScale) {
                    Spacer()
                    
                    // 3D Flip Card Container
                    ZStack {
                        if !isFlipped {
                            // Front of Card (Question)
                            VStack(alignment: .leading, spacing: 16 * fontScale) {
                                HStack {
                                    BadgeView(text: loc.text("questionSide"), color: .blue)
                                    Spacer()
                                    Image(systemName: "hand.tap.fill")
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(currentCard.text)
                                    .font(.system(size: 21 * fontScale, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Text("Chạm thẻ hoặc bấm phím Cách (Spacebar ␣) để lật")
                                    .font(.system(size: 11 * fontScale))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(28 * fontScale)
                            .frame(maxWidth: 520 * fontScale, minHeight: 300 * fontScale)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(NSColor.controlBackgroundColor))
                                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                            )
                        } else {
                            // Back of Card (Correct Answer & Explanation)
                            VStack(alignment: .leading, spacing: 16 * fontScale) {
                                HStack {
                                    BadgeView(text: loc.text("answerSide"), color: .green)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 12 * fontScale) {
                                    Text("\(currentCard.correctAnswerLabel). \(currentCard.correctAnswerText)")
                                        .font(.system(size: 21 * fontScale, weight: .bold))
                                        .foregroundColor(.green)
                                    
                                    if !currentCard.explanation.isEmpty {
                                        Text(currentCard.explanation)
                                            .font(.system(size: 14 * fontScale))
                                            .foregroundColor(.secondary)
                                            .padding(.top, 4)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(28 * fontScale)
                            .frame(maxWidth: 520 * fontScale, minHeight: 300 * fontScale)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.green.opacity(0.08))
                                    .shadow(color: Color.green.opacity(0.15), radius: 10, x: 0, y: 6)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.green.opacity(0.5), lineWidth: 2)
                            )
                            .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
                        }
                    }
                    .rotation3DEffect(
                        .degrees(isFlipped ? 180 : 0),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            isFlipped.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    // V and X Action Buttons at Bottom
                    HStack(spacing: 24 * fontScale) {
                        // X Button (Chưa thuộc - Need Review)
                        Button(action: markNeedReview) {
                            HStack(spacing: 10 * fontScale) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20 * fontScale))
                                Text("X - Chưa thuộc")
                                    .font(.system(size: 15 * fontScale, weight: .bold))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 24 * fontScale)
                            .padding(.vertical, 14 * fontScale)
                            .background(Color.red.opacity(0.12))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // V Button (Đã thuộc - Mastered)
                        Button(action: markRemembered) {
                            HStack(spacing: 10 * fontScale) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20 * fontScale))
                                Text("V - Đã thuộc")
                                    .font(.system(size: 15 * fontScale, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28 * fontScale)
                            .padding(.vertical, 14 * fontScale)
                            .background(
                                LinearGradient(colors: [.green, .green.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: .green.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Footer Shortcut Text
                    Text("Phím tắt: Bấm phím V (hoặc 1) Thuộc • Phím X (hoặc 2) Chưa thuộc • Spacebar Lật thẻ • Delete thoát")
                        .font(.system(size: 11 * fontScale))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16 * fontScale)
                }
            }
        }
        .sheet(isPresented: $showReviewSheet) {
            ReviewView(quiz: quiz, questions: quiz.questions, userAnswers: [:], wrongIds: needRepeatQuestionIds)
        }
        .onAppear {
            setupFlashcards()
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
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
        .padding(.vertical, 12 * fontScale)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
            
            if event.keyCode == 51 {
                dismiss()
                return nil
            }
            
            if event.keyCode == 49 {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    isFlipped.toggle()
                }
                return nil
            }
            
            if chars == "v" || chars == "1" {
                markRemembered()
                return nil
            }
            
            if chars == "x" || chars == "2" {
                markNeedReview()
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
    
    private func setupFlashcards() {
        cardQueue = quiz.questions.shuffled()
        activeDeck = cardQueue
        totalInitialCards = quiz.questions.count
        reviewedCount = 0
        currentRound = 1
        masteredIds = []
        needRepeatQuestionIds = []
        isFlipped = false
        isCompleted = false
    }
    
    private func startNextRoundForRepeatCards() {
        let repeatCards = quiz.questions.filter { needRepeatQuestionIds.contains($0.id) }.shuffled()
        cardQueue = repeatCards
        activeDeck = repeatCards
        reviewedCount = 0
        currentRound += 1
        isFlipped = false
        isCompleted = false
    }
    
    private func shuffleCards() {
        withAnimation {
            cardQueue.shuffle()
            isFlipped = false
        }
    }
    
    private func markRemembered() {
        guard !cardQueue.isEmpty else { return }
        let currentCard = cardQueue.removeFirst()
        
        masteredIds.insert(currentCard.id)
        needRepeatQuestionIds.remove(currentCard.id)
        reviewedCount += 1
        
        saveFlashcardProgress()
        
        if cardQueue.isEmpty {
            isCompleted = true
        } else {
            isFlipped = false
        }
    }
    
    private func markNeedReview() {
        guard !cardQueue.isEmpty else { return }
        let currentCard = cardQueue.removeFirst()
        
        needRepeatQuestionIds.insert(currentCard.id)
        reviewedCount += 1
        
        saveFlashcardProgress()
        
        if cardQueue.isEmpty {
            isCompleted = true
        } else {
            isFlipped = false
        }
    }
    
    private func saveFlashcardProgress() {
        var prog = project.progressMap[quiz.id] ?? QuizProgress(quizId: quiz.id)
        prog.flashcardMasteredIds = masteredIds
        storage.saveProgress(projectId: project.id, progress: prog)
    }
}
