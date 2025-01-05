import Foundation

class ProfileViewModel: ObservableObject {
    @Published var tasks: [XPTask]
    @Published var levelRewards: [String] = []
    @Published var editIndex: Int?
    @Published var errorMessage: String?
    
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
            FirestoreManager.shared.fetchLevelRewards(userID: userID) { [weak self] rewards, error in
                if let rewards = rewards {
                    DispatchQueue.main.async {
                        self?.levelRewards = rewards
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error fetching rewards: \(error.localizedDescription)"
                    }
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
            while levelRewards.count < index {
                levelRewards.append("")
            }
            levelRewards.append(reward)
        }
    }
    
    private func saveReward(index: Int) {
        guard index >= 0 && index < levelRewards.count else {
            errorMessage = "Invalid reward index"
            return
        }
        
        if let userID = authViewModel.currentUser?.uid {
            let reward = levelRewards[index]
            
            // Save to Firestore
            persistenceManager.saveLevelReward(userID: userID, level: index + 1, reward: reward) { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error saving reward: \(error.localizedDescription)"
                    }
                    return
                }
                
                // Save locally
                DispatchQueue.main.async {
                    do {
                        try self?.persistenceManager.saveLevelRewards(self?.levelRewards ?? [])
                    } catch {
                        self?.errorMessage = "Error saving rewards locally: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
