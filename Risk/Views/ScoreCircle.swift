import SwiftUI

struct ScoreCircle: View {
    let value: Int
    let gar: GAR
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            Circle()
                .fill(gar.color.opacity(0.14))
            Circle()
                .strokeBorder(gar.color.opacity(0.35), lineWidth: 1)
            Text("\(value)")
                .font(.system(size: size * 0.46, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(gar.color)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 12) {
        ScoreCircle(value: 1, gar: .green, size: 28)
        ScoreCircle(value: 6, gar: .amber, size: 36)
        ScoreCircle(value: 10, gar: .red, size: 44)
    }
    .padding()
}
