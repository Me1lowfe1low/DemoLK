import SwiftUI
import Logging
import LiveKit

struct RoomSwitchView: View {
    @EnvironmentObject var applicationContext: AppContext
    @EnvironmentObject var roomContext: RoomContext
    @EnvironmentObject var room: Room
    
    private var shouldShowRoomView: Bool {
        room.connectionState.isConnected || room.connectionState.isReconnecting
    }
    
    private func computeTitle() -> String {
        if shouldShowRoomView {
            let elements = [
                room.name,
                room.localParticipant?.name,
                room.localParticipant?.identity
            ]
            
            return elements.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        }
        
        return "DemoLK"
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if shouldShowRoomView {
                RoomView()
            } else {
                ConnectView()
            }
        }
        .navigationTitle(computeTitle())
    }
}
