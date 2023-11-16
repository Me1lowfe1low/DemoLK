import Foundation
import SwiftUI
import LiveKit

struct ConnectView: View {
    @EnvironmentObject var applicationContext: AppContext
    @EnvironmentObject var roomContext: RoomContext
    @EnvironmentObject var room: Room
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(
                    alignment: .center,
                    spacing: connectViewVerticalSpacing
                ) {
                    VStack {
                        Text("LiveKit SDK Version \(LiveKit.version)")
                            .opacity(textFieldOpacity)
                    }
                    
                    VStack(spacing: textFieldSpacing) {
                        ConnectionTextField(title: "Server URL", text: $roomContext.url, type: .URL)
                        ConnectionTextField(title: "Token", text: $roomContext.token, type: .ascii)
                        ConnectionTextField(title: "E2EE Key", text: $roomContext.e2eeKey, type: .ascii)
                    }
                    .padding(.horizontal, textFieldHorizontalPadding)
                    
                    if case .connecting = room.connectionState {
                        ProgressView()
                    } else {
                        ConnectionButton(title: "Connect") {
                            Task {
                                let _ = try await roomContext.connect()
                            }
                        }
                        .foregroundColor(Color.white)
                        .frame(alignment: .center)
                    }
                }
                .padding()
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .alert(isPresented: $roomContext.shouldShowDisconnectReason) {
            Alert(
                title: Text("Disconnected"),
                message: Text(
                    "Reason: " + (
                        roomContext.latestError != nil
                        ? String(describing: roomContext.latestError!)
                        : "Unknown"
                    )
                )
            )
        }
    }
}

private let connectViewVerticalSpacing: CGFloat = 40.0
private let textFieldOpacity: CGFloat = 0.5
private let textFieldSpacing: CGFloat = 15.0
private let textFieldHorizontalPadding: CGFloat = 15.0

#if DEBUG
#Preview {
    ContentView()
}
#endif
