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
                .padding(textPadding)
                .background(isMe ? .red : .gray)
                .foregroundColor(Color.white)
                .cornerRadius(textCornerRadius)
            
            if !isMe {
                Spacer()
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }
}

private let textPadding: CGFloat = 8.0
private let textCornerRadius: CGFloat = 8.0
private let verticalPadding: CGFloat = 5.0
private let horizontalPadding: CGFloat = 10.0
