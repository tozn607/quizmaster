import SwiftUI

public struct EndingView: View {
    let project: StudyProject
    let quiz: Quiz
    let progress: QuizProgress
    
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var showReviewSheet: Bool = false
    
    public var body: some View {
        let totalQuestions = quiz.questions.count
        let correctFirstTry = progress.userAnswers.filter { qId, ansIdx in
            if let q = quiz.questions.first(where: { $0.id == qId }) {
                return q.correctAnswerIndex == ansIdx
            }
            return false
        }.count
        
        let wrongCount = progress.wrongQuestionIds.count
        let accuracyPercent = totalQuestions > 0 ? Int((Double(correctFirstTry) / Double(totalQuestions)) * 100.0) : 0
        
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24 * fontScale) {
                    // Celebration Banner
                    VStack(spacing: 12 * fontScale) {
                        Image(systemName: accuracyPercent >= 80 ? "star.seal.fill" : "checkmark.seal.fill")
                            .font(.system(size: 64 * fontScale))
                            .foregroundColor(accuracyPercent >= 80 ? .yellow : .blue)
                        
                        Text(loc.text("quizFinishedTitle"))
                            .font(.system(size: 24 * fontScale, weight: .bold))
                        
                        Text(quiz.title)
                            .font(.system(size: 16 * fontScale))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24 * fontScale)
                    
                    // Detailed Score Grid
                    GlassCard {
                        VStack(spacing: 18 * fontScale) {
                            Text("Tổng kết Điểm số")
                                .font(.system(size: 16 * fontScale, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 16 * fontScale) {
                                statTile(title: "Điểm số", value: "\(accuracyPercent)%", color: accuracyPercent >= 70 ? .green : .orange)
                                statTile(title: "Trả lời Đúng", value: "\(correctFirstTry) / \(totalQuestions)", color: .blue)
                                statTile(title: "Trả lời Sai", value: "\(wrongCount)", color: .red)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text(loc.text("masteryLevel"))
                                    .font(.system(size: 13 * fontScale, weight: .semibold))
                                Spacer()
                                Text(masteryRatingText(percent: accuracyPercent))
                                    .font(.system(size: 14 * fontScale, weight: .bold))
                                    .foregroundColor(accuracyPercent >= 80 ? .green : .blue)
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12 * fontScale) {
                        if wrongCount > 0 {
                            PrimaryButton(
                                title: loc.text("btnRedoWrongOnly") + " (\(wrongCount) câu)",
                                icon: "arrow.triangle.2.circlepath",
                                color: .orange
                            ) {
                                dismiss()
                            }
                        }
                        
                        SecondaryButton(
                            title: loc.text("btnReviewWithAnswers"),
                            icon: "doc.text.magnifyingglass"
                        ) {
                            showReviewSheet = true
                        }
                        
                        Button(loc.text("backToDashboard")) {
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 13 * fontScale))
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .frame(width: 540 * fontScale, height: 600 * fontScale)
        .sheet(isPresented: $showReviewSheet) {
            ReviewView(quiz: quiz, questions: quiz.questions, userAnswers: progress.userAnswers, wrongIds: progress.wrongQuestionIds)
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
    
    private func masteryRatingText(percent: Int) -> String {
        if percent >= 90 { return "★★★★★ Xuất sắc (Mastered)" }
        if percent >= 75 { return "★★★★☆ Tốt (Proficient)" }
        if percent >= 50 { return "★★★☆☆ Khá (Intermediate)" }
        return "★★☆☆☆ Cần Ôn Luyện Thêm"
    }
}
