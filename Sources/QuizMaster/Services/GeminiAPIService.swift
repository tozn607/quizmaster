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
    
    /// Extract or generate Quiz questions from text using Gemini 3.5 Flash Lite
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
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=\(trimmedKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Gemini API endpoint URL."])
        }
        
        let targetLangInstruction = language == .english ?
            "STRICT LANGUAGE REQUIREMENT: Write ALL questions, options, and explanations in ENGLISH." :
            "YÊU CẦU NGÔN NGỮ BẮT BUỘC: Viết BẮT BUỘC TOÀN BỘ câu hỏi, các phương án lựa chọn và phần giải thích bằng TIẾNG VIỆT."
        
        let depthInstruction: String
        switch depthMode {
        case .normal:
            depthInstruction = "DEPTH MODE - NORMAL: Generate a balanced multiple-choice test matching the document length (aim for 12 to 20 questions)."
        case .core:
            depthInstruction = "DEPTH MODE - CORE: Focus strictly on the CORE ideas, main takeaways, key theorems, and essential concepts of the document (aim for 8 to 15 high-level questions)."
        case .thorough:
            depthInstruction = "DEPTH MODE - THOROUGH: Exhaustively analyze every single paragraph, sentence, and sub-clause of the document. Create a DENSE, EXTREMELY DETAILED, and COMPREHENSIVE multiple-choice test containing 35 to 60+ questions, covering EVERY fact, rule, date, definition, example, and detail mentioned in the document. Do not skip any section."
        }
        
        let promptText: String
        if isCreateMultipleChoice {
            promptText = """
            You are a master academic professor and test designer. Analyze the document below.
            
            \(targetLangInstruction)
            \(depthInstruction)
            
            Strict Anti-Bias & Option Randomization Rules:
            1. CHOICE LENGTH EQUALIZATION: All 4 choices (A, B, C, D) MUST be of equal length, depth, and detail. DO NOT make the correct choice noticeably longer or more complex than the wrong choices (distractors).
            2. PLAUSIBLE DISTRACTORS: All wrong choices must be realistic and plausible.
            3. CORRECT ANSWER SHUFFLING: Do NOT place all correct answers in option A or B. Randomly distribute correct answers across A, B, C, D.
            4. Correct Answer Indexing: Set "correctAnswerIndex" as a 0-BASED integer (0 for A, 1 for B, 2 for C, 3 for D).
            
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
            \(documentText.prefix(30000))
            """
        } else {
            promptText = """
            You are an expert document OCR quiz extractor. Extract ALL pre-existing questions, answer options (A, B, C, D), correct answer indexes (0-based integer), and explanations found in the document.
            
            \(targetLangInstruction)
            
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
            \(documentText.prefix(30000))
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
                "temperature": 0.3,
                "responseMimeType": "application/json"
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown HTTP error"
            throw NSError(domain: "GeminiAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gemini API Error: \(errorMsg)"])
        }
        
        return try parseQuestionsFromGeminiResponse(data: data)
    }
    
    private func parseQuestionsFromGeminiResponse(data: Data) throws -> [Question] {
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = jsonObject["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw NSError(domain: "GeminiAPIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not parse text candidate from Gemini response."])
        }
        
        var cleanJsonText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanJsonText.hasPrefix("```json") {
            cleanJsonText = String(cleanJsonText.dropFirst(7))
        } else if cleanJsonText.hasPrefix("```") {
            cleanJsonText = String(cleanJsonText.dropFirst(3))
        }
        if cleanJsonText.hasSuffix("```") {
            cleanJsonText = String(cleanJsonText.dropLast(3))
        }
        cleanJsonText = cleanJsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let rawData = cleanJsonText.data(using: .utf8) else {
            throw NSError(domain: "GeminiAPIService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF8 string from Gemini JSON."])
        }
        
        struct DTOOption: Codable {
            let label: String?
            let text: String
        }
        
        struct DTOQuestion: Codable {
            let text: String
            let options: [DTOOption]
            let correctAnswerIndex: Int?
            let correctIndex: Int?
            let correctAnswer: String?
            let explanation: String?
        }
        
        let decoder = JSONDecoder()
        let dtoQuestions = try decoder.decode([DTOQuestion].self, from: rawData)
        
        var questions: [Question] = []
        for dto in dtoQuestions {
            var rawOptions: [QuestionOption] = []
            for (idx, opt) in dto.options.enumerated() {
                rawOptions.append(QuestionOption(label: "\(idx)", text: opt.text))
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
            
            let targetCorrectOption = rawOptions[max(0, min(initialCorrectIdx, rawOptions.count - 1))]
            
            // Randomly shuffle options to guarantee correct answer is NOT always option A!
            var shuffledOptions = rawOptions.shuffled()
            let labels = ["A", "B", "C", "D", "E", "F"]
            for i in 0..<shuffledOptions.count {
                shuffledOptions[i].label = i < labels.count ? labels[i] : "\(i + 1)"
            }
            
            let finalCorrectIndex = shuffledOptions.firstIndex(where: { $0.id == targetCorrectOption.id }) ?? 0
            
            let q = Question(
                text: dto.text,
                options: shuffledOptions,
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
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=\(trimmedKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Gemini API endpoint URL."])
        }
        
        let cefrFilter = targetCEFR == .all ? "Extract vocabulary words across CEFR levels (A1 to C2) found in the test." : "Focus vocabulary extraction on words around CEFR level \(targetCEFR.rawValue) or higher."
        
        let promptText = """
        You are a master English linguistics professor and exam parser specializing in Vietnamese National High School Graduation Exams ("Đề thi tốt nghiệp THPT môn Tiếng Anh"), IELTS, and CEFR-aligned standardized language tests.
        
        Analyze the provided document text and perform two tasks in a single JSON response:
        
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
        \(documentText.prefix(35000))
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
                "responseMimeType": "application/json"
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
        
        var cleanJsonText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanJsonText.hasPrefix("```json") {
            cleanJsonText = String(cleanJsonText.dropFirst(7))
        } else if cleanJsonText.hasPrefix("```") {
            cleanJsonText = String(cleanJsonText.dropFirst(3))
        }
        if cleanJsonText.hasSuffix("```") {
            cleanJsonText = String(cleanJsonText.dropLast(3))
        }
        cleanJsonText = cleanJsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Robust Substring Slicing: Locate outermost '{' ... '}' or '[' ... ']'
        if let firstBrace = cleanJsonText.firstIndex(of: "{"),
           let lastBrace = cleanJsonText.lastIndex(of: "}"),
           firstBrace < lastBrace {
            cleanJsonText = String(cleanJsonText[firstBrace...lastBrace])
        } else if let firstBracket = cleanJsonText.firstIndex(of: "["),
                  let lastBracket = cleanJsonText.lastIndex(of: "]"),
                  firstBracket < lastBracket {
            cleanJsonText = String(cleanJsonText[firstBracket...lastBracket])
        }
        
        guard let rawData = cleanJsonText.data(using: .utf8) else {
            throw NSError(domain: "GeminiAPIService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF8 data."])
        }
        
        struct DTOOption: Codable {
            let label: String?
            let text: String?
            
            init(label: String?, text: String?) {
                self.label = label
                self.text = text
            }
            
            init(from decoder: Decoder) throws {
                if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                    self.label = try? container.decodeIfPresent(String.self, forKey: .label)
                    self.text = try? container.decodeIfPresent(String.self, forKey: .text)
                } else if let singleVal = try? decoder.singleValueContainer(), let str = try? singleVal.decode(String.self) {
                    // Handle options as raw string array: "A. washed"
                    var trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
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
                case label, text
            }
        }
        
        struct DTOQuestion: Codable {
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
        
        struct DTOVocab: Codable {
            let word: String?
            let wordType: String?
            let phonetic: String?
            let vietnameseMeaning: String?
            let exampleSentence: String?
            let cefrLevel: String?
        }
        
        struct DTORoot: Codable {
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
