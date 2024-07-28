import Foundation
import SwiftUI

struct XPTask: Identifiable, Codable, Transferable {
    let id: UUID
    let name: String
    let xp: Int
    var completed: Bool = false
    var resetIntervalDays: Int = 0 // Reset interval in days
    var lastCompleted: Date? // Last completion date

    init(id: UUID = UUID(), name: String, xp: Int, completed: Bool = false, resetIntervalDays: Int = 0, lastCompleted: Date? = nil) {
        self.id = id
        self.name = name
        self.xp = xp
        self.completed = completed
        self.resetIntervalDays = resetIntervalDays
        self.lastCompleted = lastCompleted
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
