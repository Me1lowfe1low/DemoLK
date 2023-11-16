import SwiftUI
import LiveKit

struct MessageView: View {
    let message: RoomMessage
    @EnvironmentObject var room: Room
    
    var body: some View {
        let isMe = message.senderSid == room.localParticipant?.sid
        
        return HStack {
            if isMe {
                Spacer()
            }
            
            Text(message.text)
                .padding(8)
                .background(isMe ? .red : .gray)
                .foregroundColor(Color.white)
                .cornerRadius(18)
            
            if !isMe {
                Spacer()
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
    }
}
