import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct CustomGoogleSignInButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: {
            signInWithGoogle()
        }) {
            HStack {
                Image("google_logo") // Add a Google logo image in your assets with this name
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(width: 312, height: 50)
            .background(Color.white)
            .foregroundColor(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .cornerRadius(25)
        }
    }
    
    private func signInWithGoogle() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            authViewModel.signInWithGoogle(presentingViewController: rootViewController) { success in
                if success {
                    // Handle successful Google sign-in
                } else {
                    // Handle Google sign-in failure
                }
            }
        }
    }
}
