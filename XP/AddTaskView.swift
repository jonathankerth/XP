import SwiftUI

struct AddTaskView: View {
    @Binding var tasks: [XPTask]
    @Binding var totalXP: Int
    @State private var taskName: String = ""
    @State private var taskXP: String = ""
    var onTasksChange: () -> Void

    var body: some View {
        VStack {
            TextField("Task Name", text: $taskName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("XP Value", text: $taskXP)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()

            Button(action: addTask) {
                Text("Add Task")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }

    func addTask() {
        if let xpValue = Int(taskXP), !taskName.isEmpty {
            let newTask = XPTask(name: taskName, xp: xpValue)
            tasks.append(newTask)
            totalXP += xpValue
            taskName = ""
            taskXP = ""
            onTasksChange()
        }
    }
}
