import Foundation

public class WordExporter {
    public static let shared = WordExporter()
    
    private init() {}
    
    /// Default Export: Zip Bundle containing RTF files (Questions & Answer Key) + quiz_bundle.json. ONLY THIS CAN BE RE-IMPORTED.
    public func exportQuizToZipBundle(quiz: Quiz, outputDirectory: String) throws -> String {
        let fileManager = FileManager.default
        var targetDir = outputDirectory
        
        if targetDir.isEmpty || !fileManager.fileExists(atPath: targetDir) {
            targetDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? NSTemporaryDirectory()
        }
        
        let sanitizedTitle = quiz.title.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "_")
        let zipFileName = "\(sanitizedTitle)_QuizBundle.zip"
        let zipFilePath = (targetDir as NSString).appendingPathComponent(zipFileName)
        
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: tempDir)
        }
        
        let questionFileName = "\(sanitizedTitle)_Questions.rtf"
        let answerFileName = "\(sanitizedTitle)_AnswerKey.rtf"
        let jsonFileName = "quiz_bundle.json"
        
        let questionFilePath = tempDir.appendingPathComponent(questionFileName).path
        let answerFilePath = tempDir.appendingPathComponent(answerFileName).path
        let jsonFilePath = tempDir.appendingPathComponent(jsonFileName).path
        
        // 1. Generate Question File Content (Unicode RTF)
        var qRtf = "{\\rtf1\\ansi\\ansicpg1252\\deff0{\\fonttbl{\\f0 Arial;}}\n"
        qRtf += "\\f0\\fs28\\b BÀI THI TRẮC NGHIỆM: \(escapeRtf(quiz.title))\\b0\\fs20\\par\n"
        qRtf += "Thời gian làm bài: 45 phút | Tổng số câu: \(quiz.questions.count)\\par\\par\n"
        
        for (idx, q) in quiz.questions.enumerated() {
            qRtf += "\\b Câu \(idx + 1): \(escapeRtf(q.text))\\b0\\par\n"
            for opt in q.options {
                qRtf += "    \(escapeRtf(opt.label)). \(escapeRtf(opt.text))\\par\n"
            }
            qRtf += "\\par\n"
        }
        qRtf += "}"
        
        // 2. Generate Answer Key File Content (Unicode RTF)
        var aRtf = "{\\rtf1\\ansi\\ansicpg1252\\deff0{\\fonttbl{\\f0 Arial;}}\n"
        aRtf += "\\f0\\fs28\\b ĐÁP ÁN VÀ GIẢI THÍCH CHI TIẾT: \(escapeRtf(quiz.title))\\b0\\fs20\\par\n"
        aRtf += "Tổng số câu: \(quiz.questions.count)\\par\\par\n"
        
        for (idx, q) in quiz.questions.enumerated() {
            aRtf += "\\b Câu \(idx + 1): \(escapeRtf(q.text))\\b0\\par\n"
            aRtf += "-> \\b Đáp án đúng: \(escapeRtf(q.correctAnswerLabel))\\b0  (\(escapeRtf(q.correctAnswerText)))\\par\n"
            if !q.explanation.isEmpty {
                aRtf += "   \\i Giải thích: \(escapeRtf(q.explanation))\\i0\\par\n"
            }
            aRtf += "\\par\n"
        }
        aRtf += "}"
        
        // 3. Generate JSON bundle file for loss-less re-importing
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonBundleData = try encoder.encode(quiz.questions)
        
        try qRtf.write(toFile: questionFilePath, atomically: true, encoding: .utf8)
        try aRtf.write(toFile: answerFilePath, atomically: true, encoding: .utf8)
        try jsonBundleData.write(to: URL(fileURLWithPath: jsonFilePath))
        
        // 4. Zip the files into a single bundle
        if fileManager.fileExists(atPath: zipFilePath) {
            try fileManager.removeItem(atPath: zipFilePath)
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.currentDirectoryURL = tempDir
        process.arguments = ["-r", zipFilePath, questionFileName, answerFileName, jsonFileName]
        try process.run()
        process.waitUntilExit()
        
        return zipFilePath
    }
    
    /// Export Native Word .docx Files packaged inside a Zip archive: [QuizName]_WordDocxBundle.zip containing Questions.docx & AnswerKey.docx (NO JSON)
    public func exportQuizToWordDocxZip(quiz: Quiz, outputDirectory: String) throws -> String {
        let fileManager = FileManager.default
        var targetDir = outputDirectory
        
        if targetDir.isEmpty || !fileManager.fileExists(atPath: targetDir) {
            targetDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? NSTemporaryDirectory()
        }
        
        let sanitizedTitle = quiz.title.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "_")
        let zipFileName = "\(sanitizedTitle)_WordDocxBundle.zip"
        let zipFilePath = (targetDir as NSString).appendingPathComponent(zipFileName)
        
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: tempDir)
        }
        
        let questionDocxName = "\(sanitizedTitle)_Questions.docx"
        let answerDocxName = "\(sanitizedTitle)_AnswerKey.docx"
        let questionDocxPath = tempDir.appendingPathComponent(questionDocxName).path
        let answerDocxPath = tempDir.appendingPathComponent(answerDocxName).path
        
        // Build Question Document XML content
        var qXml = "<w:p><w:r><w:rPr><w:b/><w:sz w:val=\"28\"/></w:rPr><w:t>BÀI THI TRẮC NGHIỆM: \(xmlEscape(quiz.title))</w:t></w:r></w:p>"
        qXml += "<w:p><w:r><w:t>Thời gian làm bài: 45 phút | Tổng số câu: \(quiz.questions.count)</w:t></w:r></w:p><w:p/>"
        
        for (idx, q) in quiz.questions.enumerated() {
            qXml += "<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Câu \(idx + 1): \(xmlEscape(q.text))</w:t></w:r></w:p>"
            for opt in q.options {
                qXml += "<w:p><w:r><w:t>    \(xmlEscape(opt.label)). \(xmlEscape(opt.text))</w:t></w:r></w:p>"
            }
            qXml += "<w:p/>"
        }
        
        // Build Answer Key Document XML content
        var aXml = "<w:p><w:r><w:rPr><w:b/><w:sz w:val=\"28\"/></w:rPr><w:t>ĐÁP ÁN VÀ GIẢI THÍCH CHI TIẾT: \(xmlEscape(quiz.title))</w:t></w:r></w:p>"
        aXml += "<w:p><w:r><w:t>Tổng số câu: \(quiz.questions.count)</w:t></w:r></w:p><w:p/>"
        
        for (idx, q) in quiz.questions.enumerated() {
            aXml += "<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Câu \(idx + 1): \(xmlEscape(q.text))</w:t></w:r></w:p>"
            aXml += "<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>-> Đáp án đúng: \(xmlEscape(q.correctAnswerLabel)) (\(xmlEscape(q.correctAnswerText)))</w:t></w:r></w:p>"
            if !q.explanation.isEmpty {
                aXml += "<w:p><w:r><w:rPr><w:i/></w:rPr><w:t>   Giải thích: \(xmlEscape(q.explanation))</w:t></w:r></w:p>"
            }
            aXml += "<w:p/>"
        }
        
        // Create native .docx files
        try createDocxPackage(bodyXml: qXml, outputPath: questionDocxPath)
        try createDocxPackage(bodyXml: aXml, outputPath: answerDocxPath)
        
        // Zip both docx files into single WordDocxBundle.zip
        if fileManager.fileExists(atPath: zipFilePath) {
            try fileManager.removeItem(atPath: zipFilePath)
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.currentDirectoryURL = tempDir
        process.arguments = ["-r", zipFilePath, questionDocxName, answerDocxName]
        try process.run()
        process.waitUntilExit()
        
        return zipFilePath
    }
    
    private func createDocxPackage(bodyXml: String, outputPath: String) throws {
        let fm = FileManager.default
        let tempDocxDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: tempDocxDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: tempDocxDir) }
        
        let relsDir = tempDocxDir.appendingPathComponent("_rels")
        let wordDir = tempDocxDir.appendingPathComponent("word")
        try fm.createDirectory(at: relsDir, withIntermediateDirectories: true)
        try fm.createDirectory(at: wordDir, withIntermediateDirectories: true)
        
        let contentTypesXml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
            <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
            <Default Extension="xml" ContentType="application/xml"/>
            <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
        </Types>
        """
        
        let relsXml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
        </Relationships>
        """
        
        let docXml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:body>
                \(bodyXml)
            </w:body>
        </w:document>
        """
        
        try contentTypesXml.write(to: tempDocxDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
        try relsXml.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
        try docXml.write(to: wordDir.appendingPathComponent("document.xml"), atomically: true, encoding: .utf8)
        
        if fm.fileExists(atPath: outputPath) {
            try fm.removeItem(atPath: outputPath)
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.currentDirectoryURL = tempDocxDir
        process.arguments = ["-r", outputPath, "[Content_Types].xml", "_rels", "word"]
        try process.run()
        process.waitUntilExit()
    }
    
    private func xmlEscape(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
    
    private func escapeRtf(_ text: String) -> String {
        var result = ""
        for scalar in text.unicodeScalars {
            let val = scalar.value
            if val > 127 {
                let signedVal = Int16(bitPattern: UInt16(val & 0xFFFF))
                result += "\\u\(signedVal)?"
            } else if scalar == "\\" {
                result += "\\\\"
            } else if scalar == "{" {
                result += "\\{"
            } else if scalar == "}" {
                result += "\\}"
            } else if scalar == "\n" {
                result += "\\par\n"
            } else {
                result += String(scalar)
            }
        }
        return result
    }
}
