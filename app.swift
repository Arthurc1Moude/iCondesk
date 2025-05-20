import SwiftUI

@main
struct iCondeskApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ConnectionManager.shared)
                .environmentObject(FileTransferManager.shared)
                .environmentObject(ScreenMirrorManager.shared)
                .environmentObject(RemoteControlManager.shared)
        }
    }
}