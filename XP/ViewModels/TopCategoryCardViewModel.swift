import Foundation

class TopCategoryCardViewModel: ObservableObject {
    @Published var topCategory: TaskCategory?
    @Published var topCategoryCount: Int = 0

    private var tasks: [XPTask]

    init(tasks: [XPTask]) {
        self.tasks = tasks
        calculateTopCategory()
    }

    private func calculateTopCategory() {
        let categoryCount = tasks.filter { $0.completed }
                                 .reduce(into: [TaskCategory: Int]()) { counts, task in
                                     counts[task.category, default: 0] += 1
                                 }

        if let (category, count) = categoryCount.max(by: { $0.value < $1.value }) {
            topCategory = category
            topCategoryCount = count
        }
    }
}
