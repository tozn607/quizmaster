import SwiftUI

public struct ReviewView: View {
    let quiz: Quiz
    let questions: [Question]
    let userAnswers: [String: Int]
    let wrongIds: Set<String>
    
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var filterWrongOnly: Bool = false
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("\(loc.text("reviewTitle")): \(quiz.title)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("", selection: $filterWrongOnly) {
                    Text(loc.text("filterAll")).tag(false)
                    Text("\(loc.text("filterWrong")) (\(wrongIds.count))").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .padding(.leading, 12)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            let displayedQuestions = filterWrongOnly ? questions.filter { wrongIds.contains($0.id) } : questions
            
            ScrollView {
                VStack(spacing: 16) {
                    if displayedQuestions.isEmpty {
                        Text("Không có câu hỏi nào phù hợp với bộ lọc.")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(Array(displayedQuestions.enumerated()), id: \.element.id) { idx, question in
                            let userChoice = userAnswers[question.id]
                            let isWrong = wrongIds.contains(question.id) || (userChoice != nil && userChoice != question.correctAnswerIndex)
                            
                            GlassCard {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        BadgeView(
                                            text: "Câu \(idx + 1)",
                                            color: isWrong ? .red : .green
                                        )
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            Image(systemName: isWrong ? "xmark.circle.fill" : "checkmark.circle.fill")
                                            Text(isWrong ? "Trả lời Sai" : "Trả lời Đúng")
                                        }
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(isWrong ? .red : .green)
                                    }
                                    
                                    Text(question.text)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(Array(question.options.enumerated()), id: \.offset) { optIdx, opt in
                                            let isUserSelected = userChoice == optIdx
                                            let isCorrectOption = optIdx == question.correctAnswerIndex
                                            
                                            HStack(spacing: 10) {
                                                Text("\(opt.label). \(opt.text)")
                                                    .font(.subheadline)
                                                    .foregroundColor(
                                                        isCorrectOption ? .green : (isUserSelected ? .red : .primary)
                                                    )
                                                    .fontWeight(isCorrectOption || isUserSelected ? .bold : .regular)
                                                
                                                Spacer()
                                                
                                                if isCorrectOption {
                                                    BadgeView(text: loc.text("correctChoice"), color: .green)
                                                } else if isUserSelected {
                                                    BadgeView(text: loc.text("yourChoice"), color: .red)
                                                }
                                            }
                                            .padding(10)
                                            .background(
                                                isCorrectOption ? Color.green.opacity(0.1) : (isUserSelected ? Color.red.opacity(0.1) : Color.clear)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    if !question.explanation.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(loc.text("explanation"))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                            Text(question.explanation)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(10)
                                        .background(Color.blue.opacity(0.08))
                                        .cornerRadius(8)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 680, height: 600)
    }
}
