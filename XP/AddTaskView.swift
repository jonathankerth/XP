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
                Text(showAddTaskForm ? "-" : "+")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding()

            if showAddTaskForm {
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
                        Text("Task Frequency")
                        Picker("Reset Interval (days)", selection: $resetIntervalDays) {
                            ForEach(1..<31) { day in
                                Text("\(day) days").tag(day)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                    Button(action: addTask) {
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
                    .padding()
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
