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
            // Fallback try reading as string
            return try String(contentsOf: url, encoding: .utf8)
        }
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
                // Perform OCR using Vision framework for scanned pages
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
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                continuation.resume(returning: recognizedStrings.joined(separator: "\n"))
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
        // Run unzip command in temporary location to read word/document.xml
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

// Simple XML Parser for Word document text node extraction
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
        return extractedText
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "w:t" {
            isInsideTextNode = true
        } else if elementName == "w:p" || elementName == "w:tr" {
            extractedText += "\n"
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
