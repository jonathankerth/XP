import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = Auth.auth().currentUser != nil

    func signIn(completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                self.isAuthenticated = true
                completion(true)
            }
        }
    }

    func signUp(completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                self.signIn { signInSuccess in
                    completion(signInSuccess)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
        } catch let error {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
}
