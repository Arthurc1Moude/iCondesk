import SwiftUI

struct FileTransferView: View {
    @EnvironmentObject private var connectionManager: ConnectionManager
    @EnvironmentObject private var fileTransferManager: FileTransferManager
    @State private var selectedPath: String = ""
    @State private var isUploading = false
    @State private var isShowingDocumentPicker = false
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .nameAscending
    @State private var showingCreateFolderDialog = false
    @State private var newFolderName = ""
    @State private var selectedItems: Set<String> = []
    @State private var isMultiSelectMode = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !connectionManager.isConnected {
                    ConnectionRequiredView()
                } else {
                    VStack {
                        // Path navigation
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button(action: {
                                    fileTransferManager.navigateToRoot()
                                }) {
                                    Image(systemName: "house.fill")
                                        .padding(.horizontal, 5)
                                }
                                
                                ForEach(fileTransferManager.pathComponents, id: \.self) { component in
                                    Button(action: {
                                        fileTransferManager.navigateToPath(component)
                                    }) {
                                        Text(component)
                                    }
                                    
                                    if component != fileTransferManager.pathComponents.last {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search files", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Menu {
                                Button(action: { sortOrder = .nameAscending }) {
                                    Label("Name (A-Z)", systemImage: "arrow.up")
                                }
                                Button(action: { sortOrder = .nameDescending }) {
                                    Label("Name (Z-A)", systemImage: "arrow.down")
                                }
                                Button(action: { sortOrder = .dateAscending }) {
                                    Label("Date (Oldest first)", systemImage: "calendar")
                                }
                                Button(action: { sortOrder = .dateDescending }) {
                                    Label("Date (Newest first)", systemImage: "calendar.badge.clock")
                                }
                                Button(action: { sortOrder = .sizeAscending }) {
                                    Label("Size (Smallest first)", systemImage: "arrow.up.arrow.down")
                                }
                                Button(action: { sortOrder = .sizeDescending }) {
                                    Label("Size (Largest first)", systemImage: "arrow.down.arrow.up")
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // File list
                        List {
                            if fileTransferManager.currentPath != "/" {
                                Button(action: {
                                    fileTransferManager.navigateUp()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.doc.fill")
                                            .foregroundColor(.blue)
                                        Text("..")
                                        Spacer()
                                    }
                                }
                            }
                            
                            ForEach(filteredItems, id: \.path) { item in
                                FileListItemView(
                                    item: item,
                                    isSelected: selectedItems.contains(item.path),
                                    isMultiSelectMode: isMultiSelectMode,
                                    onTap: {
                                        if isMultiSelectMode {
                                            toggleItemSelection(item.path)
                                        } else {
                                            handleItemTap(item)
                                        }
                                    },
                                    onLongPress: {
                                        if !isMultiSelectMode {
                                            isMultiSelectMode = true
                                            selectedItems.insert(item.path)
                                        }
                                    }
                                )
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        // Bottom toolbar
                        HStack {
                            if isMultiSelectMode {
                                Button(action: {
                                    isMultiSelectMode = false
                                    selectedItems.removeAll()
                                }) {
                                    Text("Cancel")
                                }
                                
                                Spacer()
                                
                                Text("\(selectedItems.count) selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Menu {
                                    Button(action: {
                                        fileTransferManager.downloadItems(Array(selectedItems))
                                        isMultiSelectMode = false
                                        selectedItems.removeAll()
                                    }) {
                                        Label("Download", systemImage: "arrow.down.circle")
                                    }
                                    
                                    Button(action: {
                                        fileTransferManager.deleteItems(Array(selectedItems))
                                        isMultiSelectMode = false
                                        selectedItems.removeAll()
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button(action: {
                                        // Implement zip functionality
                                        fileTransferManager.compressItems(Array(selectedItems))
                                        isMultiSelectMode = false
                                        selectedItems.removeAll()
                                    }) {
                                        Label("Compress", systemImage: "doc.zipper")
                                    }
                                } label: {
                                    Text("Actions")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            } else {
                                Button(action: {
                                    isShowingDocumentPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.doc")
                                        Text("Upload")
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showingCreateFolderDialog = true
                                }) {
                                    HStack {
                                        Image(systemName: "folder.badge.plus")
                                        Text("New Folder")
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    isMultiSelectMode = true
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle")
                                        Text("Select")
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                    }
                }
            }
            .navigationTitle("File Transfer")
            .navigationBarItems(
                trailing: Button(action: {
                    fileTransferManager.refreshCurrentDirectory()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(!connectionManager.isConnected)
            )
            .alert("Create New Folder", isPresented: $showingCreateFolderDialog) {
                TextField("Folder Name", text: $newFolderName)
                Button("Cancel", role: .cancel) {
                    newFolderName = ""
                }
                Button("Create") {
                    if !newFolderName.isEmpty {
                        fileTransferManager.createFolder(newFolderName)
                        newFolderName = ""
                    }
                }
            }
            .sheet(isPresented: $isShowingDocumentPicker) {
                DocumentPickerView { urls in
                    if let url = urls.first {
                        fileTransferManager.uploadFile(from: url)
                    }
                }
            }
        }
    }
    
    private var filteredItems: [FileItem] {
        let items = fileTransferManager.currentDirectoryItems
        
        // Apply search filter
        let filtered = searchText.isEmpty ? items : items.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText)
        }
        
        // Apply sorting
        return filtered.sorted { first, second in
            switch sortOrder {
            case .nameAscending:
                return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
            case .nameDescending:
                return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedDescending
            case .dateAscending:
                return first.modificationDate < second.modificationDate
            case .dateDescending:
                return first.modificationDate > second.modificationDate
            case .sizeAscending:
                return first.size < second.size
            case .sizeDescending:
                return first.size > second.size
            }
        }
    }
    
    private func handleItemTap(_ item: FileItem) {
        if item.isDirectory {
            fileTransferManager.navigateToDirectory(item.name)
        } else {
            fileTransferManager.previewFile(item)
        }
    }
    
    private func toggleItemSelection(_ path: String) {
        if selectedItems.contains(path) {
            selectedItems.remove(path)
        } else {
            selectedItems.insert(path)
        }
    }
}

struct FileListItemView: View {
    let item: FileItem
    let isSelected: Bool
    let isMultiSelectMode: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: iconForFileType(item))
                    .foregroundColor(colorForFileType(item))
                
                VStack(alignment: .leading) {
                    Text(item.name)
                        .lineLimit(1)
                    
                    HStack {
                        Text(item.formattedSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(item.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isMultiSelectMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .contentShape(Rectangle())
        .onLongPressGesture {
            onLongPress()
        }
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
    
    private func iconForFileType(_ item: FileItem) -> String {
        if item.isDirectory {
            return "folder.fill"
        }
        
        switch item.fileExtension.lowercased() {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "film.fill"
        case "mp3", "wav", "aac":
            return "music.note"
        case "doc", "docx":
            return "doc.text.fill"
        case "xls", "xlsx":
            return "chart.bar.doc.horizontal.fill"
        case "ppt", "pptx":
            return "chart.bar.doc.horizontal.fill"
        case "zip", "rar", "7z":
            return "doc.zipper"
        default:
            return "doc.fill"
        }
    }
    
    private func colorForFileType(_ item: FileItem) -> Color {
        if item.isDirectory {
            return .blue
        }
        
        switch item.fileExtension.lowercased() {
        case "pdf":
            return .red
        case "jpg", "jpeg", "png", "gif", "heic":
            return .green
        case "mp4", "mov", "avi":
            return .purple
        case "mp3", "wav", "aac":
            return .pink
        case "doc", "docx":
            return .blue
        case "xls", "xlsx":
            return .green
        case "ppt", "pptx":
            return .orange
        case "zip", "rar", "7z":
            return .gray
        default:
            return .gray
        }
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    let onPick: ([URL]) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onPick(urls)
        }
    }
}

struct ConnectionRequiredView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Connection Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please connect to a device to access file transfer features")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            NavigationLink(destination: ConnectionView()) {
                Text("Go to Connection")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct FileTransferView_Previews: PreviewProvider {
    static var previews: some View {
        FileTransferView()
            .environmentObject(ConnectionManager.shared)
            .environmentObject(FileTransferManager.shared)
    }
}