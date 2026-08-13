import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct DocumentImportView: View {
    let project: StudyProject
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    // Default Document Scanner State
    @State private var docFileURL: URL? = nil
    @State private var isCreateMultipleChoice: Bool = false
    @State private var depthMode: QuestionDepthMode = .normal
    @State private var geminiTitle: String = ""
    @State private var isProcessingGemini: Bool = false
    @State private var geminiError: String? = nil
    @State private var geminiSuccessQuiz: Quiz? = nil
    @State private var exportedZipPath: String? = nil
    @State private var showScanConfirmation: Bool = false
    
    // Bottom Dropdown State for Pre-made Quiz File Import
    @State private var isPremadeImportExpanded: Bool = false
    @State private var quizFileURL: URL? = nil
    @State private var isProcessingQuizFile: Bool = false
    @State private var quizFileError: String? = nil
    
    public var body: some View {
        LiquidGlassWindowBackdrop {
            VStack(spacing: 0) {
                // Header Bar
                HStack {
                    Text(loc.text("importDoc"))
                        .font(.system(size: 20 * fontScale, weight: .bold))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20 * fontScale))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(.thinMaterial)
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20 * fontScale) {
                        
                        // DEFAULT MAIN SECTION: GEMINI AI DOCUMENT SCANNER
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14 * fontScale) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 20 * fontScale))
                                        .foregroundColor(.accentColor)
                                    Text("Quét & Nhận diện Tài liệu với Gemini 3.5 Flash Lite")
                                        .font(.system(size: 16 * fontScale, weight: .bold))
                                    .foregroundColor(.purple)
                            }
                            
                            VStack(alignment: .leading, spacing: 8 * fontScale) {
                                Text("Khuyên dùng cho người dùng tải lên tài liệu bài giảng, sách giáo khoa hoặc tệp câu hỏi có sẵn (Word/PDF/TXT).")
                                    .font(.system(size: 12 * fontScale))
                                    .foregroundColor(.secondary)
                                
                                HStack(alignment: .top, spacing: 8 * fontScale) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(LiquidGlassPalette.sunsetOrange)
                                        .font(.system(size: 13 * fontScale))
                                    
                                    Text(loc.text("documentLengthWarningNote"))
                                        .font(.system(size: 12 * fontScale, weight: .bold))
                                        .foregroundColor(LiquidGlassPalette.sunsetOrange)
                                }
                                .padding(10 * fontScale)
                                .background(LiquidGlassPalette.sunsetOrange.opacity(0.12))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(LiquidGlassPalette.sunsetOrange.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            Divider()
                            
                            // File Selection
                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                Text("Chọn tệp tài liệu (Word .docx / PDF / TXT):")
                                    .font(.system(size: 13 * fontScale, weight: .semibold))
                                
                                HStack {
                                    Text(docFileURL?.lastPathComponent ?? "Chưa chọn tệp...")
                                        .font(.system(size: 13 * fontScale))
                                        .foregroundColor(docFileURL != nil ? .primary : .secondary)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8 * fontScale)
                                        .background(Color(NSColor.controlBackgroundColor))
                                        .cornerRadius(6)
                                    
                                    PrimaryButton(title: "Chọn tệp...", icon: "doc.badge.plus", color: .purple) {
                                        selectDocumentFile()
                                    }
                                }
                            }
                            
                            // Title & Toggles
                            VStack(alignment: .leading, spacing: 10 * fontScale) {
                                TextField("Tên bộ đề mới (Tùy chọn)...", text: $geminiTitle)
                                    .textFieldStyle(.roundedBorder)
                                
                                Toggle(isOn: $isCreateMultipleChoice) {
                                    Text("Bật \"Tạo câu hỏi trắc nghiệm tự động\" từ tài liệu văn bản thường")
                                        .font(.system(size: 13 * fontScale, weight: .semibold))
                                }
                                .toggleStyle(.checkbox)
                                
                                // Show Depth Control ONLY when "Create Multiple-Choice" is ON!
                                if isCreateMultipleChoice {
                                    VStack(alignment: .leading, spacing: 6 * fontScale) {
                                        Text("Độ phủ & Mức độ chi tiết của câu hỏi (Depth Mode):")
                                            .font(.system(size: 13 * fontScale, weight: .semibold))
                                        
                                        Picker("", selection: $depthMode) {
                                            ForEach(QuestionDepthMode.allCases) { mode in
                                                Text(mode.displayName).tag(mode)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                        
                                        Text(depthMode.description)
                                            .font(.system(size: 11 * fontScale))
                                            .foregroundColor(.purple)
                                            .italic()
                                    }
                                    .padding(.top, 4 * fontScale)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            
                            if let err = geminiError {
                                Text("✕ Lỗi: \(err)")
                                    .font(.system(size: 12 * fontScale))
                                    .foregroundColor(.red)
                            }
                            
                            if isProcessingGemini {
                                HStack(spacing: 10 * fontScale) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Gemini 3.5 Flash Lite đang phân tích và quét tài liệu...")
                                        .font(.system(size: 13 * fontScale))
                                        .foregroundColor(.purple)
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    PrimaryButton(title: "Bắt đầu Quét với Gemini AI", icon: "sparkles", color: .purple) {
                                        showScanConfirmation = true
                                    }
                                    .disabled(docFileURL == nil)
                                }
                            }
                            
                            // Success & Immediate Export triggers
                            if let createdQuiz = geminiSuccessQuiz {
                                VStack(alignment: .leading, spacing: 10 * fontScale) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Đã quét thành công! Bộ đề \"\(createdQuiz.title)\" (\(createdQuiz.questions.count) câu) đã thêm vào dự án.")
                                            .font(.system(size: 13 * fontScale, weight: .bold))
                                            .foregroundColor(.green)
                                    }
                                    
                                    HStack(spacing: 12 * fontScale) {
                                        PrimaryButton(title: "Xuất ngay file Zip (RTF Bundle)", icon: "archivebox.fill", color: .blue) {
                                            exportImmediately(quiz: createdQuiz, isWord: false)
                                        }
                                        
                                        PrimaryButton(title: "Xuất ngay file Word (.docx)", icon: "doc.text.fill", color: .indigo) {
                                            exportImmediately(quiz: createdQuiz, isWord: true)
                                        }
                                    }
                                    
                                    if let path = exportedZipPath {
                                        Text("✓ Đã xuất tại: \(path)")
                                            .font(.system(size: 11 * fontScale))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(12 * fontScale)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // BOTTOM DROPDOWN MENU: PRE-MADE QUIZ FILE IMPORT
                    GlassCard {
                        DisclosureGroup(isExpanded: $isPremadeImportExpanded) {
                            VStack(alignment: .leading, spacing: 14 * fontScale) {
                                Text("Dành cho người dùng nạp bài thi có sẵn dưới dạng tệp Zip Bundle (.zip) hoặc tệp JSON được xuất từ ứng dụng trước đây.")
                                    .font(.system(size: 12 * fontScale))
                                    .foregroundColor(.secondary)
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 6 * fontScale) {
                                    Text("Chọn tệp bộ đề (.zip hoặc .json):")
                                        .font(.system(size: 13 * fontScale, weight: .semibold))
                                    
                                    HStack {
                                        Text(quizFileURL?.lastPathComponent ?? "Chưa chọn tệp bộ đề...")
                                            .font(.system(size: 13 * fontScale))
                                            .foregroundColor(quizFileURL != nil ? .primary : .secondary)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(8 * fontScale)
                                            .background(Color(NSColor.controlBackgroundColor))
                                            .cornerRadius(6)
                                        
                                        SecondaryButton(title: "Chọn tệp đề...", icon: "folder.badge.plus") {
                                            selectQuizFile()
                                        }
                                    }
                                }
                                
                                if let err = quizFileError {
                                    Text("✕ Lỗi: \(err)")
                                        .font(.system(size: 12 * fontScale))
                                        .foregroundColor(.red)
                                }
                                
                                HStack {
                                    Spacer()
                                    PrimaryButton(title: "Nhập Bộ Đề Có Sẵn vào Dự án", icon: "square.and.arrow.down.fill", color: .blue) {
                                        processQuizFileImport()
                                    }
                                    .disabled(quizFileURL == nil || isProcessingQuizFile)
                                }
                            }
                            .padding(.top, 10 * fontScale)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.doc.fill")
                                    .font(.system(size: 18 * fontScale))
                                    .foregroundColor(.blue)
                                Text(loc.text("orImportPremade"))
                                    .font(.system(size: 14 * fontScale, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer Bar
            HStack {
                Spacer()
                SecondaryButton(title: "Đóng", icon: "xmark") {
                    dismiss()
                }
            }
            .padding()
            .background(.thinMaterial)
        }
        }
        .frame(width: 720 * fontScale, height: 740 * fontScale)
        .confirmationDialog(
            loc.text("confirmScanTitle"),
            isPresented: $showScanConfirmation,
            titleVisibility: .visible
        ) {
            Button("Bắt đầu Quét với Gemini AI", role: .none) {
                processGeminiDoc()
            }
            Button("Hủy bỏ", role: .cancel) {}
        } message: {
            Text(isCreateMultipleChoice ? loc.text("confirmScanMsgToggleOn") : loc.text("confirmScanMsgToggleOff"))
        }
    }
    
    // MARK: - Actions & Helpers
    private func selectDocumentFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            docFileURL = url
            if geminiTitle.isEmpty {
                geminiTitle = url.deletingPathExtension().lastPathComponent
            }
        }
    }
    
    private func selectQuizFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            quizFileURL = url
        }
    }
    
    private func processGeminiDoc() {
        guard let url = docFileURL else { return }
        isProcessingGemini = true
        geminiError = nil
        geminiSuccessQuiz = nil
        exportedZipPath = nil
        
        Task {
            do {
                let extractedText = try await DocumentProcessor.shared.extractText(from: url)
                guard !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw NSError(domain: "DocumentImport", code: 1, userInfo: [NSLocalizedDescriptionKey: "Tài liệu rỗng hoặc không thể trích xuất văn bản."])
                }
                
                let title = geminiTitle.isEmpty ? url.deletingPathExtension().lastPathComponent : geminiTitle
                
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
    
    private func processQuizFileImport() {
        guard let url = quizFileURL else { return }
        isProcessingQuizFile = true
        quizFileError = nil
        
        Task {
            do {
                let quiz = try DocumentProcessor.shared.extractQuizFromFile(at: url)
                await MainActor.run {
                    storage.addQuiz(to: project.id, quiz: quiz)
                    isProcessingQuizFile = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    quizFileError = error.localizedDescription
                    isProcessingQuizFile = false
                }
            }
        }
    }
    
    private func exportImmediately(quiz: Quiz, isWord: Bool) {
        let outputDir = storage.settings.defaultOutputDirectory
        do {
            let zipPath: String
            if isWord {
                zipPath = try WordExporter.shared.exportQuizToWordDocxZip(quiz: quiz, outputDirectory: outputDir)
            } else {
                zipPath = try WordExporter.shared.exportQuizToZipBundle(quiz: quiz, outputDirectory: outputDir)
            }
            exportedZipPath = zipPath
        } catch {
            geminiError = "Lỗi xuất Zip: \(error.localizedDescription)"
        }
    }
}
