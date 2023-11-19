import SwiftUI
import LiveKit
import WebRTC

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
                
                ToolbarView(
                    isCameraPublishingBusy: $isCameraPublishingBusy,
                    isMicrophonePublishingBusy: $isMicrophonePublishingBusy,
                    isScreenSharePublishingBusy: $isScreenSharePublishingBusy
                    ,screenPickerPresented: $screenPickerPresented
                )
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
