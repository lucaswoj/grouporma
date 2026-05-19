import SwiftUI

struct DropZoneView: View {
    let zone: Vote
    let category: Category
    let tokens: [UUID]
    var hiddenTokenID: UUID? = nil
    let namespace: Namespace.ID
    let isHoverTarget: Bool
    var onTap: () -> Void
    var onTokenDragStart: (UUID) -> Void
    var onTokenDragChanged: (CGPoint) -> Void
    var onTokenDragEnded: (CGPoint) -> Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: zone.symbolName)
                    .font(.subheadline.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .rotationEffect(zone.symbolRotation)
                Text(zone.label)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("^[\(tokens.count) vote](inflect: true)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .opacity(0.7)
            }
            .foregroundStyle(tint)

            FlowLayout(spacing: 8) {
                ForEach(tokens, id: \.self) { id in
                    DraggableToken(
                        id: id,
                        namespace: namespace,
                        tint: tint,
                        isGeometrySource: id != hiddenTokenID,
                        onStart: onTokenDragStart,
                        onChanged: onTokenDragChanged,
                        onEnded: onTokenDragEnded
                    )
                    .opacity(id == hiddenTokenID ? 0 : 1)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 84, alignment: .topLeading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(tint.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isHoverTarget ? tint : tint.opacity(0.35),
                    lineWidth: isHoverTarget ? 2.5 : 1
                )
        )
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: ZoneFramesKey.self,
                    value: [zone: geo.frame(in: .named("zones"))]
                )
            }
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isHoverTarget)
        .sensoryFeedback(.impact(weight: .light), trigger: tokens.count)
    }

    private var tint: Color {
        switch zone {
        case .up: .green
        case .sideways: .orange
        case .down: .red
        }
    }
}

private struct DraggableToken: View {
    let id: UUID
    let namespace: Namespace.ID
    let tint: Color
    var isGeometrySource: Bool = true
    var onStart: (UUID) -> Void
    var onChanged: (CGPoint) -> Void
    var onEnded: (CGPoint) -> Bool

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    var body: some View {
        TokenView(tint: tint, size: 36)
            .scaleEffect(isDragging ? 1.18 : 1.0)
            .shadow(color: .black.opacity(isDragging ? 0.25 : 0),
                    radius: isDragging ? 8 : 0,
                    y: isDragging ? 4 : 0)
            .offset(dragOffset)
            .zIndex(isDragging ? 100 : 0)
            .matchedGeometryEffect(id: id, in: namespace, isSource: isGeometrySource)
            .gesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .named("zones"))
                    .onChanged { value in
                        if !isDragging {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                isDragging = true
                            }
                            onStart(id)
                        }
                        dragOffset = value.translation
                        onChanged(value.location)
                    }
                    .onEnded { value in
                        let didMove = onEnded(value.location)
                        if didMove {
                            // The token is moving to another zone. Its view in the
                            // source zone is removed and matchedGeometryEffect on
                            // the new view in the target zone animates from this
                            // view's drag-location frame, so we leave dragOffset
                            // alone here.
                            return
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
            )
    }
}

struct ZoneFramesKey: PreferenceKey {
    static var defaultValue: [Vote: CGRect] = [:]
    static func reduce(value: inout [Vote: CGRect], nextValue: () -> [Vote: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
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
