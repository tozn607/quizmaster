import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct DocumentImportView: View {
    let project: StudyProject
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    // Default Document Scanner State (For General Projects)
    @State private var docFileURL: URL? = nil
    @State private var isCreateMultipleChoice: Bool = false
    @State private var depthMode: QuestionDepthMode = .normal
    @State private var geminiTitle: String = ""
    @State private var isProcessingGemini: Bool = false
    @State private var geminiError: String? = nil
    @State private var geminiSuccessQuiz: Quiz? = nil
    @State private var exportedZipPath: String? = nil
    @State private var showScanConfirmation: Bool = false
    
    // Language Learning Scanner State
    @State private var isLanguageImportExpanded: Bool = false
    @State private var langDocFileURL: URL? = nil
    @State private var langExamTitle: String = ""
    @State private var selectedCEFRLevel: CEFRLevel = .all
    @State private var isProcessingLanguageExam: Bool = false
    @State private var langExamError: String? = nil
    @State private var langSuccessQuiz: Quiz? = nil
    @State private var showLangScanConfirmation: Bool = false
    
    // Bottom Dropdown State for Pre-made Quiz File Import
    @State private var isPremadeImportExpanded: Bool = false
    @State private var quizFileURL: URL? = nil
    @State private var isProcessingQuizFile: Bool = false
    @State private var quizFileError: String? = nil
    
    private var isLLProject: Bool {
        project.projectType == .languageLearning
    }
    
    public var body: some View {
        LiquidGlassWindowBackdrop {
            VStack(spacing: 0) {
                // Header Bar
                HStack {
                    HStack(spacing: 8 * fontScale) {
                        Image(systemName: isLLProject ? "character.book.closed.fill" : "plus.circle.fill")
                            .font(.system(size: 20 * fontScale))
                            .foregroundColor(isLLProject ? LiquidGlassPalette.deepPurple : .accentColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isLLProject ? "Nhập Đề Thi Ngoại Ngữ" : loc.text("importDoc"))
                                .font(.system(size: 18 * fontScale, weight: .bold))
                            
                            Text("Dự án: \(project.name) (\(project.projectType.displayName))")
                                .font(.system(size: 11 * fontScale))
                                .foregroundColor(.secondary)
                        }
                    }
                    
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
                        
                        // SECTION 1: GEMINI AI DOCUMENT SCANNER (For General Project)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14 * fontScale) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 20 * fontScale))
                                        .foregroundColor(.accentColor)
                                    Text("Quét & Nhận diện Bài giảng / Sách giáo khoa")
                                        .font(.system(size: 16 * fontScale, weight: .bold))
                                        .foregroundColor(.purple)
                                    
                                    Spacer()
                                    
                                    if isLLProject {
                                        BadgeView(text: "Chỉ dành cho Dự án Ôn tập Chung", color: .orange)
                                    }
                                }
                                
                                if isLLProject {
                                    HStack(alignment: .top, spacing: 8 * fontScale) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 13 * fontScale))
                                        Text(loc.text("onlyInGeneralProjectNotice"))
                                            .font(.system(size: 12 * fontScale))
                                            .foregroundColor(.orange)
                                    }
                                    .padding(10 * fontScale)
                                    .background(Color.orange.opacity(0.12))
                                    .cornerRadius(8)
                                } else {
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
                                            Text("Gemini AI đang phân tích và quét tài liệu...")
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
                        }
                        
                        // SECTION 2: SECOND DROPDOWN MENU - LANGUAGE LEARNING (For LL Projects)
                        GlassCard {
                            DisclosureGroup(isExpanded: $isLanguageImportExpanded) {
                                VStack(alignment: .leading, spacing: 14 * fontScale) {
                                    if !isLLProject {
                                        HStack(alignment: .top, spacing: 8 * fontScale) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 13 * fontScale))
                                            Text(loc.text("onlyInLLProjectNotice"))
                                                .font(.system(size: 12 * fontScale))
                                                .foregroundColor(.orange)
                                        }
                                        .padding(10 * fontScale)
                                        .background(Color.orange.opacity(0.12))
                                        .cornerRadius(8)
                                    } else {
                                        HStack(alignment: .top, spacing: 10 * fontScale) {
                                            Image(systemName: "wrench.and.screwdriver.fill")
                                                .font(.system(size: 14 * fontScale))
                                                .foregroundColor(LiquidGlassPalette.sunsetOrange)
                                            VStack(alignment: .leading, spacing: 3 * fontScale) {
                                                Text("TÍNH NĂNG ĐANG PHÁT TRIỂN & THỬ NGHIỆM (WIP / EXPERIMENTAL)")
                                                    .font(.system(size: 11 * fontScale, weight: .bold))
                                                    .foregroundColor(LiquidGlassPalette.sunsetOrange)
                                                Text("Chế độ Học Ngoại ngữ đang được hoàn thiện định dạng và tối ưu hóa xử lý văn bản chuyên sâu. Bạn có thể thử nghiệm tính năng này với các đề thi tiếng Anh mẫu.")
                                                    .font(.system(size: 11 * fontScale))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(10 * fontScale)
                                        .background(LiquidGlassPalette.sunsetOrange.opacity(0.12))
                                        .cornerRadius(8)
                                        
                                        Text(loc.text("langLearningDesc"))
                                            .font(.system(size: 12 * fontScale))
                                            .foregroundColor(.secondary)
                                        
                                        Divider()
                                        
                                        // File Selection
                                        VStack(alignment: .leading, spacing: 6 * fontScale) {
                                            Text("Chọn tệp đề thi ngoại ngữ có sẵn (Word .docx / PDF / TXT):")
                                                .font(.system(size: 13 * fontScale, weight: .semibold))
                                            
                                            HStack {
                                                Text(langDocFileURL?.lastPathComponent ?? "Chưa chọn tệp đề thi...")
                                                    .font(.system(size: 13 * fontScale))
                                                    .foregroundColor(langDocFileURL != nil ? .primary : .secondary)
                                                    .lineLimit(1)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(8 * fontScale)
                                                    .background(Color(NSColor.controlBackgroundColor))
                                                    .cornerRadius(6)
                                                
                                                PrimaryButton(title: "Chọn tệp đề...", icon: "doc.badge.plus", color: LiquidGlassPalette.deepPurple) {
                                                    selectLanguageDocFile()
                                                }
                                            }
                                        }
                                        
                                        // Title & CEFR Selector
                                        VStack(alignment: .leading, spacing: 10 * fontScale) {
                                            TextField("Tên đề thi ngoại ngữ (Tùy chọn)...", text: $langExamTitle)
                                                .textFieldStyle(.roundedBorder)
                                            
                                            VStack(alignment: .leading, spacing: 6 * fontScale) {
                                                Text(loc.text("cefrSelectorLabel"))
                                                    .font(.system(size: 13 * fontScale, weight: .semibold))
                                                
                                                Picker("", selection: $selectedCEFRLevel) {
                                                    ForEach(CEFRLevel.allCases) { lvl in
                                                        Text(lvl.displayName).tag(lvl)
                                                    }
                                                }
                                                .pickerStyle(.menu)
                                                
                                                Text("AI sẽ nhận diện bài đọc hiểu (Reading), ngữ pháp / phát âm (Lexical) và trích xuất danh sách thẻ Flashcard từ vựng theo trình độ đã chọn.")
                                                    .font(.system(size: 11 * fontScale))
                                                    .foregroundColor(LiquidGlassPalette.deepPurple)
                                            }
                                        }
                                        
                                        if let err = langExamError {
                                            Text("✕ Lỗi: \(err)")
                                                .font(.system(size: 12 * fontScale))
                                                .foregroundColor(.red)
                                        }
                                        
                                        if isProcessingLanguageExam {
                                            HStack(spacing: 10 * fontScale) {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                                Text("Gemini AI đang phân tích cấu trúc đề ngoại ngữ & trích xuất từ vựng CEFR...")
                                                    .font(.system(size: 13 * fontScale))
                                                    .foregroundColor(LiquidGlassPalette.deepPurple)
                                            }
                                        } else {
                                            HStack {
                                                Spacer()
                                                PrimaryButton(title: loc.text("startLangScanBtn"), icon: "sparkles", color: LiquidGlassPalette.deepPurple) {
                                                    showLangScanConfirmation = true
                                                }
                                                .disabled(langDocFileURL == nil)
                                            }
                                        }
                                        
                                        if let createdQuiz = langSuccessQuiz {
                                            VStack(alignment: .leading, spacing: 8 * fontScale) {
                                                HStack {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                    Text("Đã quét thành công! Bộ đề \"\(createdQuiz.title)\" (\(createdQuiz.questions.count) câu hỏi, \(createdQuiz.vocabularies.count) từ vựng Flashcard).")
                                                        .font(.system(size: 13 * fontScale, weight: .bold))
                                                        .foregroundColor(.green)
                                                }
                                            }
                                            .padding(12 * fontScale)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.top, 10 * fontScale)
                            } label: {
                                HStack {
                                    Image(systemName: "character.book.closed.fill")
                                        .font(.system(size: 18 * fontScale))
                                        .foregroundColor(LiquidGlassPalette.deepPurple)
                                    Text(loc.text("langLearningHeader"))
                                        .font(.system(size: 15 * fontScale, weight: .bold))
                                        .foregroundColor(LiquidGlassPalette.deepPurple)
                                    
                                    Spacer()
                                    
                                    BadgeView(text: "⚠️ Thử nghiệm (WIP)", color: LiquidGlassPalette.sunsetOrange)
                                }
                            }
                        }
                        
                        // SECTION 3: BOTTOM DROPDOWN MENU - PRE-MADE QUIZ FILE IMPORT
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
        .frame(width: 740 * fontScale, height: 760 * fontScale)
        .onAppear {
            if isLLProject {
                isLanguageImportExpanded = true
            }
        }
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
        .confirmationDialog(
            "Xác nhận quét Đề Ngoại Ngữ",
            isPresented: $showLangScanConfirmation,
            titleVisibility: .visible
        ) {
            Button("Bắt đầu Quét Đề Ngoại Ngữ", role: .none) {
                processLanguageExamDoc()
            }
            Button("Hủy bỏ", role: .cancel) {}
        } message: {
            Text("AI sẽ trích xuất toàn bộ câu hỏi đề thi (Reading, Ngữ pháp, Nghe...) và tạo bộ thẻ từ vựng Flashcard theo trình độ CEFR đã chọn.")
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
    
    private func selectLanguageDocFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            langDocFileURL = url
            if langExamTitle.isEmpty {
                langExamTitle = url.deletingPathExtension().lastPathComponent
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
                
                let quiz = Quiz(title: title, questions: questions, isPreMade: !isCreateMultipleChoice, quizType: .general)
                
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
    
    private func processLanguageExamDoc() {
        guard let url = langDocFileURL else { return }
        isProcessingLanguageExam = true
        langExamError = nil
        langSuccessQuiz = nil
        
        Task {
            do {
                let extractedText = try await DocumentProcessor.shared.extractText(from: url)
                guard !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw NSError(domain: "DocumentImport", code: 1, userInfo: [NSLocalizedDescriptionKey: "Tài liệu rỗng hoặc không thể trích xuất văn bản."])
                }
                
                let title = langExamTitle.isEmpty ? url.deletingPathExtension().lastPathComponent : langExamTitle
                
                let result = try await GeminiAPIService.shared.generateLanguageExam(
                    from: extractedText,
                    targetCEFR: selectedCEFRLevel,
                    apiKey: storage.settings.apiKey
                )
                
                let quiz = Quiz(
                    title: title,
                    description: "Đề thi Ngoại ngữ • Khung \(selectedCEFRLevel.badgeLabel)",
                    questions: result.questions,
                    isPreMade: true,
                    quizType: .languageLearning,
                    targetCEFR: selectedCEFRLevel,
                    vocabularies: result.vocabularies,
                    durationMinutes: result.detectedDurationMinutes
                )
                
                await MainActor.run {
                    storage.addQuiz(to: project.id, quiz: quiz)
                    langSuccessQuiz = quiz
                    isProcessingLanguageExam = false
                }
            } catch {
                await MainActor.run {
                    langExamError = error.localizedDescription
                    isProcessingLanguageExam = false
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
                // Enforce project type matching
                if isLLProject && quiz.quizType != .languageLearning {
                    throw NSError(domain: "DocumentImport", code: 2, userInfo: [NSLocalizedDescriptionKey: "Không thể nạp bộ đề thông thường vào Dự án Ngoại ngữ. Vui lòng chọn Dự án Ôn tập Chung."])
                } else if !isLLProject && quiz.quizType == .languageLearning {
                    throw NSError(domain: "DocumentImport", code: 3, userInfo: [NSLocalizedDescriptionKey: "Không thể nạp bộ đề Ngoại ngữ vào Dự án Ôn tập Chung. Vui lòng chuyển sang Dự án Ngoại ngữ."])
                }
                
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
