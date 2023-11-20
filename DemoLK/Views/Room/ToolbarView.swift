import SwiftUI
import LiveKit

struct ToolbarView: View {
    @EnvironmentObject var roomContext: RoomContext
    @EnvironmentObject var room: Room
//    @StateObject var screenRecorderManager: ScreenRecorderManagerImpl = ScreenRecorderManagerImpl()
    @Binding var isCameraPublishingBusy: Bool
    @Binding var isMicrophonePublishingBusy: Bool
//    @Binding var isScreenSharePublishingBusy: Bool
//    @Binding var screenPickerPresented: Bool
//    @Binding var shareScreenOpened: Bool
    
    var sessionId = UUID().uuidString
    
    var body: some View {
        Group {
            let isCameraEnabled = room.localParticipant?.isCameraEnabled() ?? false
            let isMicrophoneEnabled = room.localParticipant?.isMicrophoneEnabled() ?? false
//            let isScreenShareEnabled = room.localParticipant?.isScreenShareEnabled() ?? false
            
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
        }
    }
}
