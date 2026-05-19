import SwiftUI
import UIKit

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
        .tabViewStyle(.page(indexDisplayMode: .never))
        .overlay(alignment: .bottom) {
            HStack(spacing: 7) {
                ForEach(0..<(Category.all.count + 2), id: \.self) { i in
                    Circle()
                        .fill(i == selection ? Color.primary : Color.primary.opacity(0.25))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(.regularMaterial, in: .capsule)
            .padding(.bottom, 6)
        }
        .onChange(of: selection) { _, _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onChange(of: store.state) { _, _ in store.save() }
    }
}

#Preview {
    ContentView()
        .environment(PersistentStore())
}
