import Foundation
import AppKit

public class UpdateChecker: ObservableObject {
    public static let shared = UpdateChecker()
    
    @Published public var hasUpdateAvailable: Bool = false
    @Published public var latestVersionTag: String = ""
    @Published public var releaseNotes: String = ""
    @Published public var releasePageURL: String = "https://github.com/tozn607/quizmaster/releases"
    @Published public var isChecking: Bool = false
    
    private init() {}
    
    /// Check latest release on GitHub API
    public func checkForUpdates() async {
        await MainActor.run { isChecking = true }
        
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
                let current = AppVersionInfo.currentVersion.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                let latest = tagName.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                await MainActor.run {
                    self.latestVersionTag = tagName
                    self.releasePageURL = htmlUrl
                    self.releaseNotes = body
                    self.isChecking = false
                    
                    // Simple version compare
                    if self.isVersionNewer(latest: latest, current: current) {
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
    
    private func isVersionNewer(latest: String, current: String) -> Bool {
        let latestComponents = latest.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(latestComponents.count, currentComponents.count) {
            let l = i < latestComponents.count ? latestComponents[i] : 0
            let c = i < currentComponents.count ? currentComponents[i] : 0
            if l > c { return true }
            if l < c { return false }
        }
        return false
    }
}
