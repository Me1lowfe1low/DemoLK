import SwiftUI
import LiveKit

struct RoomContent: View {
    @EnvironmentObject var applicationContext: AppContext
    @EnvironmentObject var roomContext: RoomContext
    @EnvironmentObject var room: Room
    
    @State var geometry: GeometryProxy
    
    var body: some View {
        VStack {
            AdaptiveStack(
                axis: geometry.isTall ? .vertical : .horizontal,
                spacing: stackSpacing
            ) {
                Group {
                    if let focusParticipant = roomContext.focusParticipant {
                        ZStack(alignment: .bottomTrailing) {
                            ParticipantView(
                                participant: focusParticipant,
                                videoViewMode: applicationContext.videoViewMode
                            ) { _ in
                                roomContext.focusParticipant = nil
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: overlayCornerRadius)
                                    .stroke(
                                        overlayBorderColor
                                            .opacity(overlayBorderColorOpacity),
                                        lineWidth: overlayBorderWidth
                                    )
                            )
                        }
                    } else {
                        ParticipantLayout(
                            sortedParticipants(),
                            spacing: layoutSpacing
                        ) { participant in
                            ParticipantView(
                                participant: participant,
                                videoViewMode: applicationContext.videoViewMode
                            ) { participant in
                                roomContext.focusParticipant = participant
                            }
                        }
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                
                if roomContext.showMessagesView {
                    MessagesView(geometry: geometry)
                }
            }
        }
        .padding(5)
    }
}

private let overlayCornerRadius: CGFloat = 4.0
private let overlayBorderColor: Color = .red
private let overlayBorderColorOpacity: CGFloat = 0.7
private let overlayBorderWidth: CGFloat = 1.0
private let stackSpacing: CGFloat = 5.0
private let layoutSpacing: CGFloat = 5.0

extension RoomContent {
    private func sortedParticipants() -> [Participant] {
        room.allParticipants.values.sorted { p1, p2 in
            if p1 is LocalParticipant { return true }
            if p2 is LocalParticipant { return false }
            return (p1.joinedAt ?? Date()) < (p2.joinedAt ?? Date())
        }
    }
}
