import SwiftUI
import AppKit

public struct AskGeminiSheet: View {
    let question: Question
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
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
                    .font(.system(size: 20 * fontScale))
                    .foregroundColor(LiquidGlassPalette.cyanTeal)
                Text("Hỏi Gemini AI về Câu hỏi này")
                    .font(.system(size: 18 * fontScale, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20 * fontScale))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18 * fontScale) {
                    
                    // Warning Banner for API Rate Limits
                    HStack(alignment: .top, spacing: 12 * fontScale) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18 * fontScale))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4 * fontScale) {
                            Text("CẢNH BÁO GIỚI HẠN API (API RATE LIMIT):")
                                .font(.system(size: 13 * fontScale, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Chỉ nên đặt câu hỏi trực tiếp cho AI đối với những câu thực sự quan trọng hoặc phức tạp để tránh quá tải hạn ngạch sử dụng Google AI Studio API Key của bạn.")
                                .font(.system(size: 11 * fontScale))
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
                        VStack(alignment: .leading, spacing: 10 * fontScale) {
                            BadgeView(text: "Câu hỏi đang xem", color: LiquidGlassPalette.oceanBlue)
                            Text(question.text)
                                .font(.system(size: 16 * fontScale, weight: .bold))
                            
                            VStack(alignment: .leading, spacing: 4 * fontScale) {
                                ForEach(question.options) { opt in
                                    Text("\(opt.label). \(opt.text)")
                                        .font(.system(size: 13 * fontScale, weight: opt.label == question.correctAnswerLabel ? .bold : .regular))
                                        .foregroundColor(opt.label == question.correctAnswerLabel ? LiquidGlassPalette.emeraldMint : .secondary)
                                }
                            }
                            .padding(.top, 4 * fontScale)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Quick Preset Query Buttons
                    VStack(alignment: .leading, spacing: 8 * fontScale) {
                        Text("Gợi ý thắc mắc nhanh:")
                            .font(.system(size: 12 * fontScale, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8 * fontScale) {
                                presetButton(title: "Giải thích chi tiết tại sao đáp án đúng", query: "Hãy giải thích chi tiết vì sao đáp án đúng là chính xác.")
                                presetButton(title: "Phân tích các đáp án sai", query: "Hãy phân tích chi tiết vì sao từng phương án còn lại là sai.")
                                presetButton(title: "Thêm ví dụ minh họa thực tế", query: "Hãy cho thêm ví dụ minh họa thực tế để hiểu rõ câu hỏi này.")
                            }
                        }
                    }
                    
                    // Custom Query Textfield & Ask Button
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12 * fontScale) {
                            Text("Thắc mắc cụ thể của bạn (Tùy chọn):")
                                .font(.system(size: 14 * fontScale, weight: .semibold))
                            
                            TextField("Ví dụ: Tại sao phương án B lại sai trong trường hợp này?...", text: $userQuery)
                                .textFieldStyle(.roundedBorder)
                            
                            HStack {
                                Spacer()
                                PrimaryButton(
                                    title: "Gửi câu hỏi tới Gemini AI",
                                    icon: "paperplane.fill",
                                    color: LiquidGlassPalette.cyanTeal
                                ) {
                                    sendQueryToGemini()
                                }
                                .disabled(isQuerying)
                            }
                        }
                    }
                    
                    // Loading State
                    if isQuerying {
                        HStack(spacing: 12 * fontScale) {
                            ProgressView()
                            Text("Gemini AI đang phân tích và soạn câu trả lời chi tiết...")
                                .font(.system(size: 13 * fontScale))
                                .foregroundColor(LiquidGlassPalette.cyanTeal)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    if let err = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("✕ Lỗi: \(err)")
                        }
                        .foregroundColor(LiquidGlassPalette.crimsonRed)
                        .font(.system(size: 12 * fontScale))
                        .padding()
                        .background(LiquidGlassPalette.crimsonRed.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // AI Detailed Explanation Result Card with Formatted Markdown Support
                    if let aiText = aiResponseText {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12 * fontScale) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(LiquidGlassPalette.cyanTeal)
                                    Text("Giải thích Chi tiết từ Gemini AI:")
                                        .font(.system(size: 16 * fontScale, weight: .bold))
                                        .foregroundColor(LiquidGlassPalette.cyanTeal)
                                }
                                
                                Divider()
                                
                                // Native Formatted Markdown Rendering using LocalizedStringKey
                                Text(LocalizedStringKey(cleanMarkdownForSwiftUI(aiText)))
                                    .font(.system(size: 14 * fontScale))
                                    .lineSpacing(6 * fontScale)
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
        .frame(width: 680 * fontScale, height: 680 * fontScale)
        .onAppear {
            if !question.explanation.isEmpty && aiResponseText == nil {
                aiResponseText = question.explanation
            }
        }
    }
    
    @ViewBuilder
    private func presetButton(title: String, query: String) -> some View {
        Button(action: {
            userQuery = query
            sendQueryToGemini()
        }) {
            Text(title)
                .font(.system(size: 12 * fontScale))
                .padding(.horizontal, 12 * fontScale)
                .padding(.vertical, 6 * fontScale)
                .background(LiquidGlassPalette.cyanTeal.opacity(0.12))
                .foregroundColor(LiquidGlassPalette.cyanTeal)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LiquidGlassPalette.cyanTeal.opacity(0.3), lineWidth: 1)
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
                    storage.updateQuestionExplanation(questionId: question.id, explanation: response)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isQuerying = false
                }
            }
        }
    }

    
    private func cleanMarkdownForSwiftUI(_ rawText: String) -> String {
        var str = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove code fences
        if str.hasPrefix("```markdown") { str = String(str.dropFirst(11)) }
        if str.hasPrefix("```") { str = String(str.dropFirst(3)) }
        if str.hasSuffix("```") { str = String(str.dropLast(3)) }
        
        // Clean line by line
        let lines = str.components(separatedBy: "\n")
        let cleanedLines = lines.map { line -> String in
            var l = line.trimmingCharacters(in: .whitespaces)
            // Replace markdown headers ### Header -> **Header**
            if l.hasPrefix("### ") { l = "**" + l.dropFirst(4) + "**" }
            else if l.hasPrefix("## ") { l = "**" + l.dropFirst(3) + "**" }
            else if l.hasPrefix("# ") { l = "**" + l.dropFirst(2) + "**" }
            
            // Replace horizontal rules
            if l == "---" || l == "***" || l == "___" { return "───────────────" }
            
            // Replace blockquotes
            if l.hasPrefix("> ") { l = "💡 " + l.dropFirst(2) }
            
            return l
        }
        
        return cleanedLines.joined(separator: "\n")
    }
}
