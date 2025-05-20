import SwiftUI

struct RemoteControlView: View {
    @EnvironmentObject private var connectionManager: ConnectionManager
    @EnvironmentObject private var remoteControlManager: RemoteControlManager
    @State private var controlMode: ControlMode = .touchpad
    @State private var showKeyboard = false
    @State private var isShowingAppList = false
    @State private var isShowingSpecialKeys = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !connectionManager.isConnected {
                    ConnectionRequiredView()
                } else {
                    VStack {
                        // Mode selector
                        Picker("Control Mode", selection: $controlMode) {
                            Text("Touchpad").tag(ControlMode.touchpad)
                            Text("Keyboard").tag(ControlMode.keyboard)
                            Text("Gamepad").tag(ControlMode.gamepad)
                            Text("Media").tag(ControlMode.media)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        // Control interface based on selected mode
                        switch controlMode {
                        case .touchpad:
                            TouchpadControlView()
                        case .keyboard:
                            KeyboardControlView(showKeyboard: $showKeyboard)
                        case .gamepad:
                            GamepadControlView()
                        case .media:
                            MediaControlView()
                        }
                        
                        // Bottom toolbar
                        HStack(spacing: 20) {
                            Button(action: {
                                remoteControlManager.sendHomeButton()
                            }) {
                                VStack {
                                    Image(systemName: "house.fill")
                                        .font(.system(size: 24))
                                    Text("Home")
                                        .font(.caption)
                                }
                            }
                            
                            Button(action: {
                                remoteControlManager.sendBackButton()
                            }) {
                                VStack {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 24))
                                    Text("Back")
                                        .font(.caption)
                                }
                            }
                            
                            Button(action: {
                                isShowingAppList = true
                            }) {
                                VStack {
                                    Image(systemName: "square.grid.2x2.fill")
                                        .font(.system(size: 24))
                                    Text("Apps")
                                        .font(.caption)
                                }
                            }
                            
                            Button(action: {
                                remoteControlManager.sendMultitaskingButton()
                            }) {
                                VStack {
                                    Image(systemName: "rectangle.stack.fill")
                                        .font(.system(size: 24))
                                    Text("Recent")
                                        .font(.caption)
                                }
                            }
                            
                            Button(action: {
                                isShowingSpecialKeys = true
                            }) {
                                VStack {
                                    Image(systemName: "ellipsis.circle.fill")
                                        .font(.system(size: 24))
                                    Text("More")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding()
                    }
                }
            }
            .navigationTitle("Remote Control")
            .sheet(isPresented: $isShowingAppList) {
                AppListView()
            }
            .actionSheet(isPresented: $isShowingSpecialKeys) {
                ActionSheet(
                    title: Text("Special Functions"),
                    buttons: [
                        .default(Text("Lock Screen")) {
                            remoteControlManager.sendLockScreen()
                        },
                        .default(Text("Take Screenshot")) {
                            remoteControlManager.sendScreenshot()
                        },
                        .default(Text("Rotation Lock")) {
                            remoteControlManager.toggleRotationLock()
                        },
                        .default(Text("Volume Up")) {
                            remoteControlManager.sendVolumeUp()
                        },
                        .default(Text("Volume Down")) {
                            remoteControlManager.sendVolumeDown()
                        },
                        .default(Text("Mute/Unmute")) {
                            remoteControlManager.sendMuteToggle()
                        },
                        .default(Text("Power Dialog")) {
                            remoteControlManager.sendPowerDialog()
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}

struct TouchpadControlView: View {
    @EnvironmentObject private var remoteControlManager: RemoteControlManager
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging = false
    
    var body: some View {
        VStack {
            ZStack {
                // Touchpad area
                Rectangle()
                    .fill(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                    dragLocation = value.location
                                } else {
                                    let deltaX = value.location.x - dragLocation.x
                                    let deltaY = value.location.y - dragLocation.y
                                    remoteControlManager.sendMouseMove(deltaX: deltaX, deltaY: deltaY)
                                    dragLocation = value.location
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                
                Text("Touchpad")
                    .foregroundColor(.secondary)
                    .opacity(0.5)
            }
            .frame(height: 300)
            .padding()
            
            // Mouse buttons
            HStack(spacing: 20) {
                Button(action: {
                    remoteControlManager.sendLeftClick()
                }) {
                    Text("Left Click")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    remoteControlManager.sendRightClick()
                }) {
                    Text("Right Click")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Scroll and additional controls
            HStack(spacing: 20) {
                Button(action: {
                    remoteControlManager.sendScrollUp()
                }) {
                    Image(systemName: "arrow.up")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    remoteControlManager.sendScrollDown()
                }) {
                    Image(systemName: "arrow.down")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    remoteControlManager.sendDoubleClick()
                }) {
                    Text("Double Click")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    remoteControlManager.sendMiddleClick()
                }) {
                    Text("Middle Click")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct KeyboardControlView: View {
    @EnvironmentObject private var remoteControlManager: RemoteControlManager
    @Binding var showKeyboard: Bool
    @State private var textInput: String = ""
    
    var body: some View {
        VStack {
            // Text input field
            TextField("Type here...", text: $textInput, onCommit: {
                remoteControlManager.sendText(textInput)
                textInput = ""
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            // Special keys
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    SpecialKeyButton(title: "Esc", action: {
                        remoteControlManager.sendKey(.escape)
                    })
                    
                    SpecialKeyButton(title: "Tab", action: {
                        remoteControlManager.sendKey(.tab)
                    })
                    
                    SpecialKeyButton(title: "Ctrl", action: {
                        remoteControlManager.sendKey(.control)
                    })
                    
                    SpecialKeyButton(title: "Alt", action: {
                        remoteControlManager.sendKey(.option)
                    })
                    
                    SpecialKeyButton(title: "Shift", action: {
                        remoteControlManager.sendKey(.shift)
                    })
                    
                    SpecialKeyButton(title: "Cmd", action: {
                        remoteControlManager.sendKey(.command)
                    })
                    
                    SpecialKeyButton(title: "Enter", action: {
                        remoteControlManager.sendKey(.return)
                    })
                    
                    SpecialKeyButton(title: "Delete", action: {
                        remoteControlManager.sendKey(.delete)
                    })
                    
                    SpecialKeyButton(title: "Space", action: {
                        remoteControlManager.sendKey(.space)
                    })
                }
                .padding(.horizontal)
            }
            
            // Function keys
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1...12, id: \.self) { i in
                        SpecialKeyButton(title: "F\(i)", action: {
                            remoteControlManager.sendFunctionKey(i)
                        })
                    }
                }
                .padding(.horizontal)
            }
            
            // Arrow keys
            HStack(spacing: 10) {
                SpecialKeyButton(title: "←", action: {
                    remoteControlManager.sendKey(.leftArrow)
                })
                
                SpecialKeyButton(title: "↑", action: {
                    remoteControlManager.sendKey(.upArrow)
                })
                
                SpecialKeyButton(title: "↓", action: {
                    remoteControlManager.sendKey(.downArrow)
                })
                
                SpecialKeyButton(title: "→", action: {
                    remoteControlManager.sendKey(.rightArrow)
                })
            }
            .padding()
            
            // Key combinations
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    SpecialKeyButton(title: "Ctrl+C", action: {
                        remoteControlManager.sendKeyCombination([.control, .c])
                    })
                    
                    SpecialKeyButton(title: "Ctrl+V", action: {
                        remoteControlManager.sendKeyCombination([.control, .v])
                    })
                    
                    SpecialKeyButton(title: "Ctrl+X", action: {
                        remoteControlManager.sendKeyCombination([.control, .x])
                    })
                    
                    SpecialKeyButton(title: "Ctrl+Z", action: {
                        remoteControlManager.sendKeyCombination([.control, .z])
                    })
                    
                    SpecialKeyButton(title: "Ctrl+A", action: {
                        remoteControlManager.sendKeyCombination([.control, .a])
                    })
                    
                    SpecialKeyButton(title: "Alt+Tab", action: {
                        remoteControlManager.sendKeyCombination([.option, .tab])
                    })
                    
                    SpecialKeyButton(title: "Cmd+Space", action: {
                        remoteControlManager.sendKeyCombination([.command, .space])
                    })
                }
                .padding(.horizontal)
            }
            
            // Show system keyboard button
            Button(action: {
                showKeyboard.toggle()
            }) {
                Text(showKeyboard ? "Hide Keyboard" : "Show Keyboard")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}

struct SpecialKeyButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(6)
        }
    }
}

struct GamepadControlView: View {
    @EnvironmentObject private var remoteControlManager: RemoteControlManager
    
    var body: some View {
        VStack {
            Text("Gamepad Controls")
                .font(.headline)
                .padding()
            
            // D-Pad
            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.dpadUp)
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 50))
                    }
                    
                    HStack {
                        Button(action: {
                            remoteControlManager.sendGamepadButton(.dpadLeft)
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 50))
                        }
                        
                        Spacer()
                            .frame(width: 50)
                        
                        Button(action: {
                            remoteControlManager.sendGamepadButton(.dpadRight)
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 50))
                        }
                    }
                    
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.dpadDown)
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 50))
                    }
                }
                .padding()
                
                Spacer()
                
                // Action buttons
                VStack {
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.y)
                    }) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 50, height: 50)
                            .overlay(Text("Y").foregroundColor(.black).font(.title))
                    }
                    
                    HStack {
                        Button(action: {
                            remoteControlManager.sendGamepadButton(.x)
                        }) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 50, height: 50)
                                .overlay(Text("X").foregroundColor(.white).font(.title))
                        }
                        
                        Spacer()
                            .frame(width: 50)
                        
                        Button(action: {
                            remoteControlManager.sendGamepadButton(.b)
                        }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 50, height: 50)
                                .overlay(Text("B").foregroundColor(.white).font(.title))
                        }
                    }
                    
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.a)
                    }) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 50, height: 50)
                            .overlay(Text("A").foregroundColor(.white).font(.title))
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Shoulder buttons and menu buttons
            HStack {
                VStack {
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.l1)
                    }) {
                        Text("L1")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.l2)
                    }) {
                        Text("L2")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.select)
                    }) {
                        Text("Select")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.start)
                    }) {
                        Text("Start")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                VStack {
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.r1)
                    }) {
                        Text("R1")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        remoteControlManager.sendGamepadButton(.r2)
                    }) {
                        Text("R2")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray4))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

