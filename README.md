<p align="center">
  <img src="https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png" width="80" alt="SwiftUI icon"/>
</p>

<h1 align="center">Performance Viewer</h1>

<p align="center">
  <strong>A lightweight macOS menu bar app for real-time system monitoring.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2015%2B-blue?logo=apple&logoColor=white" alt="macOS 15+"/>
  <img src="https://img.shields.io/badge/Swift-5-orange?logo=swift&logoColor=white" alt="Swift 5"/>
  <img src="https://img.shields.io/badge/UI-SwiftUI-blue?logo=swift&logoColor=white" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/dependencies-zero-brightgreen" alt="Zero dependencies"/>
  <img src="https://img.shields.io/github/license/sanztheo/PerformanceViewer" alt="License"/>
</p>

---

## Overview

**Performance Viewer** lives in your menu bar and gives you a constant, at-a-glance view of your Mac's vital signs — CPU, memory, disk, battery and thermal state — updated every 2 seconds. Click it to reveal a rich popover with detailed breakdowns and the top 10 memory-hungry processes.

No Dock icon. No window clutter. Just the numbers you need, always visible.

## Features

- **Menu Bar Summary** — CPU %, RAM used/total, battery or thermal state, disk usage — all in a compact monospaced label
- **Interactive Popover** — 2×2 card grid with color-coded progress bars and click-to-expand detail panels
- **CPU Breakdown** — User, System, Idle, Nice percentages with visual bars
- **Memory Details** — Active, Wired, Compressed, Free with proportional visualization
- **Disk Usage** — Used / Free / Total in GB (base 10, matching Finder)
- **Energy & Battery** — Thermal state, power source, battery level, charging status
- **Top 10 Processes** — Ranked by resident memory, with formatted sizes
- **Launch at Login** — Toggle via `SMAppService`, auto-registers on first launch
- **Activity Monitor Shortcut** — One-click link to macOS Activity Monitor
- **Native & Lightweight** — Pure SwiftUI + Mach/Darwin APIs, zero third-party dependencies

## Architecture

```
Performance/
├── PerformanceApp.swift              # @main — MenuBarExtra scene
├── Models/
│   └── SystemStats.swift             # CPUStats, MemoryStats, DiskStats, EnergyStats, ProcessStats
├── Services/
│   └── SystemMonitor.swift           # @Observable service — Mach host_info, proc_*, IOKit
└── Views/
    ├── MenuBarPopover.swift           # Main popover UI — grid, details, processes, footer
    └── Components/
        ├── ProcessRowView.swift       # Individual process row
        └── GaugeRingView.swift        # Reusable gauge ring component
```

| Layer | Responsibility |
|-------|---------------|
| **Models** | Sendable value types with computed properties for formatting and derived values |
| **Services** | Low-level system data collection via Mach APIs, `proc_pidinfo`, IOKit power sources |
| **Views** | SwiftUI interface with animated transitions, color-coded thresholds, and responsive layout |

## System APIs Used

| Metric | API |
|--------|-----|
| CPU | `host_processor_info` / `PROCESSOR_CPU_LOAD_INFO` (delta between samples) |
| Memory | `host_statistics64` / `HOST_VM_INFO64` (formula matching Activity Monitor) |
| Disk | `URL.resourceValues` — `volumeTotalCapacity`, `volumeAvailableCapacityForImportantUsage` |
| Battery | `IOPSCopyPowerSourcesInfo` / `IOPSCopyPowerSourcesList` (IOKit) |
| Thermal | `ProcessInfo.thermalState` |
| Processes | `proc_listallpids` / `proc_pidinfo` with `PROC_PIDTASKALLINFO` |

## Requirements

- macOS 15.0+
- Xcode 16+
- App Sandbox disabled (required for process enumeration and IOKit access)

## Build & Run

```bash
git clone https://github.com/sanztheo/PerformanceViewer.git
cd PerformanceViewer/Performance
open Performance.xcodeproj
```

Then hit **⌘R** in Xcode. The app appears in your menu bar — no Dock icon.

## License

MIT

---

<p align="center">
  Built with ❤️ and SwiftUI
</p>
