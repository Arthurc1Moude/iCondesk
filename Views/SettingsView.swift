import SwiftUI

struct SettingsView: View {
    @AppStorage("autoConnect") private var autoConnect = false
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("securityLevel") private var securityLevel = 1
    @AppStorage("connectionTimeout") private var connectionTimeout = 30
    @AppStorage("keepScreenAwake") private var keepScreenAwake = true
    @AppStorage("compressionLevel") private var compressionLevel = 1
    @AppStorage("audioQuality") private var audioQuality = 1
    @AppStorage("showConnectionStats") private var showConnectionStats = true
    @AppStorage("saveConnectionHistory") private var saveConnectionHistory = true
    @AppStorage("maxHistoryEntries") private var maxHistoryEntries = 10
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Connection")) {
                    Toggle("Auto-connect to last device", isOn: $autoConnect)
                    
                    Picker("Security Level", selection: $securityLevel) {
                        Text("Basic").tag(0)
                        Text("Standard").tag(1)
                        Text("High").tag(2)
                    }
                    
                    Stepper("Connection Timeout: \(connectionTimeout)s", value: $connectionTimeout, in: 5...120, step: 5)
                    
                    Toggle("Keep Screen Awake", isOn: $keepScreenAwake)
                    
                    Toggle("Save Connection History", isOn: $saveConnectionHistory)
                    
                    if saveConnectionHistory {
                        Stepper("Max History Entries: \(maxHistoryEntries)", value: $maxHistoryEntries, in: 1...50)
                    }
                }
                
                Section(header: Text("Performance")) {
                    Picker("Compression Level", selection: $compressionLevel) {
                        Text("Low (Better Performance)").tag(0)
                        Text("Medium").tag(1)
                        Text("High (Better Quality)").tag(2)
                    }
                    
                    Picker("Audio Quality", selection: $audioQuality) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    
                    Toggle("Show Connection Statistics", isOn: $showConnectionStats)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkMode)
                    
                    NavigationLink(destination: CustomizationView()) {
                        Text("Customize Interface")
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        NavigationLink(destination: NotificationSettingsView()) {
                            Text("Notification Settings")
                        }
                    }
                }
                
                Section(header: Text("Desktop Clients")) {
                    NavigationLink(destination: DesktopClientsView()) {
                        Text("Download Desktop Clients")
                    }
                    
                    NavigationLink(destination: ClientManagementView()) {
                        Text("Manage Connected Clients")
                    }
                }
                
                Section(header: Text("Support")) {
                    NavigationLink(destination: HelpView()) {
                        Text("Help & Documentation")
                    }
                    
                    Button(action: {
                        showingHelp = true
                    }) {
                        Text("Troubleshooting")
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        Text("Send Feedback")
                    }
                    
                    Button(action: {
                        showingAbout = true
                    }) {
                        Text("About iCondesk")
                    }
                }
                
                Section {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        Text("Reset All Settings")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset Settings"),
                    message: Text("Are you sure you want to reset all settings to default values? This cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        resetAllSettings()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingHelp) {
                TroubleshootingView()
            }
        }
    }
    
    private func resetAllSettings() {
        autoConnect = false
        darkMode = false
        notificationsEnabled = true
        securityLevel = 1
        connectionTimeout = 30
        keepScreenAwake = true
        compressionLevel = 1
        audioQuality = 1
        showConnectionStats = true
        saveConnectionHistory = true
        maxHistoryEntries = 10
    }
}

struct CustomizationView: View {
    @AppStorage("accentColor") private var accentColor = 0
    @AppStorage("fontScale") private var fontScale = 1.0
    @AppStorage("buttonStyle") private var buttonStyle = 0
    @AppStorage("showLabels") private var showLabels = true
    
    let accentColors = ["Blue", "Red", "Green", "Purple", "Orange", "Pink"]
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("Accent Color", selection: $accentColor) {
                    ForEach(0..<accentColors.count, id: \.self) { index in
                        Text(accentColors[index]).tag(index)
                    }
                }
                
