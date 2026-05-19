import SwiftUI

struct StartPane: View {
    @Environment(PersistentStore.self) private var store
    @Binding var selection: Int

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)

            VStack(alignment: .leading, spacing: 12) {
                Text("Group ORMA")
                    .font(.largeTitle.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("This Operational Risk Management Assessment (ORMA) structures a group review of 8 risk categories. The aggregate score informs the go / no-go decision, but the discussion is what surfaces concerns the score alone cannot capture.\n\nFor each category, count to 3 so everyone votes simultaneously. This prevents anchoring on whoever speaks first.\n\nAny thumbs-down vote pauses the assessment. Record the specific concern and the planned mitigation before continuing.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 10) {
                Text("Participants")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                HStack(spacing: 24) {
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
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 32)
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
            .padding(.horizontal, 20)

            Spacer()

            Button {
                withAnimation { selection = 1 }
            } label: {
                Text("Begin")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .padding(.bottom, 56)
        }
    }
}

#Preview {
    StartPane(selection: .constant(0))
        .environment(PersistentStore())
}
