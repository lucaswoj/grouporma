import SwiftUI

struct TokenView: View {
    let tint: Color
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.95), tint.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Circle()
                .strokeBorder(.white.opacity(0.55), lineWidth: 1.2)
        }
        .frame(width: size, height: size)
        .shadow(color: tint.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HStack {
        TokenView(tint: .green)
        TokenView(tint: .orange)
        TokenView(tint: .red)
    }
    .padding()
}
