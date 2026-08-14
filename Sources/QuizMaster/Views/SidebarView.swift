import SwiftUI

public struct SidebarView: View {
    @Binding var selectedProject: StudyProject?
    @Binding var showSettingsSheet: Bool
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.appFontScale) var fontScale
    
    @State private var showNewProjectSheet: Bool = false
    @State private var newProjectName: String = ""
    @State private var newProjectDesc: String = ""
    @State private var newProjectType: ProjectType = .general
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Title & Settings
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    AppLogoView(size: 32)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("QuizMaster")
                            .font(.system(size: 15, weight: .bold))
                        Text(loc.text("projects"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(loc.text("settings"))
                }
                
                timeBasedGreetingBadge
            }
            .padding()
            
            Divider()
            
            // Project List
            if storage.projects.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                    Text(loc.text("noProjects"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                Spacer()
            } else {
                List(selection: $selectedProject) {
                    ForEach(storage.projects) { project in
                        projectRow(project: project)
                            .tag(project)
                    }
                    .onDelete(perform: deleteProjects)
                }
                .listStyle(.sidebar)
            }
            
            Divider()
            
            // Bottom Add Project Button
            Button(action: { showNewProjectSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(LiquidGlassPalette.oceanBlue)
                    Text(loc.text("addProject"))
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(12)
                .background(.thinMaterial)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showNewProjectSheet) {
            newProjectDialog
        }
    }
    
    @ViewBuilder
    private func projectRow(project: StudyProject) -> some View {
        let isLL = project.projectType == .languageLearning
        let iconColor = isLL ? LiquidGlassPalette.deepPurple : LiquidGlassPalette.oceanBlue
        
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: project.projectType.iconName)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(project.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    if isLL {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 9))
                            .foregroundColor(LiquidGlassPalette.deepPurple)
                    }
                }
                
                HStack(spacing: 8) {
                    Text("\(project.quizzes.count) \(loc.text("quizzesCount"))")
                    Text("•")
                    Text("\(project.totalQuestions) \(loc.text("questionsCount"))")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if project.overallMasteryPercentage > 0 {
                BadgeView(text: "\(project.overallMasteryPercentage)%", color: project.overallMasteryPercentage > 75 ? LiquidGlassPalette.emeraldMint : LiquidGlassPalette.oceanBlue)
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button {
                storage.resetProjectProgress(projectId: project.id)
            } label: {
                Label(loc.text("resetProgress"), systemImage: "arrow.counterclockwise")
            }
            
            Divider()
            
            Button(role: .destructive) {
                storage.deleteProject(id: project.id)
                if selectedProject?.id == project.id {
                    selectedProject = storage.projects.first
                }
            } label: {
                Label(loc.text("deleteProject"), systemImage: "trash")
            }
        }
    }
    
    private var newProjectDialog: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.text("newProjectTitle"))
                .font(.title3)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(loc.text("projectTypeSelector"))
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Picker("", selection: $newProjectType) {
                    ForEach(ProjectType.allCases) { type in
                        Label(type.displayName, systemImage: type.iconName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                if newProjectType == .languageLearning {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.caption2)
                            .foregroundColor(LiquidGlassPalette.sunsetOrange)
                        Text("Chế độ Ngoại ngữ đang trong giai đoạn thử nghiệm (WIP) và liên tục được cải tiến định dạng đề thi.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(loc.text("projectName"))
                    .font(.caption)
                    .fontWeight(.semibold)
                TextField(newProjectType == .languageLearning ? "Ví dụ: Luyện đề THPT Tiếng Anh / IELTS Reading" : "Ví dụ: Lịch sử 12 / Tin học Đại cương", text: $newProjectName)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Mô tả (Không bắt buộc)")
                    .font(.caption)
                    .fontWeight(.semibold)
                TextField("Mô tả ngắn gọn mục tiêu bài học...", text: $newProjectDesc)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Button(loc.text("cancel")) {
                    showNewProjectSheet = false
                    newProjectName = ""
                    newProjectDesc = ""
                    newProjectType = .general
                }
                
                Spacer()
                
                PrimaryButton(title: loc.text("create"), icon: "plus", color: newProjectType == .languageLearning ? LiquidGlassPalette.deepPurple : LiquidGlassPalette.oceanBlue) {
                    let created = storage.addProject(name: newProjectName, description: newProjectDesc, projectType: newProjectType)
                    selectedProject = created
                    showNewProjectSheet = false
                    newProjectName = ""
                    newProjectDesc = ""
                    newProjectType = .general
                }
                .disabled(newProjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(width: 380)
    }
    
    private func showInFinder(project: StudyProject) {
        let url = storage.storageDirectoryURL
        NSWorkspace.shared.open(url)
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let id = storage.projects[index].id
            storage.deleteProject(id: id)
        }
        selectedProject = storage.projects.first
    }
    
    // MARK: - Time-Based Emoji & Cheeky Greetings
    private var timeBasedGreetingBadge: some View {
        let hour = Calendar.current.component(.hour, from: Date())
        let (emoji, greeting) = timeGreeting(for: hour)
        
        return HStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 13))
            Text(greeting)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(LiquidGlassPalette.oceanBlue)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LiquidGlassPalette.oceanBlue.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(LiquidGlassPalette.oceanBlue.opacity(0.2), lineWidth: 1)
        )
    }

    private func timeGreeting(for hour: Int) -> (emoji: String, greeting: String) {
        if hour >= 5 && hour < 11 {
            let options = [
                "Chào buổi sáng! Làm tách cà phê rồi vào cày đề nào ☕",
                "Sáng sớm tinh mơ, bộ não đang ở đỉnh cao phong độ! 🧠",
                "Dậy sớm để thành công... hoặc để giải nốt bộ đề này! 🚀"
            ]
            return ("🌅", options[abs(hour) % options.count])
        } else if hour >= 11 && hour < 14 {
            let options = [
                "Chào giữa trưa! Vừa nghỉ trưa vừa nạp thêm vài câu trắc nghiệm 🍱",
                "Nắng đã lên cao, điểm số cũng phải lên theo! ☀️",
                "Nghỉ trưa ôn bài, chiều thi bao đậu! 🚀"
            ]
            return ("☀️", options[abs(hour) % options.count])
        } else if hour >= 14 && hour < 18 {
            let options = [
                "Chào buổi chiều! Làm ly trà sữa cho tỉnh táo rồi ôn tập tiếp 🧋",
                "Chiều rồi, làm vài câu trắc nghiệm xả stress nào! ⚡",
                "Năng lượng buổi chiều cực sung, cày nốt bài giảng nào! 📚"
            ]
            return ("🌤️", options[abs(hour) % options.count])
        } else if hour >= 18 && hour < 23 {
            let options = [
                "Chào buổi tối! Đèn sách ban đêm luôn mang lại điểm cao 🌙",
                "Cú đêm học bài! Quyết tâm không thua đứa bạn cùng lớp 🦉",
                "Tối mát mẻ, làm vài đề luyện tập rồi thư giãn nào 🚀"
            ]
            return ("🌙", options[abs(hour) % options.count])
        } else {
            let options = [
                "Nửa đêm rồi! Học muộn thế này là thi chắc chắn 10 điểm! 🌌",
                "Ngủ sớm đi bạn ơi... thôi làm nốt câu này rồi ngủ! 😴",
                "Học đêm yên tĩnh, kiến thức ngấm cực sâu! 🕯️"
            ]
            return ("🌌", options[abs(hour) % options.count])
        }
    }
}
