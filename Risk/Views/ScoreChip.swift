import SwiftUI

struct ScoreChip: View {
    let label: String
    let value: Int
    let gar: GAR

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text("\(value)")
                .font(.title2.weight(.bold))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(minWidth: 72)
        .background(gar.color.opacity(0.18), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(gar.color.opacity(0.5), lineWidth: 1)
        )
        .foregroundStyle(gar.color.mix(with: .primary, by: 0.4))
    }
}

extension Color {
    func mix(with other: Color, by amount: Double) -> Color {
        let a = max(0, min(1, amount))
        return Color(
            light: UIColor(self).blended(with: UIColor(other), fraction: a),
            dark: UIColor(self).blended(with: UIColor(other), fraction: a)
        )
    }

    init(light: UIColor, dark: UIColor) {
        self = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}

private extension UIColor {
    func blended(with other: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(
            red: r1 + (r2 - r1) * fraction,
            green: g1 + (g2 - g1) * fraction,
            blue: b1 + (b2 - b1) * fraction,
            alpha: a1 + (a2 - a1) * fraction
        )
    }
}

#Preview {
    HStack {
        ScoreChip(label: "Category", value: 3, gar: .green)
        ScoreChip(label: "Overall", value: 42, gar: .amber)
        ScoreChip(label: "Overall", value: 65, gar: .red)
    }
    .padding()
}
