import Foundation
import AppKit

public class UpdateChecker: ObservableObject {
    public static let shared = UpdateChecker()
    
    @Published public var hasUpdateAvailable: Bool = false
    @Published public var latestVersionTag: String = ""
    @Published public var latestBuildNumber: Int = 0
    @Published public var releaseNotes: String = ""
    @Published public var releasePageURL: String = "https://github.com/tozn607/quizmaster/releases"
    @Published public var latestZipDownloadURL: String = ""
    @Published public var isChecking: Bool = false
    
    // OTA Auto-Update States
    @Published public var isDownloadingUpdate: Bool = false
    @Published public var updateProgress: Double = 0.0
    @Published public var updateStatusText: String = ""
    @Published public var updateError: String? = nil
    
    private init() {}
    
    /// Check latest release on GitHub API or build_info.json
    public func checkForUpdates() async {
        await MainActor.run {
            isChecking = true
            updateError = nil
        }
        
        let currentBuild = Int(AppVersionInfo.buildNumber) ?? 100
        
        // 1. Fetch GitHub Releases API for zip assets and tag
        if let url = URL(string: "https://api.github.com/repos/tozn607/quizmaster/releases/latest") {
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            request.setValue("QuizMaster-macOS-App", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            if let (data, response) = try? await URLSession.shared.data(for: request),
               let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let tagName = json["tag_name"] as? String,
               let htmlUrl = json["html_url"] as? String {
                
                let body = json["body"] as? String ?? ""
                
                // Extract zip download asset URL
                var zipUrl = ""
                if let assets = json["assets"] as? [[String: Any]] {
                    for asset in assets {
                        if let name = asset["name"] as? String, name.hasSuffix(".zip"),
                           let downloadUrl = asset["browser_download_url"] as? String {
                            zipUrl = downloadUrl
                            break
                        }
                    }
                }
                
                // Parse build number from tag e.g. v1.1.1-b140
                let parsedBuild: Int
                if let bRange = tagName.range(of: "-b") {
                    let bStr = String(tagName[bRange.upperBound...])
                    parsedBuild = Int(bStr) ?? 0
                } else {
                    parsedBuild = 0
                }
                
                let finalZipUrl = zipUrl
                await MainActor.run {
                    self.latestBuildNumber = parsedBuild
                    self.latestVersionTag = tagName
                    self.releasePageURL = htmlUrl
                    self.releaseNotes = body
                    self.latestZipDownloadURL = finalZipUrl
                    self.isChecking = false
                    
                    if parsedBuild > currentBuild {
                        self.hasUpdateAvailable = true
                    } else {
                        self.hasUpdateAvailable = false
                    }
                }
                return
            }
        }
        
        // 2. Fallback to build_info.json on GitHub main branch
        if let rawUrl = URL(string: "https://raw.githubusercontent.com/tozn607/quizmaster/main/build_info.json") {
            var request = URLRequest(url: rawUrl)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 6
            
            if let (data, response) = try? await URLSession.shared.data(for: request),
               let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let remoteBuild = json["buildNumber"] as? Int,
               let versionStr = json["version"] as? String {
                
                let tagStr = json["releaseTag"] as? String ?? "v\(versionStr)-b\(remoteBuild)"
                let zipUrl = "https://github.com/tozn607/quizmaster/releases/download/\(tagStr)/QuizMaster-\(tagStr).zip"
                
                await MainActor.run {
                    self.latestBuildNumber = remoteBuild
                    self.latestVersionTag = tagStr
                    self.latestZipDownloadURL = zipUrl
                    self.isChecking = false
                    
                    if remoteBuild > currentBuild {
                        self.hasUpdateAvailable = true
                    } else {
                        self.hasUpdateAvailable = false
                    }
                }
                return
            }
        }
        
        await MainActor.run { isChecking = false }
    }
    
    /// Download latest release zip and perform automatic OTA update
    public func startAutomaticOTAUpdate() {
        guard !latestZipDownloadURL.isEmpty, let downloadURL = URL(string: latestZipDownloadURL) else {
            // Fallback if URL empty: construct default GitHub release asset URL
            let fallbackTag = latestVersionTag.isEmpty ? "v1.1.1-b140" : latestVersionTag
            let fallbackStr = "https://github.com/tozn607/quizmaster/releases/download/\(fallbackTag)/QuizMaster-\(fallbackTag).zip"
            guard let fallbackURL = URL(string: fallbackStr) else {
                updateError = "Không tìm thấy đường dẫn tải về bản cập nhật."
                return
            }
            performDownloadAndInstall(url: fallbackURL)
            return
        }
        
        performDownloadAndInstall(url: downloadURL)
    }
    
    private func performDownloadAndInstall(url: URL) {
        DispatchQueue.main.async {
            self.isDownloadingUpdate = true
            self.updateProgress = 0.05
            self.updateStatusText = "Đang kết nối và tải bản cập nhật..."
            self.updateError = nil
        }
        
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isDownloadingUpdate = false
                    self.updateError = "Lỗi khi tải bản cập nhật: \(error.localizedDescription)"
                }
                return
            }
            
            guard let localURL = localURL else {
                DispatchQueue.main.async {
                    self.isDownloadingUpdate = false
                    self.updateError = "Không nhận được tệp cập nhật từ máy chủ."
                }
                return
            }
            
            DispatchQueue.main.async {
                self.updateProgress = 0.60
                self.updateStatusText = "Đang giải nén & chuẩn bị cài đặt..."
            }
            
            do {
                let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
                
                let zipDestination = tempDir.appendingPathComponent("update.zip")
                try FileManager.default.copyItem(at: localURL, to: zipDestination)
                
                // Unzip using ditto
                let unzipProcess = Process()
                unzipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
                unzipProcess.arguments = ["-x", "-k", zipDestination.path, tempDir.path]
                try unzipProcess.run()
                unzipProcess.waitUntilExit()
                
                // Search for QuizMaster.app in extracted temp directory
                let extractedAppPath: String
                let extractedAppURL = tempDir.appendingPathComponent("QuizMaster.app")
                if FileManager.default.fileExists(atPath: extractedAppURL.path) {
                    extractedAppPath = extractedAppURL.path
                } else if let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir.path),
                          let appName = contents.first(where: { $0.hasSuffix(".app") }) {
                    extractedAppPath = tempDir.appendingPathComponent(appName).path
                } else {
                    DispatchQueue.main.async {
                        self.isDownloadingUpdate = false
                        self.updateError = "Không tìm thấy QuizMaster.app trong tệp giải nén."
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.updateProgress = 0.95
                    self.updateStatusText = "Đang cài đặt và khởi động lại QuizMaster..."
                }
                
                let currentAppPath = Bundle.main.bundlePath
                
                // Self-replacing OTA bash script
                let script = """
                sleep 0.8
                rm -rf "\(currentAppPath)"
                cp -R "\(extractedAppPath)" "\(currentAppPath)"
                xattr -cr "\(currentAppPath)" || true
                open "\(currentAppPath)"
                """
                
                let installerProcess = Process()
                installerProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
                installerProcess.arguments = ["-c", script]
                try installerProcess.run()
                
                DispatchQueue.main.async {
                    NSApplication.shared.terminate(nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isDownloadingUpdate = false
                    self.updateError = "Lỗi cài đặt bản cập nhật: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
    }
    
    public func openReleasePage() {
        if let url = URL(string: releasePageURL) {
            NSWorkspace.shared.open(url)
        }
    }
}
