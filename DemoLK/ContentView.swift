import SwiftUI
import LiveKit

let sync = Preferences()

struct ContentView: View {
    @EnvironmentObject var applicationContext: AppContext
    @StateObject var roomContext = RoomContext(store: sync)
    
    var body: some View {
        RoomSwitchView()
            .environmentObject(roomContext)
            .environmentObject(roomContext.room)
            .environment(\.colorScheme, .dark)
            .onDisappear {
                Task {
                    try await roomContext.disconnect()
                }
            }
    }
}

#Preview {
    ContentView()
}
