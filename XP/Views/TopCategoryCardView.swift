import SwiftUI

struct TopCategoryCardView: View {
    @ObservedObject var viewModel: TopCategoryCardViewModel

    var body: some View {
        VStack {
            Text("Top Category")
                .font(.headline)
            if let category = viewModel.topCategory {
                Text(category.rawValue)
                    .font(.title)
                Text("Completed \(viewModel.topCategoryCount) times")
                    .font(.subheadline)
            } else {
                Text("No tasks completed yet.")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
