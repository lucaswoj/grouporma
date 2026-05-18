import SwiftUI

struct ScoreCapsule: View {
    let value: Int
    let band: RiskBand
    var height: CGFloat = 30

    var body: some View {
        HStack(spacing: height * 0.18) {
            Text("\(value)")
                .font(.system(size: height * 0.5, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            Image(systemName: band.iconName)
                .font(.system(size: height * 0.48, weight: band.iconWeight))
                .symbolRenderingMode(band.iconRenderingMode)
                .rotationEffect(band.iconRotation)
        }
        .foregroundStyle(band.color)
        .padding(.horizontal, height * 0.34)
        .frame(height: height)
        .background(band.color.opacity(0.14), in: .capsule)
        .overlay(Capsule().strokeBorder(band.color.opacity(0.35), lineWidth: 1))
    }
}

#Preview {
    VStack(spacing: 12) {
        ScoreCapsule(value: 1, band: .low, height: 30)
        ScoreCapsule(value: 6, band: .medium, height: 40)
        ScoreCapsule(value: 8, band: .high, height: 44)
        ScoreCapsule(value: 10, band: .extreme, height: 48)
    }
    .padding()
}
