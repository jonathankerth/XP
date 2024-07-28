import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6) // Grey background behind the tasks
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach($tasks) { $task in
                    VStack(alignment: .leading, spacing: 10) { // Added spacing between tasks
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
                    .padding()
                    .background(Color.white) // White background for each task
                    .cornerRadius(20) // Rounded the corners more
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Added shadow for better visual separation
                    .listRowSeparator(.hidden) // Remove the separator line between tasks
                    .draggable(task) // Make the task draggable
                }
                .onMove(perform: moveTask) // Allow tasks to be moved
                .onDelete(perform: deleteTask)
            }
            .listStyle(PlainListStyle()) // Ensure the list has no additional styling
        }
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        onTasksChange()
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        onTasksChange()
    }
}
