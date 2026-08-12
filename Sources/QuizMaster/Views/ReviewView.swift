import SwiftUI

public struct ReviewView: View {
    let quiz: Quiz
    let questions: [Question]
    let userAnswers: [String: Int]
    let wrongIds: Set<String>
    
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var filterWrongOnly: Bool = false
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
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
            
            Divider()
            
            let displayedQuestions = filterWrongOnly ? questions.filter { wrongIds.contains($0.id) } : questions
            
            ScrollView {
                VStack(spacing: 16 * fontScale) {
                    if displayedQuestions.isEmpty {
                        Text("Không có câu hỏi nào phù hợp với bộ lọc.")
                            .font(.system(size: 14 * fontScale))
                            .foregroundColor(.secondary)
                            .padding(.top, 40 * fontScale)
                    } else {
                        ForEach(Array(displayedQuestions.enumerated()), id: \.element.id) { idx, question in
                            let userChoice = userAnswers[question.id]
                            let isWrong = wrongIds.contains(question.id) || (userChoice != nil && userChoice != question.correctAnswerIndex)
                            
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
                                            let isUserSelected = userChoice == optIdx
                                            let isCorrectOption = optIdx == question.correctAnswerIndex
                                            
                                            HStack(spacing: 10 * fontScale) {
                                                Text("\(opt.label). \(opt.text)")
                                                    .font(.system(size: 14 * fontScale, weight: isCorrectOption || isUserSelected ? .bold : .regular))
                                                    .foregroundColor(
                                                        isCorrectOption ? .green : (isUserSelected ? .red : .primary)
                                                    )
                                                
                                                Spacer()
                                                
                                                if isCorrectOption {
                                                    BadgeView(text: loc.text("correctChoice"), color: .green)
                                                } else if isUserSelected {
                                                    BadgeView(text: loc.text("yourChoice"), color: .red)
                                                }
                                            }
                                            .padding(10 * fontScale)
                                            .background(
                                                isCorrectOption ? Color.green.opacity(0.1) : (isUserSelected ? Color.red.opacity(0.1) : Color.clear)
                                            )
                                            .cornerRadius(8)
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
                    }
                }
                .padding()
            }
        }
        .frame(width: 720 * fontScale, height: 640 * fontScale)
    }
}
