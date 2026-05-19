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
    @Namespace private var tokenNamespace

    private var hoveredZone: Vote? {
        guard let loc = dragLocation else { return nil }
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

                VStack(spacing: 10) {
                    ForEach(Vote.allCases) { zone in
                        DropZoneView(
                            zone: zone,
                            category: category,
                            tokens: store.state.tokens(in: category, zone: zone),
                            namespace: tokenNamespace,
                            isHoverTarget: hoveredZone == zone && dragSource != zone,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    store.state.tapMove(in: category, to: zone)
                                }
                            },
                            onTokenDragStart: { id in
                                dragSource = zone
                                dragTokenID = id
                            },
                            onTokenDragChanged: { location in dragLocation = location },
                            onTokenDragEnded: { location in
                                let target = zoneFrames.first { $0.value.contains(location) }?.key
                                let source = dragSource
                                let id = dragTokenID
                                dragSource = nil
                                dragTokenID = nil
                                dragLocation = nil
                                guard let target, let source, let id, source != target else {
                                    return false
                                }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    store.state.move(in: category, from: source, to: target, tokenID: id)
                                }
                                return true
                            }
                        )
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
