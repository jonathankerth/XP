import SwiftUI

struct AddTaskView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void

    @State private var taskName: String = ""
    @State private var taskXP: Int = 1
    @State private var resetIntervalDays: Int = 1
    @State private var showAddTaskForm: Bool = false

    var body: some View {
        VStack {
            Button(action: {
                showAddTaskForm.toggle()
            }) {
                Text(showAddTaskForm ? "Hide Add Task" : "Show Add Task")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if showAddTaskForm {
                TextField("Task Name", text: $taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Picker("XP Value", selection: $taskXP) {
                    ForEach(1..<101) { xp in
                        Text("\(xp) XP").tag(xp)
                    }
                }
                .padding()

                HStack {
                    Text("Task Frequency")
                    Picker("Reset Interval (days)", selection: $resetIntervalDays) {
                        ForEach(1..<31) { day in
                            Text("\(day) days").tag(day)
                        }
                    }
                }
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
    }

    func addTask() {
        if !taskName.isEmpty {
            let newTask = XPTask(name: taskName, xp: taskXP, resetIntervalDays: resetIntervalDays)
            tasks.append(newTask)
            taskName = ""
            taskXP = 1
            resetIntervalDays = 1
            onTasksChange()
            showAddTaskForm = false // Hide the form after adding the task
        }
    }
}
