import SwiftUI

public struct SidebarView: View {
    @Binding var selectedProject: StudyProject?
    @Binding var showSettingsSheet: Bool
    
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var loc: LocalizationManager
    
    @State private var showNewProjectSheet: Bool = false
    @State private var newProjectName: String = ""
    @State private var newProjectDesc: String = ""
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Title & Settings
            HStack {
                Text(loc.text("projects"))
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showSettingsSheet = true }) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help(loc.text("settings"))
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
                        .foregroundColor(.blue)
                    Text(loc.text("addProject"))
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showNewProjectSheet) {
            newProjectDialog
        }
    }
    
    @ViewBuilder
    private func projectRow(project: StudyProject) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(project.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
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
                BadgeView(text: "\(project.overallMasteryPercentage)%", color: project.overallMasteryPercentage > 75 ? .green : .blue)
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button {
                showInFinder(project: project)
            } label: {
                Label(loc.text("showInFinder"), systemImage: "folder")
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
                Text(loc.text("projectName"))
                    .font(.caption)
                    .fontWeight(.semibold)
                TextField("Ví dụ: Ôn thi Tiếng Anh / Lịch sử", text: $newProjectName)
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
                }
                
                Spacer()
                
                PrimaryButton(title: loc.text("create"), icon: "plus") {
                    let created = storage.addProject(name: newProjectName, description: newProjectDesc)
                    selectedProject = created
                    showNewProjectSheet = false
                    newProjectName = ""
                    newProjectDesc = ""
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
}
