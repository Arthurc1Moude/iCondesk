# iCondesk Project Structure

This document provides an overview of the iCondesk iOS app project structure and architecture.

## Architecture

iCondesk follows the MVVM (Model-View-ViewModel) architecture pattern with SwiftUI for the user interface. The app is organized into the following main components:

1. **Models**: Data structures and manager classes that handle business logic
2. **Views**: SwiftUI views that make up the user interface
3. **Managers**: Singleton classes that manage specific functionality domains

## Directory Structure

```
iCondesk/
├── iCondeskApp.swift       # Main app entry point
├── app.swift               # App configuration
├── Models/                 # Data models and managers
│   ├── ConnectionManager.swift
│   ├── FileTransferManager.swift
│   ├── ScreenMirrorManager.swift
│   └── RemoteControlManager.swift
├── Views/                  # SwiftUI views
│   ├── ContentView.swift   # Main tab view container
│   ├── ConnectionView.swift
│   ├── FileTransferView.swift
│   ├── ScreenMirrorView.swift
│   ├── RemoteControlView.swift
│   └── SettingsView.swift
└── Resources/              # Assets and resources
    └── Assets.xcassets
```

## Key Components

### Managers

1. **ConnectionManager**: Handles device connections via Wi-Fi, USB, and Bluetooth
2. **FileTransferManager**: Manages file browsing and transfer operations
3. **ScreenMirrorManager**: Controls screen mirroring and recording functionality
4. **RemoteControlManager**: Handles remote control features and input commands

### Views

1. **ContentView**: Main tab-based container view
2. **ConnectionView**: Interface for establishing and managing connections
3. **FileTransferView**: File browser and transfer interface
4. **ScreenMirrorView**: Screen mirroring controls and display
5. **RemoteControlView**: Remote control interface with multiple control modes
6. **SettingsView**: App settings and configuration

## Data Flow

1. The app uses environment objects to share manager instances across views
2. Managers implement the ObservableObject protocol for reactive updates
3. Views observe changes to manager state using @EnvironmentObject
4. User actions in views trigger methods on the appropriate managers
5. Managers update their state, which automatically updates the UI

## Connection Protocol

The app uses a custom protocol for communication between iOS devices and computers:

1. **Discovery**: Devices discover each other via Bonjour/mDNS or direct connection
2. **Authentication**: Secure pairing process with verification on both devices
3. **Communication**: Encrypted bidirectional communication channel
4. **Commands**: Structured command protocol for various operations
5. **Data Transfer**: Efficient binary protocol for file and screen data

## Future Enhancements

1. Add support for cloud storage integration
2. Implement multi-device control
3. Add voice command support
4. Enhance security with biometric authentication
5. Add support for Apple Pencil input
6. Implement collaborative features for shared workspaces