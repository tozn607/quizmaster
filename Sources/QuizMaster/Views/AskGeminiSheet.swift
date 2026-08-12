import SwiftUI
import AppKit

public struct AskGeminiSheet: View {
    let question: Question
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var userQuery: String = ""
    @State private var isQuerying: Bool = false
    @State private var aiResponseText: String? = nil
    @State private var errorMessage: String? = nil
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Hỏi Gemini AI về Câu hỏi này")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Warning Banner for API Rate Limits
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CẢNH BÁO GIỚI HẠN API (API RATE LIMIT):")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Chỉ nên đặt câu hỏi trực tiếp cho AI đối với những câu thực sự quan trọng hoặc phức tạp để tránh quá tải hạn ngạch sử dụng Google AI Studio API Key của bạn.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                    
                    // Question Preview Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            BadgeView(text: "Câu hỏi đang xem", color: .blue)
                            Text(question.text)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(question.options) { opt in
                                    Text("\(opt.label). \(opt.text)")
                                        .font(.caption)
                                        .foregroundColor(opt.label == question.correctAnswerLabel ? .green : .secondary)
                                        .fontWeight(opt.label == question.correctAnswerLabel ? .bold : .regular)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Quick Preset Query Buttons
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gợi ý thắc mắc nhanh:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                presetButton(title: "Giải thích chi tiết tại sao đáp án đúng", query: "Hãy giải thích chi tiết vì sao đáp án đúng là chính xác.")
                                presetButton(title: "Phân tích các đáp án sai", query: "Hãy phân tích chi tiết vì sao từng phương án còn lại là sai.")
                                presetButton(title: "Thêm ví dụ minh họa thực tế", query: "Hãy cho thêm ví dụ minh họa thực tế để hiểu rõ câu hỏi này.")
                            }
                        }
                    }
                    
                    // Custom Query Textfield & Ask Button
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Thắc mắc cụ thể của bạn (Tùy chọn):")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            TextField("Ví dụ: Tại sao phương án B lại sai trong trường hợp này?...", text: $userQuery)
                                .textFieldStyle(.roundedBorder)
                            
                            HStack {
                                Spacer()
                                PrimaryButton(
                                    title: "Gửi câu hỏi tới Gemini 3.5 Flash Lite",
                                    icon: "paperplane.fill",
                                    color: .purple
                                ) {
                                    sendQueryToGemini()
                                }
                                .disabled(isQuerying)
                            }
                        }
                    }
                    
                    // Loading State
                    if isQuerying {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Gemini 3.5 Flash Lite đang phân tích và soạn câu trả lời chi tiết...")
                                .font(.subheadline)
                                .foregroundColor(.purple)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    if let err = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("✕ Lỗi: \(err)")
                        }
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // AI Detailed Explanation Result Card
                    if let aiText = aiResponseText {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.purple)
                                    Text("Giải thích Chi tiết từ Gemini 3.5 Flash Lite:")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.purple)
                                }
                                
                                Divider()
                                
                                Text(aiText)
                                    .font(.body)
                                    .lineSpacing(6)
                                    .textSelection(.enabled)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                SecondaryButton(title: "Đóng", icon: "xmark") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 650, height: 650)
    }
    
    @ViewBuilder
    private func presetButton(title: String, query: String) -> some View {
        Button(action: {
            userQuery = query
            sendQueryToGemini()
        }) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.12))
                .foregroundColor(.purple)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func sendQueryToGemini() {
        isQuerying = true
        errorMessage = nil
        aiResponseText = nil
        
        Task {
            do {
                let response = try await GeminiAPIService.shared.askQuestionDetail(
                    question: question,
                    userQuery: userQuery,
                    apiKey: storage.settings.apiKey,
                    language: loc.currentLanguage
                )
                
                await MainActor.run {
                    aiResponseText = response
                    isQuerying = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isQuerying = false
                }
            }
        }
    }
}
