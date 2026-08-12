import Foundation
import AppKit

public class UpdateChecker: ObservableObject {
    public static let shared = UpdateChecker()
    
    @Published public var hasUpdateAvailable: Bool = false
    @Published public var latestVersionTag: String = ""
    @Published public var latestBuildNumber: Int = 0
    @Published public var releaseNotes: String = ""
    @Published public var releasePageURL: String = "https://github.com/tozn607/quizmaster/releases"
    @Published public var isChecking: Bool = false
    
    private init() {}
    
    /// Check latest release on GitHub API or build_info.json
    public func checkForUpdates() async {
        await MainActor.run { isChecking = true }
        
        let currentBuild = Int(AppVersionInfo.buildNumber) ?? 100
        
        // 1. Try checking raw build_info.json from GitHub main branch
        if let rawUrl = URL(string: "https://raw.githubusercontent.com/tozn607/quizmaster/main/build_info.json") {
            var request = URLRequest(url: rawUrl)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 6
            
            if let (data, response) = try? await URLSession.shared.data(for: request),
               let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let remoteBuild = json["buildNumber"] as? Int,
               let versionStr = json["version"] as? String {
                
                await MainActor.run {
                    self.latestBuildNumber = remoteBuild
                    self.latestVersionTag = "v\(versionStr) (Build \(remoteBuild))"
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
        
        // 2. Fallback to GitHub Releases API
        guard let url = URL(string: "https://api.github.com/repos/tozn607/quizmaster/releases/latest") else {
            await MainActor.run { isChecking = false }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("QuizMaster-macOS-App", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let tagName = json["tag_name"] as? String,
               let htmlUrl = json["html_url"] as? String {
                
                let body = json["body"] as? String ?? ""
                
                // Parse build number from tag e.g. v1.0.1-b105 or v1.0.1
                let parsedBuild: Int
                if let bRange = tagName.range(of: "-b") {
                    let bStr = String(tagName[bRange.upperBound...])
                    parsedBuild = Int(bStr) ?? 0
                } else {
                    parsedBuild = 0
                }
                
                await MainActor.run {
                    self.latestVersionTag = tagName
                    self.releasePageURL = htmlUrl
                    self.releaseNotes = body
                    self.isChecking = false
                    
                    if parsedBuild > currentBuild {
                        self.hasUpdateAvailable = true
                    } else {
                        self.hasUpdateAvailable = false
                    }
                }
            } else {
                await MainActor.run { isChecking = false }
            }
        } catch {
            await MainActor.run { isChecking = false }
        }
    }
    
    public func openReleasePage() {
        if let url = URL(string: releasePageURL) {
            NSWorkspace.shared.open(url)
        }
    }
}