struct MediaControlView: View {
    @EnvironmentObject private var remoteControlManager: RemoteControlManager
    @State private var volume: Double = 0.5
    
    var body: some View {
        VStack(spacing: 30) {
            // Now playing info (would be populated from the remote device)
            VStack {
                Image(systemName: "music.note")
                    .font(.system(size: 80))
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                
                Text("Now Playing")
                    .font(.title2)
                    .padding(.top)
                
                Text("Unknown Artist")
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Playback controls
            HStack(spacing: 40) {
                Button(action: {
                    remoteControlManager.sendMediaControl(.previous)
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                }
                
                Button(action: {
                    remoteControlManager.sendMediaControl(.playPause)
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 40))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    remoteControlManager.sendMediaControl(.next)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                }
            }
            .padding()
            
            // Volume control
            HStack {
                Image(systemName: "speaker.fill")
                
                Slider(value: $volume, in: 0...1) { _ in
                    remoteControlManager.setVolume(volume)
                }
                
                Image(systemName: "speaker.wave.3.fill")
            }
            .padding()
            
            // Additional media controls
            HStack(spacing: 30) {
                Button(action: {
                    remoteControlManager.sendMediaControl(.shuffle)
                }) {
                    VStack {
                        Image(systemName: "shuffle")
                            .font(.system(size: 24))
                        Text("Shuffle")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    remoteControlManager.sendMediaControl(.repeat)
                }) {
                    VStack {
                        Image(systemName: "repeat")
                            .font(.system(size: 24))
                        Text("Repeat")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    remoteControlManager.sendMediaControl(.mute)
                }) {
                    VStack {
                        Image(systemName: "speaker.slash.fill")
                            .font(.system(size: 24))
                        Text("Mute")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    // Open media app selector
                    remoteControlManager.openMediaAppSelector()
                }) {
                    VStack {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 24))
                        Text("Apps")
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
    }
}

struct AppListView: View {
    @EnvironmentObject private var remoteControlManager: RemoteControlManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search apps", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // App list
                List {
                    ForEach(filteredApps, id: \.id) { app in
                        Button(action: {
                            remoteControlManager.launchApp(app.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                // App icon (placeholder)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                        .frame(width: 40, height: 40)
                                    
                                    Text(String(app.name.prefix(1)))
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                
                                Text(app.name)
                                    .padding(.leading, 8)
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Applications")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return remoteControlManager.installedApps
        } else {
            return remoteControlManager.installedApps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct RemoteControlView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteControlView()
            .environmentObject(ConnectionManager.shared)
            .environmentObject(RemoteControlManager.shared)
    }
}