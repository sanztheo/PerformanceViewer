import ServiceManagement
import SwiftUI

struct MenuBarPopover: View {
    let monitor: SystemMonitor

    @State private var selectedSection: Section?
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    enum Section: Hashable {
        case cpu, memory, disk, energy
    }

    var body: some View {
        VStack(spacing: 0) {
            statsGrid
            Divider()

            if let section = selectedSection {
                detailView(for: section)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                Divider()
            } else {
                processesSection
                Divider()
            }

            footer
        }
        .frame(width: 340)
        .animation(.easeInOut(duration: 0.2), value: selectedSection)
    }

    // MARK: - Stats Grid (toujours visible)

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            statsCard(
                icon: "cpu",
                title: "CPU",
                value: "\(Int(monitor.cpu.totalUsage))%",
                color: cpuColor,
                section: .cpu
            )
            statsCard(
                icon: "memorychip",
                title: "Mémoire",
                value: memoryCardValue,
                color: memoryColor,
                section: .memory
            )
            statsCard(
                icon: "bolt.fill",
                title: "Énergie",
                value: energyCardValue,
                color: energyColor,
                section: .energy
            )
            statsCard(
                icon: "internaldrive",
                title: "Disque",
                value: "\(monitor.disk.usedGB)/\(monitor.disk.totalGB) Go",
                color: diskColor,
                section: .disk
            )
        }
        .padding(12)
    }

    private func statsCard(icon: String, title: String, value: String, color: Color, section: Section) -> some View {
        Button {
            withAnimation {
                selectedSection = selectedSection == section ? nil : section
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .font(.caption)
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if selectedSection == section {
                        Image(systemName: "chevron.up")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.opacity(0.15))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: geo.size.width * progressValue(for: section))
                    }
                }
                .frame(height: 3)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedSection == section ? color.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(selectedSection == section ? 0.3 : 0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Detail Views

    @ViewBuilder
    private func detailView(for section: Section) -> some View {
        ScrollView {
            switch section {
            case .cpu:
                cpuDetail
            case .memory:
                memoryDetail
            case .disk:
                diskDetail
            case .energy:
                energyDetail
            }
        }
        .frame(maxHeight: 200)
    }

    private var cpuDetail: some View {
        VStack(alignment: .leading, spacing: 6) {
            detailHeader("CPU — Répartition")
            barRow("Utilisateur", value: monitor.cpu.user, color: .blue)
            barRow("Système", value: monitor.cpu.system, color: .red)
            barRow("Inactif", value: monitor.cpu.idle, color: .gray)
            if monitor.cpu.nice > 0.1 {
                barRow("Nice", value: monitor.cpu.nice, color: .green)
            }
        }
        .padding(12)
    }

    private var memoryDetail: some View {
        VStack(alignment: .leading, spacing: 6) {
            detailHeader("Mémoire — Répartition")
            memRow("Active", bytes: monitor.memory.active, color: .orange)
            memRow("Wired", bytes: monitor.memory.wired, color: .red)
            memRow("Compressée", bytes: monitor.memory.compressed, color: .yellow)
            memRow("Libre", bytes: monitor.memory.free, color: .green)
            Divider()
            statRow("Total", value: formatGB(monitor.memory.total))
        }
        .padding(12)
    }

    private var diskDetail: some View {
        VStack(alignment: .leading, spacing: 6) {
            detailHeader("Disque — Utilisation")
            statRow("Utilisé", value: "\(monitor.disk.usedGB) Go")
            statRow("Libre", value: "\(monitor.disk.freeGB) Go")
            statRow("Total", value: "\(monitor.disk.totalGB) Go")

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.teal.opacity(0.15))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.teal)
                        .frame(width: geo.size.width * monitor.disk.usedPercentage / 100)
                }
            }
            .frame(height: 8)
            .padding(.top, 4)
        }
        .padding(12)
    }

    private var energyDetail: some View {
        VStack(alignment: .leading, spacing: 6) {
            detailHeader("Énergie")
            statRow("État thermique", value: monitor.energy.thermalLabel)
            statRow("Source", value: monitor.energy.powerSource)
            if let battery = monitor.energy.batteryLevel {
                statRow("Batterie", value: String(format: "%.0f%%", battery))
                if let charging = monitor.energy.isCharging {
                    statRow("Charge", value: charging ? "En charge" : "Sur batterie")
                }
            }
        }
        .padding(12)
    }

    // MARK: - Processes (default view)

    private var processesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Top Processes")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            ForEach(Array(monitor.topProcesses.enumerated()), id: \.element.id) { index, process in
                ProcessRowView(process: process, rank: index + 1)
                    .padding(.horizontal, 12)
            }

            if monitor.topProcesses.isEmpty {
                Text("Chargement...")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 12)
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            Toggle("Lancer au démarrage", isOn: $launchAtLogin)
                .toggleStyle(.switch)
                .font(.caption)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = !newValue
                    }
                }

            HStack {
                Button("Moniteur d'activité") {
                    NSWorkspace.shared.launchApplication("Activity Monitor")
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.blue)

                Spacer()

                Button("Quitter") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(10)
    }

    // MARK: - Helpers

    private func detailHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                withAnimation { selectedSection = nil }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 4)
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }

    private func barRow(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f%%", value))
                    .font(.system(.caption, design: .monospaced))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.15))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * min(value / 100, 1.0))
                }
            }
            .frame(height: 4)
        }
    }

    private func memRow(_ label: String, bytes: UInt64, color: Color) -> some View {
        barRow(label, value: Double(bytes) / Double(max(monitor.memory.total, 1)) * 100, color: color)
    }

    private func formatGB(_ bytes: UInt64) -> String {
        String(format: "%.1f Go", Double(bytes) / 1_073_741_824)
    }

    // MARK: - Colors & Progress

    private var cpuColor: Color {
        let v = monitor.cpu.totalUsage
        return v > 80 ? .red : v > 50 ? .orange : .blue
    }

    private var memoryColor: Color {
        let v = monitor.memory.usedPercentage
        return v > 85 ? .red : v > 65 ? .orange : .orange
    }

    private var diskColor: Color {
        let v = monitor.disk.usedPercentage
        return v > 90 ? .red : v > 75 ? .orange : .teal
    }

    private var energyColor: Color {
        switch monitor.energy.thermalState {
        case 0: return .green
        case 1: return .yellow
        case 2: return .orange
        case 3: return .red
        default: return .green
        }
    }

    private var memoryCardValue: String {
        let usedGB = Double(monitor.memory.used) / 1_073_741_824
        let totalGB = Double(monitor.memory.total) / 1_073_741_824
        return String(format: "%.1f/%.0f Go", usedGB, totalGB)
    }

    private var energyCardValue: String {
        if let battery = monitor.energy.batteryLevel {
            return String(format: "%.0f%%", battery)
        }
        return monitor.energy.thermalLabel
    }

    private func progressValue(for section: Section) -> Double {
        switch section {
        case .cpu: return min(monitor.cpu.totalUsage / 100, 1.0)
        case .memory: return min(monitor.memory.usedPercentage / 100, 1.0)
        case .disk: return min(monitor.disk.usedPercentage / 100, 1.0)
        case .energy:
            if let battery = monitor.energy.batteryLevel {
                return min(battery / 100, 1.0)
            }
            return Double(monitor.energy.thermalState) / 3.0
        }
    }
}
