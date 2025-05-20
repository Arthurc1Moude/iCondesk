import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ConnectionView()
                .tabItem {
                    Label("Connect", systemImage: "link")
                }
                .tag(0)
            
            FileTransferView()
                .tabItem {
                    Label("Files", systemImage: "folder")
                }
                .tag(1)
            
            ScreenMirrorView()
                .tabItem {
                    Label("Screen", systemImage: "display")
                }
                .tag(2)
            
            RemoteControlView()
                .tabItem {
                    Label("Control", systemImage: "gamecontroller")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .environmentObject(ConnectionManager.shared)
        .environmentObject(FileTransferManager.shared)
        .environmentObject(ScreenMirrorManager.shared)
        .environmentObject(RemoteControlManager.shared)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}