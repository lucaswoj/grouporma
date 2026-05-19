import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct TokenDrag: Codable, Transferable {
    let id: UUID
    let sourceZone: Vote
    let categoryID: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

struct DropZoneView: View {
    let zone: Vote
    let category: Category
    let tokens: [UUID]
    var onTap: () -> Void
    var onDrop: (TokenDrag) -> Bool

    @State private var isTargeted = false

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
                    DraggableTokenSource(
                        payload: TokenDrag(id: id, sourceZone: zone, categoryID: category.id),
                        tint: tint,
                        size: 36
                    )
                    .frame(width: 36, height: 36)
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
                    isTargeted ? tint : tint.opacity(0.35),
                    lineWidth: isTargeted ? 2.5 : 1
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onDrop(
            of: [UTType.data.identifier],
            delegate: ZoneDropDelegate(
                onDrop: onDrop,
                onTargeted: { isTargeted = $0 }
            )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isTargeted)
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

// Drop delegate that proposes a .move operation so the system suppresses the
// green plus "copy" badge during the drag preview.
struct ZoneDropDelegate: DropDelegate {
    let onDrop: (TokenDrag) -> Bool
    let onTargeted: (Bool) -> Void

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [UTType.data.identifier])
    }

    func dropEntered(info: DropInfo) { onTargeted(true) }
    func dropExited(info: DropInfo) { onTargeted(false) }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        onTargeted(false)
        guard let provider = info.itemProviders(for: [UTType.data.identifier]).first else {
            return false
        }
        provider.loadDataRepresentation(forTypeIdentifier: UTType.data.identifier) { data, _ in
            guard let data, let drag = try? JSONDecoder().decode(TokenDrag.self, from: data) else { return }
            DispatchQueue.main.async {
                _ = onDrop(drag)
            }
        }
        return true
    }
}

// Hosts a SwiftUI TokenView inside a UIView so we can attach a UIDragInteraction
// whose underlying long-press recognizer has a shorter minimumPressDuration than
// SwiftUI's .draggable allows (default is ~0.5s for scroll disambiguation).
struct DraggableTokenSource: UIViewRepresentable {
    let payload: TokenDrag
    let tint: Color
    let size: CGFloat
    var pressDuration: TimeInterval = 0.1

    func makeCoordinator() -> Coordinator { Coordinator(payload: payload) }

    func makeUIView(context: Context) -> DragHostView {
        let view = DragHostView(tint: tint, size: size, pressDuration: pressDuration)
        let interaction = UIDragInteraction(delegate: context.coordinator)
        interaction.isEnabled = true
        view.addInteraction(interaction)
        return view
    }

    func updateUIView(_ uiView: DragHostView, context: Context) {
        context.coordinator.payload = payload
    }

    final class Coordinator: NSObject, UIDragInteractionDelegate {
        var payload: TokenDrag

        init(payload: TokenDrag) { self.payload = payload }

        func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
            let snapshot = payload
            let provider = NSItemProvider()
            provider.registerDataRepresentation(forTypeIdentifier: UTType.data.identifier, visibility: .ownProcess) { completion in
                do {
                    completion(try JSONEncoder().encode(snapshot), nil)
                } catch {
                    completion(nil, error)
                }
                return nil
            }
            let item = UIDragItem(itemProvider: provider)
            item.localObject = snapshot
            return [item]
        }

        func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
            guard let view = interaction.view else { return nil }
            let params = UIDragPreviewParameters()
            params.visiblePath = UIBezierPath(ovalIn: view.bounds)
            params.backgroundColor = .clear
            return UITargetedDragPreview(view: view, parameters: params)
        }
    }
}

final class DragHostView: UIView {
    let pressDuration: TimeInterval
    private let tokenSize: CGFloat
    private let hosting: UIHostingController<TokenView>

    init(tint: Color, size: CGFloat, pressDuration: TimeInterval) {
        self.pressDuration = pressDuration
        self.tokenSize = size
        self.hosting = UIHostingController(rootView: TokenView(tint: tint, size: size))
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        backgroundColor = .clear
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            hosting.view.centerYAnchor.constraint(equalTo: centerYAnchor),
            hosting.view.widthAnchor.constraint(equalToConstant: size),
            hosting.view.heightAnchor.constraint(equalToConstant: size),
        ])
    }

    required init?(coder: NSCoder) { fatalError("unsupported") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: tokenSize, height: tokenSize)
    }

    // UIDragInteraction installs a UILongPressGestureRecognizer on this view to
    // gate the drag lift. Catch each one as it's added and shorten the press
    // duration so drags initiate faster than the iOS default.
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        super.addGestureRecognizer(gestureRecognizer)
        if let press = gestureRecognizer as? UILongPressGestureRecognizer {
            press.minimumPressDuration = pressDuration
        }
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
