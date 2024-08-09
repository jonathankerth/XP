import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(tasks.indices, id: \.self) { index in
                    let task = tasks[index]
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(task.name)
                            Spacer()
                            Text("\(task.xp) XP")
                            Button(action: {
                                tasks[index].completed.toggle()
                                tasks[index].lastCompleted = tasks[index].completed ? Date() : nil
                                updateNextDueDate(for: &tasks[index])
                                onTasksChange()
                                if let userID = authViewModel.currentUser?.uid {
                                    PersistenceManager.shared.updateTask(userID: userID, task: tasks[index])
                                }
                            }) {
                                Image(systemName: tasks[index].completed ? "checkmark.square" : "square")
                            }
                        }
                        // Display the task frequency
                        Text("Frequency: \(task.frequency.description)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if let nextDueDate = task.nextDueDate {
                            Text("Next Due: \(formattedDate(nextDueDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("Category: \(task.category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteTask(at: IndexSet(integer: index))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: moveTask)
            }
            .listStyle(PlainListStyle())
            .onAppear {
                print("Task list is now visible with \(tasks.count) tasks.")
            }
        }
    }

    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            if let userID = authViewModel.currentUser?.uid {
                PersistenceManager.shared.deleteTask(userID: userID, taskID: tasks[index].id)
            }
        }
        tasks.remove(atOffsets: offsets)
        onTasksChange()
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        onTasksChange()
    }

    func updateNextDueDate(for task: inout XPTask) {
        if let lastCompleted = task.lastCompleted {
            task.nextDueDate = Calendar.current.date(byAdding: .day, value: task.frequency.rawValue, to: lastCompleted)
        } else {
            task.nextDueDate = nil
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
