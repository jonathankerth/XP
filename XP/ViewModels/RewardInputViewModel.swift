import SwiftUI

class RewardInputViewModel: ObservableObject {
    @Published var reward: String
    @Binding var isPresented: Bool
    @Binding var showOptions: Bool

    private let level: Int
    private let persistenceManager: PersistenceManager

    init(reward: String, isPresented: Binding<Bool>, showOptions: Binding<Bool>, level: Int, persistenceManager: PersistenceManager) {
        self.reward = reward
        self._isPresented = isPresented
        self._showOptions = showOptions
        self.level = level
        self.persistenceManager = persistenceManager
    }

    func cancel() {
        isPresented = false
        showOptions = true // Reset to options view
    }

    func setReward() {
        if level - 1 < persistenceManager.levelRewards.count {
            persistenceManager.levelRewards[level - 1] = reward
        }
        isPresented = false
        showOptions = true
    }
}
