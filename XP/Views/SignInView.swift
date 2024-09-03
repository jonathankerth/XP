import SwiftUI
import Firebase
import GoogleSignIn
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 16) {
                Image("XP Header Logo")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)

                TextField("Email", text: $authViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $authViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

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
                        .frame(width: 312, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding()

                CustomGoogleSignInButton()
                    .padding(.horizontal)

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
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(width: 312, height: 50)
                .cornerRadius(25)

                Button(action: {
                    showSignUp = true
                }) {
                    Text("Don't have an account? Sign up")
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
}
