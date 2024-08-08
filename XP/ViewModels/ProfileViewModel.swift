import Foundation

class ProfileViewModel: ObservableObject {
    @Published var tasks: [XPTask]
    @Published var levelRewards: [String] = []
    @Published var editIndex: Int?

    private var persistenceManager: PersistenceManager
    private var authViewModel: AuthViewModel

    init(tasks: [XPTask], persistenceManager: PersistenceManager, authViewModel: AuthViewModel) {
        self.tasks = tasks
        self.persistenceManager = persistenceManager
        self.authViewModel = authViewModel
        fetchLevelRewards()
    }

    private func fetchLevelRewards() {
        if let userID = authViewModel.currentUser?.uid {
            FirestoreManager.shared.fetchLevelRewards(userID: userID) { rewards, error in
                if let rewards = rewards {
                    DispatchQueue.main.async {
                        self.levelRewards = rewards
                    }
                } else if let error = error {
                    print("Error fetching level rewards from Firebase: \(error)")
                }
            }
        }
    }

    func editReward(at index: Int) {
        editIndex = index
    }

    func closeEdit() {
        if let index = editIndex {
            saveReward(index: index)
            editIndex = nil
        }
    }

    func updateReward(at index: Int, with reward: String) {
        if index < levelRewards.count {
            levelRewards[index] = reward
        } else {
            levelRewards.append(reward)
        }
    }

    private func saveReward(index: Int) {
        if let userID = authViewModel.currentUser?.uid {
            let reward = levelRewards[index]
            persistenceManager.saveLevelReward(userID: userID, level: index + 1, reward: reward)
        }
        persistenceManager.saveLevelRewards(levelRewards)
    }
}
