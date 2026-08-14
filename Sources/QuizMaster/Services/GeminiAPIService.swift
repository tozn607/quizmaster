import Foundation

public class GeminiAPIService {
    public static let shared = GeminiAPIService()
    
    private init() {}
    
    /// Test if Gemini API Key is valid
    public func validateAPIKey(_ apiKey: String) async -> Bool {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "Ping test. Respond with OK."]
                    ]
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    /// Extract or generate Quiz questions from text using Gemini 3.5 Flash Lite with large-document chunking support
    public func generateQuiz(
        from documentText: String,
        isCreateMultipleChoice: Bool,
        apiKey: String,
        language: AppLanguage = .vietnamese,
        depthMode: QuestionDepthMode = .normal
    ) async throws -> [Question] {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            throw NSError(domain: "GeminiAPIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing. Please configure your Google AI Studio key in Settings."])
        }
        
        let cleanedDocText = documentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedDocText.isEmpty else {
            return []
        }
        
        // If document is large (e.g. > 13,000 characters or 25+ questions), chunk it
        let chunkSize = 13000
        if cleanedDocText.count > chunkSize {
            let chunks = splitDocumentIntoChunks(cleanedDocText, targetChunkSize: chunkSize)
            var allQuestions: [Question] = []
            var seenTexts = Set<String>()
            var lastError: Error? = nil
            
            for chunk in chunks {
                do {
                    let chunkQuestions = try await generateQuizSingleBatch(
                        from: chunk,
                        isCreateMultipleChoice: isCreateMultipleChoice,
                        apiKey: trimmedKey,
                        language: language,
                        depthMode: depthMode
                    )
                    for q in chunkQuestions {
                        let normalizedKey = q.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        if !seenTexts.contains(normalizedKey) {
                            seenTexts.insert(normalizedKey)
                            allQuestions.append(q)
                        }
                    }
                } catch {
                    lastError = error
                }
            }
            if !allQuestions.isEmpty {
                return allQuestions
            }
            if let err = lastError {
                throw err
            }
        }
        
        return try await generateQuizSingleBatch(
            from: cleanedDocText,
            isCreateMultipleChoice: isCreateMultipleChoice,
            apiKey: trimmedKey,
            language: language,
            depthMode: depthMode
        )
    }
    
    private func generateQuizSingleBatch(
        from documentText: String,
        isCreateMultipleChoice: Bool,
        apiKey: String,
        language: AppLanguage,
        depthMode: QuestionDepthMode
    ) async throws -> [Question] {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Gemini API endpoint URL."])
        }
        
        let targetLangInstruction = language == .english ?
            "STRICT LANGUAGE REQUIREMENT: Write ALL questions, options, and explanations in ENGLISH." :
            "YÊU CẦU NGÔN NGỮ BẮT BUỘC: Viết BẮT BUỘC TOÀN BỘ câu hỏi, các phương án lựa chọn và phần giải thích bằng TIẾNG VIỆT."
        
        let depthInstruction: String
        switch depthMode {
        case .normal:
            depthInstruction = "DEPTH MODE - NORMAL: Generate a comprehensive multiple-choice test covering all parts of the text thoroughly."
        case .core:
            depthInstruction = "DEPTH MODE - CORE: Focus strictly on the CORE ideas, main takeaways, key theorems, and essential concepts of the document."
        case .thorough:
            depthInstruction = "DEPTH MODE - THOROUGH: Exhaustively analyze every single paragraph, sentence, and detail of the document. Create a DENSE, EXTREMELY DETAILED, and COMPREHENSIVE multiple-choice test covering EVERY fact, rule, date, definition, example, and detail mentioned in the document. Do not skip any question or section."
        }
        
        let promptText: String
        if isCreateMultipleChoice {
            promptText = """
            You are a master academic professor and test designer. Analyze the document below.
            
            \(targetLangInstruction)
            \(depthInstruction)
            
            CRITICAL TEXT INTEGRITY & WORD ORDER RULES:
            1. PRESERVE NATURAL SENTENCE WORD ORDER: Write clear, grammatically sound, and natural sentences. Never scramble or invert word order.
            2. CHOICE LENGTH EQUALIZATION: All 4 choices (A, B, C, D) MUST be of equal length, depth, and detail. DO NOT make the correct choice noticeably longer or more complex than the wrong choices (distractors).
            3. PLAUSIBLE DISTRACTORS: All wrong choices must be realistic and plausible.
            4. CORRECT ANSWER SHUFFLING: Randomly distribute correct answers across A, B, C, D.
            5. Correct Answer Indexing: Set "correctAnswerIndex" as a 0-BASED integer (0 for A, 1 for B, 2 for C, 3 for D).
            
            Target Output JSON Schema:
            Return ONLY a valid JSON array of question objects without markdown code block syntax:
            [
              {
                "text": "Question text...",
                "options": [
                  {"label": "A", "text": "Option A..."},
                  {"label": "B", "text": "Option B..."},
                  {"label": "C", "text": "Option C..."},
                  {"label": "D", "text": "Option D..."}
                ],
                "correctAnswerIndex": 0,
                "explanation": "Detailed educational explanation..."
              }
            ]
            
            Document Content:
            \(documentText)
            """
        } else {
            promptText = """
            You are an expert document OCR quiz extractor. Extract ALL pre-existing questions, answer options (A, B, C, D), correct answer indexes (0-based integer), and explanations found in the document.
            
            \(targetLangInstruction)
            
            CRITICAL EXTRACTION INTEGRITY RULES:
            1. WORD-FOR-WORD FIDELITY: Extract the exact sentence structure, question text, options, and explanations from the document word-for-word without changing the word order or creating nonsense sentence fragments.
            2. DO NOT SKIP ANY QUESTIONS: Extract every single question found in the provided document chunk from beginning to end.
            3. PRESERVE ORIGINAL OPTION ORDER: Keep option A, B, C, D in their original sequence.
            4. Set "correctAnswerIndex" as a 0-based integer (0 for A, 1 for B, 2 for C, 3 for D).
            
            Target Output JSON Schema:
            Return ONLY a valid JSON array of question objects without markdown code block syntax:
            [
              {
                "text": "Question text...",
                "options": [
                  {"label": "A", "text": "Option A..."},
                  {"label": "B", "text": "Option B..."},
                  {"label": "C", "text": "Option C..."},
                  {"label": "D", "text": "Option D..."}
                ],
                "correctAnswerIndex": 0,
                "explanation": "Explanation..."
              }
            ]
            
            Document Content:
            \(documentText)
            """
        }
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": isCreateMultipleChoice ? 0.3 : 0.1,
                "maxOutputTokens": 8192,
                "responseMimeType": "application/json"
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 180
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown HTTP error"
            throw NSError(domain: "GeminiAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gemini API Error: \(errorMsg)"])
        }
        
        return try parseQuestionsFromGeminiResponse(data: data, shuffleOptions: isCreateMultipleChoice)
    }
    
    /// Helper to split large documents into logical chunks along question headers or paragraph breaks
    private func splitDocumentIntoChunks(_ text: String, targetChunkSize: Int) -> [String] {
        guard text.count > targetChunkSize else { return [text] }
        
        let lines = text.components(separatedBy: "\n")
        var chunks: [String] = []
        var currentChunk = ""
        
        // Regex patterns that signal the start of a new question
        let questionPattern = try? NSRegularExpression(pattern: #"^(?:câu|question|bài|q)\s*\d+[\.:\s]"#, options: [.caseInsensitive])
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let isQuestionStart: Bool
            if let pattern = questionPattern {
                let range = NSRange(location: 0, length: (trimmed as NSString).length)
                isQuestionStart = pattern.firstMatch(in: trimmed, options: [], range: range) != nil
            } else {
                isQuestionStart = false
            }
            
            if currentChunk.count >= targetChunkSize && (isQuestionStart || trimmed.isEmpty) {
                chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                currentChunk = line + "\n"
            } else if currentChunk.count >= targetChunkSize + 3000 {
                // Hard ceiling to guarantee chunks never exceed memory/token output bounds
                chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                currentChunk = line + "\n"
            } else {
                currentChunk += line + "\n"
            }
        }
        
        if !currentChunk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return chunks.isEmpty ? [text] : chunks
    }
    
    /// Resilient JSON Array extractor that backwards-validates syntax to rescue partially truncated responses
    private func extractValidJSONData(from rawText: String) -> Data? {
        var clean = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasPrefix("```json") { clean = String(clean.dropFirst(7)) }
        else if clean.hasPrefix("```") { clean = String(clean.dropFirst(3)) }
        if clean.hasSuffix("```") { clean = String(clean.dropLast(3)) }
        clean = clean.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If already valid JSON
        if let directData = clean.data(using: .utf8),
           (try? JSONSerialization.jsonObject(with: directData)) != nil {
            return directData
        }
        
        // Check root array slice
        if let firstBracket = clean.firstIndex(of: "[") {
            if let lastBracket = clean.lastIndex(of: "]"), firstBracket < lastBracket {
                let candidate = String(clean[firstBracket...lastBracket])
                if let d = candidate.data(using: .utf8), (try? JSONSerialization.jsonObject(with: d)) != nil {
                    return d
                }
            }
            
            // Backwards search through '}' to close truncated array at the last valid complete object
            var searchEnd = clean.endIndex
            while searchEnd > firstBracket {
                guard let braceIdx = clean[firstBracket..<searchEnd].lastIndex(of: "}") else { break }
                let candidate = String(clean[firstBracket...braceIdx]) + "\n]"
                if let d = candidate.data(using: .utf8), (try? JSONSerialization.jsonObject(with: d)) != nil {
                    return d
                }
                searchEnd = braceIdx
            }
        }
        
        // Check root object slice
        if let firstBrace = clean.firstIndex(of: "{") {
            if let lastBrace = clean.lastIndex(of: "}"), firstBrace < lastBrace {
                let candidate = String(clean[firstBrace...lastBrace])
                if let d = candidate.data(using: .utf8), (try? JSONSerialization.jsonObject(with: d)) != nil {
                    return d
                }
            }
        }
        
        return clean.data(using: .utf8)
    }
    
    private func parseQuestionsFromGeminiResponse(data: Data, shuffleOptions: Bool = true) throws -> [Question] {
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = jsonObject["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw NSError(domain: "GeminiAPIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not parse text candidate from Gemini response."])
        }
        
        guard let rawData = extractValidJSONData(from: text) else {
            throw NSError(domain: "GeminiAPIService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF8 string from Gemini JSON."])
        }
        
        struct DTOOption: Decodable {
            let label: String?
            let text: String?
            
            init(label: String?, text: String?) {
                self.label = label
                self.text = text
            }
            
            init(from decoder: Decoder) throws {
                if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                    self.label = try? container.decodeIfPresent(String.self, forKey: .label)
                    let t = try? container.decodeIfPresent(String.self, forKey: .text)
                    let c = try? container.decodeIfPresent(String.self, forKey: .content)
                    let o = try? container.decodeIfPresent(String.self, forKey: .option)
                    self.text = t ?? c ?? o
                } else if let singleVal = try? decoder.singleValueContainer(), let str = try? singleVal.decode(String.self) {
                    // Handle options as raw string array: "A. Option Text"
                    let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.count >= 2 && trimmed[trimmed.index(trimmed.startIndex, offsetBy: 1)] == "." {
                        self.label = String(trimmed.prefix(1))
                        self.text = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        self.label = nil
                        self.text = trimmed
                    }
                } else {
                    self.label = nil
                    self.text = nil
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case label, text, content, option
            }
        }
        
        struct DTOQuestion: Decodable {
            let text: String?
            let options: [DTOOption]?
            let correctAnswerIndex: Int?
            let correctIndex: Int?
            let correctAnswer: String?
            let explanation: String?
            
            init(from decoder: Decoder) throws {
                let container = try? decoder.container(keyedBy: CodingKeys.self)
                let t = try? container?.decodeIfPresent(String.self, forKey: .text)
                let q = try? container?.decodeIfPresent(String.self, forKey: .question)
                let p = try? container?.decodeIfPresent(String.self, forKey: .prompt)
                let tit = try? container?.decodeIfPresent(String.self, forKey: .title)
                self.text = t ?? q ?? p ?? tit
                
                self.options = try? container?.decodeIfPresent([DTOOption].self, forKey: .options)
                
                if let intIdx = try? container?.decodeIfPresent(Int.self, forKey: .correctAnswerIndex) {
                    self.correctAnswerIndex = intIdx
                } else if let strIdx = try? container?.decodeIfPresent(String.self, forKey: .correctAnswerIndex), let parsed = Int(strIdx) {
                    self.correctAnswerIndex = parsed
                } else {
                    self.correctAnswerIndex = nil
                }
                
                if let intCIdx = try? container?.decodeIfPresent(Int.self, forKey: .correctIndex) {
                    self.correctIndex = intCIdx
                } else if let strCIdx = try? container?.decodeIfPresent(String.self, forKey: .correctIndex), let parsed = Int(strCIdx) {
                    self.correctIndex = parsed
                } else {
                    self.correctIndex = nil
                }
                
                self.correctAnswer = try? container?.decodeIfPresent(String.self, forKey: .correctAnswer)
                
                let exp = try? container?.decodeIfPresent(String.self, forKey: .explanation)
                let expL = try? container?.decodeIfPresent(String.self, forKey: .explain)
                let det = try? container?.decodeIfPresent(String.self, forKey: .detail)
                self.explanation = exp ?? expL ?? det
            }
            
            private enum CodingKeys: String, CodingKey {
                case text, question, prompt, title, options, correctAnswerIndex, correctIndex, correctAnswer, explanation, explain, detail
            }
        }
        
        struct DTORoot: Decodable {
            let questions: [DTOQuestion]?
            let quiz: [DTOQuestion]?
            let items: [DTOQuestion]?
            let data: [DTOQuestion]?
        }
        
        let decoder = JSONDecoder()
        var dtoQuestions: [DTOQuestion] = []
        
        if let directArray = try? decoder.decode([DTOQuestion].self, from: rawData) {
            dtoQuestions = directArray
        } else if let rootObj = try? decoder.decode(DTORoot.self, from: rawData) {
            dtoQuestions = rootObj.questions ?? rootObj.quiz ?? rootObj.items ?? rootObj.data ?? []
        } else if let jsonDict = try? JSONSerialization.jsonObject(with: rawData) as? [String: Any] {
            // Dynamic fallback
            for key in ["questions", "quiz", "items", "data", "results"] {
                if let arr = jsonDict[key] as? [[String: Any]], let arrData = try? JSONSerialization.data(withJSONObject: arr) {
                    if let parsed = try? decoder.decode([DTOQuestion].self, from: arrData) {
                        dtoQuestions = parsed
                        break
                    }
                }
            }
        }
        
        guard !dtoQuestions.isEmpty else {
            throw NSError(domain: "GeminiAPIService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Không thể đọc dữ liệu câu hỏi từ phản hồi của Gemini AI. Vui lòng thử lại."])
        }
        
        var questions: [Question] = []
        for dto in dtoQuestions {
            guard let qText = dto.text, !qText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            var rawOptions: [QuestionOption] = []
            if let opts = dto.options {
                for (idx, opt) in opts.enumerated() {
                    let optText = opt.text ?? ""
                    rawOptions.append(QuestionOption(label: "\(idx)", text: optText))
                }
            }
            
            // If options are empty, create fallback A/B/C/D placeholder options
            if rawOptions.isEmpty {
                rawOptions = [
                    QuestionOption(label: "A", text: "A"),
                    QuestionOption(label: "B", text: "B"),
                    QuestionOption(label: "C", text: "C"),
                    QuestionOption(label: "D", text: "D")
                ]
            }
            
            var initialCorrectIdx = 0
            if let rawIdx = dto.correctAnswerIndex ?? dto.correctIndex {
                if rawIdx >= 0 && rawIdx < rawOptions.count {
                    initialCorrectIdx = rawIdx
                } else if rawIdx >= 1 && rawIdx <= rawOptions.count {
                    initialCorrectIdx = rawIdx - 1
                }
            } else if let letter = dto.correctAnswer?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
                if letter.hasPrefix("A") { initialCorrectIdx = 0 }
                else if letter.hasPrefix("B") { initialCorrectIdx = 1 }
                else if letter.hasPrefix("C") { initialCorrectIdx = 2 }
                else if letter.hasPrefix("D") { initialCorrectIdx = 3 }
            }
            
            let targetCorrectOption = rawOptions.indices.contains(initialCorrectIdx) ? rawOptions[initialCorrectIdx] : (rawOptions.first ?? QuestionOption(label: "A", text: ""))
            
            let finalOptions: [QuestionOption]
            let finalCorrectIndex: Int
            let labels = ["A", "B", "C", "D", "E", "F"]
            
            if shuffleOptions {
                var shuffled = rawOptions.shuffled()
                for i in 0..<shuffled.count {
                    shuffled[i].label = i < labels.count ? labels[i] : "\(i + 1)"
                }
                finalOptions = shuffled
                finalCorrectIndex = shuffled.firstIndex(where: { $0.id == targetCorrectOption.id }) ?? 0
            } else {
                var preserved = rawOptions
                for i in 0..<preserved.count {
                    preserved[i].label = i < labels.count ? labels[i] : "\(i + 1)"
                }
                finalOptions = preserved
                finalCorrectIndex = preserved.firstIndex(where: { $0.id == targetCorrectOption.id }) ?? 0
            }
            
            let q = Question(
                text: qText,
                options: finalOptions,
                correctAnswerIndex: finalCorrectIndex,
                explanation: dto.explanation ?? ""
            )
            questions.append(q)
        }
        
        return questions
    }
    
    /// Directly ask Gemini 3.5 Flash Lite for a detailed explanation of a specific question
    public func askQuestionDetail(question: Question, userQuery: String = "", apiKey: String, language: AppLanguage = .vietnamese) async throws -> String {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            throw NSError(domain: "GeminiAPIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing. Please configure your Google AI Studio key in Settings."])
        }
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=\(trimmedKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Gemini API URL."])
        }
        
        let optionsText = question.options.map { "\($0.label). \($0.text)" }.joined(separator: "\n")
        let targetLang = language == .english ? "ENGLISH" : "VIETNAMESE"
        
        let promptText = """
        You are an expert academic tutor. A student is asking for a detailed explanation regarding the following multiple-choice question.
        
        Language Requirement: Respond in \(targetLang).
        
        Question: \(question.text)
        Options:
        \(optionsText)
        Correct Answer: \(question.correctAnswerLabel). \(question.correctAnswerText)
        Existing Explanation: \(question.explanation)
        
        Student's Custom Question / Request:
        \(userQuery.isEmpty ? "Please explain step-by-step why the correct answer is right and why each incorrect option is wrong, with clear examples." : userQuery)
        
        Instructions for Tutor Response:
        - Provide a comprehensive, clear, and easy-to-understand response.
        - Break down the concepts step-by-step.
        - Explain why the correct option is right.
        - Explain why each distractor option is incorrect.
        - Provide a real-world example or practical analogy if applicable.
        """
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "HTTP Error"
            throw NSError(domain: "GeminiAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gemini API Error: \(errorMsg)"])
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = jsonObject["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw NSError(domain: "GeminiAPIService", code: 501, userInfo: [NSLocalizedDescriptionKey: "Could not parse response from Gemini."])
        }
        
        return text
    }
    
    // MARK: - Language Learning Exam Processing
    public struct LanguageExamResult {
        public let questions: [Question]
        public let vocabularies: [VocabularyCard]
        public let detectedDurationMinutes: Int?
    }
    
    /// Extract and structure Language Learning exams (Reading passages, Lexical, Grammar, Listening, Pronunciation) and build CEFR vocabulary deck
    public func generateLanguageExam(
        from documentText: String,
        targetCEFR: CEFRLevel = .all,
        apiKey: String
    ) async throws -> LanguageExamResult {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            throw NSError(domain: "GeminiAPIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing. Please configure your Google AI Studio key in Settings."])
        }
        
        let cleanedDocText = documentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedDocText.isEmpty else {
            return LanguageExamResult(questions: [], vocabularies: [], detectedDurationMinutes: nil)
        }
        
        // Chunk if text is large
        let chunkSize = 13000
        if cleanedDocText.count > chunkSize {
            let chunks = splitDocumentIntoChunks(cleanedDocText, targetChunkSize: chunkSize)
            var allQuestions: [Question] = []
            var allVocabs: [VocabularyCard] = []
            var detectedDuration: Int? = nil
            var seenQuestionTexts = Set<String>()
            var seenWords = Set<String>()
            var lastError: Error? = nil
            
            for chunk in chunks {
                do {
                    let result = try await generateLanguageExamSingleBatch(from: chunk, targetCEFR: targetCEFR, apiKey: trimmedKey)
                    if detectedDuration == nil {
                        detectedDuration = result.detectedDurationMinutes
                    }
                    for q in result.questions {
                        let key = q.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        if !seenQuestionTexts.contains(key) {
                            seenQuestionTexts.insert(key)
                            allQuestions.append(q)
                        }
                    }
                    for v in result.vocabularies {
                        let wordKey = v.word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        if !seenWords.contains(wordKey) {
                            seenWords.insert(wordKey)
                            allVocabs.append(v)
                        }
                    }
                } catch {
                    lastError = error
                }
            }
            if !allQuestions.isEmpty {
                return LanguageExamResult(questions: allQuestions, vocabularies: allVocabs, detectedDurationMinutes: detectedDuration)
            }
            if let err = lastError {
                throw err
            }
        }
        
        return try await generateLanguageExamSingleBatch(from: cleanedDocText, targetCEFR: targetCEFR, apiKey: trimmedKey)
    }
    
    private func generateLanguageExamSingleBatch(
        from documentText: String,
        targetCEFR: CEFRLevel,
        apiKey: String
    ) async throws -> LanguageExamResult {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Gemini API endpoint URL."])
        }
        
        let cefrFilter = targetCEFR == .all ? "Extract vocabulary words across CEFR levels (A1 to C2) found in the test." : "Focus vocabulary extraction on words around CEFR level \(targetCEFR.rawValue) or higher."
        
        let promptText = """
        You are a master English linguistics professor and exam parser specializing in Vietnamese National High School Graduation Exams ("Đề thi tốt nghiệp THPT môn Tiếng Anh"), IELTS, and CEFR-aligned standardized language tests.
        
        Analyze the provided document text and perform two tasks in a single JSON response:
        
        CRITICAL ACCURACY & WORD ORDER RULES:
        1. PRESERVE ORIGINAL WORD ORDER: Maintain the exact natural word sequence and grammatical structure for all questions, reading passages, and options. Do not scramble words.
        2. EXTRACT ALL QUESTIONS IN THE PROVIDED CHUNK: Do not omit or truncate any question from the text.
        3. PRESERVE OPTION ORDER: Keep options (A, B, C, D) in their exact original sequence.
        
        TASK 1: Extract all Exam Questions into structured sections:
        - Detect if the document states an allotted exam time (e.g. "Thời gian làm bài: 50 phút", "Time allowed: 60 minutes"). If found, set "durationMinutes" to that integer (e.g. 50, 60). If not found, set "durationMinutes" to null.
        - Identify the skill of each question: "reading" (Reading comprehension / Đọc hiểu), "listening" (Nghe hiểu), "lexical" (Grammar, Vocabulary, Pronunciation, Stress / Ngữ âm, Trọng âm, Tìm lỗi sai, Điền từ vào đoạn văn / Cloze test), or "general".
        - CRITICAL RULE FOR READING & CLOZE TEST PASSAGES:
          * If a group of questions belongs to a Reading passage or a Cloze test passage (điền từ vào đoạn văn), extract the FULL passage text and attach it to the "readingPassage" field of EVERY question belonging to that passage.
          * For each individual question belonging to a Reading/Cloze passage, DO NOT REPEAT the passage in "text". Instead, set "text" strictly to the specific question prompt, blank reference or instruction (e.g. "Question 23:" or "Read the following passage and mark the letter A, B, C, or D to indicate the correct word or phrase that best fits each of the numbered blanks from 23 to 27.\\n\\n**Blank (23):**" or the specific reading comprehension question). KEEP THE QUESTION BOX CLEAN AND SHORT!
        - TARGET MARKINGS & UNDERLINES IN LEXICAL QUESTIONS:
          * Many lexical questions in Vietnamese exams target specific underlined, bolded, or opposite/closest meaning words (e.g. "underlined part", "CLOSEST in meaning to", "OPPOSITE in meaning to").
          * You MUST preserve and format target words with Markdown **bold**, _italics_, or [underlined] brackets in both "text" and "options" (e.g. "The word **ubiquitous** in paragraph 2 is closest in meaning to...").
        - Preserve all IPA pronunciation symbols, phonetic slashes (e.g. /ə/, /ɪ/, /eɪ/), and Vietnamese explanations faithfully without character corruption.
        - Set "correctAnswerIndex" as a 0-based integer (0 for A, 1 for B, 2 for C, 3 for D).
        
        TASK 2: Extract a High-Yield Vocabulary, Idioms & Phrasal Verbs Deck from the exam for flashcard study:
        - \(cefrFilter)
        - IN ADDITION TO INDIVIDUAL WORDS, YOU MUST SYSTEMATICALLY EXTRACT:
          * Idiomatic expressions (e.g. "once in a blue moon", "bite the bullet", "see eye to eye") with "wordType": "idiom"
          * Phrasal verbs & Collocations (e.g. "call off", "look down on", "come up with", "take for granted") with "wordType": "phr v" or "collocation"
          * Advanced / Key vocabulary words
        - For each target vocabulary/idiom/phrasal verb, provide:
          1. "word": Root word, phrase, idiom, or phrasal verb
          2. "wordType": Part of speech or phrase category in short notation (e.g. "n", "v", "adj", "adv", "idiom", "phr v", "collocation")
          3. "phonetic": Accurate IPA pronunciation with slashes (e.g. "/ˌʌn.dɚˈmɑɪn/", or general IPA for phrase)
          4. "vietnameseMeaning": Clear, concise Vietnamese translation
          5. "exampleSentence": An illustrative English example sentence where the target word/phrase is enclosed in markdown bold **target** (e.g. "They had to **call off** the match due to heavy rain.")
          6. "cefrLevel": Estimated CEFR level string: "A1", "A2", "B1", "B2", "C1", or "C2"
        
        Target Output JSON Schema:
        Return ONLY a single valid, well-formed JSON object matching this schema without any introductory or markdown commentary:
        {
          "durationMinutes": 50,
          "questions": [
            {
              "text": "Mark the letter A, B, C, or D on your answer sheet to indicate the word whose underlined part differs from the other three in pronunciation in each of the following questions.\\n\\n1. A. **st**op   B. po**st**   C. **st**ar   D. li**st**en",
              "options": [
                {"label": "A", "text": "stop"},
                {"label": "B", "text": "post"},
                {"label": "C", "text": "star"},
                {"label": "D", "text": "listen"}
              ],
              "correctAnswerIndex": 3,
              "explanation": "Phần gạch chân của 'listen' là âm câm /t/, các từ còn lại phát âm là /st/.",
              "skill": "lexical",
              "subTopic": "Phát âm",
              "readingPassage": null
            }
          ],
          "vocabularies": [
            {
              "word": "call off",
              "wordType": "phr v",
              "phonetic": "/kɔːl ɒf/",
              "vietnameseMeaning": "Hủy bỏ (sự kiện, kế hoạch)",
              "exampleSentence": "The concert was **called off** because of the storm.",
              "cefrLevel": "B1"
            },
            {
              "word": "bite the bullet",
              "wordType": "idiom",
              "phonetic": "/baɪt ðə ˈbʊl.ɪt/",
              "vietnameseMeaning": "Cắn răng chịu đựng, chấp nhận đối mặt với hoàn cảnh khó khăn",
              "exampleSentence": "I decided to **bite the bullet** and tell my boss the truth.",
              "cefrLevel": "C1"
            }
          ]
        }
        
        Document Content:
        \(documentText)
        """
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "maxOutputTokens": 8192,
                "responseMimeType": "application/json"
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 180
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown HTTP error"
            throw NSError(domain: "GeminiAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gemini API Error: \(errorMsg)"])
        }
        
        return try parseLanguageExamFromGeminiResponse(data: data)
    }
    
    private func parseLanguageExamFromGeminiResponse(data: Data) throws -> LanguageExamResult {
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = jsonObject["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw NSError(domain: "GeminiAPIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not parse text candidate from Gemini response."])
        }
        
        guard let rawData = extractValidJSONData(from: text) else {
            throw NSError(domain: "GeminiAPIService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF8 data."])
        }
        
        struct DTOOption: Decodable {
            let label: String?
            let text: String?
            
            init(label: String?, text: String?) {
                self.label = label
                self.text = text
            }
            
            init(from decoder: Decoder) throws {
                if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                    self.label = try? container.decodeIfPresent(String.self, forKey: .label)
                    let t = try? container.decodeIfPresent(String.self, forKey: .text)
                    let c = try? container.decodeIfPresent(String.self, forKey: .content)
                    let o = try? container.decodeIfPresent(String.self, forKey: .option)
                    self.text = t ?? c ?? o
                } else if let singleVal = try? decoder.singleValueContainer(), let str = try? singleVal.decode(String.self) {
                    // Handle options as raw string array: "A. washed"
                    let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.count >= 2 && trimmed[trimmed.index(trimmed.startIndex, offsetBy: 1)] == "." {
                        self.label = String(trimmed.prefix(1))
                        self.text = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        self.label = nil
                        self.text = trimmed
                    }
                } else {
                    self.label = nil
                    self.text = nil
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case label, text, content, option
            }
        }
        
        struct DTOQuestion: Decodable {
            let text: String?
            let options: [DTOOption]?
            let correctAnswerIndex: Int?
            let correctIndex: Int?
            let correctAnswer: String?
            let explanation: String?
            let skill: String?
            let subTopic: String?
            let readingPassage: String?
            
            init(from decoder: Decoder) throws {
                let container = try? decoder.container(keyedBy: CodingKeys.self)
                self.text = try? container?.decodeIfPresent(String.self, forKey: .text)
                self.options = try? container?.decodeIfPresent([DTOOption].self, forKey: .options)
                
                // Decode correctAnswerIndex flexibly as Int or String
                if let intIdx = try? container?.decodeIfPresent(Int.self, forKey: .correctAnswerIndex) {
                    self.correctAnswerIndex = intIdx
                } else if let strIdx = try? container?.decodeIfPresent(String.self, forKey: .correctAnswerIndex), let parsed = Int(strIdx) {
                    self.correctAnswerIndex = parsed
                } else {
                    self.correctAnswerIndex = nil
                }
                
                if let intCIdx = try? container?.decodeIfPresent(Int.self, forKey: .correctIndex) {
                    self.correctIndex = intCIdx
                } else if let strCIdx = try? container?.decodeIfPresent(String.self, forKey: .correctIndex), let parsed = Int(strCIdx) {
                    self.correctIndex = parsed
                } else {
                    self.correctIndex = nil
                }
                
                self.correctAnswer = try? container?.decodeIfPresent(String.self, forKey: .correctAnswer)
                self.explanation = try? container?.decodeIfPresent(String.self, forKey: .explanation)
                self.skill = try? container?.decodeIfPresent(String.self, forKey: .skill)
                self.subTopic = try? container?.decodeIfPresent(String.self, forKey: .subTopic)
                self.readingPassage = try? container?.decodeIfPresent(String.self, forKey: .readingPassage)
            }
            
            private enum CodingKeys: String, CodingKey {
                case text, options, correctAnswerIndex, correctIndex, correctAnswer, explanation, skill, subTopic, readingPassage
            }
        }
        
        struct DTOVocab: Decodable {
            let word: String?
            let wordType: String?
            let phonetic: String?
            let vietnameseMeaning: String?
            let exampleSentence: String?
            let cefrLevel: String?
        }
        
        struct DTORoot: Decodable {
            let durationMinutes: Int?
            let questions: [DTOQuestion]?
            let vocabularies: [DTOVocab]?
        }
        
        let decoder = JSONDecoder()
        var questionsDTO: [DTOQuestion] = []
        var vocabsDTO: [DTOVocab] = []
        var detectedDuration: Int? = nil
        
        if let root = try? decoder.decode(DTORoot.self, from: rawData) {
            questionsDTO = root.questions ?? []
            vocabsDTO = root.vocabularies ?? []
            detectedDuration = root.durationMinutes
        } else if let arrayQuestions = try? decoder.decode([DTOQuestion].self, from: rawData) {
            // Fallback if AI returned raw array of questions
            questionsDTO = arrayQuestions
        } else {
            // Last resort fallback: try decoding object manually via JSONSerialization
            if let obj = try? JSONSerialization.jsonObject(with: rawData) as? [String: Any] {
                if let dur = obj["durationMinutes"] as? Int {
                    detectedDuration = dur
                } else if let strDur = obj["durationMinutes"] as? String {
                    detectedDuration = Int(strDur)
                }
                
                if let qArr = obj["questions"] as? [[String: Any]], let qData = try? JSONSerialization.data(withJSONObject: qArr) {
                    questionsDTO = (try? decoder.decode([DTOQuestion].self, from: qData)) ?? []
                }
                if let vArr = obj["vocabularies"] as? [[String: Any]], let vData = try? JSONSerialization.data(withJSONObject: vArr) {
                    vocabsDTO = (try? decoder.decode([DTOVocab].self, from: vData)) ?? []
                }
            }
            
            if questionsDTO.isEmpty {
                throw NSError(domain: "GeminiAPIService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Không thể đọc dữ liệu đề thi JSON từ Gemini AI. Vui lòng kiểm tra lại tài liệu hoặc thử lại."])
            }
        }
        
        var questions: [Question] = []
        for dto in questionsDTO {
            guard let qText = dto.text, !qText.isEmpty else { continue }
            var rawOptions: [QuestionOption] = []
            if let opts = dto.options {
                for (idx, opt) in opts.enumerated() {
                    let optText = opt.text ?? ""
                    rawOptions.append(QuestionOption(label: "\(idx)", text: optText))
                }
            }
            
            var initialCorrectIdx = 0
            if let rawIdx = dto.correctAnswerIndex ?? dto.correctIndex {
                if rawIdx >= 0 && rawIdx < rawOptions.count {
                    initialCorrectIdx = rawIdx
                } else if rawIdx >= 1 && rawIdx <= rawOptions.count {
                    initialCorrectIdx = rawIdx - 1
                }
            } else if let letter = dto.correctAnswer?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
                if letter.hasPrefix("A") { initialCorrectIdx = 0 }
                else if letter.hasPrefix("B") { initialCorrectIdx = 1 }
                else if letter.hasPrefix("C") { initialCorrectIdx = 2 }
                else if letter.hasPrefix("D") { initialCorrectIdx = 3 }
            }
            
            let targetCorrectOption = rawOptions.indices.contains(initialCorrectIdx) ? rawOptions[initialCorrectIdx] : (rawOptions.first ?? QuestionOption(label: "A", text: ""))
            
            var shuffledOptions = rawOptions
            let labels = ["A", "B", "C", "D", "E", "F"]
            for i in 0..<shuffledOptions.count {
                shuffledOptions[i].label = i < labels.count ? labels[i] : "\(i + 1)"
            }
            let finalCorrectIndex = shuffledOptions.firstIndex(where: { $0.id == targetCorrectOption.id }) ?? 0
            
            var mappedSkill: LanguageSkill = .general
            if let skStr = dto.skill?.lowercased() {
                if skStr.contains("read") { mappedSkill = .reading }
                else if skStr.contains("listen") { mappedSkill = .listening }
                else if skStr.contains("lexic") || skStr.contains("gram") || skStr.contains("vocab") || skStr.contains("pronunc") { mappedSkill = .lexical }
            }
            
            let q = Question(
                text: qText,
                options: shuffledOptions,
                correctAnswerIndex: finalCorrectIndex,
                explanation: dto.explanation ?? "",
                skill: mappedSkill,
                readingPassage: dto.readingPassage,
                subTopic: dto.subTopic
            )
            questions.append(q)
        }
        
        var vocabularies: [VocabularyCard] = []
        for v in vocabsDTO {
            guard let word = v.word, !word.isEmpty else { continue }
            let lvl = CEFRLevel(rawValue: v.cefrLevel?.uppercased() ?? "B1") ?? .b1
            let card = VocabularyCard(
                word: word,
                wordType: v.wordType ?? "",
                phonetic: v.phonetic ?? "",
                vietnameseMeaning: v.vietnameseMeaning ?? "",
                exampleSentence: v.exampleSentence ?? "",
                cefrLevel: lvl
            )
            vocabularies.append(card)
        }
        
        return LanguageExamResult(questions: questions, vocabularies: vocabularies, detectedDurationMinutes: detectedDuration)
    }
}
