import Foundation

struct XPTask: Identifiable, Codable {
    let id: UUID
    let name: String
    let xp: Int
    var completed: Bool = false

    init(id: UUID = UUID(), name: String, xp: Int, completed: Bool = false) {
        self.id = id
        self.name = name
        self.xp = xp
        self.completed = completed
    }
}
