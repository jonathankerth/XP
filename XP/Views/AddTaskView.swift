import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: AddTaskViewModel

    var body: some View {
        VStack(spacing: 20) {
            TextField("Task Name", text: $viewModel.taskName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            Picker("XP Value", selection: $viewModel.taskXP) {
                ForEach(1..<101) { xp in
                    Text("\(xp) XP").tag(xp)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)

            Picker("Frequency", selection: $viewModel.taskFrequency) {
                ForEach(TaskFrequency.allCases) { frequency in
                    Text(frequency.description).tag(frequency)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            
            Picker("Category", selection: $viewModel.taskCategory) {
                ForEach(TaskCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)

            HStack {
                Button(action: {
                    viewModel.addTask()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .imageScale(.large)
                        Text("Add Task")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }

                Button(action: {
                    viewModel.cancel()
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
}
