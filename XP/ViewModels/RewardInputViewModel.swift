import Foundation

class RewardInputViewModel: ObservableObject {
    @Published var reward: String = ""
    @Published var isPresented: Bool = false

    private var level: Int
    private var persistenceManager: PersistenceManager

    init(reward: String, isPresented: Bool, level: Int, persistenceManager: PersistenceManager) {
        self.reward = reward
        self.isPresented = isPresented
        self.level = level
        self.persistenceManager = persistenceManager
    }

    func cancel() {
        isPresented = false
    }

    func setReward() {
        while persistenceManager.levelRewards.count < level {
            persistenceManager.levelRewards.append("")
        }
        persistenceManager.levelRewards[level - 1] = reward
        persistenceManager.saveLevelRewards(persistenceManager.levelRewards)
        isPresented = false
    }
}
