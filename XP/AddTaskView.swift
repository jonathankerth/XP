import SwiftUI

struct AddTaskView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void
    @Binding var showAddTaskForm: Bool

    @State private var taskName: String = ""
    @State private var taskXP: Int = 1

    var body: some View {
        VStack(spacing: 20) {
            TextField("Task Name", text: $taskName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            Picker("XP Value", selection: $taskXP) {
                ForEach(1..<101) { xp in
                    Text("\(xp) XP").tag(xp)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)

            HStack {
                Button(action: {
                    addTask()
                    onTasksChange()
                    showAddTaskForm = false
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .imageScale(.large)
                        Text("Add Task")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Button(action: {
                    showAddTaskForm = false
                }) {
                    Text("Cancel")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding()
    }

    func addTask() {
        if !taskName.isEmpty {
            let newTask = XPTask(name: taskName, xp: taskXP)
            tasks.append(newTask)
            taskName = ""
            taskXP = 1
        }
    }
}
