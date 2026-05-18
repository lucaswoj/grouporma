import SwiftUI

struct StartPane: View {
    @Environment(PersistentStore.self) private var store
    @Binding var selection: Int

    var body: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 24)

            VStack(spacing: 12) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.tint)
                Text("Risk")
                    .font(.largeTitle.weight(.bold))
                Text("Group ORMA")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text("ORMA is the team risk assessment used by NPS Search and Rescue. Each person votes thumbs up, sideways, or down on 8 categories. Swipe to begin.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            VStack(spacing: 8) {
                Text("Participants")
                    .font(.headline)
                HStack(spacing: 20) {
                    Button {
                        store.state.setParticipantCount(store.state.participantCount - 1)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 36))
                    }
                    .disabled(store.state.participantCount <= 2)

                    Text("\(store.state.participantCount)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .frame(minWidth: 80)
                        .contentTransition(.numericText())

                    Button {
                        store.state.setParticipantCount(store.state.participantCount + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                    }
                    .disabled(store.state.participantCount >= 12)
                }
                .sensoryFeedback(.selection, trigger: store.state.participantCount)
                Text("2 to 12")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(24)
            .background(.regularMaterial, in: .rect(cornerRadius: 24))
            .padding(.horizontal, 24)

            Spacer()

            Button {
                withAnimation { selection = 1 }
            } label: {
                Label("Begin", systemImage: "chevron.right.circle.fill")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 56)
        }
    }
}

#Preview {
    StartPane(selection: .constant(0))
        .environment(PersistentStore())
}
