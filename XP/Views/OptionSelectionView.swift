import SwiftUI

struct OptionSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var showAddTaskForm: Bool
    @Binding var showAddRewardForm: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("What would you like to add?")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(spacing: 10) {
                Button(action: {
                    showAddTaskForm = true
                    showAddRewardForm = false
                    isPresented = false
                }) {
                    Text("Add Task")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    showAddRewardForm = true
                    showAddTaskForm = false
                    isPresented = false
                }) {
                    Text("Add Reward")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}
