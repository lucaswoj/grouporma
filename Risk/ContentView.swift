import SwiftUI

struct ContentView: View {
    @Environment(PersistentStore.self) private var store
    @State private var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            StartPane(selection: $selection)
                .tag(0)

            ForEach(Array(Category.all.enumerated()), id: \.element.id) { index, category in
                CategoryPane(
                    category: category,
                    isLast: index == Category.all.count - 1,
                    selection: $selection,
                    paneIndex: index + 1
                )
                .tag(index + 1)
            }

            SummaryPane(selection: $selection)
                .tag(Category.all.count + 1)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea(.keyboard)
        .onChange(of: store.state.votes) { _, _ in store.save() }
        .onChange(of: store.state.participantCount) { _, _ in store.save() }
    }
}

#Preview {
    ContentView()
        .environment(PersistentStore())
}
