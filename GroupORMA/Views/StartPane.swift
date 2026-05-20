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

        Text(
          "We're running an Operational Risk Management Assessment (ORMA). It covers eight risk categories. On each one, we each vote thumbs up, thumbs sideways, or thumbs down. No diagonal thumbs allowed.\n\nFor each category, I'll count to three. We all vote on three. No peeking, and no changes once you've cast your vote.\n\nIf anyone votes thumbs down, we stop and work out a mitigation that moves the vote to a thumbs sideways or thumbs up.\n\nWe'll tally the votes across all categories to produce a final score. That score frames our plan going forward: normal caution, extra caution, or no-go."
        )
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
