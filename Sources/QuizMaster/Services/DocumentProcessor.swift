import Foundation
import PDFKit
import Vision
import AppKit

public class DocumentProcessor {
    public static let shared = DocumentProcessor()
    
    private init() {}
    
    /// Extract text content from supported file types (.pdf, .docx, .txt, .json)
    public func extractText(from url: URL) async throws -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf":
            return try await extractTextFromPDF(url: url)
        case "docx":
            return try extractTextFromDocx(url: url)
        case "zip":
            return try extractTextFromZip(url: url)
        case "txt", "json", "rtf", "csv", "md":
            return try String(contentsOf: url, encoding: .utf8)
        default:
            return try String(contentsOf: url, encoding: .utf8)
        }
    }
    
    // MARK: - Pre-made Quiz File Importer
    public func extractQuizFromFile(at url: URL) throws -> Quiz {
        let title = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension.lowercased()
        
        if ext == "zip" {
            if let questions = try extractQuizFromZip(url: url) {
                return Quiz(title: title, questions: questions, isPreMade: true)
            }
        } else if ext == "json" {
            let data = try Data(contentsOf: url)
            if let questions = try? JSONDecoder().decode([Question].self, from: data) {
                return Quiz(title: title, questions: questions, isPreMade: true)
            } else if let quiz = try? JSONDecoder().decode(Quiz.self, from: data) {
                return quiz
            }
        }
        
        throw NSError(domain: "DocumentProcessor", code: 404, userInfo: [NSLocalizedDescriptionKey: "Không thể đọc bộ đề thi từ tệp này. Vui lòng chọn tệp Zip Bundle (.zip) hoặc JSON được xuất từ ứng dụng."])
    }
    
    // MARK: - PDF Extraction (PDFKit + Vision OCR fallback)
    private func extractTextFromPDF(url: URL) async throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw NSError(domain: "DocumentProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot open PDF file."])
        }
        
        var fullText = ""
        let pageCount = pdfDocument.pageCount
        
        for i in 0..<pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            if let pageText = page.string, !pageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fullText += pageText + "\n\n"
            } else {
                if let pageImage = renderPDFPageToImage(page: page) {
                    let ocrText = try await performOCROnImage(image: pageImage)
                    fullText += ocrText + "\n\n"
                }
            }
        }
        
        return fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func renderPDFPageToImage(page: PDFPage) -> NSImage? {
        let bounds = page.bounds(for: .mediaBox)
        let renderer = NSImage(size: bounds.size, flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            context.setFillColor(NSColor.white.cgColor)
            context.fill(rect)
            page.draw(with: .mediaBox, to: context)
            return true
        }
        return renderer
    }
    
    private func performOCROnImage(image: NSImage) async throws -> String {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return ""
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                // Pair observations with top candidate text
                struct RecognizedLineItem {
                    let text: String
                    let box: CGRect
                }
                
                var items: [RecognizedLineItem] = []
                for obs in observations {
                    if let text = obs.topCandidates(1).first?.string, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        items.append(RecognizedLineItem(text: text, box: obs.boundingBox))
                    }
                }
                
                guard !items.isEmpty else {
                    continuation.resume(returning: "")
                    return
                }
                
                // Sort observations geometrically: top-to-bottom (descending Y in Vision coords), then left-to-right (ascending X)
                // Group items into horizontal lines using dynamic line height threshold
                let sortedByY = items.sorted { $0.box.midY > $1.box.midY }
                
                var lines: [[RecognizedLineItem]] = []
                for item in sortedByY {
                    let itemMidY = item.box.midY
                    let itemHeight = max(0.012, item.box.height)
                    let threshold = itemHeight * 0.65
                    
                    if let lineIdx = lines.firstIndex(where: { line in
                        guard let firstInLine = line.first else { return false }
                        return abs(firstInLine.box.midY - itemMidY) < threshold
                    }) {
                        lines[lineIdx].append(item)
                    } else {
                        lines.append([item])
                    }
                }
                
                // Sort each line from left to right (minX ascending) and join
                var reconstructedText = ""
                for var line in lines {
                    line.sort { $0.box.minX < $1.box.minX }
                    let lineStr = line.map { $0.text }.joined(separator: " ")
                    reconstructedText += lineStr + "\n"
                }
                
                continuation.resume(returning: reconstructedText.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["vi-VN", "en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - ZIP Archive Import Helper
    public func extractQuizFromZip(url: URL) throws -> [Question]? {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", url.path, "-d", tempDir.path]
        try process.run()
        process.waitUntilExit()
        
        let jsonPath = tempDir.appendingPathComponent("quiz_bundle.json")
        if FileManager.default.fileExists(atPath: jsonPath.path),
           let data = try? Data(contentsOf: jsonPath),
           let questions = try? JSONDecoder().decode([Question].self, from: data) {
            return questions
        }
        return nil
    }
    
    private func extractTextFromZip(url: URL) throws -> String {
        if let questions = try? extractQuizFromZip(url: url) {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(questions), let str = String(data: data, encoding: .utf8) {
                return str
            }
        }
        return ""
    }
    
    // MARK: - DOCX Extraction via unzip & XML stripping
    private func extractTextFromDocx(url: URL) throws -> String {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", url.path, "-d", tempDir.path]
        try process.run()
        process.waitUntilExit()
        
        let documentXmlPath = tempDir.appendingPathComponent("word/document.xml")
        guard FileManager.default.fileExists(atPath: documentXmlPath.path) else {
            throw NSError(domain: "DocumentProcessor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to extract document.xml from .docx file."])
        }
        
        let xmlData = try Data(contentsOf: documentXmlPath)
        let parser = DocxTextParser(xmlData: xmlData)
        return parser.parse()
    }
}

// XML Parser for Word document text node extraction with whitespace and table preservation
private class DocxTextParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private var extractedText = ""
    private var isInsideTextNode = false
    
    init(xmlData: Data) {
        self.parser = XMLParser(data: xmlData)
        super.init()
        self.parser.delegate = self
    }
    
    func parse() -> String {
        parser.parse()
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "w:t" {
            isInsideTextNode = true
        } else if elementName == "w:tab" {
            extractedText += "    "
        } else if elementName == "w:br" || elementName == "w:cr" {
            extractedText += "\n"
        } else if elementName == "w:p" || elementName == "w:tr" {
            if !extractedText.isEmpty && !extractedText.hasSuffix("\n") {
                extractedText += "\n"
            }
        } else if elementName == "w:tc" {
            if !extractedText.isEmpty && !extractedText.hasSuffix(" ") && !extractedText.hasSuffix("\n") {
                extractedText += " "
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "w:t" {
            isInsideTextNode = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInsideTextNode {
            extractedText += string
        }
    }
}
