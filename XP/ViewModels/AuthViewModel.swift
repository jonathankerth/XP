import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import CryptoKit
import AuthenticationServices

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = Auth.auth().currentUser != nil
    @Published var currentUser: User?
    @Published var currentNonce: String?

    init() {
        self.currentUser = Auth.auth().currentUser
    }

    // MARK: - Email/Password Authentication
    func signIn(completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                self.isAuthenticated = true
                self.currentUser = result?.user
                completion(true)
            }
        }
    }

    func signUp(firstName: String, lastName: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                self.updateUserProfile(firstName: firstName, lastName: lastName) { success in
                    self.signIn { signInSuccess in
                        completion(signInSuccess)
                    }
                }
            }
        }
    }

    private func updateUserProfile(firstName: String, lastName: String, completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = "\(firstName) \(lastName)"
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Failed to update profile: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("User profile updated")
                    completion(true)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch let error {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }

    // MARK: - Google Sign-In
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [unowned self] result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(false)
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                print("Successfully signed in with Google!")
                self.isAuthenticated = true
                self.currentUser = authResult?.user
                completion(true)
            }
        }
    }

    // MARK: - Apple Sign-In
    func handleSignInWithApple(result: ASAuthorization) {
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        guard let identityToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }

        guard let idTokenString = String(data: identityToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(identityToken.debugDescription)")
            return
        }

        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }

        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce,
            accessToken: nil
        )

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error authenticating: \(error.localizedDescription)")
                return
            }

            print("Successfully signed in with Apple!")
            self.isAuthenticated = true
            self.currentUser = authResult?.user
        }
    }

    // MARK: - Helper Methods
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02x", $0) }.joined()

        return hashString
    }
}
