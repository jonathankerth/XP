import Foundation
import FirebaseAuth

class SignUpViewModel: AuthViewModel {
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    override func signUp(firstName: String, lastName: String, completion: @escaping (Bool) -> Void) {
        self.firstName = firstName
        self.lastName = lastName
        
        super.signUp(firstName: firstName, lastName: lastName) { success in
            if success {
                if let userID = Auth.auth().currentUser?.uid {
                    FirestoreManager.shared.saveUserProfile(userID: userID, firstName: firstName, lastName: lastName) { error in
                        if let error = error {
                            print("Error saving user profile: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
}
