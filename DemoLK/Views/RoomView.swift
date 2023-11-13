import SwiftUI
import LiveKit
import WebRTC

let adaptiveMin = 170.0
let toolbarPlacement: ToolbarItemPlacement = .bottomBar

struct RoomView: View {
    @EnvironmentObject var appCtx: AppContext
    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room
    
    @State var isCameraPublishingBusy = false
    @State var isMicrophonePublishingBusy = false
    @State var isScreenSharePublishingBusy = false
    
    @State private var screenPickerPresented = false
    @State private var showConnectionTime = true
    
    func sortedParticipants() -> [Participant] {
        room.allParticipants.values.sorted { p1, p2 in
            if p1 is LocalParticipant { return true }
            if p2 is LocalParticipant { return false }
            return (p1.joinedAt ?? Date()) < (p2.joinedAt ?? Date())
        }
    }
    
    func content(geometry: GeometryProxy) -> some View {
        VStack {
            HorVStack(
                axis: geometry.isTall ? .vertical : .horizontal,
                spacing: 5
            ) {
                Group {
                    if let focusParticipant = roomCtx.focusParticipant {
                        ZStack(alignment: .bottomTrailing) {
                            ParticipantView(
                                participant: focusParticipant,
                                videoViewMode: appCtx.videoViewMode
                            ) { _ in
                                roomCtx.focusParticipant = nil
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(
                                        Color.customRed.opacity(0.7),
                                        lineWidth: 5.0
                                    )
                            )
                        }
                    } else {
                        ParticipantLayout(
                            sortedParticipants(),
                            spacing: 5
                        ) { participant in
                            ParticipantView(
                                participant: participant,
                                videoViewMode: appCtx.videoViewMode
                            ) { participant in
                                roomCtx.focusParticipant = participant
                            }
                        }
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
            }
        }
        .padding(5)
    }
    
    var body: some View {
        GeometryReader { geometry in
            content(geometry: geometry)
        }
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                // VideoView mode switcher
                Picker("Mode", selection: $appCtx.videoViewMode) {
                    Text("Fit").tag(VideoView.LayoutMode.fit)
                    Text("Fill").tag(VideoView.LayoutMode.fill)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                Group {
                    let isCameraEnabled = room.localParticipant?.isCameraEnabled() ?? false
                    let isMicrophoneEnabled = room.localParticipant?.isMicrophoneEnabled() ?? false
                    let isScreenShareEnabled = room.localParticipant?.isScreenShareEnabled() ?? false
                    
                    if (isCameraEnabled) && CameraCapturer.canSwitchPosition() {
                        Menu {
                            Button("Switch position") {
                                Task {
                                    isCameraPublishingBusy = true
                                    defer { Task { @MainActor in isCameraPublishingBusy = false } }
                                    if let track = room.localParticipant?.firstCameraVideoTrack as? LocalVideoTrack,
                                       let cameraCapturer = track.capturer as? CameraCapturer {
                                        try await cameraCapturer.switchCameraPosition()
                                    }
                                }
                            }
                            
                            Button("Disable") {
                                Task {
                                    isCameraPublishingBusy = true
                                    defer { Task { @MainActor in isCameraPublishingBusy = false } }
                                    try await room.localParticipant?.setCamera(enabled: !isCameraEnabled)
                                }
                            }
                        } label: {
                            Image(systemName: "video.fill")
                                .renderingMode(.original)
                        }
                        // disable while publishing/un-publishing
                        .disabled(isCameraPublishingBusy)
                    } else {
                        // Toggle camera enabled
                        Button(action: {
                            Task {
                                isCameraPublishingBusy = true
                                defer { Task { @MainActor in isCameraPublishingBusy = false } }
                                try await room.localParticipant?.setCamera(enabled: !isCameraEnabled)
                            }
                        }, label: {
                            Image(systemName: "video.fill")
                                .renderingMode(isCameraEnabled ? .original : .template)
                        })
                        // disable while publishing/un-publishing
                        .disabled(isCameraPublishingBusy)
                    }
                    
                    // Toggle microphone enabled
                    Button(action: {
                        Task {
                            isMicrophonePublishingBusy = true
                            defer { Task { @MainActor in isMicrophonePublishingBusy = false } }
                            try await room.localParticipant?.setMicrophone(enabled: !isMicrophoneEnabled)
                        }
                    }, label: {
                        Image(systemName: "mic.fill")
                            .renderingMode(isMicrophoneEnabled ? .original : .template)
                    })
                    // disable while publishing/un-publishing
                    .disabled(isMicrophonePublishingBusy)
                    
                    Button(action: {
                        Task {
                            isScreenSharePublishingBusy = true
                            defer { Task { @MainActor in isScreenSharePublishingBusy = false } }
                            try await room.localParticipant?.setScreenShare(enabled: !isScreenShareEnabled)
                        }
                    }, label: {
                        Image(systemName: "rectangle.fill.on.rectangle.fill")
                            .renderingMode(isScreenShareEnabled ? .original : .template)
                    })
                    // disable while publishing/un-publishing
                    .disabled(isScreenSharePublishingBusy)
                }
                
                Spacer()
                
                // Disconnect
                Button(action: {
                    Task {
                        try await roomCtx.disconnect()
                    }
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .renderingMode(.original)
                })
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                DispatchQueue.main.async {
                    withAnimation {
                        self.showConnectionTime = false
                    }
                }
            }
        }
    }
}
