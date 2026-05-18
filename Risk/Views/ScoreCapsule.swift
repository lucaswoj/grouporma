import SwiftUI

struct ScoreCapsule: View {
    let value: Int
    let gar: GAR
    var height: CGFloat = 30

    var body: some View {
        let vote = gar.vote
        HStack(spacing: height * 0.18) {
            Text("\(value)")
                .font(.system(size: height * 0.5, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            Image(systemName: vote.symbolName)
                .font(.system(size: height * 0.48, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .rotationEffect(vote.symbolRotation)
        }
        .foregroundStyle(gar.color)
        .padding(.horizontal, height * 0.34)
        .frame(height: height)
        .background(gar.color.opacity(0.14), in: .capsule)
        .overlay(Capsule().strokeBorder(gar.color.opacity(0.35), lineWidth: 1))
    }
}

#Preview {
    VStack(spacing: 12) {
        ScoreCapsule(value: 1, gar: .green, height: 30)
        ScoreCapsule(value: 6, gar: .amber, height: 40)
        ScoreCapsule(value: 10, gar: .red, height: 48)
    }
    .padding()
}
