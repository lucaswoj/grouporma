import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(PersistentStore.self) private var store
    @State private var selection: Int = 0
    @State private var keyboardVisible = false

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
            if !keyboardVisible {
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
                .transition(.opacity)
            }
        }
        .onChange(of: store.state.votes) { _, _ in store.save() }
        .onChange(of: store.state.participantCount) { _, _ in store.save() }
        .onChange(of: store.state.notes) { _, _ in store.save() }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) { keyboardVisible = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) { keyboardVisible = false }
        }
    }
}

#Preview {
    ContentView()
        .environment(PersistentStore())
}
