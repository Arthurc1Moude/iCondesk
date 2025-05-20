import Foundation
import SwiftUI

struct FileItem {
    let name: String
    let path: String
    let size: Int64
    let modificationDate: Date
    let isDirectory: Bool
    
    var fileExtension: String {
        return (name as NSString).pathExtension
    }
    
    var formattedSize: String {
        if isDirectory {
            return "--"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: modificationDate)
    }
}

enum SortOrder {
    case nameAscending
    case nameDescending
    case dateAscending
    case dateDescending
    case sizeAscending
    case sizeDescending
}

class FileTransferManager: ObservableObject {
    static let shared = FileTransferManager()
    
    @Published var currentPath: String = "/"
    @Published var currentDirectoryItems: [FileItem] = []
    @Published var pathComponents: [String] = ["/"]
    @Published var isLoading = false
    @Published var transferProgress: Double = 0.0
    @Published var activeTransfers: [String: Double] = [:]
    
    private init() {
        // Load initial directory contents
        refreshCurrentDirectory()
    }
    
    func refreshCurrentDirectory() {
        isLoading = true
        
        // In a real app, this would fetch the directory contents from the connected device
        // For demo purposes, we'll simulate some files and folders
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentDirectoryItems = self.generateSampleFiles(for: self.currentPath)
            self.isLoading = false
        }
    }
    
    func navigateToDirectory(_ directoryName: String) {
        let newPath = currentPath.hasSuffix("/") ? "\(currentPath)\(directoryName)" : "\(currentPath)/\(directoryName)"
        currentPath = newPath
        pathComponents.append(directoryName)
        refreshCurrentDirectory()
    }
    
    func navigateUp() {
        guard currentPath != "/" else { return }
        
        let components = currentPath.split(separator: "/")
        if components.count > 0 {
            _ = pathComponents.popLast()
            currentPath = "/" + components.dropLast().joined(separator: "/")
            if currentPath == "" {
                currentPath = "/"
            }
            refreshCurrentDirectory()
        }
    }
    
    func navigateToRoot() {
        currentPath = "/"
        pathComponents = ["/"]
        refreshCurrentDirectory()
    }
    
    func navigateToPath(_ component: String) {
        if component == "/" {
            navigateToRoot()
            return
        }
        
        if let index = pathComponents.firstIndex(of: component) {
            let newPathComponents = Array(pathComponents.prefix(through: index))
            pathComponents = newPathComponents
            
            if newPathComponents.count == 1 && newPathComponents[0] == "/" {
                currentPath = "/"
            } else {
                currentPath = newPathComponents.joined(separator: "/")
                if !currentPath.hasPrefix("/") {
                    currentPath = "/\(currentPath)"
                }
            }
            
            refreshCurrentDirectory()
        }
    }
    
    func uploadFile(from url: URL) {
        // In a real app, this would upload the file to the connected device
        // For demo purposes, we'll simulate a file upload with progress
        
        let fileName = url.lastPathComponent
        activeTransfers[fileName] = 0.0
        
        // Simulate upload progress
        var progress = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.05
            self.activeTransfers[fileName] = min(progress, 1.0)
            
            if progress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.activeTransfers.removeValue(forKey: fileName)
                    self.refreshCurrentDirectory()
                }
            }
        }
    }
    
    func downloadItems(_ paths: [String]) {
        // In a real app, this would download the files from the connected device
        // For demo purposes, we'll simulate a file download with progress
        
        for path in paths {
            let fileName = (path as NSString).lastPathComponent
            activeTransfers[fileName] = 0.0
            
            // Simulate download progress
            var progress = 0.0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                progress += 0.05
                self.activeTransfers[fileName] = min(progress, 1.0)
                
                if progress >= 1.0 {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.activeTransfers.removeValue(forKey: fileName)
                    }
                }
            }
        }
    }
    
    func deleteItems(_ paths: [String]) {
        // In a real app, this would delete the files from the connected device
        // For demo purposes, we'll simulate file deletion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for path in paths {
                self.currentDirectoryItems.removeAll { $0.path == path }
            }
        }
    }
    
    func compressItems(_ paths: [String]) {
        // In a real app, this would compress the files on the connected device
        // For demo purposes, we'll simulate file compression
        
        let fileNames = paths.map { ($0 as NSString).lastPathComponent }
        let archiveName = fileNames.count == 1 ? "\(fileNames[0]).zip" : "Archive.zip"
        
        activeTransfers[archiveName] = 0.0
        
        // Simulate compression progress
        var progress = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.02
            self.activeTransfers[archiveName] = min(progress, 1.0)
            
            if progress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.activeTransfers.removeValue(forKey: archiveName)
                    
                    // Add the new zip file to the directory
                    let now = Date()
                    let zipSize: Int64 = 1024 * 1024 * Int64.random(in: 1...10) // Random size between 1-10 MB
                    
                    let zipFile = FileItem(
                        name: archiveName,
                        path: "\(self.currentPath)/\(archiveName)",
                        size: zipSize,
                        modificationDate: now,
                        isDirectory: false
                    )
                    
                    self.currentDirectoryItems.append(zipFile)
                }
            }
        }
    }
    
    func createFolder(_ folderName: String) {
        // In a real app, this would create a folder on the connected device
        // For demo purposes, we'll simulate folder creation
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let now = Date()
            
            let newFolder = FileItem(
                name: folderName,
                path: "\(self.currentPath)/\(folderName)",
                size: 0,
                modificationDate: now,
                isDirectory: true
            )
            
            self.currentDirectoryItems.append(newFolder)
        }
    }
    
    func previewFile(_ file: FileItem) {
        // In a real app, this would show a preview of the file
        // For demo purposes, we'll just print the file details
        print("Previewing file: \(file.name)")
    }
    
    // MARK: - Helper Methods
    
    private func generateSampleFiles(for path: String) -> [FileItem] {
        // Generate sample files and folders based on the current path
        var items: [FileItem] = []
        let now = Date()
        
        if path == "/" {
            // Root directory
            items = [
                FileItem(name: "Documents", path: "/Documents", size: 0, modificationDate: now.addingTimeInterval(-86400 * 5), isDirectory: true),
                FileItem(name: "Downloads", path: "/Downloads", size: 0, modificationDate: now.addingTimeInterval(-86400 * 2), isDirectory: true),
                FileItem(name: "Pictures", path: "/Pictures", size: 0, modificationDate: now.addingTimeInterval(-86400 * 10), isDirectory: true),
                FileItem(name: "Music", path: "/Music", size: 0, modificationDate: now.addingTimeInterval(-86400 * 15), isDirectory: true),
                FileItem(name: "Videos", path: "/Videos", size: 0, modificationDate: now.addingTimeInterval(-86400 * 20), isDirectory: true),
                FileItem(name: "README.txt", path: "/README.txt", size: 1024, modificationDate: now.addingTimeInterval(-86400 * 30), isDirectory: false)
            ]
        } else if path == "/Documents" {
            items = [
                FileItem(name: "Work", path: "/Documents/Work", size: 0, modificationDate: now.addingTimeInterval(-86400 * 3), isDirectory: true),
                FileItem(name: "Personal", path: "/Documents/Personal", size: 0, modificationDate: now.addingTimeInterval(-86400 * 7), isDirectory: true),
                FileItem(name: "Project Plan.pdf", path: "/Documents/Project Plan.pdf", size: 2 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 1), isDirectory: false),
                FileItem(name: "Resume.docx", path: "/Documents/Resume.docx", size: 500 * 1024, modificationDate: now.addingTimeInterval(-86400 * 12), isDirectory: false),
                FileItem(name: "Budget.xlsx", path: "/Documents/Budget.xlsx", size: 750 * 1024, modificationDate: now.addingTimeInterval(-86400 * 5), isDirectory: false)
            ]
        } else if path == "/Pictures" {
            items = [
                FileItem(name: "Vacation", path: "/Pictures/Vacation", size: 0, modificationDate: now.addingTimeInterval(-86400 * 60), isDirectory: true),
                FileItem(name: "Family", path: "/Pictures/Family", size: 0, modificationDate: now.addingTimeInterval(-86400 * 90), isDirectory: true),
                FileItem(name: "Selfie.jpg", path: "/Pictures/Selfie.jpg", size: 3 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 2), isDirectory: false),
                FileItem(name: "Beach.png", path: "/Pictures/Beach.png", size: 5 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 45), isDirectory: false),
                FileItem(name: "Mountains.jpg", path: "/Pictures/Mountains.jpg", size: 4 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 30), isDirectory: false),
                FileItem(name: "Screenshot.png", path: "/Pictures/Screenshot.png", size: 1 * 1024 * 1024, modificationDate: now, isDirectory: false)
            ]
        } else if path == "/Downloads" {
            items = [
                FileItem(name: "Software", path: "/Downloads/Software", size: 0, modificationDate: now.addingTimeInterval(-86400 * 10), isDirectory: true),
                FileItem(name: "Movie.mp4", path: "/Downloads/Movie.mp4", size: 1500 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 3), isDirectory: false),
                FileItem(name: "Book.pdf", path: "/Downloads/Book.pdf", size: 25 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 7), isDirectory: false),
                FileItem(name: "Archive.zip", path: "/Downloads/Archive.zip", size: 100 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 1), isDirectory: false),
                FileItem(name: "Installer.dmg", path: "/Downloads/Installer.dmg", size: 200 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 5), isDirectory: false)
            ]
        } else if path == "/Music" {
            items = [
                FileItem(name: "Rock", path: "/Music/Rock", size: 0, modificationDate: now.addingTimeInterval(-86400 * 100), isDirectory: true),
                FileItem(name: "Jazz", path: "/Music/Jazz", size: 0, modificationDate: now.addingTimeInterval(-86400 * 120), isDirectory: true),
                FileItem(name: "Classical", path: "/Music/Classical", size: 0, modificationDate: now.addingTimeInterval(-86400 * 150), isDirectory: true),
                FileItem(name: "Favorite Song.mp3", path: "/Music/Favorite Song.mp3", size: 10 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 2), isDirectory: false),
                FileItem(name: "New Album.m4a", path: "/Music/New Album.m4a", size: 50 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 1), isDirectory: false)
            ]
        } else if path == "/Videos" {
            items = [
                FileItem(name: "Movies", path: "/Videos/Movies", size: 0, modificationDate: now.addingTimeInterval(-86400 * 30), isDirectory: true),
                FileItem(name: "TV Shows", path: "/Videos/TV Shows", size: 0, modificationDate: now.addingTimeInterval(-86400 * 45), isDirectory: true),
                FileItem(name: "Vacation.mp4", path: "/Videos/Vacation.mp4", size: 500 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 60), isDirectory: false),
                FileItem(name: "Birthday.mov", path: "/Videos/Birthday.mov", size: 300 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 180), isDirectory: false),
                FileItem(name: "Tutorial.mp4", path: "/Videos/Tutorial.mp4", size: 200 * 1024 * 1024, modificationDate: now.addingTimeInterval(-86400 * 10), isDirectory: false)
            ]
        } else {
            // For other paths, generate some random files
            let fileTypes = ["txt", "pdf", "docx", "xlsx", "jpg", "png", "mp3", "mp4", "zip"]
            
            for i in 1...5 {
                let fileType = fileTypes.randomElement() ?? "txt"
                let fileName = "File\(i).\(fileType)"
                let fileSize = Int64.random(in: 1024...1024*1024*10)
                let modDate = now.addingTimeInterval(-Double.random(in: 0...86400*30))
                
                items.append(FileItem(
                    name: fileName,
                    path: "\(path)/\(fileName)",
                    size: fileSize,
                    modificationDate: modDate,
                    isDirectory: false
                ))
            }
            
            // Add a couple of folders
            items.append(FileItem(
                name: "Folder A",
                path: "\(path)/Folder A",
                size: 0,
                modificationDate: now.addingTimeInterval(-86400 * 5),
                isDirectory: true
            ))
            
            items.append(FileItem(
                name: "Folder B",
                path: "\(path)/Folder B",
                size: 0,
                modificationDate: now.addingTimeInterval(-86400 * 10),
                isDirectory: true
            ))
        }
        
        return items
    }
}