import SwiftUI
import FirebaseAuth

struct MainContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var tasks: [XPTask] = []
    @State private var accumulatedXP: Int = 0
    @State private var level: Int = 1
    @State private var maxXP: Int = 100
    @State private var levelRewards: [String] = []
    @StateObject private var persistenceManager = PersistenceManager.shared

    @State private var showAddTaskForm = false
    @State private var showAddRewardForm = false
    @State private var showOptions = false

    var body: some View {
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
                XPBar(totalXP: accumulatedXP, maxXP: maxXP, level: level, reward: currentReward)
                    .padding(.top, 20)

                TaskListView(tasks: $tasks, onTasksChange: saveTasks)
                    .padding(.top, 10)
                    .environmentObject(authViewModel)

                if !showAddTaskForm && !showAddRewardForm {
                    Button(action: {
                        showOptions.toggle()
                    }) {
                        Text(showOptions ? "-" : "+")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding()
                }

                if showOptions {
                    VStack {
                        Button(action: {
                            showAddTaskForm = true
                            showAddRewardForm = false
                            showOptions = false
                        }) {
                            Text("Add Task")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .padding(.bottom, 5)
                        Button(action: {
                            showAddRewardForm = true
                            showAddTaskForm = false
                            showOptions = false
                        }) {
                            Text("Add Reward")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
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
                            authViewModel: authViewModel
                        ))
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            if let userID = authViewModel.currentUser?.uid {
                persistenceManager.syncUserData(userID: userID) { tasks in
                    self.tasks = tasks
                    calculateAccumulatedXP()
                    fetchLevelRewards(userID: userID)
                }
            }
            startResetTimer() // Start the reset timer when the view appears
        }
        .onDisappear {
            if let userID = authViewModel.currentUser?.uid {
                persistenceManager.saveUserDataToFirestore(userID: userID)
            }
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
            persistenceManager.saveTasks(tasks)
            calculateAccumulatedXP()
            persistenceManager.saveUserDataToFirestore(userID: userID)
        }
    }

    private func calculateAccumulatedXP() {
        accumulatedXP = tasks.filter { $0.completed }.reduce(0) { $0 + Int($1.xp) }
        persistenceManager.saveAccumulatedXP(accumulatedXP)
        checkLevelUp()
    }

    private func checkLevelUp() {
        if accumulatedXP >= maxXP {
            level += 1
            accumulatedXP -= maxXP
            maxXP = calculateMaxXP(for: level)
            persistenceManager.saveLevel(level)
            persistenceManager.saveAccumulatedXP(accumulatedXP)
        }
        updateXPAndLevelInFirestore()
    }

    private func calculateMaxXP(for level: Int) -> Int {
        return 100 + (level - 1) * 50
    }

    private func updateXPAndLevelInFirestore() {
        if let userID = authViewModel.currentUser?.uid {
            persistenceManager.saveUserDataToFirestore(userID: userID)
        }
    }

    private func fetchLevelRewards(userID: String) {
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

    // Start a timer that checks every few minutes if tasks need to be reset
    private func startResetTimer() {
        Timer.scheduledTimer(withTimeInterval: 60 * 5, repeats: true) { _ in
            self.persistenceManager.resetTasksIfNeeded()
            self.calculateAccumulatedXP() // Recalculate XP after resetting tasks
        }
    }
}
