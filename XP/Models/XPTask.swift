import Foundation

struct XPTask: Identifiable, Codable {
    var id: String
    var name: String
    var xp: Int
    var completed: Bool
    var lastCompleted: Date?
    var resetFrequency: Int
    var lastReset: Date?

    init(id: String = UUID().uuidString, name: String, xp: Int, completed: Bool = false, lastCompleted: Date? = nil, resetFrequency: Int = 1, lastReset: Date? = nil) {
        self.id = id
        self.name = name
        self.xp = xp
        self.completed = completed
        self.lastCompleted = lastCompleted
        self.resetFrequency = resetFrequency
        self.lastReset = lastReset
    }
}