                VStack {
                    Text("Font Size")
                    Slider(value: $fontScale, in: 0.8...1.4, step: 0.1) {
                        Text("Font Size")
                    } minimumValueLabel: {
                        Text("A").font(.caption)
                    } maximumValueLabel: {
                        Text("A").font(.title)
                    }
                    Text("\(Int(fontScale * 100))%")
                        .font(.caption)
                }
                
                Picker("Button Style", selection: $buttonStyle) {
                    Text("Standard").tag(0)
                    Text("Rounded").tag(1)
                    Text("Capsule").tag(2)
                }
                
                Toggle("Show Button Labels", isOn: $showLabels)
            }
            
            Section(header: Text("Preview")) {
                VStack(spacing: 20) {
                    Text("iCondesk")
                        .font(.title)
                        .scaleEffect(fontScale)
                    
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "link")
                                    .font(.system(size: 24))
                                
                                if showLabels {
                                    Text("Connect")
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .background(colorForIndex(accentColor))
                            .foregroundColor(.white)
                            .cornerRadius(buttonCornerRadius)
                        }
                        
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "display")
                                    .font(.system(size: 24))
                                
                                if showLabels {
                                    Text("Screen")
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .background(colorForIndex(accentColor))
                            .foregroundColor(.white)
                            .cornerRadius(buttonCornerRadius)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Customize Interface")
    }
    
    private var buttonCornerRadius: CGFloat {
        switch buttonStyle {
        case 0: return 8
        case 1: return 16
        case 2: return 30
        default: return 8
        }
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        switch index {
        case 0: return .blue
        case 1: return .red
        case 2: return .green
        case 3: return .purple
        case 4: return .orange
        case 5: return .pink
        default: return .blue
        }
    }
}

struct NotificationSettingsView: View {
    @AppStorage("notifyOnConnect") private var notifyOnConnect = true
    @AppStorage("notifyOnDisconnect") private var notifyOnDisconnect = true
    @AppStorage("notifyOnFileTransfer") private var notifyOnFileTransfer = true
    @AppStorage("notifyOnScreenshot") private var notifyOnScreenshot = true
    @AppStorage("notifyOnError") private var notifyOnError = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    
    var body: some View {
        Form {
            Section(header: Text("Notification Events")) {
                Toggle("Connection Established", isOn: $notifyOnConnect)
                Toggle("Connection Lost", isOn: $notifyOnDisconnect)
                Toggle("File Transfer Completed", isOn: $notifyOnFileTransfer)
                Toggle("Screenshot Taken", isOn: $notifyOnScreenshot)
                Toggle("Errors", isOn: $notifyOnError)
            }
            
            Section(header: Text("Notification Style")) {
                Toggle("Enable Sounds", isOn: $soundEnabled)
                Toggle("Enable Vibration", isOn: $vibrationEnabled)
            }
        }
        .navigationTitle("Notification Settings")
    }
}

struct DesktopClientsView: View {
    var body: some View {
        List {
            Section(header: Text("Available Clients")) {
                ClientDownloadRow(
                    platform: "macOS",
                    version: "1.2.3",
                    size: "24.5 MB",
                    icon: "laptopcomputer"
                )
                
                ClientDownloadRow(
                    platform: "Windows",
                    version: "1.2.3",
                    size: "28.7 MB",
                    icon: "pc"
                )
                
                ClientDownloadRow(
                    platform: "Linux",
                    version: "1.2.1",
                    size: "22.3 MB",
                    icon: "terminal"
                )
                
                ClientDownloadRow(
                    platform: "Chrome OS",
                    version: "1.2.0",
                    size: "18.9 MB",
                    icon: "globe"
                )
            }
            
            Section(header: Text("Installation Instructions")) {
                NavigationLink(destination: InstallationInstructionsView(platform: "macOS")) {
                    Text("macOS Installation Guide")
                }
                
                NavigationLink(destination: InstallationInstructionsView(platform: "Windows")) {
                    Text("Windows Installation Guide")
                }
                
                NavigationLink(destination: InstallationInstructionsView(platform: "Linux")) {
                    Text("Linux Installation Guide")
                }
            }
        }
        .navigationTitle("Desktop Clients")
    }
}

struct ClientDownloadRow: View {
    let platform: String
    let version: String
    let size: String
    let icon: String
    @State private var isDownloading = false
    @State private var downloadProgress = 0.0
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(platform)
                    .font(.headline)
                
