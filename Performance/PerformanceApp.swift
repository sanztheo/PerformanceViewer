import SwiftUI

@main
struct PerformanceApp: App {
    @State private var monitor = SystemMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopover(monitor: monitor)
        } label: {
            let cpu = Int(monitor.cpu.totalUsage)
            let memUsed = Double(monitor.memory.used) / 1_073_741_824
            let memTotal = Double(monitor.memory.total) / 1_073_741_824
            let diskUsed = monitor.disk.usedGB
            let diskTotal = monitor.disk.totalGB

            HStack(spacing: 2) {
                Image(systemName: "cpu")
                    .imageScale(.small)
                Text("\(cpu)%")

                Text("│").foregroundStyle(.quaternary)

                Image(systemName: "memorychip")
                    .imageScale(.small)
                Text(String(format: "%.1f/%.0f", memUsed, memTotal))

                Text("│").foregroundStyle(.quaternary)

                Image(systemName: "bolt.fill")
                    .imageScale(.small)
                Text(energyMenuLabel)

                Text("│").foregroundStyle(.quaternary)

                Image(systemName: "internaldrive")
                    .imageScale(.small)
                Text("\(diskUsed)/\(diskTotal)")
            }
            .font(.system(size: 10, weight: .medium, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }

    private var energyMenuLabel: String {
        if let battery = monitor.energy.batteryLevel {
            return String(format: "%.0f%%", battery)
        }
        return monitor.energy.thermalLabel
    }
}
