import SwiftUI
import FirebaseAuth

class SettingsViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var errorMessage: String?
    private var userID: String? {
        return Auth.auth().currentUser?.uid
    }

    func loadUserData() {
        if let userID = userID {
            FirestoreManager.shared.fetchUserProfile(userID: userID, completion: { [weak self] (fetchedFirstName: String?, fetchedLastName: String?, error: Error?) in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.firstName = fetchedFirstName ?? ""
                    self?.lastName = fetchedLastName ?? ""
                }
            })
        }
    }

    func updateUserName() {
        guard !firstName.isEmpty && !lastName.isEmpty else {
            errorMessage = "First and last name cannot be empty."
            return
        }

        if let userID = userID {
            FirestoreManager.shared.saveUserProfile(userID: userID, firstName: firstName, lastName: lastName, completion: { [weak self] (error: Error?) in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = "Name updated successfully."
                }
            })
        }
    }

    func updatePassword() {
        guard !newPassword.isEmpty else {
            errorMessage = "New password cannot be empty."
            return
        }

        if let user = Auth.auth().currentUser, let providerData = user.providerData.first {
            if providerData.providerID == "password" {
                // Re-authenticate the user with their current password before updating
                let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
                user.reauthenticate(with: credential) { [weak self] result, error in
                    if let error = error {
                        self?.errorMessage = "Re-authentication failed: \(error.localizedDescription)"
                    } else {
                        // Update to the new password
                        user.updatePassword(to: self?.newPassword ?? "") { error in
                            if let error = error {
                                self?.errorMessage = "Password update failed: \(error.localizedDescription)"
                            } else {
                                self?.errorMessage = "Password updated successfully."
                            }
                        }
                    }
                }
            } else {
                errorMessage = "Password cannot be updated for this sign-in method."
            }
        }
    }
}