                Text("Version \(version) • \(size)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isDownloading {
                VStack {
                    ProgressView(value: downloadProgress, total: 1.0)
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text("\(Int(downloadProgress * 100))%")
                        .font(.caption2)
                }
                .frame(width: 60)
            } else {
                Button(action: {
                    downloadClient()
                }) {
                    Text("Download")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func downloadClient() {
        isDownloading = true
        
        // Simulate download progress
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            downloadProgress += 0.1
            
            if downloadProgress >= 1.0 {
                timer.invalidate()
                isDownloading = false
                downloadProgress = 0.0
            }
        }
    }
}

struct InstallationInstructionsView: View {
    let platform: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Installation Guide for \(platform)")
                    .font(.title)
                    .padding(.bottom)
                
                Text("System Requirements:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(systemRequirements, id: \.self) { req in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(req)
                        }
                    }
                }
                .padding(.bottom)
                
                Text("Installation Steps:")
                    .font(.headline)
                
                ForEach(0..<installationSteps.count, id: \.self) { index in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .font(.body)
                            .fontWeight(.bold)
                            .frame(width: 25, alignment: .leading)
                        
                        Text(installationSteps[index])
                    }
                    .padding(.bottom, 8)
                }
                
                Text("Troubleshooting:")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(troubleshootingTips, id: \.self) { tip in
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text(tip)
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding()
        }
        .navigationTitle("\(platform) Installation")
    }
    
    private var systemRequirements: [String] {
        switch platform {
        case "macOS":
            return [
                "macOS 10.15 (Catalina) or later",
                "4GB RAM minimum, 8GB recommended",
                "100MB free disk space",
                "Administrator privileges for installation"
            ]
        case "Windows":
            return [
                "Windows 10 (64-bit) or later",
                "4GB RAM minimum, 8GB recommended",
                "100MB free disk space",
                "Administrator privileges for installation",
                ".NET Framework 4.7.2 or later"
            ]
        case "Linux":
            return [
                "Ubuntu 18.04 LTS or later, Fedora 30+, or other major distributions",
                "4GB RAM minimum",
                "100MB free disk space",
                "libusb 1.0 or later",
                "GTK+ 3.0 or later"
            ]
        default:
            return ["Information not available"]
        }
    }
    
    private var installationSteps: [String] {
        switch platform {
        case "macOS":
            return [
                "Download the iCondesk.dmg file from the Downloads section.",
                "Open the downloaded DMG file.",
                "Drag the iCondesk application to your Applications folder.",
                "Open the application from your Applications folder.",
                "If prompted about an app from an unidentified developer, go to System Preferences > Security & Privacy and click 'Open Anyway'.",
                "Follow the on-screen instructions to complete setup.",
                "When prompted, allow the app to access your USB devices."
            ]
        case "Windows":
            return [
                "Download the iCondesk_Setup.exe file from the Downloads section.",
                "Right-click the installer and select 'Run as administrator'.",
                "Follow the installation wizard instructions.",
                "When prompted, install the USB drivers for device connectivity.",
                "After installation completes, launch iCondesk from the Start menu.",
                "Allow the application through Windows Firewall when prompted."
            ]
        case "Linux":
            return [
                "Download the appropriate package for your distribution (.deb for Ubuntu/Debian, .rpm for Fedora/RHEL, or .AppImage).",
                "For .deb: Open terminal and run 'sudo dpkg -i icondesk_1.2.1_amd64.deb' followed by 'sudo apt-get install -f'",
                "For .rpm: Open terminal and run 'sudo rpm -i icondesk-1.2.1.x86_64.rpm'",
                "For .AppImage: Make the file executable with 'chmod +x iCondesk-1.2.1.AppImage' and then run it.",
                "Add udev rules for USB access: 'sudo cp /opt/icondesk/resources/99-icondesk.rules /etc/udev/rules.d/'",
                "Reload udev rules: 'sudo udevadm control --reload-rules && sudo udevadm trigger'",
                "Launch iCondesk from your applications menu or terminal with 'icondesk'"
            ]
        default:
            return ["Information not available"]
        }
    }
    
    private var troubleshootingTips: [String] {
        switch platform {
        case "macOS":
            return [
                "If the app won't open due to security settings, go to System Preferences > Security & Privacy > General and click 'Open Anyway'.",
                "If USB connection fails, disconnect and reconnect your device, then restart the app.",
                "For network connection issues, ensure both devices are on the same Wi-Fi network and check your firewall settings."
            ]
        case "Windows":
            return [
                "If installation fails, try running the installer as administrator.",
                "If USB drivers fail to install, try installing them manually from the 'drivers' folder in the installation directory.",
                "For connection issues, check Windows Firewall settings and ensure the app has network permissions."
            ]
        case "Linux":
            return [
                "If you encounter permission issues with USB devices, ensure your user is in the 'plugdev' group.",
                "For dependency issues, run 'sudo apt-get install -f' (Debian/Ubuntu) or 'sudo dnf install --allowerasing' (Fedora).",
                "If the app doesn't appear in your applications menu, try logging out and back in."
            ]
        default:
            return ["Information not available"]
        }
    }
}

