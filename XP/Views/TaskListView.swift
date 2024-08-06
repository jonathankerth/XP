import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [XPTask]
    var onTasksChange: () -> Void

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(task.name)
                            Spacer()
                            Text("\(task.xp) XP")
                            Button(action: {
                                tasks[index].completed.toggle()
                                tasks[index].lastCompleted = tasks[index].completed ? Date() : nil
                                onTasksChange()
                            }) {
                                Image(systemName: tasks[index].completed ? "checkmark.square" : "square")
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteTask(at: IndexSet(integer: index))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: moveTask)
            }
            .listStyle(PlainListStyle())
            .onAppear {
                print("Task list is now visible with \(tasks.count) tasks.")
            }
        }
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        onTasksChange()
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        onTasksChange()
    }
}
