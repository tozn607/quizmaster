import SwiftUI

public struct QuizEditorView: View {
    let projectId: String
    @Binding var quiz: Quiz
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    @State private var editedTitle: String = ""
    @State private var editedQuestions: [Question] = []
    @State private var selectedQuestionIndex: Int = 0
    @State private var showSavedAlert: Bool = false
    
    public init(projectId: String, quiz: Binding<Quiz>) {
        self.projectId = projectId
        self._quiz = quiz
    }
    
    public var body: some View {
        LiquidGlassWindowBackdrop {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Đóng")
                        }
                        .font(.system(size: 13 * fontScale))
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Chỉnh sửa Bộ đề: \(editedTitle)")
                        .font(.system(size: 16 * fontScale, weight: .bold))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    PrimaryButton(title: "Lưu thay đổi", icon: "checkmark", color: LiquidGlassPalette.emeraldMint) {
                        saveChanges()
                    }
                }
                .padding()
                .background(.thinMaterial)
                
                Divider()
                
                // Main split layout: Questions sidebar on left, editing pane on right
                HStack(spacing: 0) {
                    // Left sidebar: Questions list
                    VStack(alignment: .leading, spacing: 10 * fontScale) {
                        HStack {
                            Text("Danh sách câu hỏi (\(editedQuestions.count))")
                                .font(.system(size: 13 * fontScale, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: addNewQuestion) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                            .help("Thêm câu hỏi mới")
                        }
                        .padding(.horizontal, 14 * fontScale)
                        .padding(.top, 12 * fontScale)
                        
                        List(selection: $selectedQuestionIndex) {
                            ForEach(0..<editedQuestions.count, id: \.self) { idx in
                                HStack {
                                    Text("Câu \(idx + 1)")
                                        .font(.system(size: 13 * fontScale, weight: idx == selectedQuestionIndex ? .bold : .regular))
                                    Spacer()
                                    if idx < editedQuestions.count {
                                        Text(editedQuestions[idx].correctAnswerLabel)
                                            .font(.system(size: 11 * fontScale, weight: .bold))
                                            .foregroundColor(.green)
                                    }
                                }
                                .tag(idx)
                            }
                            .onDelete(perform: deleteQuestions)
                        }
                        .listStyle(.sidebar)
                    }
                    .frame(width: 220 * fontScale)
                    .background(.ultraThinMaterial)
                    
                    Divider()
                    
                    // Right detail editor
                    if selectedQuestionIndex >= 0 && selectedQuestionIndex < editedQuestions.count {
                        questionEditDetail(index: selectedQuestionIndex)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "pencil.and.list.clipboard")
                                .font(.system(size: 40 * fontScale))
                                .foregroundColor(.gray)
                            Text("Chọn một câu hỏi ở bên trái để chỉnh sửa nội dung và đáp án.")
                                .font(.system(size: 13 * fontScale))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .frame(minWidth: 850, minHeight: 620)
        .onAppear {
            editedTitle = quiz.title
            editedQuestions = quiz.questions
            if selectedQuestionIndex >= editedQuestions.count {
                selectedQuestionIndex = 0
            }
        }
        .alert("Đã lưu thành công!", isPresented: $showSavedAlert) {
            Button("OK") {}
        } message: {
            Text("Các thay đổi về câu hỏi và đáp án đã được cập nhật vào bộ đề thi.")
        }
    }
    
    // MARK: - Question Detail Editor
    private func questionEditDetail(index: Int) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16 * fontScale) {
                // Question text input
                VStack(alignment: .leading, spacing: 6 * fontScale) {
                    Text("Nội dung câu hỏi:")
                        .font(.system(size: 13 * fontScale, weight: .bold))
                    
                    TextEditor(text: $editedQuestions[index].text)
                        .font(.system(size: 14 * fontScale))
                        .frame(minHeight: 80)
                        .padding(4)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                }
                
                Divider()
                
                // Options list editor
                VStack(alignment: .leading, spacing: 10 * fontScale) {
                    HStack {
                        Text("Các phương án lựa chọn:")
                            .font(.system(size: 13 * fontScale, weight: .bold))
                        Spacer()
                        Text("(Chọn nút tròn để đánh dấu đáp án ĐÚNG)")
                            .font(.system(size: 11 * fontScale))
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(0..<editedQuestions[index].options.count, id: \.self) { optIdx in
                        HStack(spacing: 10 * fontScale) {
                            Button(action: {
                                editedQuestions[index].correctAnswerIndex = optIdx
                            }) {
                                Image(systemName: editedQuestions[index].correctAnswerIndex == optIdx ? "largecircle.fill.circle" : "circle")
                                    .font(.system(size: 16 * fontScale))
                                    .foregroundColor(editedQuestions[index].correctAnswerIndex == optIdx ? LiquidGlassPalette.emeraldMint : .gray)
                            }
                            .buttonStyle(.plain)
                            .help("Đánh dấu đây là đáp án đúng")
                            
                            Text(editedQuestions[index].options[optIdx].label + ".")
                                .font(.system(size: 14 * fontScale, weight: .bold))
                                .frame(width: 24 * fontScale)
                            
                            TextField("Nội dung phương án...", text: $editedQuestions[index].options[optIdx].text)
                                .textFieldStyle(.roundedBorder)
                            
                            Button(action: {
                                if editedQuestions[index].options.count > 2 {
                                    editedQuestions[index].options.remove(at: optIdx)
                                    if editedQuestions[index].correctAnswerIndex >= editedQuestions[index].options.count {
                                        editedQuestions[index].correctAnswerIndex = 0
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                            .disabled(editedQuestions[index].options.count <= 2)
                        }
                    }
                    
                    if editedQuestions[index].options.count < 6 {
                        Button(action: {
                            let labels = ["A", "B", "C", "D", "E", "F"]
                            let nextIdx = editedQuestions[index].options.count
                            let newLabel = nextIdx < labels.count ? labels[nextIdx] : "\(nextIdx + 1)"
                            editedQuestions[index].options.append(QuestionOption(label: newLabel, text: ""))
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Thêm phương án")
                            }
                            .font(.system(size: 12 * fontScale))
                        }
                        .padding(.top, 4)
                    }
                }
                
                Divider()
                
                // Explanation Editor
                VStack(alignment: .leading, spacing: 6 * fontScale) {
                    Text("Lời giải thích / Hướng dẫn chi tiết:")
                        .font(.system(size: 13 * fontScale, weight: .bold))
                    
                    TextEditor(text: $editedQuestions[index].explanation)
                        .font(.system(size: 13 * fontScale))
                        .frame(minHeight: 60)
                        .padding(4)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                }
            }
            .padding()
        }
    }
    
    private func addNewQuestion() {
        let newQ = Question(
            text: "Câu hỏi mới...",
            options: [
                QuestionOption(label: "A", text: "Phương án A"),
                QuestionOption(label: "B", text: "Phương án B"),
                QuestionOption(label: "C", text: "Phương án C"),
                QuestionOption(label: "D", text: "Phương án D")
            ],
            correctAnswerIndex: 0,
            explanation: ""
        )
        editedQuestions.append(newQ)
        selectedQuestionIndex = editedQuestions.count - 1
    }
    
    private func deleteQuestions(at offsets: IndexSet) {
        editedQuestions.remove(atOffsets: offsets)
        if selectedQuestionIndex >= editedQuestions.count {
            selectedQuestionIndex = max(0, editedQuestions.count - 1)
        }
    }
    
    private func saveChanges() {
        var updated = quiz
        updated.title = editedTitle
        updated.questions = editedQuestions
        quiz = updated
        storage.updateQuiz(projectId: projectId, quiz: updated)
        showSavedAlert = true
    }
}
