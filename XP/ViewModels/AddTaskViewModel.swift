import Foundation
import SwiftUI

class AddTaskViewModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var taskXP: Int = 1
    @Published var taskFrequency: TaskFrequency = .oneDay
    @Published var taskCategory: TaskCategory = .hobbies
    @Published var errorMessage: String?
    
    var tasks: Binding<[XPTask]>
    var showAddTaskForm: Binding<Bool>
    var onTasksChange: () -> Void
    var authViewModel: AuthViewModel

    init(tasks: Binding<[XPTask]>, showAddTaskForm: Binding<Bool>, onTasksChange: @escaping () -> Void, authViewModel: AuthViewModel) {
        self.tasks = tasks
        self.showAddTaskForm = showAddTaskForm
        self.onTasksChange = onTasksChange
        self.authViewModel = authViewModel
    }

    func addTask() {
        guard !taskName.isEmpty else {
            errorMessage = "Task name cannot be empty"
            return
        }

        let nextDueDate = calculateNextDueDate(for: taskFrequency)
        let newTask = XPTask(
            id: UUID().uuidString,
            name: taskName,
            xp: taskXP,
            completed: false,
            lastCompleted: nil,
            nextDueDate: nextDueDate,
            frequency: taskFrequency,
            category: taskCategory,
            lastReset: Date(),
            resetFrequency: taskFrequency.rawValue,
            xpAwarded: false
        )

        if let userID = authViewModel.currentUser?.uid {
            PersistenceManager.shared.addTask(userID: userID, task: newTask) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = "Failed to save task: \(error.localizedDescription)"
                    } else {
                        self?.tasks.wrappedValue.append(newTask)
                        self?.resetForm()
                    }
                }
            }
        } else {
            errorMessage = "User not authenticated"
        }
    }

    private func resetForm() {
        taskName = ""
        taskXP = 1
        taskFrequency = .oneDay
        taskCategory = .hobbies
        onTasksChange()
        showAddTaskForm.wrappedValue = false
    }

    func cancel() {
        showAddTaskForm.wrappedValue = false
    }

    private func calculateNextDueDate(for frequency: TaskFrequency) -> Date? {
        let calendar = Calendar.current
        let timeZone = TimeZone(identifier: "America/Los_Angeles")!
        
        let currentDate = Date()
        var currentComponents = calendar.dateComponents(in: timeZone, from: currentDate)
        currentComponents.day = (currentComponents.day ?? 0) + frequency.rawValue
        currentComponents.hour = 0
        currentComponents.minute = 0
        currentComponents.second = 0
        
        return calendar.date(from: currentComponents)
    }
}
