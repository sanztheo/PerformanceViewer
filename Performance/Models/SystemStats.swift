import Foundation

struct CPUStats: Sendable {
    let user: Double
    let system: Double
    let idle: Double
    let nice: Double

    var totalUsage: Double {
        user + system + nice
    }

    static let zero = CPUStats(user: 0, system: 0, idle: 100, nice: 0)
}

struct MemoryStats: Sendable {
    let used: UInt64
    let active: UInt64
    let wired: UInt64
    let compressed: UInt64
    let free: UInt64
    let total: UInt64

    var usedPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100
    }

    var usedFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(used), countStyle: .memory)
    }

    var totalFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .memory)
    }

    static let zero = MemoryStats(used: 0, active: 0, wired: 0, compressed: 0, free: 0, total: 0)
}

struct ProcessStats: Identifiable, Sendable {
    let pid: Int32
    let name: String
    let cpuUsage: Double
    let memoryBytes: UInt64

    var id: Int32 { pid }

    var memoryFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryBytes), countStyle: .memory)
    }
}

struct DiskStats: Sendable {
    let total: UInt64
    let free: UInt64

    var used: UInt64 { total > free ? total - free : 0 }

    var usedPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100
    }

    // Base 10 (Go) comme Finder
    var usedGB: String {
        String(format: "%.0f", Double(used) / 1_000_000_000)
    }

    var totalGB: String {
        String(format: "%.0f", Double(total) / 1_000_000_000)
    }

    var freeGB: String {
        String(format: "%.0f", Double(free) / 1_000_000_000)
    }

    static let zero = DiskStats(total: 0, free: 0)
}

struct EnergyStats: Sendable {
    let thermalState: Int // 0=nominal, 1=fair, 2=serious, 3=critical
    let batteryLevel: Double? // 0-100, nil if no battery
    let isCharging: Bool?
    let powerSource: String

    var thermalLabel: String {
        switch thermalState {
        case 0: return "Normal"
        case 1: return "Modéré"
        case 2: return "Élevé"
        case 3: return "Critique"
        default: return "—"
        }
    }

    static let zero = EnergyStats(thermalState: 0, batteryLevel: nil, isCharging: nil, powerSource: "—")
}
