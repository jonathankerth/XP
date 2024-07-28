import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6) // Grey background behind the tasks
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    VStack(alignment: .leading, spacing: 10) { // Added spacing between tasks
                        HStack {
                            Text(task.name)
                            Spacer()
                            Text("\(task.xp) XP")
                            Button(action: {
                                tasks[index].completed.toggle()
                                tasks[index].lastCompleted = tasks[index].completed ? Date() : nil
                                onTasksChange()
                            }) {
                                Image(systemName: tasks[index].completed ? "checkmark.square" : "square")
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
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteTask(at: IndexSet(integer: index))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: moveTask) // Allow tasks to be moved
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
