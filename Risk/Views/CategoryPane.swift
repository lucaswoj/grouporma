import SwiftUI

struct CategoryPane: View {
    let category: Category
    let isLast: Bool
    @Binding var selection: Int
    let paneIndex: Int
    @Environment(PersistentStore.self) private var store

    var body: some View {
        let state = store.state
        let catScore = state.score(for: category)
        let catGAR = ScoreColor.gar(forCategory: catScore)

        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 12) {
                    Text(category.title)
                        .font(.largeTitle.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer(minLength: 8)
                    ScoreCircle(value: catScore, gar: catGAR, size: 44)
                }
                Text(category.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            VStack(spacing: 10) {
                ForEach(Vote.allCases) { zone in
                    DropZoneView(
                        zone: zone,
                        category: category,
                        tokens: state.tokens(in: category, zone: zone),
                        onTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                state.tapMove(in: category, to: zone)
                            }
                        },
                        onDrop: { id in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                state.move(tokenID: id, in: category, to: zone)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 12)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    selection = paneIndex + 1
                }
            } label: {
                Label(isLast ? "See results" : "Next", systemImage: "chevron.right")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    CategoryPane(category: Category.all[0], isLast: false, selection: .constant(1), paneIndex: 1)
        .environment(PersistentStore())
}
