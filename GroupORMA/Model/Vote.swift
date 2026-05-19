import SwiftUI

enum Vote: String, CaseIterable, Codable, Identifiable, Hashable {
    case up
    case sideways
    case down

    var id: String { rawValue }

    var score: Int {
        switch self {
        case .up: 1
        case .sideways: 5
        case .down: 10
        }
    }

    var label: String {
        switch self {
        case .up: "Thumbs up"
        case .sideways: "Thumbs sideways"
        case .down: "Thumbs down"
        }
    }

    var symbolName: String {
        switch self {
        case .up, .sideways: "hand.thumbsup.fill"
        case .down: "hand.thumbsdown.fill"
        }
    }

    var symbolRotation: Angle {
        switch self {
        case .up, .down: .zero
        case .sideways: .degrees(90)
        }
    }
}
