import SwiftUI
import Firebase
import GoogleSignIn
import AuthenticationServices

struct GoogleSignInButtonWrapper: UIViewRepresentable {
    @EnvironmentObject var authViewModel: AuthViewModel

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        let button = GIDSignInButton()
        button.style = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            containerView.widthAnchor.constraint(equalToConstant: 312)
        ])
        
        button.addTarget(context.coordinator, action: #selector(Coordinator.signInTapped), for: .touchUpInside)
        
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

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

                GoogleSignInButtonWrapper()
                    .frame(width: 312, height: 50)
                    .cornerRadius(25)
                
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
