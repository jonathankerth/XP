import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    @Binding var totalXP: Int
    var onTasksChange: () -> Void

    var body: some View {
        List {
            ForEach($tasks) { $task in
                HStack {
                    Text(task.name)
                    Spacer()
                    Text("\(task.xp) XP")
                    Button(action: {
                        task.completed.toggle()
                        onTasksChange()
                    }) {
                        Image(systemName: task.completed ? "checkmark.square" : "square")
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
