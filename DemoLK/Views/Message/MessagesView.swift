import SwiftUI
import LiveKit

struct MessagesView: View {
    @EnvironmentObject var roomCtx: RoomContext
    @State var geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView(
                    .vertical,
                    showsIndicators: true
                ) {
                    LazyVStack(
                        alignment: .center,
                        spacing: 0
                    ) {
                        ForEach(roomCtx.messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 7)
                }
                .onAppear { scrollToBottom(scrollView) }
                .onChange(
                    of: roomCtx.messages,
                    perform: { _ in
                        scrollToBottom(scrollView)
                    }
                )
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
                        .foregroundColor(roomCtx.textFieldString.isEmpty ? nil : .red)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(Color(.lightGray))
        }
        .background(Color.gray)
        .cornerRadius(8)
        .frame(
            minWidth: 0,
            maxWidth: geometry.isTall ? .infinity : 320
        )
    }
}

// MARK: Private

extension MessagesView {
    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        guard let last = roomCtx.messages.last else { return }
        withAnimation {
            scrollView.scrollTo(last.id)
        }
    }
}
