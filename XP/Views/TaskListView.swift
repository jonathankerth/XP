import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        List {
            ForEach(tasks.indices, id: \.self) { index in
                let task = tasks[index]
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(task.name)
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(task.xp) XP")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button(action: {
                            if !tasks[index].completed {
                                tasks[index].completed = true
                                tasks[index].lastCompleted = Date()
                                tasks[index].xpAwarded = false
                            } else {
                                tasks[index].completed = false
                                tasks[index].lastCompleted = nil
                            }
                            updateNextDueDate(for: &tasks[index])
                            onTasksChange()
                            if let userID = authViewModel.currentUser?.uid {
                                PersistenceManager.shared.updateTask(userID: userID, task: tasks[index])
                            }
                        }) {
                            Image(systemName: tasks[index].completed ? "checkmark.square.fill" : "square")
                                .foregroundColor(tasks[index].completed ? .green : .gray)
                        }
                    }

                    Text("Category: \(task.category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Frequency: \(task.frequency.description)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if let nextDueDate = task.nextDueDate {
                        Text("Next Due: \(formattedDate(nextDueDate))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .listRowBackground(Color.clear)
            }
            .onMove(perform: moveTask)
            .onDelete(perform: deleteTask)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
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
        let calendar = Calendar.current
        let timeZone = TimeZone(identifier: "America/Los_Angeles")!
        
        if let lastCompleted = task.lastCompleted {
            var components = DateComponents()
            components.day = task.resetFrequency
            
            if let newDueDate = calendar.date(byAdding: components, to: lastCompleted) {
                var nextDueDateComponents = calendar.dateComponents(in: timeZone, from: newDueDate)
                nextDueDateComponents.hour = 0
                nextDueDateComponents.minute = 0
                nextDueDateComponents.second = 0
                
                task.nextDueDate = calendar.date(from: nextDueDateComponents)
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
