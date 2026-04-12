import Foundation
import Observation

@Observable
final class SystemMonitor {
    var cpu: CPUStats = .zero
    var memory: MemoryStats = .zero
    var topProcesses: [ProcessStats] = []

    private var previousCPUTicks: (user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)?

    // MARK: - CPU

    func refreshCPU() {
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0
        var numCPUs: natural_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &numCPUInfo
        )

        guard result == KERN_SUCCESS, let cpuInfo else { return }

        defer {
            let size = vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<integer_t>.stride)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), size)
        }

        var totalUser: UInt64 = 0
        var totalSystem: UInt64 = 0
        var totalIdle: UInt64 = 0
        var totalNice: UInt64 = 0

        for i in 0..<Int(numCPUs) {
            let offset = Int(CPU_STATE_MAX) * i
            totalUser   += UInt64(cpuInfo[offset + Int(CPU_STATE_USER)])
            totalSystem += UInt64(cpuInfo[offset + Int(CPU_STATE_SYSTEM)])
            totalIdle   += UInt64(cpuInfo[offset + Int(CPU_STATE_IDLE)])
            totalNice   += UInt64(cpuInfo[offset + Int(CPU_STATE_NICE)])
        }

        if let prev = previousCPUTicks {
            let dUser   = Double(totalUser - prev.user)
            let dSystem = Double(totalSystem - prev.system)
            let dIdle   = Double(totalIdle - prev.idle)
            let dNice   = Double(totalNice - prev.nice)
            let total   = dUser + dSystem + dIdle + dNice

            if total > 0 {
                cpu = CPUStats(
                    user:   dUser / total * 100,
                    system: dSystem / total * 100,
                    idle:   dIdle / total * 100,
                    nice:   dNice / total * 100
                )
            }
        }

        previousCPUTicks = (totalUser, totalSystem, totalIdle, totalNice)
    }

    // MARK: - Memory

    func refreshMemory() {
        var stats = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride
        )

        let result = withUnsafeMutablePointer(to: &stats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
            }
        }

        guard result == KERN_SUCCESS else { return }

        let pageSize = UInt64(vm_kernel_page_size)
        let total = ProcessInfo.processInfo.physicalMemory

        let wired      = UInt64(stats.wire_count) * pageSize
        let active      = UInt64(stats.active_count) * pageSize
        let compressed  = UInt64(stats.compressor_page_count) * pageSize
        let used        = active + wired + compressed

        let free = total > used ? total - used : 0

        memory = MemoryStats(
            used: used,
            wired: wired,
            compressed: compressed,
            free: free,
            total: total
        )
    }
}
