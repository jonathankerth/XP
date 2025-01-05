import Foundation
import Firebase
import FirebaseFirestore

// MARK: - Models
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
        case .oneDay: return "1 Day"
        case .everyOtherDay: return "Every Other Day"
        case .threeDays: return "Every 3 Days"
        case .onceAWeek: return "Once a Week"
        case .onceAMonth: return "Once a Month"
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
    var lastReset: Date?
    var resetFrequency: Int
    var xpAwarded: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, xp, completed, lastCompleted, nextDueDate, frequency
        case category, lastReset, resetFrequency, xpAwarded
    }

    init(id: String = UUID().uuidString,
         name: String,
         xp: Int,
         completed: Bool = false,
         lastCompleted: Date? = nil,
         nextDueDate: Date? = nil,
         frequency: TaskFrequency,
         category: TaskCategory,
         lastReset: Date? = nil,
         resetFrequency: Int? = nil,
         xpAwarded: Bool = false) {
        self.id = id
        self.name = name
        self.xp = xp
        self.completed = completed
        self.lastCompleted = lastCompleted
        self.nextDueDate = nextDueDate
        self.frequency = frequency
        self.category = category
        self.lastReset = lastReset
        self.resetFrequency = resetFrequency ?? frequency.rawValue
        self.xpAwarded = xpAwarded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        xp = try container.decode(Int.self, forKey: .xp)
        completed = try container.decode(Bool.self, forKey: .completed)
        
        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .lastCompleted) {
            lastCompleted = Date(timeIntervalSince1970: timestamp)
        }
        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .nextDueDate) {
            nextDueDate = Date(timeIntervalSince1970: timestamp)
        }
        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .lastReset) {
            lastReset = Date(timeIntervalSince1970: timestamp)
        }
        
        frequency = try container.decode(TaskFrequency.self, forKey: .frequency)
        category = try container.decode(TaskCategory.self, forKey: .category)
        resetFrequency = try container.decode(Int.self, forKey: .resetFrequency)
        xpAwarded = try container.decode(Bool.self, forKey: .xpAwarded)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(xp, forKey: .xp)
        try container.encode(completed, forKey: .completed)
        
        if let lastCompleted = lastCompleted {
            try container.encode(lastCompleted.timeIntervalSince1970, forKey: .lastCompleted)
        }
        if let nextDueDate = nextDueDate {
            try container.encode(nextDueDate.timeIntervalSince1970, forKey: .nextDueDate)
        }
        if let lastReset = lastReset {
            try container.encode(lastReset.timeIntervalSince1970, forKey: .lastReset)
        }
        
        try container.encode(frequency, forKey: .frequency)
        try container.encode(category, forKey: .category)
        try container.encode(resetFrequency, forKey: .resetFrequency)
        try container.encode(xpAwarded, forKey: .xpAwarded)
    }
}
