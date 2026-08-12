import SwiftUI
import AppKit

public struct DocumentImportView: View {
    let project: StudyProject
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    // Section 1: Gemini AI Document Scanner
    @State private var docFileURL: URL? = nil
    @State private var isCreateMultipleChoice: Bool = true
    @State private var depthMode: QuestionDepthMode = .normal
    @State private var geminiTitle: String = ""
    @State private var isProcessingGemini: Bool = false
    @State private var geminiError: String? = nil
    @State private var geminiSuccessQuiz: Quiz? = nil
    @State private var exportedZipPath: String? = nil
    
    // Section 2: Pre-made Quiz File / Zip Import
    @State private var premadeFileURL: URL? = nil
    @State private var premadeTitle: String = ""
    @State private var isProcessingPremade: Bool = false
    @State private var premadeError: String? = nil
    @State private var premadeSuccessMsg: String? = nil
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "doc.badge.plus")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(loc.text("importTitle"))
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
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Notice Banner
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc.text("importNoticeTitle"))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text(loc.text("importNoticeBody"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    
                    // ==========================================
                    // SECTION 1: GEMINI AI DOCUMENT SCANNER
                    // ==========================================
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                Text("PHẦN 1: QUÉT TÀI LIỆU VỚI GEMINI 3.5 FLASH LITE")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                            
                            Text("Dành cho tài liệu chưa có bộ đề (PDF, Word .docx, Văn bản bài giảng). AI sẽ tự động phân tích toàn bộ tài liệu và tạo bộ câu hỏi trắc nghiệm phủ rộng nội dung.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            HStack {
                                Button(action: chooseDocFile) {
                                    HStack {
                                        Image(systemName: "doc.fill")
                                        Text(docFileURL != nil ? docFileURL!.lastPathComponent : "Chọn Tệp Tài liệu (PDF / DOCX / TXT)")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.purple.opacity(0.12))
                                    .foregroundColor(.purple)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                                
                                if docFileURL != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            TextField("Tên bộ đề mới...", text: $geminiTitle)
                                .textFieldStyle(.roundedBorder)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Độ phủ & Mức độ chi tiết của câu hỏi (Depth Mode):")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Picker("", selection: $depthMode) {
                                    ForEach(QuestionDepthMode.allCases) { mode in
                                        Text(mode.displayName).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                Text(depthMode.description)
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                                    .italic()
                            }
                            
                            Toggle(isOn: $isCreateMultipleChoice) {
                                Text("Bật \"Tạo câu hỏi trắc nghiệm tự động\" từ nội dung văn bản")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .toggleStyle(.checkbox)
                            
                            if isProcessingGemini {
                                HStack(spacing: 10) {
                                    ProgressView()
                                    Text("Đang gửi tới Gemini 3.5 Flash Lite để quét OCR & tạo trắc nghiệm...")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                }
                            }
                            
                            if let err = geminiError {
                                Text("✕ Lỗi: \(err)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            if let quiz = geminiSuccessQuiz {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Đã quét và tạo thành công \(quiz.questions.count) câu hỏi!")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                    
                                    // Direct Export Options
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Xuất kết quả bộ đề vừa quét:")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                        
                                        HStack(spacing: 12) {
                                            PrimaryButton(
                                                title: "Xuất Gói Zip RTF (Mặc định - Có thể Nhập lại)",
                                                icon: "archivebox.fill",
                                                color: .green
                                            ) {
                                                exportGeminiQuizToZip(quiz: quiz)
                                            }
                                            
                                            SecondaryButton(
                                                title: "Xuất Tệp Word (Chỉ xem/in - Không nhập lại)",
                                                icon: "doc.text.fill"
                                            ) {
                                                exportGeminiQuizToWordOnly(quiz: quiz)
                                            }
                                        }
                                        
                                        if let path = exportedZipPath {
                                            HStack {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .foregroundColor(.green)
                                                Text("Đã xuất: \(URL(fileURLWithPath: path).lastPathComponent)")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(12)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            } else {
                                HStack {
                                    Spacer()
                                    PrimaryButton(
                                        title: "Bắt đầu Quét với Gemini AI",
                                        icon: "sparkles",
                                        color: .purple
                                    ) {
                                        processGeminiDoc()
                                    }
                                    .disabled(docFileURL == nil || isProcessingGemini)
                                }
                            }
                        }
                    }
                    
                    // ==========================================
                    // SECTION 2: PRE-MADE QUIZ FILE / ZIP IMPORT
                    // ==========================================
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "archivebox.fill")
                                    .foregroundColor(.blue)
                                Text("PHẦN 2: NHẬP BỘ ĐỀ CÓ SẴN (FILE / ZIP BUNDLE)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Dành cho các bộ đề đã soạn sẵn (file .zip bundle hoặc file .json quiz). Nhập nhanh tức thì không cần qua AI.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            HStack {
                                Button(action: choosePremadeFile) {
                                    HStack {
                                        Image(systemName: "folder.badge.gearshape")
                                        Text(premadeFileURL != nil ? premadeFileURL!.lastPathComponent : "Chọn Tệp Bộ đề (.zip bundle hoặc .json)")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                                
                                if premadeFileURL != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            TextField("Tên bộ đề (Để trống sẽ lấy theo tên tệp)...", text: $premadeTitle)
                                .textFieldStyle(.roundedBorder)
                            
                            if isProcessingPremade {
                                HStack(spacing: 10) {
                                    ProgressView()
                                    Text("Đang nhập bộ đề...")
                                        .font(.caption)
                                }
                            }
                            
                            if let err = premadeError {
                                Text("✕ Lỗi: \(err)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            if let msg = premadeSuccessMsg {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(msg)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            HStack {
                                Spacer()
                                PrimaryButton(
                                    title: "Nhập Bộ Đề Có Sẵn",
                                    icon: "arrow.down.doc.fill",
                                    color: .blue
                                ) {
                                    processPremadeImport()
                                }
                                .disabled(premadeFileURL == nil || isProcessingPremade)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer Close
            HStack {
                Spacer()
                SecondaryButton(title: "Đóng", icon: "xmark") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 640, height: 650)
        .onAppear {
            if storage.settings.apiKey.isEmpty {
                geminiError = "Vui lòng nhập Gemini API Key trong Cài đặt trước khi dùng tính năng quét AI."
            }
        }
    }
    
    // MARK: - Handlers for Section 1 (Gemini)
    private func chooseDocFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.pdf, .plainText, .rtf]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                docFileURL = url
                if geminiTitle.isEmpty {
                    geminiTitle = url.deletingPathExtension().lastPathComponent
                }
            }
        }
    }
    
    private func processGeminiDoc() {
        guard let url = docFileURL else { return }
        isProcessingGemini = true
        geminiError = nil
        geminiSuccessQuiz = nil
        
        let title = geminiTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? url.deletingPathExtension().lastPathComponent : geminiTitle
        
        Task {
            do {
                let extractedText = try await DocumentProcessor.shared.extractText(from: url)
                let questions = try await GeminiAPIService.shared.generateQuiz(
                    from: extractedText,
                    isCreateMultipleChoice: isCreateMultipleChoice,
                    apiKey: storage.settings.apiKey,
                    language: loc.currentLanguage,
                    depthMode: depthMode
                )
                
                let quiz = Quiz(title: title, questions: questions, isPreMade: !isCreateMultipleChoice)
                
                await MainActor.run {
                    storage.addQuiz(to: project.id, quiz: quiz)
                    geminiSuccessQuiz = quiz
                    isProcessingGemini = false
                }
            } catch {
                await MainActor.run {
                    geminiError = error.localizedDescription
                    isProcessingGemini = false
                }
            }
        }
    }
    
    private func exportGeminiQuizToZip(quiz: Quiz) {
        do {
            let zipPath = try WordExporter.shared.exportQuizToZipBundle(quiz: quiz, outputDirectory: storage.settings.defaultOutputDirectory)
            exportedZipPath = zipPath
        } catch {
            geminiError = "Lỗi xuất Zip: \(error.localizedDescription)"
        }
    }
    
    private func exportGeminiQuizToWordOnly(quiz: Quiz) {
        do {
            let zipPath = try WordExporter.shared.exportQuizToWordDocxZip(quiz: quiz, outputDirectory: storage.settings.defaultOutputDirectory)
            exportedZipPath = zipPath
        } catch {
            geminiError = "Lỗi xuất Word Docx Zip: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Handlers for Section 2 (Pre-made Import)
    private func choosePremadeFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                premadeFileURL = url
                if premadeTitle.isEmpty {
                    premadeTitle = url.deletingPathExtension().lastPathComponent
                }
            }
        }
    }
    
    private func processPremadeImport() {
        guard let url = premadeFileURL else { return }
        isProcessingPremade = true
        premadeError = nil
        premadeSuccessMsg = nil
        
        let title = premadeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? url.deletingPathExtension().lastPathComponent : premadeTitle
        
        Task {
            do {
                var questions: [Question]? = nil
                let ext = url.pathExtension.lowercased()
                
                if ext == "zip" {
                    questions = try DocumentProcessor.shared.extractQuizFromZip(url: url)
                } else if ext == "json" {
                    let data = try Data(contentsOf: url)
                    questions = try? JSONDecoder().decode([Question].self, from: data)
                }
                
                guard let validQuestions = questions, !validQuestions.isEmpty else {
                    throw NSError(domain: "Import", code: 20, userInfo: [NSLocalizedDescriptionKey: "Tệp không chứa bộ đề hợp lệ hoặc bị lỗi định dạng."])
                }
                
                let quiz = Quiz(title: title, questions: validQuestions, isPreMade: true)
                
                await MainActor.run {
                    storage.addQuiz(to: project.id, quiz: quiz)
                    premadeSuccessMsg = "Đã nhập thành công bộ đề với \(validQuestions.count) câu hỏi!"
                    isProcessingPremade = false
                }
            } catch {
                await MainActor.run {
                    premadeError = error.localizedDescription
                    isProcessingPremade = false
                }
            }
        }
    }
}
