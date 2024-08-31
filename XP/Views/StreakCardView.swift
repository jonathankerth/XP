import SwiftUI

struct StreakCardView: View {
    @ObservedObject var viewModel: StreakCardViewModel

    var body: some View {
        VStack {
            Text("Current Streak")
                .font(.headline)
            Text("\(viewModel.streak) days")
                .font(.title)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
