import SwiftUI

struct RewardInputView: View {
    @Binding var reward: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Set Reward for Next Level")
                .font(.headline)
            TextField("Enter reward", text: $reward)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    isPresented = false
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
