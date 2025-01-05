import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var tasks: [XPTask] = []
    @State private var accumulatedXP: Int = 0
    @State private var earnedXP: Int = 0
    @State private var level: Int = 1
    @State private var maxXP: Int = 100
    @State private var levelRewards: [String] = []
    @State private var errorMessage: String?
    @State private var showError = false
    @StateObject private var persistenceManager = PersistenceManager.shared

    @State private var showAddTaskForm = false
    @State private var showAddRewardForm = false
    @State private var showOptions = false

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                HStack {
                    NavigationLink(destination: ProfileView(viewModel: ProfileViewModel(tasks: tasks, persistenceManager: persistenceManager, authViewModel: authViewModel))) {
                        HStack {
                            Image(systemName: "person.circle")
                                .imageScale(.large)
                            Text("Profile")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal)

                VStack(spacing: 0) {
                    XPBar(accumulatedXP: accumulatedXP, earnedXP: earnedXP, maxXP: maxXP, level: level, reward: currentReward)
                        .padding(.top, 20)

                    TaskListView(tasks: $tasks, onTasksChange: saveTasks)
                        .padding(.top, 0)
                        .environmentObject(authViewModel)

                    Spacer()

                    if !showAddTaskForm && !showAddRewardForm {
                        Button(action: {
                            showOptions.toggle()
                        }) {
                            Text(showOptions ? "-" : "+")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, showOptions ? 10 : 40)
                    }

                    if showOptions {
                        OptionSelectionView(isPresented: $showOptions, showAddTaskForm: $showAddTaskForm, showAddRewardForm: $showAddRewardForm)
                            .padding(.bottom, 20)
                    }

                    if showAddTaskForm {
                        VStack(spacing: 20) {
                            AddTaskView(viewModel: AddTaskViewModel(
                                tasks: $tasks,
                                showAddTaskForm: $showAddTaskForm,
                                onTasksChange: saveTasks,
                                authViewModel: authViewModel
                            ))
                        }
                        .padding()
                    }

                    if showAddRewardForm {
                        VStack(spacing: 20) {
                            RewardInputView(viewModel: RewardInputViewModel(
                                reward: currentReward,
                                isPresented: $showAddRewardForm,
                                showOptions: $showOptions,
                                level: level,
                                persistenceManager: persistenceManager,
                                authViewModel: authViewModel,
                                onRewardSet: { newReward in
                                    if level - 1 < levelRewards.count {
                                        self.levelRewards[level - 1] = newReward
                                    } else {
                                        while self.levelRewards.count < level {
                                            self.levelRewards.append("")
                                        }
                                        self.levelRewards[level - 1] = newReward
                                    }
                                }
                            ))
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            if let userID = authViewModel.currentUser?.uid {
                persistenceManager.syncUserData(userID: userID) { result in
                    switch result {
                    case .success(let fetchedTasks):
                        self.tasks = fetchedTasks
                        calculateAccumulatedXP()
                        fetchLevelRewards(userID: userID)
                    case .failure(let error):
                        self.errorMessage = "Failed to sync data: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            }
        }
        .onDisappear {
            if let userID = authViewModel.currentUser?.uid {
                persistenceManager.saveUserDataToFirestore(userID: userID) { error in
                    if let error = error {
                        self.errorMessage = "Failed to save data: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    private var currentReward: String {
        if level - 1 < levelRewards.count {
            return levelRewards[level - 1]
        } else {
            return ""
        }
    }

    private func saveTasks() {
        if let userID = authViewModel.currentUser?.uid {
            do {
                try persistenceManager.saveTasks(tasks)
                calculateAccumulatedXP()
                persistenceManager.saveUserDataToFirestore(userID: userID) { error in
                    if let error = error {
                        self.errorMessage = "Failed to save tasks: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } catch {
                self.errorMessage = "Failed to save tasks locally: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }

    private func calculateAccumulatedXP() {
        accumulatedXP = tasks.filter { $0.completed }.reduce(0) { $0 + Int($1.xp) }
        earnedXP = persistenceManager.loadEarnedXP()
        persistenceManager.saveAccumulatedXP(accumulatedXP)
        checkLevelUp()
    }

    private func checkLevelUp() {
        if accumulatedXP + earnedXP >= maxXP {
            level += 1
            earnedXP -= (maxXP - accumulatedXP)
            accumulatedXP = 0
            maxXP = calculateMaxXP(for: level)
            persistenceManager.saveLevel(level)
            persistenceManager.saveEarnedXP(earnedXP)
        }
        updateXPAndLevelInFirestore()
    }

    private func calculateMaxXP(for level: Int) -> Int {
        return 100 + (level - 1) * 50
    }

    private func updateXPAndLevelInFirestore() {
        if let userID = authViewModel.currentUser?.uid {
            persistenceManager.saveUserDataToFirestore(userID: userID) { error in
                if let error = error {
                    self.errorMessage = "Failed to update XP and level: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }

    private func fetchLevelRewards(userID: String) {
        FirestoreManager.shared.fetchLevelRewards(userID: userID) { rewards, error in
            if let error = error {
                self.errorMessage = "Failed to fetch rewards: \(error.localizedDescription)"
                self.showError = true
                return
            }
            
            if let rewards = rewards {
                DispatchQueue.main.async {
                    self.levelRewards = rewards
                    while self.levelRewards.count < self.level {
                        self.levelRewards.append("")
                    }
                }
            }
        }
    }
}
