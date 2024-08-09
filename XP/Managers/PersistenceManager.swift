import Foundation
import Combine

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()
    
    @Published var tasks: [XPTask] = []
    @Published var levelRewards: [String] = []

    private let defaults = UserDefaults.standard

    private init() {
        self.levelRewards = loadLevelRewards()
        self.tasks = loadTasks()
    }

    func saveTasks(_ tasks: [XPTask]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: "tasks")
        }
        self.tasks = tasks
    }

    func loadTasks() -> [XPTask] {
        if let savedTasks = defaults.data(forKey: "tasks") {
            if let decodedTasks = try? JSONDecoder().decode([XPTask].self, from: savedTasks) {
                return decodedTasks
            }
        }
        return []
    }

    func saveAccumulatedXP(_ xp: Int) {
        defaults.set(xp, forKey: "accumulatedXP")
    }

    func loadAccumulatedXP() -> Int {
        return defaults.integer(forKey: "accumulatedXP")
    }

    func saveLevel(_ level: Int) {
        defaults.set(level, forKey: "level")
    }

    func loadLevel() -> Int {
        return defaults.integer(forKey: "level")
    }

    func saveRewards(_ rewards: [String]) {
        if let encoded = try? JSONEncoder().encode(rewards) {
            defaults.set(encoded, forKey: "rewards")
        }
    }

    func loadRewards() -> [String] {
        if let savedRewards = defaults.data(forKey: "rewards") {
            if let decodedRewards = try? JSONDecoder().decode([String].self, from: savedRewards) {
                return decodedRewards
            }
        }
        return []
    }

    func saveLevelRewards(_ rewards: [String]) {
        if let encoded = try? JSONEncoder().encode(rewards) {
            defaults.set(encoded, forKey: "levelRewards")
        }
        self.levelRewards = rewards
    }

    func loadLevelRewards() -> [String] {
        if let savedRewards = defaults.data(forKey: "levelRewards") {
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

        let now = Date()
        tasks = tasks.map {
            var task = $0
            if let lastReset = task.lastReset {
                let daysSinceLastReset = Calendar.current.dateComponents([.day], from: lastReset, to: now).day ?? 0
                if daysSinceLastReset >= task.resetFrequency {
                    task.completed = false
                    task.lastReset = now
                }
            } else {
                task.lastReset = now
            }
            return task
        }

        // Save updated tasks
        saveTasks(tasks)
    }

    func getLastResetDate() -> Date? {
        return defaults.object(forKey: "lastResetDate") as? Date
    }

    func setLastResetDate(_ date: Date) {
        defaults.set(date, forKey: "lastResetDate")
    }

    // Firestore sync functions
    func syncUserData(userID: String, completion: @escaping ([XPTask]) -> Void) {
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
                completion(tasks)
            } else if let error = error {
                print("Error fetching tasks from Firebase: \(error)")
                completion([])
            }
        }

        // Fetch level rewards from Firestore
        FirestoreManager.shared.fetchLevelRewards(userID: userID) { rewards, error in
            if let rewards = rewards {
                self.saveLevelRewards(rewards)
            } else if let error = error {
                print("Error fetching level rewards from Firebase: \(error)")
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
