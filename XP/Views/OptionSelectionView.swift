import SwiftUI

struct OptionSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var showAddTaskForm: Bool
    @Binding var showAddRewardForm: Bool

    var body: some View {
        VStack {
            Text("What would you like to add?")
                .font(.headline)
            HStack {
                Button(action: {
                    showAddTaskForm = true
                    showAddRewardForm = false
                    isPresented = false
                }) {
                    Text("Add Task")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    showAddRewardForm = true
                    showAddTaskForm = false
                    isPresented = false
                }) {
                    Text("Add Reward")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 10)
    }
}
