import Foundation

class AddTaskViewModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var taskXP: Int = 1
    @Published var tasks: [XPTask]
    @Published var showAddTaskForm: Bool

    var onTasksChange: () -> Void

    init(tasks: [XPTask], showAddTaskForm: Bool, onTasksChange: @escaping () -> Void) {
        self.tasks = tasks
        self.showAddTaskForm = showAddTaskForm
        self.onTasksChange = onTasksChange
    }

    func addTask() {
        if !taskName.isEmpty {
            let newTask = XPTask(name: taskName, xp: taskXP)
            tasks.append(newTask)
            taskName = ""
            taskXP = 1
            onTasksChange()
            showAddTaskForm = false
        }
    }

    func cancel() {
        showAddTaskForm = false
    }
}
