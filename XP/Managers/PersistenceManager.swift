import Foundation
import Combine

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()
    
    @Published var tasks: [XPTask] = []
    @Published var levelRewards: [String] = []
    @Published var earnedXP: Int = 0
    @Published var syncInProgress: Bool = false
    @Published var lastSyncDate: Date?
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        self.levelRewards = loadLevelRewards()
        self.tasks = loadTasks()
        self.earnedXP = loadEarnedXP()
        self.lastSyncDate = defaults.object(forKey: "lastSyncDate") as? Date
    }

    // MARK: - Local Storage Operations
    
    func saveTasks(_ tasks: [XPTask]) throws {
        let encoded = try encoder.encode(tasks)
        defaults.set(encoded, forKey: "tasks")
        self.tasks = tasks
    }

    func loadTasks() -> [XPTask] {
        guard let savedTasks = defaults.data(forKey: "tasks"),
              let decodedTasks = try? decoder.decode([XPTask].self, from: savedTasks) else {
            return []
        }
        return decodedTasks
    }

    func saveAccumulatedXP(_ xp: Int) {
        defaults.set(xp, forKey: "accumulatedXP")
    }

    func loadAccumulatedXP() -> Int {
        return defaults.integer(forKey: "accumulatedXP")
    }

    func saveEarnedXP(_ xp: Int) {
        defaults.set(xp, forKey: "earnedXP")
        self.earnedXP = xp
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

    func saveRewards(_ rewards: [String]) throws {
        let encoded = try encoder.encode(rewards)
        defaults.set(encoded, forKey: "rewards")
    }

    func loadRewards() -> [String] {
        guard let savedRewards = defaults.data(forKey: "rewards"),
              let decodedRewards = try? decoder.decode([String].self, from: savedRewards) else {
            return []
        }
        return decodedRewards
    }

    func saveLevelRewards(_ rewards: [String]) throws {
        let encoded = try encoder.encode(rewards)
        defaults.set(encoded, forKey: "levelRewards")
        self.levelRewards = rewards
    }

    func loadLevelRewards() -> [String] {
        guard let savedRewards = defaults.data(forKey: "levelRewards"),
              let decodedRewards = try? decoder.decode([String].self, from: savedRewards) else {
            return []
        }
        return decodedRewards
    }

    // MARK: - User Data Management
    
    func resetUserData() {
        saveLevel(1)
        saveAccumulatedXP(0)
        saveEarnedXP(0)
        tasks = []
        levelRewards = []
        try? saveTasks([])
        try? saveLevelRewards([])
        defaults.removeObject(forKey: "lastSyncDate")
    }

    // MARK: - Sync Operations
    
    func syncUserData(userID: String, completion: @escaping (Result<[XPTask], Error>) -> Void) {
        guard !syncInProgress else {
            completion(.failure(PersistenceError.syncInProgress))
            return
        }
        
        syncInProgress = true
        
        let group = DispatchGroup()
        var syncError: Error?
        
        // Sync XP and Level
        group.enter()
        FirestoreManager.shared.fetchUserXPAndLevel(userID: userID) { [weak self] xp, level, rewards, error in
            defer { group.leave() }
            if let error = error {
                syncError = error
                return
            }
            
            if let xp = xp, let level = level, let rewards = rewards {
                self?.saveAccumulatedXP(xp)
                self?.saveLevel(level)
                try? self?.saveRewards(rewards)
            }
        }

        // Sync Tasks
        group.enter()
        FirestoreManager.shared.fetchTasks(userID: userID) { [weak self] tasks, error in
            defer { group.leave() }
            if let error = error {
                syncError = error
                return
            }
            
            if let tasks = tasks {
                try? self?.saveTasks(tasks)
            }
        }

        // Sync Level Rewards
        group.enter()
        FirestoreManager.shared.fetchLevelRewards(userID: userID) { [weak self] rewards, error in
            defer { group.leave() }
            if let error = error {
                syncError = error
                return
            }
            
            if let rewards = rewards {
                try? self?.saveLevelRewards(rewards)
            }
        }

        // Sync Earned XP
        group.enter()
        FirestoreManager.shared.fetchEarnedXP(userID: userID) { [weak self] earnedXP, error in
            defer { group.leave() }
            if let error = error {
                syncError = error
                return
            }
            
            if let earnedXP = earnedXP {
                self?.saveEarnedXP(earnedXP)
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.syncInProgress = false
            self?.lastSyncDate = Date()
            self?.defaults.set(self?.lastSyncDate, forKey: "lastSyncDate")
            
            if let error = syncError {
                completion(.failure(error))
            } else {
                completion(.success(self?.tasks ?? []))
            }
        }
    }

    func saveUserDataToFirestore(userID: String, completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var saveError: Error?
        
        // Save XP and Level
        group.enter()
        FirestoreManager.shared.saveUserXPAndLevel(
            userID: userID,
            xp: loadAccumulatedXP(),
            level: loadLevel(),
            rewards: loadRewards()
        ) { error in
            defer { group.leave() }
            if let error = error {
                saveError = error
            }
        }

        // Save Earned XP
        group.enter()
        FirestoreManager.shared.saveEarnedXP(
            userID: userID,
            earnedXP: loadEarnedXP()
        ) { error in
            defer { group.leave() }
            if let error = error {
                saveError = error
            }
        }

        // Save Tasks
        let tasks = self.tasks
        for task in tasks {
            group.enter()
            FirestoreManager.shared.saveTask(userID: userID, task: task) { error in
                defer { group.leave() }
                if let error = error {
                    saveError = error
                }
            }
        }

        group.notify(queue: .main) {
            completion(saveError)
        }
    }

    // MARK: - Task Operations
    
    func addTask(userID: String, task: XPTask, completion: @escaping (Error?) -> Void) {
        tasks.append(task)
        do {
            try saveTasks(tasks)
            FirestoreManager.shared.saveTask(userID: userID, task: task, completion: completion)
        } catch {
            completion(error)
        }
    }

    func updateTask(userID: String, task: XPTask, completion: @escaping (Error?) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            completion(PersistenceError.taskNotFound)
            return
        }
        
        tasks[index] = task
        do {
            try saveTasks(tasks)
            FirestoreManager.shared.updateTask(userID: userID, task: task, completion: completion)
        } catch {
            completion(error)
        }
    }

    func deleteTask(userID: String, taskID: String, completion: @escaping (Error?) -> Void) {
        tasks.removeAll { $0.id == taskID }
        do {
            try saveTasks(tasks)
            FirestoreManager.shared.deleteTask(userID: userID, taskId: taskID, completion: completion)
        } catch {
            completion(error)
        }
    }

    func saveLevelReward(userID: String, level: Int, reward: String, completion: @escaping (Error?) -> Void) {
        FirestoreManager.shared.saveLevelReward(userID: userID, level: level, reward: reward, completion: completion)
    }
}

// MARK: - Error Types

enum PersistenceError: LocalizedError {
    case syncInProgress
    case taskNotFound
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .syncInProgress:
            return "A sync operation is already in progress"
        case .taskNotFound:
            return "The specified task was not found"
        case .encodingError:
            return "Failed to encode data"
        case .decodingError:
            return "Failed to decode data"
        }
    }
}