struct ClientManagementView: View {
    @State private var clients = [
        ClientDevice(id: "1", name: "MacBook Pro", platform: "macOS", lastConnected: "Today, 2:30 PM", ipAddress: "192.168.1.5", isAuthorized: true),
        ClientDevice(id: "2", name: "Work PC", platform: "Windows", lastConnected: "Yesterday", ipAddress: "192.168.1.10", isAuthorized: true),
        ClientDevice(id: "3", name: "Linux Server", platform: "Ubuntu", lastConnected: "3 days ago", ipAddress: "192.168.1.15", isAuthorized: false)
    ]
    
    var body: some View {
        List {
            ForEach(clients) { client in
                ClientDeviceRow(client: client, onToggleAuthorization: { toggleAuthorization(for: client) })
            }
            .onDelete(perform: deleteClients)
        }
        .navigationTitle("Connected Clients")
        .toolbar {
            EditButton()
        }
    }
    
    private func toggleAuthorization(for client: ClientDevice) {
        if let index = clients.firstIndex(where: { $0.id == client.id }) {
            clients[index].isAuthorized.toggle()
        }
    }
    
    private func deleteClients(at offsets: IndexSet) {
        clients.remove(atOffsets: offsets)
    }
}

struct ClientDevice: Identifiable {
    let id: String
    let name: String
    let platform: String
    let lastConnected: String
    let ipAddress: String
    var isAuthorized: Bool
}

struct ClientDeviceRow: View {
    let client: ClientDevice
    let onToggleAuthorization: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: iconForPlatform(client.platform))
                    .foregroundColor(.blue)
                
                Text(client.name)
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: .constant(client.isAuthorized))
                    .labelsHidden()
                    .onTapGesture {
                        onToggleAuthorization()
                    }
            }
            
            HStack {
                Text(client.platform)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(client.lastConnected)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("IP: \(client.ipAddress)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func iconForPlatform(_ platform: String) -> String {
        switch platform.lowercased() {
        case "macos":
            return "laptopcomputer"
        case "windows":
            return "pc"
        case "linux", "ubuntu":
            return "terminal"
        default:
            return "desktopcomputer"
        }
    }
}

