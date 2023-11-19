import SwiftUI
import LiveKit

struct ToolbarView: View {
    @EnvironmentObject var room: Room
    
    @Binding var isCameraPublishingBusy: Bool
    @Binding var isMicrophonePublishingBusy: Bool
    @Binding var isScreenSharePublishingBusy: Bool
    @Binding var screenPickerPresented: Bool
    
    var body: some View {
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
                print("🐦 screen Share")
                Task {
                    isScreenSharePublishingBusy = true
                    defer { Task { @MainActor in isScreenSharePublishingBusy = false } }
                    try await room.localParticipant?.setScreenShare(enabled: true)
//                        .setScreenShare(enabled: !isScreenShareEnabled)
                    print(room.localParticipant?.firstScreenSharePublication)
                }
            }, label: {
                Image(systemName: "rectangle.fill.on.rectangle.fill")
                    .renderingMode(isScreenShareEnabled ? .original : .template)
            })
            .disabled(isScreenSharePublishingBusy)
        }
    }
}
