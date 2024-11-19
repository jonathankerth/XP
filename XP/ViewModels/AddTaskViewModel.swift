import Foundation
import SwiftUI

class AddTaskViewModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var taskXP: Int = 1
    @Published var taskFrequency: TaskFrequency = .oneDay
    @Published var taskCategory: TaskCategory = .hobbies
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
        if !taskName.isEmpty {
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
                lastReset: Date(), // Set current date as the last reset time
                resetFrequency: taskFrequency.rawValue,
                xpAwarded: false
            )
            tasks.wrappedValue.append(newTask)
            if let userID = authViewModel.currentUser?.uid {
                PersistenceManager.shared.addTask(userID: userID, task: newTask)
            }
            taskName = ""
            taskXP = 1
            taskFrequency = .oneDay
            taskCategory = .hobbies  // Reset category
            onTasksChange()
            showAddTaskForm.wrappedValue = false
        }
    }

    func cancel() {
        showAddTaskForm.wrappedValue = false
    }

    private func calculateNextDueDate(for frequency: TaskFrequency) -> Date? {
        let calendar = Calendar.current
        let timeZone = TimeZone(identifier: "America/Los_Angeles")! // PST
        
        // Get the current date components in PST
        let currentDate = Date()
        var currentComponents = calendar.dateComponents(in: timeZone, from: currentDate)
        
        // If the task is completed today, we want to target the next midnight
        // Increment the day by the frequency
        currentComponents.day = (currentComponents.day ?? 0) + frequency.rawValue
        
        // Set the time to midnight
        currentComponents.hour = 0
        currentComponents.minute = 0
        currentComponents.second = 0
        
        // Return the next reset date (midnight of the next day after frequency days)
        return calendar.date(from: currentComponents)
    }


}
