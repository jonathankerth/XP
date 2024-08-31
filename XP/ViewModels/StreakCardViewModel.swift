import Foundation

class StreakCardViewModel: ObservableObject {
    @Published var streak: Int = 0

    private var tasks: [XPTask]

    init(tasks: [XPTask]) {
        self.tasks = tasks
        calculateStreak()
    }

    private func calculateStreak() {
        let sortedTasks = tasks.filter { $0.completed }
                               .sorted { $0.lastCompleted ?? Date.distantPast > $1.lastCompleted ?? Date.distantPast }
        
        var currentStreak = 0
        var previousDate: Date?

        for task in sortedTasks {
            guard let completedDate = task.lastCompleted else { continue }

            if let prevDate = previousDate {
                if Calendar.current.isDate(completedDate, inSameDayAs: prevDate) {
                    continue
                } else if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: completedDate), Calendar.current.isDate(prevDate, inSameDayAs: nextDate) {
                    currentStreak += 1
                } else {
                    break
                }
            } else {
                currentStreak = 1
            }

            previousDate = completedDate
        }

        streak = currentStreak
    }
}
