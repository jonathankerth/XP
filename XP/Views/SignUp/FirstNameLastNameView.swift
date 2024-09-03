import SwiftUI

struct FirstNameLastNameView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var errorMessage: String?
    @State private var navigateToNext = false // State to control navigation

    var body: some View {
        NavigationStack {
            ZStack {
                Image("blank_landing_page")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
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

                    NavigationLink(
                        destination: EmailPasswordView(firstName: firstName, lastName: lastName)
                            .environmentObject(signUpViewModel),
                        isActive: $navigateToNext
                    ) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }

    func validateAndProceed() {
        guard !firstName.isEmpty else {
            errorMessage = "First Name cannot be empty."
            return
        }

        guard !lastName.isEmpty else {
            errorMessage = "Last Name cannot be empty."
            return
        }

        // Save the names to the ViewModel
        signUpViewModel.firstName = firstName
        signUpViewModel.lastName = lastName

        // Clear any error message
        errorMessage = nil

        // Trigger navigation to the next view
        navigateToNext = true
    }
}