struct HelpView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search help topics", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            List {
                Section(header: Text("Getting Started")) {
                    NavigationLink(destination: HelpTopicView(title: "Quick Start Guide", content: quickStartGuide)) {
                        Text("Quick Start Guide")
                    }
                    
                    NavigationLink(destination: HelpTopicView(title: "Connecting Your Device", content: connectingDeviceGuide)) {
                        Text("Connecting Your Device")
                    }
                    
                    NavigationLink(destination: HelpTopicView(title: "File Transfer Guide", content: fileTransferGuide)) {
                        Text("File Transfer Guide")
                    }
                }
                
                Section(header: Text("Features")) {
                    NavigationLink(destination: HelpTopicView(title: "Screen Mirroring", content: screenMirroringGuide)) {
                        Text("Screen Mirroring")
                    }
                    
                    NavigationLink(destination: HelpTopicView(title: "Remote Control", content: remoteControlGuide)) {
                        Text("Remote Control")
                    }
                    
                    NavigationLink(destination: HelpTopicView(title: "USB Connection", content: usbConnectionGuide)) {
                        Text("USB Connection")
                    }
                }
                
                Section(header: Text("Troubleshooting")) {
                    NavigationLink(destination: HelpTopicView(title: "Connection Issues", content: connectionIssuesGuide)) {
                        Text("Connection Issues")
                    }
                    
                    NavigationLink(destination: HelpTopicView(title: "Performance Optimization", content: performanceGuide)) {
                        Text("Performance Optimization")
                    }
                }
            }
        }
        .navigationTitle("Help & Documentation")
    }
    
    private let quickStartGuide = """
    # Quick Start Guide
    
    Welcome to iCondesk! This guide will help you get started with the app quickly.
    
    ## Basic Setup
    
    1. Install the iCondesk desktop client on your computer
    2. Ensure both your iOS device and computer are on the same network
    3. Launch iCondesk on both devices
    
    ## Making Your First Connection
    
    1. On the iOS app, go to the Connect tab
    2. Select Wi-Fi connection
    3. The app will automatically scan for available computers
    4. Tap on your computer when it appears in the list
    5. Accept the connection prompt on your computer
    
    ## What's Next?
    
    Once connected, you can:
    - Transfer files between devices
    - Mirror your iOS screen to your computer
    - Control your iOS device from your computer
    - Control your computer from your iOS device
    
    Explore the different tabs to discover all features!
    """
    
    private let connectingDeviceGuide = """
    # Connecting Your Device
    
    iCondesk offers multiple ways to connect your iOS device to your computer.
    
    ## Wi-Fi Connection
    
    1. Ensure both devices are on the same Wi-Fi network
    2. Launch iCondesk on both your iOS device and computer
    3. On the iOS app, go to the Connect tab and select "Wi-Fi"
    4. The app will scan for available computers
    5. Select your computer from the list
    6. Accept the connection request on your computer
    
    ## USB Connection
    
    1. Connect your iOS device to your computer using a Lightning or USB-C cable
    2. Launch iCondesk on both devices
    3. On the iOS app, go to the Connect tab and select "USB"
    4. The app will detect the USB connection
    5. Accept the connection request on your computer
    
    ## Bluetooth Connection
    
    1. Ensure Bluetooth is enabled on both devices
    2. Launch iCondesk on both your iOS device and computer
    3. On the iOS app, go to the Connect tab and select "Bluetooth"
    4. Tap "Scan for Devices"
    5. Select your computer from the list
    6. Accept the pairing request on both devices
    
    ## QR Code Connection
    
    1. Launch iCondesk on your computer
    2. Click "Show QR Code" in the desktop app
    3. On your iOS device, tap "Scan QR Code" in the Connect tab
    4. Point your camera at the QR code displayed on your computer
    5. The connection will be established automatically
    """
    
    private let fileTransferGuide = """
    # File Transfer Guide
    
    Transferring files between your iOS device and computer is easy with iCondesk.
    
    ## Sending Files from iOS to Computer
    
    1. Connect your iOS device to your computer
    2. Go to the Files tab in the iCondesk app
    3. Browse to locate the files you want to transfer
    4. Tap the Select button to enter selection mode
    5. Select one or more files
    6. Tap the Upload button
    7. Choose the destination folder on your computer
    
    ## Receiving Files from Computer to iOS
    
    1. Connect your iOS device to your computer
    2. In the desktop app, select the files you want to send
    3. Drag and drop them to the iCondesk window
    4. On your iOS device, you'll see a transfer progress indicator
    5. Files will be saved to the Downloads folder by default
    
    ## Managing Files
    
    - Use the search bar to find specific files
    - Sort files by name, date, or size
    - Create new folders to organize your files
    - Compress multiple files into a ZIP archive
    - Preview files before downloading them
    
    ## Troubleshooting
    
    - If transfers are slow, try using a USB connection instead of Wi-Fi
    - Ensure you have sufficient storage space on both devices
    - For large files, consider compressing them before transfer
    - If a transfer fails, try again with smaller batches of files
    """
    
    private let screenMirroringGuide = """
    # Screen Mirroring Guide
    
    iCondesk allows you to mirror your iOS device's screen to your computer.
    
    ## Starting Screen Mirroring
    
    1. Connect your iOS device to your computer
    2. Go to the Screen tab in the iCondesk app
    3. Tap "Start Mirroring"
    4. Your iOS screen will appear on your computer
    
    ## Adjusting Quality Settings
    
    - Tap the Quality button to choose between:
      - Low (480p): Best for slow connections
      - Medium (720p): Balanced performance
      - High (1080p): Best quality, requires fast connection
      - Ultra (Original): Highest quality, may affect performance
    
    ## Recording Your Screen
    
    1. While mirroring, tap the Record button
    2. A red recording indicator will appear
    3. Perform the actions you want to record
    4. Tap Stop when finished
    5. The recording will be saved to your computer
    
    ## Taking Screenshots
    
    - While mirroring, tap the Screenshot button
    - The screenshot will be saved to your computer
    
    ## Performance Tips
    
    - Use a USB connection for the best performance
    - Lower the quality settings if you experience lag
    - Close other network-intensive apps
    - Keep your iOS device and computer close to your Wi-Fi router
    """
    
    private let remoteControlGuide = """
    # Remote Control Guide
    
    iCondesk allows you to control your iOS device from your computer and vice versa.
    
    ## Controlling iOS from Computer
    
    1. Connect your iOS device to your computer
    2. In the desktop app, click "Remote Control"
    3. Your iOS screen will appear with control enabled
    4. Use your mouse and keyboard to interact with your iOS device:
       - Click to tap
       - Click and drag to swipe
       - Type to enter text
       - Use keyboard shortcuts for common actions
    
    ## Controlling Computer from iOS
    
    1. Connect your iOS device to your computer
    2. Go to the Control tab in the iCondesk app
    3. Choose a control mode:
       - Touchpad: Use your iOS device as a trackpad
       - Keyboard: Send keyboard input to your computer
       - Gamepad: Use virtual gamepad controls
       - Media: Control media playback on your computer
    
    ## Special Functions
    
    - Home button: Return to iOS home screen
    - Back button: Go back in apps or menus
    - App switcher: View and switch between recent apps
    - Special keys: Access function keys, media controls, etc.
    
    ## Tips for Better Control
    
    - Adjust sensitivity settings if cursor movement feels too fast or slow
    - Use landscape orientation for a larger control surface
    - For precise control, use the touchpad mode with reduced speed
    - For gaming, connect a Bluetooth controller to your iOS device
    """
    
    private let usbConnectionGuide = """
    # USB Connection Guide
    
    USB connection provides the most reliable and fastest way to connect your iOS device to your computer.
    
    ## Requirements
    
    - Lightning or USB-C cable (depending on your iOS device)
    - iCondesk desktop client installed on your computer
    - iOS 14 or later
    - macOS 10.15+, Windows 10+, or Linux with libusb
    
    ## Setting Up USB Connection
    
    1. Connect your iOS device to your computer using a cable
    2. Launch iCondesk on both devices
    3. On your iOS device, go to the Connect tab
    4. Select "USB Connection"
    5. If prompted, tap "Trust This Computer" on your iOS device
    6. Accept the connection request on your computer
    
    ## Troubleshooting USB Connection
    
    If your computer doesn't recognize your iOS device:
    
    1. Try a different USB port
    2. Try a different cable
    3. Restart both devices
    4. Ensure you have the latest version of iCondesk
    5. On Windows, check if the drivers are installed correctly
    6. On macOS, ensure you've allowed the app in Security & Privacy settings
    
    ## Benefits of USB Connection
    
    - Faster data transfer speeds
    - More stable connection
    - Lower latency for screen mirroring and remote control
    - No dependency on Wi-Fi network quality
    - Charges your iOS device while connected
    """
    
    private let connectionIssuesGuide = """
    # Troubleshooting Connection Issues
    
    If you're having trouble connecting your iOS device to your computer, try these solutions.
    
    ## Wi-Fi Connection Issues
    
    1. Ensure both devices are on the same Wi-Fi network
    2. Check if your Wi-Fi router has client isolation turned off
    3. Temporarily disable firewalls or security software
    4. Restart your Wi-Fi router
    5. Move closer to your Wi-Fi router
    6. Try using a 5GHz network if available
    
    ## USB Connection Issues
    
    1. Try a different USB cable
    2. Connect directly to your computer (not through a hub)
    3. Try a different USB port
    4. Restart both devices
    5. Check if your iOS device shows the "Trust This Computer" prompt
    6. Reinstall the iCondesk desktop client
    
    ## Bluetooth Connection Issues
    
    1. Ensure Bluetooth is enabled on both devices
    2. Forget the device in Bluetooth settings and pair again
    3. Restart Bluetooth on both devices
    4. Keep devices within 30 feet of each other
    5. Remove other Bluetooth devices that might cause interference
    
    ## General Connection Troubleshooting
    
    1. Restart the iCondesk app on both devices
    2. Check for app updates
    3. Restart both devices
    4. Reset network settings on your iOS device
    5. Reinstall the iCondesk app
    
    If problems persist, please contact our support team with details about your devices and the specific issue you're experiencing.
    """
    
    private let performanceGuide = """
    # Performance Optimization Guide
    
    Follow these tips to get the best performance from iCondesk.
    
    ## Improving Screen Mirroring Performance
    
    1. Use a USB connection when possible
    2. Lower the quality settings (Medium or Low)
    3. Reduce the frame rate in advanced settings
    4. Close other apps on both devices
    5. Use a 5GHz Wi-Fi network if available
    6. Keep both devices close to your Wi-Fi router
    
    ## Optimizing File Transfer Speed
    
    1. Use USB connection for large files
    2. Transfer multiple small files as a compressed archive
    3. Close other apps that might be using the network
    4. Increase the compression level in settings
    5. Transfer files in smaller batches
    
    ## Reducing Remote Control Latency
    
    1. Use USB connection for the lowest latency
    2. Lower the screen quality in remote control settings
    3. Disable animations in iOS accessibility settings
    4. Close background apps on both devices
    5. Adjust the sensitivity settings to your preference
    
    ## Device-Specific Optimization
    
    ### For Older iOS Devices
    - Use lower quality settings
    - Disable background app refresh
    - Free up storage space
    - Keep your iOS version updated
    
    ### For Computers
    - Close resource-intensive applications
    - Ensure your graphics drivers are updated
    - Connect to power when using screen mirroring
    - Use a wired internet connection if possible
    """
}

