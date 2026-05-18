import SwiftUI

struct SummaryPane: View {
    @Environment(PersistentStore.self) private var store
    @Binding var selection: Int
    @State private var showResetConfirm = false

    var body: some View {
        let state = store.state
        let total = state.overallScore
        let gar = state.overallGAR

        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Overall Score")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    HStack(spacing: 18) {
                        Text("\(total)")
                            .font(.system(size: 84, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        Image(systemName: gar.vote.symbolName)
                            .font(.system(size: 72, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .rotationEffect(gar.vote.symbolRotation)
                    }
                    .foregroundStyle(gar.color)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(gar.color.opacity(0.14), in: .rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(gar.color.opacity(0.35), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)

                VStack(spacing: 0) {
                    ForEach(Category.all) { cat in
                        let s = state.score(for: cat)
                        let g = ScoreColor.gar(forCategory: s)
                        HStack(spacing: 12) {
                            Text(cat.title)
                                .font(.body)
                            Spacer()
                            ScoreCapsule(value: s, gar: g, height: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        if cat.id != Category.all.last?.id {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(.regularMaterial, in: .rect(cornerRadius: 16))
                .padding(.horizontal, 20)

                HStack(spacing: 10) {
                    ShareLink(
                        item: state.shareString(),
                        subject: Text("ORMA results"),
                        message: Text("Group ORMA assessment from Risk")
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 56)
                .confirmationDialog("Start a new assessment?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                    Button("Reset", role: .destructive) {
                        store.newAssessment()
                        withAnimation { selection = 0 }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Clears all current votes and returns to the Start pane.")
                }
            }
        }
    }
}

#Preview {
    SummaryPane(selection: .constant(9))
        .environment(PersistentStore())
}
