import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            List {
                Section(header: Text("Level Rewards")) {
                    ForEach(0..<66, id: \.self) { index in
                        VStack {
                            HStack {
                                Text("Level \(index + 1)")
                                Spacer()
                                if viewModel.editIndex == index {
                                    Button("Close") {
                                        viewModel.closeEdit()
                                    }
                                } else {
                                    Button("Edit") {
                                        viewModel.editReward(at: index)
                                    }
                                }
                            }
                            if viewModel.editIndex == index {
                                TextField("Reward", text: Binding(
                                    get: {
                                        if index < viewModel.levelRewards.count {
                                            return viewModel.levelRewards[index]
                                        } else {
                                            return ""
                                        }
                                    },
                                    set: {
                                        viewModel.updateReward(at: index, with: $0)
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                if index < viewModel.levelRewards.count && !viewModel.levelRewards[index].isEmpty {
                                    Text(viewModel.levelRewards[index])
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
            .navigationBarItems(
                leading: Button("Home") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Sign Out") {
                    authViewModel.signOut()
                }
            )
        }
    }
}
