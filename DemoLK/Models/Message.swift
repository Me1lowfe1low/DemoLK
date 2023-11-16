struct RoomMessage: Identifiable, Equatable, Hashable, Codable {
    var id: String {
        messageId
    }
    
    let messageId: String
    
    let senderSid: String
    let senderIdentity: String
    let text: String
    
    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.messageId == rhs.messageId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
}
