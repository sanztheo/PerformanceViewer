import SwiftUI

struct GaugeRingView: View {
    let value: Double
    let label: String
    let color: Color
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 6)

            Circle()
                .trim(from: 0, to: min(value / 100, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: value)

            VStack(spacing: 1) {
                Text("\(Int(value))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                Text(label)
                    .font(.system(size: size * 0.14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}
