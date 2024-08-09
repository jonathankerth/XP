import Foundation

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case hobbies = "Hobbies"
    case finance = "Finance"
    case habits = "Habits"
    case sleep = "Sleep"
    case hydration = "Hydration"
    case householdChores = "Household Chores"
    case selfCare = "Self-care"
    case work = "Work"
    case nutrition = "Nutrition"
    case personalHygiene = "Personal Hygiene"
    case creative = "Creative"
    case passionProject = "Passion Project"
    case discipline = "Discipline"
    case mindfulness = "Mindfulness"

    var id: String { self.rawValue }
}

enum TaskFrequency: Int, Codable, CaseIterable, Identifiable {
    case oneDay = 1
    case everyOtherDay = 2
    case threeDays = 3
    case onceAWeek = 7
    case onceAMonth = 30

    var id: Int { self.rawValue }

    var description: String {
        switch self {
        case .oneDay:
            return "1 Day"
        case .everyOtherDay:
            return "Every Other Day"
        case .threeDays:
            return "Every 3 Days"
        case .onceAWeek:
            return "Once a Week"
        case .onceAMonth:
            return "Once a Month"
        }
    }
}

struct XPTask: Identifiable, Codable {
    var id: String
    var name: String
    var xp: Int
    var completed: Bool
    var lastCompleted: Date?
    var nextDueDate: Date?
    var frequency: TaskFrequency
    var category: TaskCategory 
}
