import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject private var connectionManager: ConnectionManager
    @State private var ipAddress: String = ""
    @State private var port: String = "8080"
    @State private var showingQRScanner = false
    @State private var connectionType: ConnectionType = .wifi
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Connection status indicator
                HStack {
                    Circle()
                        .fill(connectionManager.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(connectionManager.isConnected ? "Connected" : "Disconnected")
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Connection type selector
                Picker("Connection Type", selection: $connectionType) {
                    Text("Wi-Fi").tag(ConnectionType.wifi)
                    Text("USB").tag(ConnectionType.usb)
                    Text("Bluetooth").tag(ConnectionType.bluetooth)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Connection form
                Form {
                    if connectionType == .wifi {
                        Section(header: Text("Network Connection")) {
                            TextField("IP Address", text: $ipAddress)
                                .keyboardType(.decimalPad)
                            
                            TextField("Port", text: $port)
                                .keyboardType(.numberPad)
                            
                            Button(action: {
                                showingQRScanner = true
                            }) {
                                HStack {
                                    Image(systemName: "qrcode.viewfinder")
                                    Text("Scan QR Code")
                                }
                            }
                        }
                    } else if connectionType == .usb {
                        Section(header: Text("USB Connection")) {
                            Text("Connect your device using a USB cable")
                                .foregroundColor(.secondary)
                            
                            Text("Make sure you have the desktop client installed")
                                .foregroundColor(.secondary)
                        }
                    } else if connectionType == .bluetooth {
                        Section(header: Text("Bluetooth Connection")) {
                            Text("Ensure Bluetooth is enabled on both devices")
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                connectionManager.scanForBluetoothDevices()
                            }) {
                                Text("Scan for Devices")
                            }
                            
                            if !connectionManager.availableBluetoothDevices.isEmpty {
                                Picker("Select Device", selection: $connectionManager.selectedBluetoothDevice) {
                                    ForEach(connectionManager.availableBluetoothDevices, id: \.self) { device in
                                        Text(device).tag(device as String?)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button(action: {
                            connectToDevice()
                        }) {
                            HStack {
                                Spacer()
                                Text(connectionManager.isConnected ? "Disconnect" : "Connect")
                                    .bold()
                                Spacer()
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                // Recent connections
                if !connectionManager.recentConnections.isEmpty {
                    Section(header: Text("Recent Connections")) {
                        List {
                            ForEach(connectionManager.recentConnections, id: \.self) { connection in
                                Button(action: {
                                    ipAddress = connection.ipAddress
                                    port = connection.port
                                    connectionType = connection.type
                                }) {
                                    HStack {
                                        Image(systemName: connectionTypeIcon(connection.type))
                                        VStack(alignment: .leading) {
                                            Text(connection.name)
                                            Text("\(connection.ipAddress):\(connection.port)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(connection.lastConnected)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("iCondesk Connection")
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Connection Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingQRScanner) {
                QRScannerView { result in
                    showingQRScanner = false
                    if let connectionInfo = parseQRCode(result) {
                        ipAddress = connectionInfo.ipAddress
                        port = connectionInfo.port
                    } else {
                        alertMessage = "Invalid QR code format"
                        isShowingAlert = true
                    }
                }
            }
        }
    }
    
    private func connectToDevice() {
        if connectionManager.isConnected {
            connectionManager.disconnect()
            alertMessage = "Disconnected successfully"
            isShowingAlert = true
        } else {
            switch connectionType {
            case .wifi:
                if ipAddress.isEmpty {
                    alertMessage = "Please enter an IP address"
                    isShowingAlert = true
                    return
                }
                
                connectionManager.connectViaWiFi(ipAddress: ipAddress, port: port) { success, message in
                    alertMessage = message
                    isShowingAlert = true
                }
                
            case .usb:
                connectionManager.connectViaUSB { success, message in
                    alertMessage = message
                    isShowingAlert = true
                }
                
            case .bluetooth:
                if connectionManager.selectedBluetoothDevice == nil {
                    alertMessage = "Please select a Bluetooth device"
                    isShowingAlert = true
                    return
                }
                
                connectionManager.connectViaBluetooth { success, message in
                    alertMessage = message
                    isShowingAlert = true
                }
            }
        }
    }
    
    private func connectionTypeIcon(_ type: ConnectionType) -> String {
        switch type {
        case .wifi:
            return "wifi"
        case .usb:
            return "cable.connector"
        case .bluetooth:
            return "bluetooth"
        }
    }
    
    private func parseQRCode(_ code: String) -> (ipAddress: String, port: String)? {
        // Format expected: icondesk://connect/192.168.1.1:8080
        if code.hasPrefix("icondesk://connect/") {
            let connectionPart = code.replacingOccurrences(of: "icondesk://connect/", with: "")
            let components = connectionPart.split(separator: ":")
            
            if components.count == 2 {
                return (String(components[0]), String(components[1]))
            }
        }
        
        return nil
    }
}

struct QRScannerView: UIViewControllerRepresentable {
    var completion: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        // In a real implementation, this would use AVCaptureSession to scan QR codes
        let viewController = UIViewController()
        
        // Simulate QR scanning for demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion("icondesk://connect/192.168.1.100:8080")
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
            .environmentObject(ConnectionManager.shared)
    }
}