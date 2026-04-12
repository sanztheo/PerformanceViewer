import SwiftUI

struct ProcessRowView: View {
    let process: ProcessStats
    let rank: Int

    var body: some View {
        HStack(spacing: 8) {
            Text("\(rank)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(width: 16, alignment: .trailing)

            Text(process.name)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Text(process.memoryFormatted)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 1)
    }
}
