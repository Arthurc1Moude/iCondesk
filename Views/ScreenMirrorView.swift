import SwiftUI

struct ScreenMirrorView: View {
    @EnvironmentObject private var connectionManager: ConnectionManager
    @EnvironmentObject private var screenMirrorManager: ScreenMirrorManager
    @State private var isShowingSettings = false
    @State private var isRecording = false
    @State private var showingQualityPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !connectionManager.isConnected {
                    ConnectionRequiredView()
                } else {
                    VStack {
                        // Screen mirror display
                        ZStack {
                            if screenMirrorManager.isStreaming {
                                // In a real app, this would be a video stream view
                                ScreenStreamView()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                
                                // Recording indicator
                                if isRecording {
                                    HStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 12, height: 12)
                                        Text("REC")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .fontWeight(.bold)
                                    }
                                    .padding(6)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(12)
                                    .position(x: 50, y: 20)
                                }
                            } else {
                                VStack(spacing: 20) {
                                    Image(systemName: "display")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    
                                    Text("Screen Mirroring Not Active")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                    
                                    Text("Press 'Start Mirroring' to begin")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        
                        // Controls
                        HStack(spacing: 20) {
                            Button(action: {
                                if screenMirrorManager.isStreaming {
                                    screenMirrorManager.stopMirroring()
                                } else {
                                    screenMirrorManager.startMirroring()
                                }
                            }) {
                                VStack {
                                    Image(systemName: screenMirrorManager.isStreaming ? "stop.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 30))
                                    Text(screenMirrorManager.isStreaming ? "Stop" : "Start")
                                        .font(.caption)
                                }
                                .frame(width: 70)
                            }
                            .disabled(!connectionManager.isConnected)
                            
                            Button(action: {
                                if isRecording {
                                    screenMirrorManager.stopRecording()
                                } else {
                                    screenMirrorManager.startRecording()
                                }
                                isRecording.toggle()
                            }) {
                                VStack {
                                    Image(systemName: isRecording ? "stop.fill" : "record.circle")
                                        .font(.system(size: 30))
                                        .foregroundColor(isRecording ? .red : .primary)
                                    Text(isRecording ? "Stop Rec" : "Record")
                                        .font(.caption)
                                }
                                .frame(width: 70)
                            }
                            .disabled(!screenMirrorManager.isStreaming)
                            
                            Button(action: {
                                screenMirrorManager.takeScreenshot()
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 30))
                                    Text("Screenshot")
                                        .font(.caption)
                                }
                                .frame(width: 70)
                            }
                            .disabled(!screenMirrorManager.isStreaming)
                            
                            Button(action: {
                                showingQualityPicker = true
                            }) {
                                VStack {
                                    Image(systemName: "dial.high")
                                        .font(.system(size: 30))
                                    Text("Quality")
                                        .font(.caption)
                                }
                                .frame(width: 70)
                            }
                            
                            Button(action: {
                                isShowingSettings = true
                            }) {
                                VStack {
                                    Image(systemName: "gear")
                                        .font(.system(size: 30))
                                    Text("Settings")
                                        .font(.caption)
                                }
                                .frame(width: 70)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding()
                        
                        // Statistics
                        if screenMirrorManager.isStreaming {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Resolution:")
                                        .fontWeight(.medium)
                                    Text(screenMirrorManager.currentResolution)
                                    Spacer()
                                    Text("FPS:")
                                        .fontWeight(.medium)
                                    Text("\(screenMirrorManager.currentFPS)")
                                }
                                
                                HStack {
                                    Text("Bitrate:")
                                        .fontWeight(.medium)
                                    Text(screenMirrorManager.currentBitrate)
                                    Spacer()
                                    Text("Latency:")
                                        .fontWeight(.medium)
                                    Text("\(screenMirrorManager.currentLatency) ms")
                                }
                                
                                HStack {
                                    Text("Data usage:")
                                        .fontWeight(.medium)
                                    Text(screenMirrorManager.dataUsage)
                                }
                            }
                            .font(.caption)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Screen Mirroring")
            .sheet(isPresented: $isShowingSettings) {
                ScreenMirrorSettingsView()
            }
            .actionSheet(isPresented: $showingQualityPicker) {
                ActionSheet(
                    title: Text("Streaming Quality"),
                    message: Text("Select the quality level for screen mirroring"),
                    buttons: [
                        .default(Text("Low (480p)")) {
                            screenMirrorManager.setQuality(.low)
                        },
                        .default(Text("Medium (720p)")) {
                            screenMirrorManager.setQuality(.medium)
                        },
                        .default(Text("High (1080p)")) {
                            screenMirrorManager.setQuality(.high)
                        },
                        .default(Text("Ultra (Original)")) {
                            screenMirrorManager.setQuality(.ultra)
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}

struct ScreenStreamView: View {
    // In a real app, this would be a UIViewRepresentable that shows the video stream
    var body: some View {
        ZStack {
            Color.black
            
            // Placeholder for the actual video stream
            Image(systemName: "display")
                .font(.system(size: 100))
                .foregroundColor(.gray)
                .opacity(0.3)
            
            Text("Screen Mirroring Active")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
}

struct ScreenMirrorSettingsView: View {
    @EnvironmentObject private var screenMirrorManager: ScreenMirrorManager
    @Environment(\.presentationMode) var presentationMode
    @State private var orientation: ScreenOrientation = .auto
    @State private var showPointer: Bool = true
    @State private var enableAudio: Bool = true
    @State private var showTouches: Bool = true
    @State private var autoReconnect: Bool = true
    @State private var recordingQuality: RecordingQuality = .high
    @State private var recordingFormat: RecordingFormat = .mp4
    @State private var recordingLocation: RecordingLocation = .documents
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Settings")) {
                    Picker("Orientation", selection: $orientation) {
                        Text("Auto").tag(ScreenOrientation.auto)
                        Text("Portrait").tag(ScreenOrientation.portrait)
                        Text("Landscape").tag(ScreenOrientation.landscape)
                    }
                    
                    Toggle("Show Mouse Pointer", isOn: $showPointer)
                    Toggle("Show Touch Indicators", isOn: $showTouches)
                }
                
                Section(header: Text("Audio Settings")) {
                    Toggle("Enable Audio", isOn: $enableAudio)
                    
                    if enableAudio {
                        Slider(value: $screenMirrorManager.audioVolume, in: 0...1, step: 0.1) {
                            Text("Volume")
                        } minimumValueLabel: {
                            Image(systemName: "speaker.fill")
                        } maximumValueLabel: {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                    }
                }
                
                Section(header: Text("Recording Settings")) {
                    Picker("Recording Quality", selection: $recordingQuality) {
                        Text("Low").tag(RecordingQuality.low)
                        Text("Medium").tag(RecordingQuality.medium)
                        Text("High").tag(RecordingQuality.high)
                    }
                    
                    Picker("Recording Format", selection: $recordingFormat) {
                        Text("MP4").tag(RecordingFormat.mp4)
                        Text("MOV").tag(RecordingFormat.mov)
                    }
                    
                    Picker("Save Recordings To", selection: $recordingLocation) {
                        Text("Documents").tag(RecordingLocation.documents)
                        Text("Photos").tag(RecordingLocation.photos)
                    }
                }
                
                Section(header: Text("Connection")) {
                    Toggle("Auto Reconnect", isOn: $autoReconnect)
                    
                    Button(action: {
                        // Reset connection
                        screenMirrorManager.resetConnection()
                    }) {
                        Text("Reset Connection")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Screen Mirror Settings")
            .navigationBarItems(trailing: Button("Done") {
                // Save settings
                screenMirrorManager.updateSettings(
                    orientation: orientation,
                    showPointer: showPointer,
                    enableAudio: enableAudio,
                    showTouches: showTouches,
                    autoReconnect: autoReconnect,
                    recordingQuality: recordingQuality,
                    recordingFormat: recordingFormat,
                    recordingLocation: recordingLocation
                )
                
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ScreenMirrorView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenMirrorView()
            .environmentObject(ConnectionManager.shared)
            .environmentObject(ScreenMirrorManager.shared)
    }
}