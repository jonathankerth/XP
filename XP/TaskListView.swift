import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void

    var body: some View {
        List {
            ForEach($tasks) { $task in
                VStack(alignment: .leading) {
                    HStack {
                        Text(task.name)
                        Spacer()
                        Text("\(task.xp) XP")
                        Button(action: {
                            task.completed.toggle()
                            task.lastCompleted = task.completed ? Date() : nil
                            onTasksChange()
                        }) {
                            Image(systemName: task.completed ? "checkmark.square" : "square")
                        }
                    }
                    HStack {
                        Text("Resets every \(task.resetIntervalDays) days")
                    }
                }
            }
            .onDelete(perform: deleteTask)
        }
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        onTasksChange()
    }
}
