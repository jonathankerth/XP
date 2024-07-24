import SwiftUI

struct ContentView: View {
    @State private var tasks: [XPTask] = PersistenceManager.shared.loadTasks()
    @State private var accumulatedXP: Int = PersistenceManager.shared.loadAccumulatedXP()
    @State private var level: Int = PersistenceManager.shared.loadLevel()
    @State private var maxXP: Int = 100
    @State private var reward: String = PersistenceManager.shared.loadReward()

    @State private var showingRewardInput = false

    var body: some View {
        NavigationView {
            VStack {
                XPBar(totalXP: accumulatedXP, maxXP: maxXP, level: level, reward: reward)
                TaskListView(tasks: $tasks, onTasksChange: saveTasks)
                AddTaskView(tasks: $tasks, onTasksChange: saveTasks)
                if reward.isEmpty {
                    Button(action: {
                        showingRewardInput = true
                    }) {
                        Text("Set Reward for Next Level")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    .sheet(isPresented: $showingRewardInput) {
                        RewardInputView(reward: $reward, isPresented: $showingRewardInput)
                    }
                } else {
                    VStack {
                        Text("Reward for Next Level: \(reward)")
                            .padding()
                        Button(action: {
                            showingRewardInput = true
                        }) {
                            Text("Edit Reward")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                        .sheet(isPresented: $showingRewardInput) {
                            RewardInputView(reward: $reward, isPresented: $showingRewardInput)
                        }
                    }
                }
            }
            .navigationTitle("XP App")
            .onAppear {
                calculateAccumulatedXP()
                resetTaskCompletionIfNeeded()
            }
        }
    }

    private func saveTasks() {
        PersistenceManager.shared.saveTasks(tasks)
        calculateAccumulatedXP()
    }

    private func calculateAccumulatedXP() {
        let dailyXP = tasks.filter { $0.completed }.reduce(0) { $0 + $1.xp }
        accumulatedXP += dailyXP
        PersistenceManager.shared.saveAccumulatedXP(accumulatedXP)
        checkLevelUp()
    }

    private func checkLevelUp() {
        if accumulatedXP >= maxXP {
            level += 1
            accumulatedXP -= maxXP
            maxXP = calculateMaxXP(for: level)
            reward = ""
            PersistenceManager.shared.saveLevel(level)
            PersistenceManager.shared.saveAccumulatedXP(accumulatedXP)
        }
    }

    private func calculateMaxXP(for level: Int) -> Int {
        return 100 + (level - 1) * 50
    }

    private func resetTaskCompletionIfNeeded() {
        // Assuming we reset task completion every day at midnight
        let lastResetDateKey = "lastResetDate"
        let defaults = UserDefaults.standard

        if let lastResetDate = defaults.object(forKey: lastResetDateKey) as? Date {
            if !Calendar.current.isDateInToday(lastResetDate) {
                resetTaskCompletion()
                defaults.set(Date(), forKey: lastResetDateKey)
            }
        } else {
            defaults.set(Date(), forKey: lastResetDateKey)
        }
    }

    private func resetTaskCompletion() {
        for index in tasks.indices {
            tasks[index].completed = false
        }
        PersistenceManager.shared.saveTasks(tasks)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