struct HelpTopicView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(content)
                    .padding()
            }
        }
        .navigationTitle(title)
    }
}

struct FeedbackView: View {
    @State private var feedbackType = 0
    @State private var feedbackText = ""
    @State private var includeScreenshot = false
    @State private var includeSystemInfo = true
    @State private var contactEmail = ""
    @State private var showingThankYou = false
    
    var body: some View {
        Form {
            Section(header: Text("Feedback Type")) {
                Picker("Type", selection: $feedbackType) {
                    Text("Bug Report").tag(0)
                    Text("Feature Request").tag(1)
                    Text("General Feedback").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Details")) {
                if feedbackType == 0 {
                    TextField("What went wrong?", text: $feedbackText)
                        .frame(height: 100)
                        .multilineTextAlignment(.leading)
                } else if feedbackType == 1 {
                    TextField("Describe the feature you'd like to see", text: $feedbackText)
                        .frame(height: 100)
                        .multilineTextAlignment(.leading)
                } else {
                    TextField("Tell us what you think", text: $feedbackText)
                        .frame(height: 100)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section(header: Text("Additional Information")) {
                Toggle("Include Screenshot", isOn: $includeScreenshot)
                Toggle("Include System Information", isOn: $includeSystemInfo)
                
                TextField("Contact Email (Optional)", text: $contactEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section {
                Button(action: {
                    submitFeedback()
                }) {
                    Text("Submit Feedback")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .disabled(feedbackText.isEmpty)
            }
        }
        .navigationTitle("Send Feedback")
        .alert(isPresented: $showingThankYou) {
            Alert(
                title: Text("Thank You!"),
                message: Text("Your feedback has been submitted. We appreciate your input!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func submitFeedback() {
        // In a real app, this would send the feedback to a server
        // For now, we'll just show a thank you message
        showingThankYou = true
        
        // Reset form
        feedbackText = ""
        includeScreenshot = false
        contactEmail = ""
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("iCondesk")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version 1.2.3 (Build 145)")
                .foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("iCondesk is a powerful tool for connecting your iOS device to your computer, allowing you to transfer files, mirror your screen, and control your device remotely.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("© 2025 iCondesk Team. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    // Open website
                }) {
                    VStack {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                        Text("Website")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    // Open privacy policy
                }) {
                    VStack {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 24))
                        Text("Privacy")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    // Open terms of service
                }) {
                    VStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 24))
                        Text("Terms")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    // Open licenses
                }) {
                    VStack {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 24))
                        Text("Licenses")
                            .font(.caption)
                    }
                }
            }
            .padding()
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
    }
}

