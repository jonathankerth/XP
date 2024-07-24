import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private let tasksKey = "tasks"
    private let accumulatedXPKey = "accumulatedXP"
    private let levelKey = "level"
    private let rewardKey = "reward"
    private let defaults = UserDefaults.standard

    func saveTasks(_ tasks: [XPTask]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: tasksKey)
        }
    }

    func loadTasks() -> [XPTask] {
        if let savedTasks = defaults.data(forKey: tasksKey) {
            if let decodedTasks = try? JSONDecoder().decode([XPTask].self, from: savedTasks) {
                return decodedTasks
            }
        }
        return []
    }

    func saveAccumulatedXP(_ xp: Int) {
        defaults.set(xp, forKey: accumulatedXPKey)
    }

    func loadAccumulatedXP() -> Int {
        return defaults.integer(forKey: accumulatedXPKey)
    }

    func saveLevel(_ level: Int) {
        defaults.set(level, forKey: levelKey)
    }

    func loadLevel() -> Int {
        return defaults.integer(forKey: levelKey)
    }

    func saveReward(_ reward: String) {
        defaults.set(reward, forKey: rewardKey)
    }

    func loadReward() -> String {
        return defaults.string(forKey: rewardKey) ?? ""
    }
}
