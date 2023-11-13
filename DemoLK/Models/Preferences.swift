import LiveKit

struct Preferences: Codable, Equatable {
    var url = "wss://demolk-tnqfv5ab.livekit.cloud"
    var token = ""
    var e2eeKey = "secret"
    var e2ee = false
    
    // Connect options
    var autoSubscribe = true
    var publishMode = false
    
    // Room options
    var simulcast = true
    var adaptiveStream = true
    var dynacast = true
    var reportStats = true
    
    // Settings
    var videoViewVisible = true
    var showInformationOverlay = false
    var preferSampleBufferRendering = false
    var videoViewMode: VideoView.LayoutMode = .fit
    var videoViewMirrored = false
}
