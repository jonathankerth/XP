import Foundation

struct XPTask: Identifiable, Codable {
    var id: String
    var name: String
    var xp: Int
    var completed: Bool
    var lastCompleted: Date?
}
