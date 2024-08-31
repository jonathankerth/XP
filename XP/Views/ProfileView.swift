import SwiftUI
import FirebaseAuth


struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showSettings = false
    @State private var fullName: String?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView() // Add the background view

                VStack {
                    if let user = Auth.auth().currentUser {
                        Text("Hello, \(fullName ?? user.email ?? "User")")
                            .font(.headline)
                            .foregroundColor(.white) // Make the text white for better contrast
                            .padding(.top, 100) // Increase the padding from the top
                            .padding(.horizontal)
                    }

                    // Cards Section
                    VStack(spacing: 20) {
                        TopCategoryCardView(viewModel: TopCategoryCardViewModel(tasks: viewModel.tasks))
                        CategoryExperienceCardView(viewModel: CategoryExperienceCardViewModel(tasks: viewModel.tasks))
                        StreakCardView(viewModel: StreakCardViewModel(tasks: viewModel.tasks))
                    }
                    .padding(.horizontal)

                    List {
                        Section(header: Text("Level Rewards").foregroundColor(.white)) {
                            ForEach(0..<66, id: \.self) { index in
                                VStack {
                                    HStack {
                                        Text("Level \(index + 1)")
                                            .background(Color.clear)
                                            .foregroundColor(.white) // Ensure the level text is white
                                        Spacer()
                                        if viewModel.editIndex == index {
                                            Button("Close") {
                                                viewModel.closeEdit()
                                            }
                                            .foregroundColor(.white)
                                        } else {
                                            Button("Edit") {
                                                viewModel.editReward(at: index)
                                            }
                                            .foregroundColor(.white)
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
                                                .foregroundColor(.white) // Ensure the reward text is white
                                        }
                                    }
                                }
                                .listRowBackground(Color.clear) // Clear background for each list row
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .background(Color.clear) // Ensure the list background is clear
                    .scrollContentBackground(.hidden) // Ensure the entire list has a clear background
                }
                .padding(.horizontal)
            }
            .onAppear {
                loadUserFullName()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(viewModel: SettingsViewModel())
            }
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .navigationBarItems(
                leading: HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white) // Custom back arrow with white color
                            Text("Home")
                                .foregroundColor(.white) // Home text with white color
                        }
                    }
                },
                trailing: HStack {
                    Button("Sign Out") {
                        authViewModel.signOut()
                        dismiss()
                    }
                    .foregroundColor(.white) // Set the Sign Out text color to white

                    Button(action: {
                        showSettings = true // Trigger the NavigationLink programmatically
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white) // Settings icon with white color
                    }
                }
            )
        }
    }

    // Function to load the user's full name from Firestore
    private func loadUserFullName() {
        if let userID = Auth.auth().currentUser?.uid {
            FirestoreManager.shared.fetchUserProfile(userID: userID) { firstName, lastName, error in
                if let firstName = firstName, let lastName = lastName {
                    self.fullName = "\(firstName) \(lastName)"
                } else {
                    // No full name, use email instead
                    self.fullName = Auth.auth().currentUser?.email
                }
            }
        }
    }
}
