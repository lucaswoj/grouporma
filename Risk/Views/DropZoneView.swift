import SwiftUI

struct DropZoneView: View {
    let zone: Vote
    let category: Category
    let tokens: [Token]
    var onTap: () -> Void
    var onDrop: (UUID) -> Void

    @State private var isTargeted = false
    @State private var isPressed = false
    @Namespace private var tokenNamespace

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: zone.symbolName)
                        .font(.title3.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                        .rotationEffect(zone.symbolRotation)
                    Text(zone.label)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(tokens.count)")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(tint.opacity(0.18), in: .capsule)
                }
                .foregroundStyle(tint)

                tokenStrip
                    .frame(height: 84, alignment: .topLeading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(tint.opacity(isPressed ? 0.28 : 0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isTargeted ? tint : tint.opacity(0.35),
                        style: StrokeStyle(lineWidth: isTargeted ? 2.5 : 1, dash: isTargeted ? [] : [])
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isTargeted)
        }
        .buttonStyle(PressedStyle(isPressed: $isPressed))
        .dropDestination(for: String.self) { items, _ in
            guard let raw = items.first, let id = UUID(uuidString: raw) else { return false }
            onDrop(id)
            return true
        } isTargeted: { isTargeted = $0 }
        .sensoryFeedback(.impact(weight: .light), trigger: tokens.count)
    }

    private var tint: Color {
        switch zone {
        case .up: .green
        case .sideways: .orange
        case .down: .red
        }
    }

    private var tokenStrip: some View {
        FlowLayout(spacing: 8) {
            ForEach(tokens) { token in
                TokenView(tint: tint, size: 36)
                    .draggable(token.id.uuidString)
                    .matchedGeometryEffect(id: token.id, in: tokenNamespace)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

private struct PressedStyle: ButtonStyle {
    @Binding var isPressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, new in isPressed = new }
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
