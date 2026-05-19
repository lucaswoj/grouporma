import SwiftUI

struct SummaryPane: View {
  @Environment(PersistentStore.self) private var store
  @Binding var selection: Int
  @State private var showResetConfirm = false
  @State private var dangerPulse = false

  var body: some View {
    let state = store.state
    let total = state.overallScore
    let band = state.overallBand

    ScrollView {
      VStack(spacing: 16) {
        VStack(spacing: 8) {
          HStack(spacing: 18) {
            Text("\(total)")
              .font(.system(size: 84, weight: .heavy, design: .rounded))
              .monospacedDigit()
              .contentTransition(.numericText())
            Image(systemName: band.iconName)
              .font(.system(size: 72, weight: band.iconWeight))
              .symbolRenderingMode(band.iconRenderingMode)
              .rotationEffect(band.iconRotation)
              .scaleEffect(band == .extreme && dangerPulse ? 1.12 : 1.0)
              .animation(.easeInOut(duration: 0.45), value: dangerPulse)
          }
          .foregroundStyle(band.color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(band.color.opacity(0.14), in: .rect(cornerRadius: 20))
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .strokeBorder(band.color.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .onAppear {
          if band == .extreme {
            dangerPulse = true
          }
        }

        VStack(spacing: 0) {
          ForEach(Category.all) { cat in
            let s = state.score(for: cat)
            let b = ScoreColor.band(forCategory: s)
            let note = (state.notes[cat.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            VStack(alignment: .leading, spacing: 6) {
              HStack(spacing: 12) {
                Text(cat.title)
                  .font(.body)
                Spacer()
                ScoreCapsule(value: s, band: b, height: 30)
              }
              if !note.isEmpty {
                Text(note)
                  .font(.callout.italic())
                  .foregroundStyle(.secondary)
                  .fixedSize(horizontal: false, vertical: true)
              }
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
            message: Text("Group ORMA assessment")
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
        .confirmationDialog(
          "Start a new assessment?", isPresented: $showResetConfirm, titleVisibility: .visible
        ) {
          Button("Reset", role: .destructive) {
            store.newAssessment()
            withAnimation { selection = 0 }
          }
          Button("Cancel", role: .cancel) {}
        } message: {
          Text("Clears all votes and starts a new assessment.")
        }
      }
    }
  }
}

#Preview {
  SummaryPane(selection: .constant(9))
    .environment(PersistentStore())
}
