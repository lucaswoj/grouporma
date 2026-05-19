import SwiftUI

struct CategoryPane: View {
    let category: Category
    let isLast: Bool
    @Binding var selection: Int
    let paneIndex: Int
    @Environment(PersistentStore.self) private var store
    @FocusState private var notesFocused: Bool
    @State private var dragSource: Vote? = nil
    @State private var dragTokenID: UUID? = nil
    @State private var dragLocation: CGPoint? = nil
    @State private var zoneFrames: [Vote: CGRect] = [:]
    // When non-nil, this token is rendered as an overlay at dragLocation
    // (outside any DropZone) so matchedGeometryEffect can start from the exact release point.
    @State private var flyingToken: (zone: Vote, id: UUID, tint: Color)? = nil

    private var hoveredZone: Vote? {
        guard dragSource != nil, let loc = dragLocation else { return nil }
        return zoneFrames.first { $0.value.contains(loc) }?.key
    }

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(category.title)
                        .font(.largeTitle.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(category.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ZStack(alignment: .topLeading) {
                    VStack(spacing: 10) {
                        ForEach(Vote.allCases) { zone in
                            DropZoneView(
                                zone: zone,
                                category: category,
                                tokens: store.state.tokens(in: category, zone: zone),
                                hiddenTokenID: flyingToken?.zone == zone ? flyingToken?.id : nil,
                                isHoverTarget: hoveredZone == zone && dragSource != zone,
                                onTap: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        store.state.tapMove(in: category, to: zone)
                                    }
                                },
                                onTokenDragStart: { id in
                                    dragSource = zone
                                    dragTokenID = id
                                    let tint: Color = {
                                        switch zone {
                                        case .up: return .green
                                        case .sideways: return .orange
                                        case .down: return .red
                                        }
                                    }()
                                    flyingToken = (zone, id, tint)
                                },
                                onTokenDragChanged: { location in dragLocation = location },
                                onTokenDragEnded: { location in
                                    let target = zoneFrames.first { $0.value.contains(location) }?.key
                                    let source = dragSource
                                    let id = dragTokenID
                                    dragSource = nil
                                    dragTokenID = nil
                                    guard let target, let source, let id, source != target else {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                            flyingToken = nil
                                            dragLocation = nil
                                        }
                                        return false
                                    }
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        store.state.move(in: category, from: source, to: target, tokenID: id)
                                        flyingToken = nil
                                        dragLocation = nil
                                    }
                                    return true
                                }
                            )
                        }
                    }

                    if let flying = flyingToken, let loc = dragLocation {
                        TokenView(tint: flying.tint, size: 36)
                            .scaleEffect(1.18)
                            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                            .position(loc)
                            .zIndex(200)
                            .allowsHitTesting(false)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .coordinateSpace(.named("zones"))
                .onPreferenceChange(ZoneFramesKey.self) { frames in
                    zoneFrames = frames
                }

                TextField(
                    "Notes",
                    text: Binding(
                        get: { store.state.notes[category.id] ?? "" },
                        set: { store.state.notes[category.id] = $0 }
                    ),
                    axis: .vertical
                )
                .lineLimit(1...3)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .focused($notesFocused)
                .padding(.horizontal, 20)

                Button {
                    notesFocused = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = paneIndex + 1
                    }
                } label: {
                    Text(isLast ? "See results" : "Next")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                .padding(.bottom, 56)
                .id("bottom")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: notesFocused) { _, focused in
            if focused {
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
        }
    }
}

#Preview {
    CategoryPane(category: Category.all[0], isLast: false, selection: .constant(1), paneIndex: 1)
        .environment(PersistentStore())
}
