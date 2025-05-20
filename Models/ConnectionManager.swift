import Foundation
import Combine

enum ConnectionType: Int, CaseIterable {
    case wifi
    case usb
    case bluetooth
}

struct RecentConnection: Hashable {
    let name: String
    let ipAddress: String
    let port: String
    let type: ConnectionType
    let lastConnected: String
}

class ConnectionManager: ObservableObject {
    static let shared = ConnectionManager()
    
    @Published var isConnected = false
    @Published var connectionType: ConnectionType = .wifi
    @Published var currentDeviceName: String = ""
    @Published var recentConnections: [RecentConnection] = []
    @Published var availableBluetoothDevices: [String] = []
    @Published var selectedBluetoothDevice: String?
    
    private init() {
        // Load recent connections from persistent storage
        loadRecentConnections()
        
        // For demo purposes, add some sample recent connections
        if recentConnections.isEmpty {
            recentConnections = [
                RecentConnection(name: "MacBook Pro", ipAddress: "192.168.1.100", port: "8080", type: .wifi, lastConnected: "Today"),
                RecentConnection(name: "Work PC", ipAddress: "192.168.1.101", port: "8080", type: .wifi, lastConnected: "Yesterday"),
                RecentConnection(name: "Home Desktop", ipAddress: "192.168.1.102", port: "8080", type: .usb, lastConnected: "3 days ago")
            ]
        }
    }
    
    func connectViaWiFi(ipAddress: String, port: String, completion: @escaping (Bool, String) -> Void) {
        // In a real app, this would establish a network connection
        // For demo purposes, we'll simulate a successful connection
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isConnected = true
            self.connectionType = .wifi
            self.currentDeviceName = "Computer at \(ipAddress)"
            
            // Add to recent connections
            let newConnection = RecentConnection(
                name: "Computer at \(ipAddress)",
                ipAddress: ipAddress,
                port: port,
                type: .wifi,
                lastConnected: "Just now"
            )
            
            self.addToRecentConnections(newConnection)
            
            completion(true, "Connected successfully to \(ipAddress)")
        }
    }
    
    func connectViaUSB(completion: @escaping (Bool, String) -> Void) {
        // In a real app, this would establish a USB connection
        // For demo purposes, we'll simulate a successful connection
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isConnected = true
            self.connectionType = .usb
            self.currentDeviceName = "USB Connected Device"
            
            // Add to recent connections
            let newConnection = RecentConnection(
                name: "USB Connected Device",
                ipAddress: "USB",
                port: "N/A",
                type: .usb,
                lastConnected: "Just now"
            )
            
            self.addToRecentConnections(newConnection)
            
            completion(true, "USB connection established")
        }
    }
    
    func scanForBluetoothDevices() {
        // In a real app, this would scan for Bluetooth devices
        // For demo purposes, we'll simulate finding some devices
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.availableBluetoothDevices = [
                "MacBook Pro",
                "Windows PC",
                "Linux Desktop"
            ]
        }
    }
    
    func connectViaBluetooth(completion: @escaping (Bool, String) -> Void) {
        // In a real app, this would establish a Bluetooth connection
        // For demo purposes, we'll simulate a successful connection
        
        guard let deviceName = selectedBluetoothDevice else {
            completion(false, "No device selected")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isConnected = true
            self.connectionType = .bluetooth
            self.currentDeviceName = deviceName
            
            // Add to recent connections
            let newConnection = RecentConnection(
                name: deviceName,
                ipAddress: "Bluetooth",
                port: "N/A",
                type: .bluetooth,
                lastConnected: "Just now"
            )
            
            self.addToRecentConnections(newConnection)
            
            completion(true, "Connected successfully to \(deviceName) via Bluetooth")
        }
    }
    
    func disconnect() {
        // In a real app, this would close the connection
        isConnected = false
        currentDeviceName = ""
    }
    
    private func addToRecentConnections(_ connection: RecentConnection) {
        // Remove existing connection with same IP if exists
        recentConnections.removeAll { $0.ipAddress == connection.ipAddress && $0.type == connection.type }
        
        // Add new connection at the beginning
        recentConnections.insert(connection, at: 0)
        
        // Limit to 10 recent connections
        if recentConnections.count > 10 {
            recentConnections = Array(recentConnections.prefix(10))
        }
        
        // Save to persistent storage
        saveRecentConnections()
    }
    
    private func saveRecentConnections() {
        // In a real app, this would save to UserDefaults or a database
    }
    
    private func loadRecentConnections() {
        // In a real app, this would load from UserDefaults or a database
    }
}