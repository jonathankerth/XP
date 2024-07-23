import SwiftUI

struct ContentView: View {
    @State private var tasks: [XPTask] = PersistenceManager.shared.loadTasks()
    @State private var totalXP: Int = 0
    @State private var level: Int = 1
    @State private var maxXP: Int = 100

    var body: some View {
        NavigationView {
            VStack {
                XPBar(totalXP: totalXP, maxXP: maxXP, level: level)
                TaskListView(tasks: $tasks, totalXP: $totalXP, onTasksChange: saveTasks)
                AddTaskView(tasks: $tasks, totalXP: $totalXP, onTasksChange: saveTasks)
            }
            .navigationTitle("XP App")
            .onAppear {
                calculateTotalXP()
            }
        }
    }

    private func saveTasks() {
        PersistenceManager.shared.saveTasks(tasks)
        calculateTotalXP()
    }

    private func calculateTotalXP() {
        totalXP = tasks.filter { $0.completed }.reduce(0) { $0 + $1.xp }
        checkLevelUp()
    }

    private func checkLevelUp() {
        if totalXP >= maxXP {
            level += 1
            totalXP -= maxXP
            maxXP = calculateMaxXP(for: level)
        }
    }

    private func calculateMaxXP(for level: Int) -> Int {
        return 100 + (level - 1) * 50
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
