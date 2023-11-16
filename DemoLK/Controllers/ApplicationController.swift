import SwiftUI
import LiveKit
import WebRTC
import Combine

// This class contains the logic to control behaviour of the whole app.
final class AppContext: ObservableObject {
    @Published var videoViewVisible: Bool = true {
        didSet { store.videoViewVisible = videoViewVisible }
    }
    @Published var showInformationOverlay: Bool = false {
        didSet { store.showInformationOverlay = showInformationOverlay }
    }
    @Published var preferSampleBufferRendering: Bool = false {
        didSet { store.preferSampleBufferRendering = preferSampleBufferRendering }
    }
    @Published var videoViewMode: VideoView.LayoutMode = .fit {
        didSet { store.videoViewMode = videoViewMode }
    }
    @Published var videoViewMirrored: Bool = false {
        didSet { store.videoViewMirrored = videoViewMirrored }
    }
    @Published var outputDevice: RTCIODevice = RTCIODevice.defaultDevice(with: .output) {
        didSet {
            print("didSet outputDevice: \(String(describing: outputDevice))")
            Room.audioDeviceModule.outputDevice = outputDevice
        }
    }
    @Published var inputDevice: RTCIODevice = RTCIODevice.defaultDevice(with: .input) {
        didSet {
            print("didSet inputDevice: \(String(describing: inputDevice))")
            Room.audioDeviceModule.inputDevice = inputDevice
        }
    }
    @Published var preferSpeakerOutput: Bool = true {
        didSet { AudioManager.shared.preferSpeakerOutput = preferSpeakerOutput }
    }
    
    private var store: Preferences
    
    public init(store: Preferences) {
        print("🦕 appContext initialization in progress...")
        self.store = store
        
        self.videoViewVisible = store.videoViewVisible
        self.showInformationOverlay = store.showInformationOverlay
        self.preferSampleBufferRendering = store.preferSampleBufferRendering
        self.videoViewMode = store.videoViewMode
        self.videoViewMirrored = store.videoViewMirrored
        
        Room.audioDeviceModule.setDevicesUpdatedHandler {
            print("🪿 devices did update")
            
            // force UI update for outputDevice / inputDevice
            DispatchQueue.main.async {
                self.outputDevice = Room.audioDeviceModule.outputDevice
                self.inputDevice = Room.audioDeviceModule.inputDevice
            }
        }
    }
}
