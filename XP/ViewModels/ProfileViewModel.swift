import Foundation

class ProfileViewModel: ObservableObject {
    @Published var tasks: [XPTask]
    @Published var levelRewards: [String]
    @Published var editIndex: Int?

    private var persistenceManager: PersistenceManager
    private var authViewModel: AuthViewModel

    init(tasks: [XPTask], persistenceManager: PersistenceManager, authViewModel: AuthViewModel) {
        self.tasks = tasks
        self.persistenceManager = persistenceManager
        self.authViewModel = authViewModel
        self.levelRewards = persistenceManager.levelRewards
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
