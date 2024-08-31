import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            BackgroundView() // Reuse the background from ProfileView
            
            VStack(spacing: 20) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                TextField("First Name", text: $viewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Last Name", text: $viewModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Current Password", text: $viewModel.currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("New Password", text: $viewModel.newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.updateUserName()
                }) {
                    Text("Update Name")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.updatePassword()
                }) {
                    Text("Update Password")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 100) // Ensure there's enough space at the top
        }
        .onAppear {
            viewModel.loadUserData()
        }
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(
            leading: Button(action: {
                dismiss() // Navigate back to the ProfileView
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                    Text("Home")
                        .foregroundColor(.white)
                }
            }
        )
    }
}
