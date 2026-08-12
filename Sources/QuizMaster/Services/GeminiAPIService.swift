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
            depthInstruction = "DEPTH MODE - THOROUGH: Exhaustively analyze every paragraph and create extremely DETAILED questions covering EVERY fact, date, definition, rule, and piece of information mentioned (aim for 20 to 35 comprehensive questions)."
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
}
