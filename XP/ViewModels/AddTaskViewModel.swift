import SwiftUI
import Foundation

class AddTaskViewModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var taskXP: Int = 1
    @Published var resetFrequency: Int = 1
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
            let newTask = XPTask(id: UUID().uuidString, name: taskName, xp: taskXP, completed: false, lastCompleted: nil, resetFrequency: resetFrequency)
            tasks.wrappedValue.append(newTask)
            if let userID = authViewModel.currentUser?.uid {
                PersistenceManager.shared.addTask(userID: userID, task: newTask)
            }
            taskName = ""
            taskXP = 1
            resetFrequency = 1
            onTasksChange()
            showAddTaskForm.wrappedValue = false
        }
    }

    func cancel() {
        showAddTaskForm.wrappedValue = false
    }
}
