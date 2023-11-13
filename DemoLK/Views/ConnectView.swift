import Foundation
import SwiftUI
import LiveKit

struct ConnectView: View {
    @EnvironmentObject var appCtx: AppContext
    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(
                    alignment: .center,
                    spacing: 40.0
                ) {
                    VStack(spacing: 10) {
                        Text("SDK Version \(LiveKit.version)")
                            .opacity(0.5)
                    }
                    
                    VStack(spacing: 15) {
                        LKTextField(title: "Server URL", text: $roomCtx.url, type: .URL)
                        LKTextField(title: "Token", text: $roomCtx.token, type: .ascii)
                        LKTextField(title: "E2EE Key", text: $roomCtx.e2eeKey, type: .ascii)
                    }
                    .frame(maxWidth: 350)
                    .padding(.horizontal, 10)
                    
                    if case .connecting = room.connectionState {
                        ProgressView()
                    } else {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            LKButton(title: "Connect") {
                                Task {
                                    let _ = try await roomCtx.connect()
                                }
                            }
                            .foregroundColor(Color.white)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .frame(width: geometry.size.width)      // Make the scroll view full-width
                .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
            }
        }
        .alert(isPresented: $roomCtx.shouldShowDisconnectReason) {
            Alert(
                title: Text("Disconnected"),
                message: Text(
                    "Reason: " + (
                        roomCtx.latestError != nil
                        ? String(describing: roomCtx.latestError!)
                        : "Unknown"
                    )
                )
            )
        }
    }
}
