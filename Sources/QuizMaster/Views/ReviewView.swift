import SwiftUI

public struct ReviewView: View {
    let quiz: Quiz
    let questions: [Question]
    let userAnswers: [String: Int]
    var userSelectedOptionIds: [String: String] = [:]
    let wrongIds: Set<String>
    
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var filterWrongOnly: Bool = false
    
    public init(quiz: Quiz, questions: [Question], userAnswers: [String: Int], userSelectedOptionIds: [String: String] = [:], wrongIds: Set<String>) {
        self.quiz = quiz
        self.questions = questions
        self.userAnswers = userAnswers
        self.userSelectedOptionIds = userSelectedOptionIds
        self.wrongIds = wrongIds
    }
    
    private var displayedQuestions: [Question] {
        filterWrongOnly ? questions.filter { wrongIds.contains($0.id) } : questions
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16 * fontScale) {
                    if displayedQuestions.isEmpty {
                        Text("Không có câu hỏi nào phù hợp với bộ lọc.")
                            .font(.system(size: 14 * fontScale))
                            .foregroundColor(.secondary)
                            .padding(.top, 40 * fontScale)
                    } else {
                        ForEach(Array(displayedQuestions.enumerated()), id: \.element.id) { idx, question in
                            reviewQuestionCard(idx: idx, question: question)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 800 * fontScale, idealWidth: 950 * fontScale, maxWidth: .infinity, minHeight: 600 * fontScale, idealHeight: 750 * fontScale, maxHeight: .infinity)
    }
    
    private var headerBar: some View {
        HStack {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 20 * fontScale))
                .foregroundColor(.blue)
            Text("\(loc.text("reviewTitle")): \(quiz.title)")
                .font(.system(size: 18 * fontScale, weight: .bold))
            
            Spacer()
            
            Picker("", selection: $filterWrongOnly) {
                Text(loc.text("filterAll")).tag(false)
                Text("\(loc.text("filterWrong")) (\(wrongIds.count))").tag(true)
            }
            .pickerStyle(.segmented)
            .frame(width: 260 * fontScale)
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20 * fontScale))
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
            .padding(.leading, 12 * fontScale)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder
    private func reviewQuestionCard(idx: Int, question: Question) -> some View {
        let chosenOptId = userSelectedOptionIds[question.id]
        let userChoiceIdx = userAnswers[question.id]
        let correctOptId = (question.correctAnswerIndex >= 0 && question.correctAnswerIndex < question.options.count) ? question.options[question.correctAnswerIndex].id : ""
        let isWrong = isQuestionWrong(question: question, chosenOptId: chosenOptId, userChoiceIdx: userChoiceIdx, correctOptId: correctOptId)
        
        GlassCard {
            VStack(alignment: .leading, spacing: 14 * fontScale) {
                HStack {
                    BadgeView(
                        text: "Câu \(idx + 1)",
                        color: isWrong ? .red : .green
                    )
                    
                    Spacer()
                    
                    HStack(spacing: 6 * fontScale) {
                        Image(systemName: isWrong ? "xmark.circle.fill" : "checkmark.circle.fill")
                        Text(isWrong ? "Trả lời Sai" : "Trả lời Đúng")
                    }
                    .font(.system(size: 12 * fontScale, weight: .bold))
                    .foregroundColor(isWrong ? .red : .green)
                }
                
                Text(question.text)
                    .font(.system(size: 16 * fontScale, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 8 * fontScale) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { optIdx, opt in
                        reviewOptionRow(optIdx: optIdx, opt: opt, question: question, chosenOptId: chosenOptId, userChoiceIdx: userChoiceIdx, correctOptId: correctOptId)
                    }
                }
                
                if !question.explanation.isEmpty {
                    VStack(alignment: .leading, spacing: 4 * fontScale) {
                        Text("GIẢI THÍCH:")
                            .font(.system(size: 11 * fontScale, weight: .bold))
                            .foregroundColor(.blue)
                        Text(question.explanation)
                            .font(.system(size: 13 * fontScale))
                            .foregroundColor(.secondary)
                    }
                    .padding(10 * fontScale)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private func reviewOptionRow(optIdx: Int, opt: QuestionOption, question: Question, chosenOptId: String?, userChoiceIdx: Int?, correctOptId: String) -> some View {
        let isUserSelected = chosenOptId != nil ? (chosenOptId == opt.id) : (userChoiceIdx == optIdx)
        let isCorrectOption = !correctOptId.isEmpty ? (opt.id == correctOptId) : (optIdx == question.correctAnswerIndex)
        
        HStack(spacing: 10 * fontScale) {
            Text("\(opt.label). \(opt.text)")
                .font(.system(size: 14 * fontScale, weight: isCorrectOption || isUserSelected ? .bold : .regular))
                .foregroundColor(isCorrectOption ? .green : (isUserSelected ? .red : .primary))
            
            Spacer()
            
            if isCorrectOption {
                BadgeView(text: loc.text("correctChoice"), color: .green)
            } else if isUserSelected {
                BadgeView(text: loc.text("yourChoice"), color: .red)
            }
        }
        .padding(10 * fontScale)
        .background(isCorrectOption ? Color.green.opacity(0.1) : (isUserSelected ? Color.red.opacity(0.1) : Color.clear))
        .cornerRadius(8)
    }
    
    private func isQuestionWrong(question: Question, chosenOptId: String?, userChoiceIdx: Int?, correctOptId: String) -> Bool {
        if wrongIds.contains(question.id) {
            return true
        }
        if let chosenId = chosenOptId {
            return chosenId != correctOptId
        }
        if let uChoice = userChoiceIdx {
            return uChoice != question.correctAnswerIndex
        }
        return true
    }
}
