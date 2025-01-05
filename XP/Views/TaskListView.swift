import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        List {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                TaskRowView(
                    task: task,
                    onToggle: { updatedTask in
                        toggleTask(at: index, with: updatedTask)
                    }
                )
                .listRowBackground(Color.clear)
            }
            .onMove(perform: moveTask)
            .onDelete(perform: deleteTask)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }

    private func toggleTask(at index: Int, with updatedTask: XPTask) {
        var task = updatedTask
        if !task.completed {
            task.completed = true
            task.lastCompleted = Date()
            task.xpAwarded = false
        } else {
            task.completed = false
            task.lastCompleted = nil
        }
        updateNextDueDate(for: &task)
        
        if let userID = authViewModel.currentUser?.uid {
            PersistenceManager.shared.updateTask(userID: userID, task: task) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to update task: \(error.localizedDescription)"
                        showError = true
                    }
                } else {
                    DispatchQueue.main.async {
                        if index < tasks.count {
                            tasks[index] = task
                            onTasksChange()
                        }
                    }
                }
            }
        }
    }

    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            if let userID = authViewModel.currentUser?.uid {
                let taskID = tasks[index].id
                PersistenceManager.shared.deleteTask(userID: userID, taskID: taskID) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            errorMessage = "Failed to delete task: \(error.localizedDescription)"
                            showError = true
                        }
                    }
                }
            }
        }
        tasks.remove(atOffsets: offsets)
        onTasksChange()
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        onTasksChange()
    }

    private func updateNextDueDate(for task: inout XPTask) {
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
}

struct TaskRowView: View {
    let task: XPTask
    let onToggle: (XPTask) -> Void
    
    var body: some View {
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
                    onToggle(task)
                }) {
                    Image(systemName: task.completed ? "checkmark.square.fill" : "square")
                        .foregroundColor(task.completed ? .green : .gray)
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
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
