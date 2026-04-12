import SwiftUI

@main
struct PerformanceApp: App {
    @State private var monitor = SystemMonitor()

    var body: some Scene {
        MenuBarExtra {
            Text("Loading...")
                .frame(width: 320, height: 400)
        } label: {
            Label("Performance", systemImage: "gauge.medium")
        }
        .menuBarExtraStyle(.window)
    }
}
