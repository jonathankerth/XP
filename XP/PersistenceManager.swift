import Foundation
import Combine

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()

    private let tasksKey = "tasks"
    private let accumulatedXPKey = "accumulatedXP"
    private let levelKey = "level"
    private let rewardKey = "reward"
    private let futureRewardsKey = "futureRewards"
    private let pastRewardsKey = "pastRewards"
    private let levelRewardsKey = "levelRewards"
    private let defaults = UserDefaults.standard

    @Published var levelRewards: [String] = []

    init() {
        self.levelRewards = loadLevelRewards()
    }

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

    func saveFutureRewards(_ rewards: [String]) {
        if let encoded = try? JSONEncoder().encode(rewards) {
            defaults.set(encoded, forKey: futureRewardsKey)
        }
    }

    func loadFutureRewards() -> [String] {
        if let savedRewards = defaults.data(forKey: futureRewardsKey) {
            if let decodedRewards = try? JSONDecoder().decode([String].self, from: savedRewards) {
                return decodedRewards
            }
        }
        return []
    }

    func savePastRewards(_ rewards: [String]) {
        if let encoded = try? JSONEncoder().encode(rewards) {
            defaults.set(encoded, forKey: pastRewardsKey)
        }
    }

    func loadPastRewards() -> [String] {
        if let savedRewards = defaults.data(forKey: pastRewardsKey) {
            if let decodedRewards = try? JSONDecoder().decode([String].self, from: savedRewards) {
                return decodedRewards
            }
        }
        return []
    }

    func saveLevelRewards(_ rewards: [String]) {
        if let encoded = try? JSONEncoder().encode(rewards) {
            defaults.set(encoded, forKey: levelRewardsKey)
        }
        levelRewards = rewards
    }

    func loadLevelRewards() -> [String] {
        if let savedRewards = defaults.data(forKey: levelRewardsKey) {
            if let decodedRewards = try? JSONDecoder().decode([String].self, from: savedRewards) {
                return decodedRewards
            }
        }
        return []
    }
}
