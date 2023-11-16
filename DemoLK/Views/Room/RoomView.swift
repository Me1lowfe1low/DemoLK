import SwiftUI
import LiveKit
import WebRTC

let adaptiveMin = 170.0
let toolbarPlacement: ToolbarItemPlacement = .bottomBar

struct RoomView: View {
    @EnvironmentObject var applicationContext: AppContext
    @EnvironmentObject var roomContext: RoomContext
    @EnvironmentObject var room: Room
    
    @State var isCameraPublishingBusy = false
    @State var isMicrophonePublishingBusy = false
    @State var isScreenSharePublishingBusy = false
    
    @State private var screenPickerPresented = false
    @State private var showConnectionTime = true
    
    var body: some View {
        GeometryReader { geometry in
            RoomContent(geometry: geometry)
        }
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                // VideoView mode switcher
                Picker("Mode", selection: $applicationContext.videoViewMode) {
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
                    // Toggle messages view (chat example)
                Button(action: {
                    withAnimation {
                        roomContext.showMessagesView.toggle()
                    }
                },
                       label: {
                    Image(systemName: "message.fill")
                        .renderingMode(roomContext.showMessagesView ? .original : .template)
                })
                Spacer()
                
                // Disconnect
                Button(action: {
                    Task {
                        try await roomContext.disconnect()
                    }
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .renderingMode(.original)
                })
            }
        }
        .onAppear {
            Timer.scheduledTimer(
                withTimeInterval: 3,
                repeats: false
            ) { _ in
                DispatchQueue.main.async {
                    withAnimation {
                        self.showConnectionTime = false
                    }
                }
            }
        }
    }
}
