import SwiftUI
import Firebase
import GoogleSignIn
import AuthenticationServices

// Wrapper for GIDSignInButton to be used in SwiftUI
struct GoogleSignInButtonWrapper: UIViewRepresentable {
    @EnvironmentObject var authViewModel: AuthViewModel

    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.style = .wide
        button.addTarget(context.coordinator, action: #selector(Coordinator.signInTapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: GoogleSignInButtonWrapper

        init(_ parent: GoogleSignInButtonWrapper) {
            self.parent = parent
        }

        @objc func signInTapped() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                parent.authViewModel.signInWithGoogle(presentingViewController: rootViewController) { success in
                    if success {
                        // Handle successful Google sign-in
                    } else {
                        // Handle Google sign-in failure
                    }
                }
            }
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false

    var body: some View {
        VStack {
            // Email and Password Fields
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Sign In with Google Button
            GoogleSignInButtonWrapper()
                .frame(height: 50)
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
