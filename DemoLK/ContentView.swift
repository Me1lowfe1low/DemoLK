import SwiftUI
import LiveKit

let sync = Preferences()

// Attaches RoomContext and Room to the environment
struct ContentView: View {
    @EnvironmentObject var applicationContext: AppContext
    @StateObject var roomContext = RoomContext(store: sync)
    
    var body: some View {
        RoomSwitchView()
            .environmentObject(roomContext)
            .environmentObject(roomContext.room)
            .environment(\.colorScheme, .dark)
            .onDisappear {
                print("🙈 onDisappear")
                Task {
                    try await roomContext.disconnect()
                }
            }
    }
}

#Preview {
    ContentView()
}
