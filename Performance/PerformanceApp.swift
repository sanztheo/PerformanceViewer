import SwiftUI

@main
struct PerformanceApp: App {
    @State private var monitor = SystemMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopover(monitor: monitor)
        } label: {
            Text(menuBarLabel)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarLabel: String {
        let cpu = Int(monitor.cpu.totalUsage)
        let memUsed = String(format: "%.1f", Double(monitor.memory.used) / 1_073_741_824)
        let memTotal = String(format: "%.0f", Double(monitor.memory.total) / 1_073_741_824)
        let disk = "\(monitor.disk.usedGB)/\(monitor.disk.totalGB)"
        let energy = energyLabel

        return "CPU \(cpu)%  RAM \(memUsed)/\(memTotal)  \(energy)  Disk \(disk)"
    }

    private var energyLabel: String {
        if let battery = monitor.energy.batteryLevel {
            let charging = (monitor.energy.isCharging == true) ? "⚡" : "🔋"
            return "\(charging)\(Int(battery))%"
        }
        return "⚡\(monitor.energy.thermalLabel)"
    }
}
