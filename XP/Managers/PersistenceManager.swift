import Foundation
import Combine

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()
    
    @Published var tasks: [XPTask] = []
    @Published var levelRewards: [String] = []
    @Published var earnedXP: Int = 0 // New field to store earned XP

    private let defaults = UserDefaults.standard

    private init() {
        self.levelRewards = loadLevelRewards()
        self.tasks = loadTasks()
        self.earnedXP = loadEarnedXP() // Load earned XP from defaults
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

    func saveEarnedXP(_ xp: Int) {
        defaults.set(xp, forKey: "earnedXP")
    }

    func loadEarnedXP() -> Int {
        return defaults.integer(forKey: "earnedXP")
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
        saveEarnedXP(0)
    }

    func endOfDayReset(tasks: inout [XPTask]) {
        let now = Date()
        let calendar = Calendar.current
        let timeZone = TimeZone(identifier: "America/Los_Angeles")! // PST
        var earnedXP = loadEarnedXP()

        tasks = tasks.map { task in
            var task = task
            if task.completed && !task.xpAwarded {
                earnedXP += task.xp
                task.xpAwarded = true // Mark XP as awarded
            }

            // Check if the current time has passed the next due date
            if let nextDueDate = task.nextDueDate, now >= nextDueDate {
                task.completed = false
                task.lastReset = now

                // Calculate the next due date by adding resetFrequency to the current next due date
                if let newNextDueDate = calendar.date(byAdding: .day, value: task.resetFrequency, to: nextDueDate) {
                    var components = calendar.dateComponents(in: timeZone, from: newNextDueDate)
                    components.hour = 0
                    components.minute = 0
                    components.second = 0
                    task.nextDueDate = calendar.date(from: components)
                }
                task.xpAwarded = false // Reset xpAwarded for the next cycle
            }

            return task
        }

        saveEarnedXP(earnedXP)
        saveTasks(tasks)
    }



    func getLastResetDate() -> Date? {
        return defaults.object(forKey: "lastResetDate") as? Date
    }

    func setLastResetDate(_ date: Date) {
        defaults.set(date, forKey: "lastResetDate")
    }

    // Reset tasks if needed
    func resetTasksIfNeeded() {
        var tasks = self.tasks
        endOfDayReset(tasks: &tasks)
        self.tasks = tasks
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

        FirestoreManager.shared.fetchLevelRewards(userID: userID) { rewards, error in
            if let rewards = rewards {
                self.saveLevelRewards(rewards)
            } else if let error = error {
                print("Error fetching level rewards from Firebase: \(error)")
            }
        }

        // Fetch earned XP
        FirestoreManager.shared.fetchEarnedXP(userID: userID) { earnedXP, error in
            if let earnedXP = earnedXP {
                self.saveEarnedXP(earnedXP)
            } else if let error = error {
                print("Error fetching earned XP from Firebase: \(error)")
            }
        }
    }

    func saveUserDataToFirestore(userID: String) {
        let xp = loadAccumulatedXP()
        let level = loadLevel()
        let rewards = loadRewards()
        let earnedXP = loadEarnedXP()

        FirestoreManager.shared.saveUserXPAndLevel(userID: userID, xp: xp, level: level, rewards: rewards) { error in
            if let error = error {
                print("Error saving user XP and level to Firebase: \(error)")
            }
        }

        FirestoreManager.shared.saveEarnedXP(userID: userID, earnedXP: earnedXP) { error in
            if let error = error {
                print("Error saving earned XP to Firebase: \(error)")
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
