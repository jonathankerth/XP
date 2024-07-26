import SwiftUI

struct ContentView: View {
    @State private var tasks: [XPTask] = PersistenceManager.shared.loadTasks()
    @State private var accumulatedXP: Int = PersistenceManager.shared.loadAccumulatedXP()
    @State private var level: Int = PersistenceManager.shared.loadLevel()
    @State private var maxXP: Int = 100
    @State private var reward: String = PersistenceManager.shared.loadReward()

    @State private var showAddTaskForm = false
    @State private var showAddRewardForm = false
    @State private var showOptions = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: ProfileView(tasks: tasks)) {
                        HStack {
                            Image(systemName: "person.circle")
                                .imageScale(.large)
                            Text("Profile")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .padding()
                    Spacer()
                }

                XPBar(totalXP: accumulatedXP, maxXP: maxXP, level: level, reward: reward)
                TaskListView(tasks: $tasks, onTasksChange: saveTasks)

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
                                .cornerRadius(8)
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
                                .cornerRadius(8)
                        }
                    }
                }

                if showAddTaskForm {
                    VStack(spacing: 20) {
                        AddTaskView(tasks: $tasks, onTasksChange: {
                            saveTasks()
                        }, showAddTaskForm: $showAddTaskForm)
                    }
                    .padding()
                }

                if showAddRewardForm {
                    VStack(spacing: 20) {
                        RewardInputView(reward: $reward, isPresented: $showAddRewardForm)
                    }
                    .padding()
                }
            }
            .onAppear {
                calculateAccumulatedXP()
                resetTaskCompletionIfNeeded()
            }
            .navigationTitle("")
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
        let now = Date()
        for index in tasks.indices {
            if let lastCompleted = tasks[index].lastCompleted,
               let resetInterval = Calendar.current.date(byAdding: .day, value: tasks[index].resetIntervalDays, to: lastCompleted),
               now >= resetInterval {
                tasks[index].completed = false
                tasks[index].lastCompleted = nil
            }
        }
        PersistenceManager.shared.saveTasks(tasks)
    }
}
