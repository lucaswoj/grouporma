import Foundation

struct Category: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String

    static let all: [Category] = [
        Category(
            id: "supervision",
            title: "Supervision",
            description: "Leadership and supervision are actively engaged, involved, and accessible for all teams and personnel. There is a clear chain of command."
        ),
        Category(
            id: "planning",
            title: "Planning",
            description: "There is adequate information and proper planning time. JHAs are current and have been reviewed and signed by all levels. All required equipment, training, and PPE has been provided."
        ),
        Category(
            id: "contingency_resources",
            title: "Contingency Resources",
            description: "Local emergency services can be contacted, available, and respond to the worksite in a reasonable amount of time. Examples: Do you have an emergency evacuation plan?"
        ),
        Category(
            id: "communication",
            title: "Communication",
            description: "There is established two-way communication throughout the area of operations. Radios should always be your primary means of communication. You should know your area of coverage."
        ),
        Category(
            id: "team_selection",
            title: "Team Selection",
            description: "Level of individual training and experiences. Cohesiveness and atmosphere that values input/self-critique."
        ),
        Category(
            id: "team_fitness",
            title: "Team Fitness",
            description: "This includes physical and mental fitness. Team members are rested, engaged, and overall morale is good. The team is mindful and has a high level of situational awareness."
        ),
        Category(
            id: "environment",
            title: "Environment",
            description: "Extreme temperatures, elevations, difficulty of terrain, long approaches and remoteness, not excluding the office environment."
        ),
        Category(
            id: "task_complexity",
            title: "Task Complexity",
            description: "Severity, probability, and exposure of mishap. The potential for incident that would tax the current staffing levels."
        ),
    ]
}
