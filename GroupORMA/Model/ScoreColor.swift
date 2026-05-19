import SwiftUI

enum RiskBand: String, Codable {
    case low
    case medium
    case high
    case extreme

    var label: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .extreme: "Extremely High"
        }
    }

    var color: Color {
        switch self {
        case .low: Color.green
        case .medium: Color.yellow
        case .high: Color.orange
        case .extreme: Color.red
        }
    }

    var iconName: String {
        switch self {
        case .low, .medium: "hand.thumbsup.fill"
        case .high: "hand.thumbsdown.fill"
        case .extreme: "exclamationmark.octagon.fill"
        }
    }

    var iconRotation: Angle {
        switch self {
        case .medium: .degrees(90)
        case .low, .high, .extreme: .zero
        }
    }

    // The thumb symbols are fully filled, so .hierarchical reads at full
    // weight. The danger octagon has thin outline ink that .hierarchical
    // pushes to a secondary opacity, leaving only the exclamation mark
    // looking bold and making the icon read lighter than the thumbs.
    // .monochrome keeps the whole octagon at full ink so it matches.
    var iconRenderingMode: SymbolRenderingMode {
        switch self {
        case .low, .medium, .high: .hierarchical
        case .extreme: .monochrome
        }
    }

    var iconWeight: Font.Weight {
        switch self {
        case .low, .medium, .high: .semibold
        case .extreme: .heavy
        }
    }
}

enum ScoreColor {
    // Per-category band on the 1-10 scale. Thresholds are the NPS RM-50B
    // Table C-2 overall bands (8-35 / 36-60 / 61-70 / 71-80) divided by 8
    // and rounded to natural breakpoints: 1-4 / 5-7 / 8 / 9-10.
    static func band(forCategory score: Int) -> RiskBand {
        switch score {
        case ...4: .low
        case 5...7: .medium
        case 8: .high
        default: .extreme
        }
    }

    // Overall is the sum of 8 category averages (range 8-80). Thresholds
    // match NPS RM-50B Table C-2 verbatim.
    static func band(forOverall score: Int) -> RiskBand {
        switch score {
        case ...35: .low
        case 36...60: .medium
        case 61...70: .high
        default: .extreme
        }
    }
}
