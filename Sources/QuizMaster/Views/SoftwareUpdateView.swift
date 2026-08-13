import SwiftUI
import AppKit

public struct SoftwareUpdateView: View {
    @ObservedObject var updateChecker = UpdateChecker.shared
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        LiquidGlassWindowBackdrop {
            VStack(spacing: 0) {
                // Header Bar
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .font(.system(size: 20 * fontScale))
                        .foregroundColor(LiquidGlassPalette.oceanBlue)
                    Text(loc.text("checkUpdates"))
                        .font(.system(size: 18 * fontScale, weight: .bold))
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
            
            VStack(spacing: 20 * fontScale) {
                // Hero Icon
                Image(systemName: updateChecker.hasUpdateAvailable ? "sparkles.tv.fill" : "checkmark.seal.fill")
                    .font(.system(size: 54 * fontScale))
                    .foregroundColor(updateChecker.hasUpdateAvailable ? LiquidGlassPalette.oceanBlue : LiquidGlassPalette.emeraldMint)
                    .padding(.top, 12 * fontScale)
                
                VStack(spacing: 6 * fontScale) {
                    Text(updateChecker.hasUpdateAvailable ? loc.text("updateAvailableTitle") : loc.text("youAreUpToDate"))
                        .font(.system(size: 20 * fontScale, weight: .bold))
                    
                    Text("QuizMaster \(AppVersionInfo.currentVersion) (Build \(AppVersionInfo.buildNumber))")
                        .font(.system(size: 14 * fontScale))
                        .foregroundColor(.secondary)
                }
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 12 * fontScale) {
                        HStack {
                            Text(loc.text("currentVersionLabel"))
                                .font(.system(size: 13 * fontScale, weight: .semibold))
                            Spacer()
                            BadgeView(text: "\(AppVersionInfo.currentVersion) (Build \(AppVersionInfo.buildNumber))", color: .gray)
                        }
                        
                        if updateChecker.hasUpdateAvailable {
                            HStack {
                                Text(loc.text("latestVersionLabel"))
                                    .font(.system(size: 13 * fontScale, weight: .semibold))
                                Spacer()
                                BadgeView(text: updateChecker.latestVersionTag, color: LiquidGlassPalette.oceanBlue)
                            }
                            
                            if !updateChecker.releaseNotes.isEmpty {
                                Divider()
                                VStack(alignment: .leading, spacing: 4 * fontScale) {
                                    Text(loc.text("releaseNotesLabel"))
                                        .font(.system(size: 12 * fontScale, weight: .bold))
                                        .foregroundColor(LiquidGlassPalette.oceanBlue)
                                    ScrollView {
                                        Text(updateChecker.releaseNotes)
                                            .font(.system(size: 12 * fontScale))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .frame(maxHeight: 110 * fontScale)
                                }
                            }
                        }
                    }
                }
                
                // OTA Update Progress & Status Banner
                if updateChecker.isDownloadingUpdate {
                    VStack(spacing: 8 * fontScale) {
                        ProgressView(value: updateChecker.updateProgress)
                            .progressViewStyle(.linear)
                            .tint(LiquidGlassPalette.oceanBlue)
                        
                        Text(updateChecker.updateStatusText)
                            .font(.system(size: 13 * fontScale, weight: .semibold))
                            .foregroundColor(LiquidGlassPalette.oceanBlue)
                    }
                    .padding(.horizontal)
                } else if let err = updateChecker.updateError {
                    Text(err)
                        .font(.system(size: 12 * fontScale, weight: .bold))
                        .foregroundColor(LiquidGlassPalette.coralRed)
                        .padding(.horizontal)
                } else if updateChecker.isChecking {
                    HStack(spacing: 8 * fontScale) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Đang kiểm tra trên GitHub...")
                            .font(.system(size: 13 * fontScale))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(24 * fontScale)
            
            Divider()
            
            // Footer Bar
            HStack {
                SecondaryButton(title: loc.text("close"), icon: "xmark") {
                    dismiss()
                }
                
                Spacer()
                
                if updateChecker.hasUpdateAvailable {
                    SecondaryButton(title: "Mở trên GitHub ↗", icon: "square.and.arrow.up") {
                        updateChecker.openReleasePage()
                    }
                    
                    PrimaryButton(
                        title: updateChecker.isDownloadingUpdate ? "Đang Cài đặt..." : "Tải & Tự động Cài đặt",
                        icon: "arrow.down.circle.fill",
                        color: LiquidGlassPalette.oceanBlue
                    ) {
                        updateChecker.startAutomaticOTAUpdate()
                    }
                    .disabled(updateChecker.isDownloadingUpdate)
                } else {
                    PrimaryButton(title: loc.text("checkUpdates"), icon: "arrow.clockwise", color: LiquidGlassPalette.oceanBlue) {
                        Task {
                            await updateChecker.checkForUpdates()
                        }
                    }
                }
            }
            .padding()
            .background(.thinMaterial)
        }
        }
        .frame(width: 520 * fontScale, height: 520 * fontScale)
        .onAppear {
            Task {
                await updateChecker.checkForUpdates()
            }
        }
    }
}
