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
    private let lastResetDateKey = "lastResetDate"
    private let defaults = UserDefaults.standard

    @Published var tasks: [XPTask] = []
    @Published var levelRewards: [String] = []

    private init() {
        self.levelRewards = loadLevelRewards()
        self.tasks = loadTasks()
    }

    func saveTasks(_ tasks: [XPTask]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: tasksKey)
        }
        self.tasks = tasks
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

    func resetUserData() {
        saveLevel(1)
        saveAccumulatedXP(0)
    }

    func endOfDayReset(tasks: inout [XPTask]) {
        // Accumulate XP and reset tasks
        let completedXP = tasks.filter { $0.completed }.reduce(0) { $0 + Int($1.xp) }
        var totalXP = loadAccumulatedXP()
        totalXP += completedXP
        saveAccumulatedXP(totalXP)

        // Reset task completion
        tasks = tasks.map {
            var task = $0
            task.completed = false
            task.lastCompleted = nil
            return task
        }

        // Save updated tasks
        saveTasks(tasks)
    }

    func getLastResetDate() -> Date? {
        return defaults.object(forKey: lastResetDateKey) as? Date
    }

    func setLastResetDate(_ date: Date) {
        defaults.set(date, forKey: lastResetDateKey)
    }

    // Firestore sync functions
    func syncTasksWithFirebase() {
        FirestoreManager.shared.fetchTasks { tasks, error in
            if let tasks = tasks {
                self.saveTasks(tasks)
            } else if let error = error {
                print("Error fetching tasks from Firebase: \(error)")
            }
        }
    }

    func addTask(_ task: XPTask) {
        tasks.append(task)
        saveTasks(tasks)
        FirestoreManager.shared.saveTask(task) { error in
            if let error = error {
                print("Error adding task to Firebase: \(error)")
            }
        }
    }

    func updateTask(_ task: XPTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks(tasks)
            FirestoreManager.shared.updateTask(task) { error in
                if let error = error {
                    print("Error updating task in Firebase: \(error)")
                }
            }
        }
    }

    func deleteTask(_ taskID: String) {
        tasks.removeAll { $0.id == taskID }
        saveTasks(tasks)
        FirestoreManager.shared.deleteTask(taskID) { error in
            if let error = error {
                print("Error deleting task from Firebase: \(error)")
            }
        }
    }
}
