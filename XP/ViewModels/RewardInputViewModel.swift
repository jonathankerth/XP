    import SwiftUI

    class RewardInputViewModel: ObservableObject {
        @Published var reward: String
        @Binding var isPresented: Bool
        @Binding var showOptions: Bool

        private let level: Int
        private let persistenceManager: PersistenceManager
        var authViewModel: AuthViewModel
        var onRewardSet: (String) -> Void

        init(reward: String, isPresented: Binding<Bool>, showOptions: Binding<Bool>, level: Int, persistenceManager: PersistenceManager, authViewModel: AuthViewModel, onRewardSet: @escaping (String) -> Void) {
            self.reward = reward
            self._isPresented = isPresented
            self._showOptions = showOptions
            self.level = level
            self.persistenceManager = persistenceManager
            self.authViewModel = authViewModel
            self.onRewardSet = onRewardSet
        }

        func cancel() {
            isPresented = false
            showOptions = true // Reset to options view
        }

        func setReward() {
            if level - 1 < persistenceManager.levelRewards.count {
                persistenceManager.levelRewards[level - 1] = reward
            } else {
                persistenceManager.levelRewards.append(reward)
            }
            if let userID = authViewModel.currentUser?.uid {
                persistenceManager.saveLevelReward(userID: userID, level: level, reward: reward)
            }
            onRewardSet(reward) // Call the closure to update the reward in MainContentView
            isPresented = false
            showOptions = true
        }
    }
