import SwiftUI

enum GAR: String, Codable {
    case green
    case amber
    case red

    var label: String {
        switch self {
        case .green: "Green"
        case .amber: "Amber"
        case .red: "Red"
        }
    }

    var color: Color {
        switch self {
        case .green: Color.green
        case .amber: Color.orange
        case .red: Color.red
        }
    }

    var vote: Vote {
        switch self {
        case .green: .up
        case .amber: .sideways
        case .red: .down
        }
    }
}

enum ScoreColor {
    // Per-category band on the 1-10 scale, matching the standard NPS/USCG GAR
    // proportions scaled down (0-23/24-44/45-60 of 60 -> roughly 1-4/5-7/8-10).
    static func gar(forCategory score: Int) -> GAR {
        switch score {
        case ...4: .green
        case 5...7: .amber
        default: .red
        }
    }

    // Overall is the sum of 8 category averages (range 8-80). Thresholds are
    // the USCG 0-23/24-44/45-60 bands scaled from /60 to /80.
    static func gar(forOverall score: Int) -> GAR {
        switch score {
        case ...31: .green
        case 32...58: .amber
        default: .red
        }
    }
}
