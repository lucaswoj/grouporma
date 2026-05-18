import Foundation
import Observation

@Observable
final class PersistentStore {
    static let key = "risk.assessment.v2"

    var state: AssessmentState

    init() {
        if
            let data = UserDefaults.standard.data(forKey: Self.key),
            let decoded = try? JSONDecoder().decode(AssessmentState.self, from: data)
        {
            state = decoded
        } else {
            state = AssessmentState()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    func newAssessment() {
        state = AssessmentState(participantCount: state.participantCount)
        save()
    }
}