struct TroubleshootingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedIssue = 0
    
    let issues = [
        "Can't connect to computer",
        "Screen mirroring is laggy",
        "File transfer is slow",
        "USB connection not working",
        "Remote control not responding",
        "App crashes frequently"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Issue", selection: $selectedIssue) {
                    ForEach(0..<issues.count, id: \.self) { index in
                        Text(issues[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Troubleshooting: \(issues[selectedIssue])")
                            .font(.headline)
                            .padding(.bottom)
                        
                        ForEach(0..<troubleshootingSteps(for: selectedIssue).count, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .frame(width: 25, alignment: .leading)
                                
                                Text(troubleshootingSteps(for: selectedIssue)[index])
                            }
                            .padding(.bottom, 8)
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        Text("Still having issues?")
                            .font(.headline)
                        
                        Button(action: {
                            // Contact support
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Contact Support")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Troubleshooting")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func troubleshootingSteps(for issueIndex: Int) -> [String] {
        switch issueIndex {
        case 0: // Can't connect to computer
            return [
                "Ensure both devices are on the same Wi-Fi network.",
                "Check if your firewall is blocking the connection. Try temporarily disabling it.",
                "Restart the iCondesk app on both devices.",
                "Try using a USB connection instead of Wi-Fi.",
                "Restart your Wi-Fi router.",
                "Reinstall the desktop client.",
                "Check if your computer's IP address has changed."
            ]
        case 1: // Screen mirroring is laggy
            return [
                "Lower the quality settings in the Screen Mirroring tab.",
                "Use a USB connection for better performance.",
                "Close other apps that might be using network bandwidth.",
                "Move closer to your Wi-Fi router or use a 5GHz network if available.",
                "Restart both devices to free up resources.",
                "Reduce the frame rate in advanced settings.",
                "Check if your computer meets the minimum system requirements."
            ]
        case 2: // File transfer is slow
            return [
                "Use a USB connection for faster transfer speeds.",
                "Transfer multiple small files as a compressed archive.",
                "Close other apps that might be using the network.",
                "Try transferring smaller batches of files.",
                "Check your Wi-Fi signal strength and move closer to the router if needed.",
                "Restart both devices and try again.",
                "Ensure your computer has enough free disk space."
            ]
        case 3: // USB connection not working
            return [
                "Try a different USB cable.",
                "Connect directly to your computer (not through a hub).",
                "Try a different USB port.",
                "Restart both devices.",
                "Check if your iOS device shows the 'Trust This Computer' prompt.",
                "Reinstall the iCondesk desktop client.",
                "On Windows, check if the drivers are installed correctly.",
                "On macOS, ensure you've allowed the app in Security & Privacy settings."
            ]
        case 4: // Remote control not responding
            return [
                "Check if your connection is stable.",
                "Restart the remote control session.",
                "Use a USB connection for better responsiveness.",
                "Close other apps on both devices to free up resources.",
                "Adjust the sensitivity settings in the remote control preferences.",
                "Restart both devices and try again.",
                "Check if your iOS device has any restrictions enabled that might block remote control."
            ]
        case 5: // App crashes frequently
            return [
                "Update to the latest version of iCondesk.",
                "Restart your iOS device.",
                "Free up storage space on your device.",
                "Close other apps running in the background.",
                "Check if your iOS version is compatible with iCondesk.",
                "Reinstall the iCondesk app.",
                "Reset app preferences in the iOS Settings app.",
                "If the issue persists, contact support with details about your device and iOS version."
            ]
        default:
            return ["No troubleshooting steps available for this issue."]
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}