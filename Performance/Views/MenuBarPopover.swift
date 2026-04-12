import SwiftUI

struct MenuBarPopover: View {
    let monitor: SystemMonitor

    @State private var selectedTab: Tab = .overview

    enum Tab: String, CaseIterable {
        case overview = "Vue d'ensemble"
        case cpu = "CPU"
        case memory = "Mémoire"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            Picker("", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(8)

            ScrollView {
                switch selectedTab {
                case .overview:
                    overviewTab
                case .cpu:
                    cpuDetailTab
                case .memory:
                    memoryDetailTab
                }
            }

            Divider()
            footer
        }
        .frame(width: 320)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 24) {
            GaugeRingView(
                value: monitor.cpu.totalUsage,
                label: "CPU",
                color: .blue
            )
            GaugeRingView(
                value: monitor.memory.usedPercentage,
                label: "MEM",
                color: .orange
            )
        }
        .padding(16)
    }

    // MARK: - Overview Tab

    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top Processes (par mémoire)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)

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
        .padding(.vertical, 8)
    }

    // MARK: - CPU Detail Tab

    private var cpuDetailTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            statRow("Utilisateur", value: String(format: "%.1f%%", monitor.cpu.user))
            statRow("Système", value: String(format: "%.1f%%", monitor.cpu.system))
            statRow("Inactif", value: String(format: "%.1f%%", monitor.cpu.idle))
            if monitor.cpu.nice > 0.1 {
                statRow("Nice", value: String(format: "%.1f%%", monitor.cpu.nice))
            }
        }
        .padding(12)
    }

    // MARK: - Memory Detail Tab

    private var memoryDetailTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            statRow("Utilisée", value: monitor.memory.usedFormatted)
            statRow("Wired", value: ByteCountFormatter.string(
                fromByteCount: Int64(monitor.memory.wired), countStyle: .memory))
            statRow("Compressée", value: ByteCountFormatter.string(
                fromByteCount: Int64(monitor.memory.compressed), countStyle: .memory))
            statRow("Libre", value: ByteCountFormatter.string(
                fromByteCount: Int64(monitor.memory.free), countStyle: .memory))
            Divider()
            statRow("Total", value: monitor.memory.totalFormatted)
        }
        .padding(12)
    }

    // MARK: - Footer

    private var footer: some View {
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
        .padding(10)
    }

    // MARK: - Helpers

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }
}
