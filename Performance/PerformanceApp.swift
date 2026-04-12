import SwiftUI

@main
struct PerformanceApp: App {
    @State private var monitor = SystemMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopover(monitor: monitor)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "gauge.medium")
                Text(menuBarLabel)
                    .font(.system(.caption2, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarLabel: String {
        let cpu = Int(monitor.cpu.totalUsage)
        let mem = Int(monitor.memory.usedPercentage)
        return "\(cpu)% · \(mem)%"
    }
}
