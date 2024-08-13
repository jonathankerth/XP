import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var confirmEmail: String = ""
    @State private var confirmPassword: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""

    var body: some View {
        ZStack {
            BackgroundView() // Add the background view here

            VStack(spacing: 16) {
                Image("XP Header Logo")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .autocapitalization(.words)
                
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .autocapitalization(.words)

                TextField("Email", text: $authViewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                TextField("Confirm Email", text: $confirmEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Password", text: $authViewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button(action: {
                    guard authViewModel.email == confirmEmail else {
                        print("Emails do not match.")
                        return
                    }
                    
                    guard authViewModel.password == confirmPassword else {
                        print("Passwords do not match.")
                        return
                    }

                    authViewModel.signUp(firstName: firstName, lastName: lastName) { success in
                        if success {
                            dismiss()
                        } else {
                            // Handle sign-up failure
                        }
                    }
                }) {
                    Text("Sign Up")
                        .frame(width: 312, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.top, 10)


                Button(action: {
                    dismiss()
                }) {
                    Text("Already have an account? Sign in")

                }
                .padding(.bottom, 60) // Minimal bottom padding to avoid going off-screen
            }
            .padding()
        }
    }
}
