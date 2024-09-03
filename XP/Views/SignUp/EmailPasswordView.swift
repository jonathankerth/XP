import SwiftUI

struct EmailPasswordView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @State private var email: String = ""
    @State private var confirmEmail: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var navigateToNext = false

    var firstName: String
    var lastName: String

    var body: some View {
        NavigationStack {
            ZStack {
                Image("blank_landing_page")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
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

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        validateAndProceed()
                    }) {
                        Text("Next")
                            .frame(width: 312, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }

                    .navigationDestination(isPresented: $navigateToNext) {
                        NotificationPermissionView(firstName: firstName, lastName: lastName, email: email, password: password)
                            .environmentObject(signUpViewModel)
                    }
                }
                .padding()
            }
        }
    }

    func validateAndProceed() {
        guard email == confirmEmail else {
            errorMessage = "Emails do not match."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }

        errorMessage = nil

        signUpViewModel.email = email
        signUpViewModel.password = password

        navigateToNext = true
    }
}
