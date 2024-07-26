import SwiftUI

struct ProfileView: View {
    var tasks: [XPTask]
    @Environment(\.presentationMode) var presentationMode

    @StateObject private var persistenceManager = PersistenceManager.shared
    @State private var editIndex: Int? = nil

    var body: some View {
        VStack {
            List {
                Section(header: Text("Past Tasks")) {
                    ForEach(tasks) { task in
                        Text(task.name)
                    }
                }

                Section(header: Text("Level Rewards")) {
                    ForEach(0..<66, id: \.self) { index in
                        VStack {
                            HStack {
                                Text("Level \(index + 1)")
                                Spacer()
                                if editIndex == index {
                                    Button("Close") {
                                        saveReward(index: index)
                                        editIndex = nil
                                    }
                                } else {
                                    Button("Edit") {
                                        editIndex = index
                                    }
                                }
                            }
                            if editIndex == index {
                                TextField("Reward", text: Binding(
                                    get: {
                                        if index < persistenceManager.levelRewards.count {
                                            return persistenceManager.levelRewards[index]
                                        } else {
                                            return ""
                                        }
                                    },
                                    set: {
                                        if index < persistenceManager.levelRewards.count {
                                            persistenceManager.levelRewards[index] = $0
                                        } else {
                                            persistenceManager.levelRewards.append($0)
                                        }
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                if index < persistenceManager.levelRewards.count && !persistenceManager.levelRewards[index].isEmpty {
                                    Text(persistenceManager.levelRewards[index])
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Home") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func saveReward(index: Int) {
        persistenceManager.saveLevelRewards(persistenceManager.levelRewards)
    }
}
