import Foundation

class CategoryExperienceCardViewModel: ObservableObject {
    @Published var experienceByCategory: [TaskCategory: Int] = [:]

    private var tasks: [XPTask]

    init(tasks: [XPTask]) {
        self.tasks = tasks
        calculateExperienceByCategory()
    }

    private func calculateExperienceByCategory() {
        experienceByCategory = tasks.filter { $0.completed }
                                    .reduce(into: [TaskCategory: Int]()) { result, task in
                                        result[task.category, default: 0] += task.xp
                                    }
    }
}
