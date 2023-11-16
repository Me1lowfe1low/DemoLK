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
                .background(isMe ? Color.customRed : Color.customGray2)
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

struct MessagesView: View {
        //    @ObservedObject var roomCtx:  // Replace with your actual RoomContext type
    @EnvironmentObject var roomCtx: RoomContext
    @State var geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .center, spacing: 0) {
                        ForEach(roomCtx.messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 7)
                }
                .onAppear(perform: {
                        // Scroll to bottom when first showing the messages list
                    scrollToBottom(scrollView)
                })
                .onChange(of: roomCtx.messages, perform: { _ in
                        // Scroll to bottom when there is a new message
                    scrollToBottom(scrollView)
                })
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
            HStack(spacing: 0) {
                TextField("Enter message", text: $roomCtx.textFieldString)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                Button {
                    roomCtx.sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(roomCtx.textFieldString.isEmpty ? nil : Color.customRed)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(Color.customGray2)
        }
        .background(Color.customGray1)
        .cornerRadius(8)
        .frame(
            minWidth: 0,
            maxWidth: geometry.isTall ? .infinity : 320
        )
    }
    
    func scrollToBottom(_ scrollView: ScrollViewProxy) {
        guard let last = roomCtx.messages.last else { return }
        withAnimation {
            scrollView.scrollTo(last.id)
        }
    }
}
