import Foundation

struct XPTask: Identifiable, Codable {
    var id: String?
    var name: String
    var xp: Int
    var completed: Bool
    var lastCompleted: Date?

    init(id: String? = nil, name: String, xp: Int, completed: Bool = false, lastCompleted: Date? = nil) {
        self.id = id
        self.name = name
        self.xp = xp
        self.completed = completed
        self.lastCompleted = lastCompleted
    }
}
