import SwiftUI
import FirebaseAuth

struct MainContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var tasks: [XPTask] = PersistenceManager.shared.tasks
    @State private var accumulatedXP: Int = PersistenceManager.shared.loadAccumulatedXP()
    @State private var level: Int = max(1, PersistenceManager.shared.loadLevel())
    @State private var maxXP: Int = 100
    @StateObject private var persistenceManager = PersistenceManager.shared

    @State private var showAddTaskForm = false
    @State private var showAddRewardForm = false
    @State private var showOptions = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                NavigationLink(destination: ProfileView(viewModel: ProfileViewModel(tasks: tasks, persistenceManager: persistenceManager))) {
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
                Spacer().frame(width: 0)
            }
            .padding(.top, 50)
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                XPBar(totalXP: accumulatedXP, maxXP: maxXP, level: level, reward: currentReward)
                    .padding(.top, 20)

                TaskListView(tasks: $tasks, onTasksChange: saveTasks)
                    .padding(.top, 10)

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
                            onTasksChange: saveTasks
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
                            persistenceManager: persistenceManager
                        ))
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            endOfDayResetIfNeeded()
            calculateAccumulatedXP()
            persistenceManager.syncTasksWithFirebase()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    private var currentReward: String {
        if level - 1 < persistenceManager.levelRewards.count {
            return persistenceManager.levelRewards[level - 1]
        } else {
            return ""
        }
    }

    private func saveTasks() {
        PersistenceManager.shared.saveTasks(tasks)
        calculateAccumulatedXP()
    }

    private func calculateAccumulatedXP() {
        accumulatedXP = tasks.filter { $0.completed }.reduce(0) { $0 + Int($1.xp) }
        PersistenceManager.shared.saveAccumulatedXP(accumulatedXP)
        checkLevelUp()
    }

    private func checkLevelUp() {
        if accumulatedXP >= maxXP {
            level += 1
            accumulatedXP -= maxXP
            maxXP = calculateMaxXP(for: level)
            persistenceManager.saveLevel(level)
            PersistenceManager.shared.saveAccumulatedXP(accumulatedXP)
        }
    }

    private func calculateMaxXP(for level: Int) -> Int {
        return 100 + (level - 1) * 50
    }

    private func endOfDayResetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let lastResetDate = persistenceManager.getLastResetDate() ?? Date.distantPast
        if calendar.isDateInToday(lastResetDate) {
            return
        }

        persistenceManager.endOfDayReset(tasks: &tasks)
        persistenceManager.setLastResetDate(startOfDay)
    }
}
