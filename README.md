<p align="center">
  <img src="https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png" width="80" alt="SwiftUI icon"/>
</p>

<h1 align="center">Performance Viewer</h1>

<p align="center">
  <strong>A lightweight macOS menu bar utility for real-time system monitoring.</strong><br/>
  <em>CPU · Memory · Disk · Battery · Thermal · Top Processes</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2015%2B-blue?logo=apple&logoColor=white" alt="macOS 15+"/>
  <img src="https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white" alt="Swift 5"/>
  <img src="https://img.shields.io/badge/UI-SwiftUI-007AFF?logo=swift&logoColor=white" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/dependencies-zero-2ea44f" alt="Zero dependencies"/>
  <img src="https://img.shields.io/github/license/sanztheo/PerformanceViewer" alt="License"/>
  <img src="https://img.shields.io/github/stars/sanztheo/PerformanceViewer?style=social" alt="Stars"/>
</p>

---

## Why?

macOS Activity Monitor is powerful but heavy. Third-party monitors are bloated with features you don't need. **Performance Viewer** gives you the essentials — always visible in your menu bar, one click away from details, zero background overhead.

## Features

| | Feature | Description |
|---|---------|-------------|
| 📊 | **Menu Bar Summary** | CPU %, RAM, battery/thermal, disk — compact monospaced label, always visible |
| 🎛️ | **Interactive Popover** | 2×2 card grid with color-coded progress bars and click-to-expand details |
| 🧠 | **CPU Breakdown** | User / System / Idle / Nice with proportional bars |
| 💾 | **Memory Details** | Active / Wired / Compressed / Free breakdown |
| 💿 | **Disk Usage** | Used / Free / Total in GB (base 10, matching Finder) |
| 🔋 | **Energy & Battery** | Thermal state, power source, charge level, charging status |
| 📋 | **Top 10 Processes** | Ranked by resident memory with formatted sizes |
| 🚀 | **Launch at Login** | One toggle, powered by `SMAppService` |
| 🔗 | **Activity Monitor** | Quick link to open macOS Activity Monitor |

## How It Works

Performance Viewer runs as a **menu bar agent** (no Dock icon, no main window). A background timer refreshes all metrics every **2 seconds** using low-level macOS APIs:

| Metric | API | Notes |
|--------|-----|-------|
| CPU | `host_processor_info` | Delta between samples for accurate percentages |
| Memory | `host_statistics64` | Formula aligned with Activity Monitor / fastfetch |
| Disk | `URL.resourceValues` | Uses `volumeAvailableCapacityForImportantUsage` like Finder |
| Battery | `IOPSCopyPowerSourcesInfo` | IOKit power source enumeration |
| Thermal | `ProcessInfo.thermalState` | Nominal → Fair → Serious → Critical |
| Processes | `proc_listallpids` + `proc_pidinfo` | Top 10 by RSS, updated live |

## Architecture

```
Performance/
├── PerformanceApp.swift                 # @main — MenuBarExtra scene + login item
├── Models/
│   └── SystemStats.swift                # Sendable value types with computed formatting
├── Services/
│   └── SystemMonitor.swift              # @Observable — Mach, proc_*, IOKit collection
└── Views/
    ├── MenuBarPopover.swift              # Main UI — stats grid, details, processes, footer
    └── Components/
        ├── ProcessRowView.swift          # Process row with rank, name, memory
        └── GaugeRingView.swift           # Reusable circular gauge component
```

**Design principles:**
- Pure SwiftUI with `@Observable` (Swift Observation framework)
- Zero third-party dependencies — only Apple frameworks
- `Sendable` models for thread safety
- Color thresholds adapt to load (green → orange → red)

## Requirements

- **macOS 15.0** (Sequoia) or later
- **Xcode 16+** to build
- App Sandbox disabled (required for `proc_pidinfo`, IOKit, and Mach APIs)

## Build & Run

```bash
git clone https://github.com/sanztheo/PerformanceViewer.git
cd PerformanceViewer/Performance
open Performance.xcodeproj
```

Press **⌘R** in Xcode. The app appears in your menu bar.

## Contributing

Contributions are welcome! Some ideas:

- [ ] Per-process CPU usage tracking
- [ ] Network throughput monitoring
- [ ] GPU utilization (Metal Performance HUD)
- [ ] Configurable refresh interval
- [ ] Sparkline history graphs in the popover
- [ ] Notification alerts for high usage thresholds

## License

[MIT](LICENSE)

---

<p align="center">
  <sub>Built with SwiftUI · No dependencies · Open source</sub>
</p>
