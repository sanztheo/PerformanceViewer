import SwiftUI

@main
struct PerformanceApp: App {
    @State private var monitor = SystemMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopover(monitor: monitor)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                Text("\(Int(monitor.cpu.totalUsage))%")

                Image(systemName: "memorychip")
                Text(memoryLabel)

                Image(systemName: "internaldrive")
                Text("\(monitor.disk.usedGB)/\(monitor.disk.totalGB)")
            }
            .font(.system(.caption2, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }

    private var memoryLabel: String {
        let usedGB = Double(monitor.memory.used) / 1_073_741_824
        let totalGB = Double(monitor.memory.total) / 1_073_741_824
        return String(format: "%.1f/%.0f GB", usedGB, totalGB)
    }
}
