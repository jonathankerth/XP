import Foundation
import Combine

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()

    private let tasksKey = "tasks"
    private let accumulatedXPKey = "accumulatedXP"
    private let levelKey = "level"
    private let rewardsKey = "rewards"
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

    func saveRewards(_ rewards: [String]) {
        if let encoded = try? JSONEncoder().encode(rewards) {
            defaults.set(encoded, forKey: rewardsKey)
        }
    }

    func loadRewards() -> [String] {
        if let savedRewards = defaults.data(forKey: rewardsKey) {
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
        self.levelRewards = rewards
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
    func syncUserData(userID: String) {
        FirestoreManager.shared.fetchUserXPAndLevel(userID: userID) { xp, level, rewards, error in
            if let xp = xp, let level = level, let rewards = rewards {
                self.saveAccumulatedXP(xp)
                self.saveLevel(level)
                self.saveRewards(rewards)
            } else if let error = error {
                print("Error fetching user XP and level from Firebase: \(error)")
            }
        }

        FirestoreManager.shared.fetchTasks(userID: userID) { tasks, error in
            if let tasks = tasks {
                self.saveTasks(tasks)
            } else if let error = error {
                print("Error fetching tasks from Firebase: \(error)")
            }
        }
    }

    func saveUserDataToFirestore(userID: String) {
        let xp = loadAccumulatedXP()
        let level = loadLevel()
        let rewards = loadRewards()
        FirestoreManager.shared.saveUserXPAndLevel(userID: userID, xp: xp, level: level, rewards: rewards) { error in
            if let error = error {
                print("Error saving user XP and level to Firebase: \(error)")
            }
        }

        tasks.forEach { task in
            FirestoreManager.shared.saveTask(userID: userID, task: task) { error in
                if let error = error {
                    print("Error saving task to Firebase: \(error)")
                }
            }
        }
    }

    func addTask(userID: String, task: XPTask) {
        tasks.append(task)
        saveTasks(tasks)
        FirestoreManager.shared.saveTask(userID: userID, task: task) { error in
            if let error = error {
                print("Error adding task to Firebase: \(error)")
            }
        }
    }

    func updateTask(userID: String, task: XPTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks(tasks)
            FirestoreManager.shared.updateTask(userID: userID, task: task) { error in
                if let error = error {
                    print("Error updating task in Firebase: \(error)")
                }
            }
        }
    }

    func deleteTask(userID: String, taskID: String) {
        tasks.removeAll { $0.id == taskID }
        saveTasks(tasks)
        FirestoreManager.shared.deleteTask(userID: userID, taskId: taskID) { error in
            if let error = error {
                print("Error deleting task from Firebase: \(error)")
            }
        }
    }

    func saveLevelReward(userID: String, level: Int, reward: String) {
        FirestoreManager.shared.saveLevelReward(userID: userID, level: level, reward: reward) { error in
            if let error = error {
                print("Error saving level reward to Firebase: \(error)")
            }
        }
    }
}
