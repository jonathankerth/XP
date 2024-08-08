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

            Picker("Reset Frequency (days)", selection: $viewModel.resetFrequency) {
                ForEach(1..<8) { frequency in
                    Text("\(frequency) day\(frequency > 1 ? "s" : "")").tag(frequency)
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
                    .background(Color.black)
                    .foregroundColor(.white)
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
