import SwiftUI

public struct EndingView: View {
    let project: StudyProject
    let quiz: Quiz
    let progress: QuizProgress
    
    @EnvironmentObject var loc: LocalizationManager
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
                VStack(spacing: 24) {
                    // Celebration Banner
                    VStack(spacing: 12) {
                        Image(systemName: accuracyPercent >= 80 ? "star.seal.fill" : "checkmark.seal.fill")
                            .font(.system(size: 64))
                            .foregroundColor(accuracyPercent >= 80 ? .yellow : .blue)
                        
                        Text(loc.text("congrats"))
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(quiz.title)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)
                    
                    // Detailed Score Grid
                    GlassCard {
                        VStack(spacing: 18) {
                            Text(loc.text("scoreSummary"))
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 16) {
                                statTile(title: loc.text("accuracyScore"), value: "\(accuracyPercent)%", color: accuracyPercent >= 70 ? .green : .orange)
                                statTile(title: loc.text("correctCount"), value: "\(correctFirstTry) / \(totalQuestions)", color: .blue)
                                statTile(title: loc.text("wrongCount"), value: "\(wrongCount)", color: .red)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text(loc.text("masteryLevel"))
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(masteryRatingText(percent: accuracyPercent))
                                    .fontWeight(.bold)
                                    .foregroundColor(accuracyPercent >= 80 ? .green : .blue)
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if wrongCount > 0 {
                            PrimaryButton(
                                title: loc.text("redoWrong"),
                                icon: "arrow.triangle.2.circlepath",
                                color: .orange
                            ) {
                                dismiss()
                            }
                        }
                        
                        SecondaryButton(
                            title: loc.text("reviewDetailed"),
                            icon: "doc.text.magnifyingglass"
                        ) {
                            showReviewSheet = true
                        }
                        
                        Button(loc.text("backToDashboard")) {
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .frame(width: 520, height: 580)
        .sheet(isPresented: $showReviewSheet) {
            ReviewView(quiz: quiz, questions: quiz.questions, userAnswers: progress.userAnswers, wrongIds: progress.wrongQuestionIds)
        }
    }
    
    @ViewBuilder
    private func statTile(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
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
