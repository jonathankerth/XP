import SwiftUI

struct CategoryExperienceCardView: View {
    @ObservedObject var viewModel: CategoryExperienceCardViewModel

    var body: some View {
        VStack {
            Text("Experience by Category")
                .font(.headline)
            ForEach(TaskCategory.allCases, id: \.self) { category in
                if let xp = viewModel.experienceByCategory[category] {
                    Text("\(category.rawValue): \(xp) XP")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
