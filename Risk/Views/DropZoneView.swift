import SwiftUI

struct DropZoneView: View {
    let zone: Vote
    let category: Category
    let count: Int
    var onTap: () -> Void
    var onDrop: (Vote) -> Void

    @State private var isTargeted = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: zone.symbolName)
                        .font(.subheadline.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                        .rotationEffect(zone.symbolRotation)
                    Text(zone.label)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("^[\(count) vote](inflect: true)")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .opacity(0.7)
                }
                .foregroundStyle(tint)

                FlowLayout(spacing: 8) {
                    ForEach(0..<count, id: \.self) { _ in
                        TokenView(tint: tint, size: 36)
                            .draggable(zone.rawValue)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 84, alignment: .topLeading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(DropZoneButtonStyle(tint: tint, isTargeted: isTargeted))
        .dropDestination(for: String.self) { items, _ in
            guard let raw = items.first, let source = Vote(rawValue: raw) else { return false }
            onDrop(source)
            return true
        } isTargeted: { isTargeted = $0 }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isTargeted)
        .sensoryFeedback(.impact(weight: .light), trigger: count)
    }

    private var tint: Color {
        switch zone {
        case .up: .green
        case .sideways: .orange
        case .down: .red
        }
    }
}

private struct DropZoneButtonStyle: ButtonStyle {
    let tint: Color
    let isTargeted: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(tint.opacity(configuration.isPressed ? 0.28 : 0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isTargeted ? tint : tint.opacity(0.35),
                        lineWidth: isTargeted ? 2.5 : 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += sz.width + spacing
            rowHeight = max(rowHeight, sz.height)
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: sz.width, height: sz.height))
            x += sz.width + spacing
            rowHeight = max(rowHeight, sz.height)
        }
    }
}
