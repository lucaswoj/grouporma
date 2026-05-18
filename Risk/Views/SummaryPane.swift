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
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("ORMA Result")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text("\(total)")
                        .font(.system(size: 96, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .foregroundStyle(gar.color.mix(with: .primary, by: 0.4))
                    Text(gar.label)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .background(gar.color, in: .capsule)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(gar.color.opacity(0.14), in: .rect(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(gar.color.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)

                VStack(spacing: 0) {
                    ForEach(Category.all) { cat in
                        let s = state.score(for: cat)
                        let g = ScoreColor.gar(forCategory: s)
                        HStack {
                            Circle()
                                .fill(g.color)
                                .frame(width: 10, height: 10)
                            Text(cat.title)
                                .font(.body)
                            Spacer()
                            Text("\(s)")
                                .font(.body.weight(.semibold))
                                .monospacedDigit()
                                .frame(minWidth: 32, alignment: .trailing)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        if cat.id != Category.all.last?.id {
                            Divider().padding(.leading, 18)
                        }
                    }
                }
                .background(.regularMaterial, in: .rect(cornerRadius: 18))
                .padding(.horizontal, 20)

                ShareLink(
                    item: state.shareString(),
                    subject: Text("ORMA results"),
                    message: Text("Group ORMA assessment from Risk")
                ) {
                    Label("Share results", systemImage: "square.and.arrow.up")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                .padding(.top, 4)

                Button(role: .destructive) {
                    showResetConfirm = true
                } label: {
                    Label("New assessment", systemImage: "arrow.counterclockwise")
                        .font(.body.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal, 20)
                .padding(.bottom, 80)
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
