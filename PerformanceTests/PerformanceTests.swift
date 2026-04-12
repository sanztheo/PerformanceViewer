import XCTest
@testable import Performance

final class SystemStatsTests: XCTestCase {
    func testCPUUsageTotal() {
        let cpu = CPUStats(user: 30, system: 20, idle: 45, nice: 5)
        XCTAssertEqual(cpu.totalUsage, 55.0, accuracy: 0.1)
    }

    func testCPUZero() {
        let cpu = CPUStats.zero
        XCTAssertEqual(cpu.totalUsage, 0.0, accuracy: 0.1)
        XCTAssertEqual(cpu.idle, 100.0, accuracy: 0.1)
    }

    func testMemoryUsedPercentage() {
        let mem = MemoryStats(
            used: 8 * 1024 * 1024 * 1024,
            wired: 2 * 1024 * 1024 * 1024,
            compressed: 1 * 1024 * 1024 * 1024,
            free: 8 * 1024 * 1024 * 1024,
            total: 16 * 1024 * 1024 * 1024
        )
        XCTAssertEqual(mem.usedPercentage, 50.0, accuracy: 0.1)
    }

    func testMemoryZeroTotal() {
        let mem = MemoryStats(used: 0, wired: 0, compressed: 0, free: 0, total: 0)
        XCTAssertEqual(mem.usedPercentage, 0.0, accuracy: 0.1)
    }

    func testProcessInfoDisplay() {
        let proc = ProcessStats(pid: 123, name: "Safari", cpuUsage: 12.5, memoryBytes: 500_000_000)
        XCTAssertEqual(proc.id, 123)
        XCTAssertFalse(proc.memoryFormatted.isEmpty)
    }
}

final class SystemMonitorTests: XCTestCase {
    func testCPUStatsArePopulated() {
        let monitor = SystemMonitor()
        // Need two refreshes for delta calculation
        monitor.refreshCPU()
        Thread.sleep(forTimeInterval: 0.1)
        monitor.refreshCPU()

        let total = monitor.cpu.user + monitor.cpu.system + monitor.cpu.idle + monitor.cpu.nice
        XCTAssertGreaterThan(total, 0, "CPU ticks should be populated after two samples")
    }

    func testMemoryStatsArePopulated() {
        let monitor = SystemMonitor()
        monitor.refreshMemory()

        XCTAssertGreaterThan(monitor.memory.total, 0, "Total memory should be > 0")
        XCTAssertGreaterThan(monitor.memory.used, 0, "Used memory should be > 0")
        XCTAssertLessThanOrEqual(monitor.memory.used, monitor.memory.total)
    }
}
