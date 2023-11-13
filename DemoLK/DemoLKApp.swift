import SwiftUI

@main
struct DemoLKApp: App {
    @StateObject var ApplicationContext = AppContext(store: sync)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ApplicationContext)
        }
    }
}
