import SwiftUI
import LiveKit
import WebRTC

// This class contains the logic to control behaviour of the whole app.
final class RoomContext: ObservableObject {
    @Published var shouldShowDisconnectReason: Bool = false
    @Published var url: String = "" {
        didSet { store.url = url }
    }
    @Published var token: String = "" {
        didSet { store.token = token }
    }
    @Published var e2eeKey: String = "" {
        didSet { store.e2eeKey = e2eeKey }
    }
    @Published var e2ee: Bool = false {
        didSet { store.e2ee = e2ee }
    }
    
    // RoomOptions
    @Published var simulcast: Bool = true {
        didSet { store.simulcast = simulcast }
    }
    @Published var adaptiveStream: Bool = false {
        didSet { store.adaptiveStream = adaptiveStream }
    }
    @Published var dynacast: Bool = false {
        didSet { store.dynacast = dynacast }
    }
    @Published var reportStats: Bool = false {
        didSet { store.reportStats = reportStats }
    }
    
    // ConnectOptions
    @Published var autoSubscribe: Bool = true {
        didSet { store.autoSubscribe = autoSubscribe}
    }
    @Published var publish: Bool = false {
        didSet { store.publishMode = publish }
    }
    @Published var focusParticipant: Participant?
    @Published var textFieldString: String = ""
    
    public var latestError: DisconnectReason?
    public let room = Room()
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private var store: Preferences
    
    public init(store: Preferences) {
        self.store = store
        room.add(delegate: self)
        
        self.url = store.url
        self.token = store.token
        self.e2ee = store.e2ee
        self.e2eeKey = store.e2eeKey
        self.simulcast = store.simulcast
        self.adaptiveStream = store.adaptiveStream
        self.dynacast = store.dynacast
        self.reportStats = store.reportStats
        self.autoSubscribe = store.autoSubscribe
        self.publish = store.publishMode
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        print("RoomContext.deinit")
    }
    
    @MainActor
    func connect() async throws -> Room {
        print("🐵 Connecting to the room")
        let connectOptions = ConnectOptions(
            autoSubscribe: !publish && autoSubscribe,
            publishOnlyMode: publish 
            ? "publish_\(UUID().uuidString)"
            : nil
        )
        
        var e2eeOptions: E2EEOptions?
        
        if e2ee {
            let keyProvider = BaseKeyProvider(isSharedKey: true)
            
            keyProvider.setKey(key: e2eeKey)
            e2eeOptions = E2EEOptions(keyProvider: keyProvider)
        }
        
        print("🐵 Installing room options...")
        let roomOptions = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
                dimensions: .h1080_169
            ),
            defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
                dimensions: .h1080_169,
                useBroadcastExtension: true
            ),
            defaultVideoPublishOptions: VideoPublishOptions(
                simulcast: publish ? false : simulcast
            ),
            adaptiveStream: adaptiveStream,
            dynacast: dynacast,
            reportStats: reportStats,
            e2eeOptions: e2eeOptions
        )
        
        print("🐸 local: \(room.localParticipant)")
        print("🐸 remote: \(room.remoteParticipants)")
        
        return try await room.connect(
            url,
            token,
            connectOptions: connectOptions,
            roomOptions: roomOptions
        )
    }
    
    func disconnect() async throws {
        print("Disconnecting...")
        try await room.disconnect()
    }
}

extension RoomContext: RoomDelegate {
    func room(
        _ room: Room,
        publication: TrackPublication,
        didUpdateE2EEState e2eeState: E2EEState
    ) {
        print("🐋 room(). e2eeState = [\(e2eeState.toString())] for publication \(publication.sid)")
    }
    
    func room(
        _ room: Room,
        didUpdate connectionState: ConnectionState,
        oldValue: ConnectionState
    ) {
        print("🐋 room(). connectionState \(oldValue) -> \(connectionState)")
        print("🦆 local: \(room.localParticipant)")
        print("🦆 remote: \(room.remoteParticipants)")
        
        if case .disconnected(let reason) = connectionState, reason != .user {
            latestError = reason
            
            DispatchQueue.main.async {
                self.shouldShowDisconnectReason = true
                // Reset state
                self.focusParticipant = nil
                self.textFieldString = ""
            }
        }
    }
    
    func room(
        _ room: Room,
        participantDidLeave participant: RemoteParticipant
    ) {
        print("🐋 room(). Participant left the channel")
        
        DispatchQueue.main.async {
            if let focusParticipant = self.focusParticipant,
               focusParticipant.sid == participant.sid {
                self.focusParticipant = nil
            }
        }
    }
    
    func room(
        _ room: Room,
        participant: RemoteParticipant?,
        didReceive data: Data
    ) {
        print("🐋 room(). Message resolver")
    }
}
