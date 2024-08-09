import SwiftUI
import Firebase
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false

    var body: some View {
        VStack {
            // Email and Password Fields
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Sign In Button
            Button(action: {
                authViewModel.signIn { success in
                    if success {
                        // Handle successful sign-in
                    } else {
                        // Handle sign-in failure
                    }
                }
            }) {
                Text("Sign In")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Sign In with Apple Button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    let nonce = authViewModel.randomNonceString()
                    authViewModel.currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = authViewModel.sha256(nonce)
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        authViewModel.handleSignInWithApple(result: authResults)
                    case .failure(let error):
                        print("Authorization failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)
            .padding()

            // Sign Up Navigation
            Button(action: {
                showSignUp = true
            }) {
                Text("Don't have an account? Sign up here.")
                    .foregroundColor(.blue)
            }
            .padding()
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
        .padding()
    }
}
