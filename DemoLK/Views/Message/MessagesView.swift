import SwiftUI
import LiveKit

struct MessagesView: View {
    @EnvironmentObject var roomContext: RoomContext
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
                        ForEach(roomContext.messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding(.vertical, verticalPadding)
                    .padding(.horizontal, 7)
                }
                .onAppear { scrollToBottom(scrollView) }
                .onChange(
                    of: roomContext.messages,
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
                TextField("Enter message", text: $roomContext.textFieldString)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                Button {
                    roomContext.sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(roomContext.textFieldString.isEmpty ? nil : .red)
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

// MARK: - Private

extension MessagesView {
    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        guard let last = roomContext.messages.last else { return }
        withAnimation {
            scrollView.scrollTo(last.id)
        }
    }
}

private let textPadding: CGFloat = 8.0
private let textCornerRadius: CGFloat = 8.0
private let verticalPadding: CGFloat = 15.0
private let horizontalPadding: CGFloat = 5.0
