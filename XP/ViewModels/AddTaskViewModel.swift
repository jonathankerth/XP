import SwiftUI
import Foundation

class AddTaskViewModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var taskXP: Int = 1
    var tasks: Binding<[XPTask]>
    var showAddTaskForm: Binding<Bool>
    var onTasksChange: () -> Void

    init(tasks: Binding<[XPTask]>, showAddTaskForm: Binding<Bool>, onTasksChange: @escaping () -> Void) {
        self.tasks = tasks
        self.showAddTaskForm = showAddTaskForm
        self.onTasksChange = onTasksChange
    }

    func addTask() {
        if !taskName.isEmpty {
            let newTask = XPTask(name: taskName, xp: taskXP)
            tasks.wrappedValue.append(newTask)
            taskName = ""
            taskXP = 1
            onTasksChange()
            showAddTaskForm.wrappedValue = false
        }
    }

    func cancel() {
        showAddTaskForm.wrappedValue = false
    }
}
