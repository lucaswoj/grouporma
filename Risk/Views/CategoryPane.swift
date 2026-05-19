import SwiftUI

struct CategoryPane: View {
    let category: Category
    let isLast: Bool
    @Binding var selection: Int
    let paneIndex: Int
    @Environment(PersistentStore.self) private var store
    @FocusState private var notesFocused: Bool

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
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    store.state.tapMove(in: category, to: zone)
                                }
                            },
                            onDrop: { drag in
                                guard drag.categoryID == category.id, drag.sourceZone != zone else {
                                    return false
                                }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    store.state.move(in: category, from: drag.sourceZone, to: zone, tokenID: drag.id)
                                }
                                return true
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)

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
