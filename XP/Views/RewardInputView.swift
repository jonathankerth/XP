import SwiftUI

struct RewardInputView: View {
    @ObservedObject var viewModel: RewardInputViewModel

    var body: some View {
        VStack {
            Text("Set Reward for Current Level")
                .font(.headline)
            TextField("Enter reward", text: $viewModel.reward)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button(action: {
                    viewModel.cancel()
                }) {
                    Text("Cancel")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    viewModel.setReward()
                }) {
                    Text("Set Reward")
                        .padding()
                        .background(Color.blue)
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
