import SwiftUI
import UserNotifications

struct NotificationPermissionView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToMainContent = false
    var firstName: String
    var lastName: String
    var email: String
    var password: String

    var body: some View {
        ZStack {
            Image("blank_landing_page")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Enable Notifications")
                    .font(.headline)
                    .foregroundColor(.white)

                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text("Enable Notifications")
                        .frame(width: 312, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }

                Button(action: {
                    completeSignUp()
                }) {
                    Text("Not Now")
                        .frame(width: 312, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $navigateToMainContent) {
            MainContentView().environmentObject(signUpViewModel)
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completeSignUp()
            }
        }
    }

    func completeSignUp() {
        signUpViewModel.signUp(firstName: firstName, lastName: lastName) { success in
            if success {
                DispatchQueue.main.async {
                    navigateToMainContent = true
                }
            } else {
                // Handle sign-up failure
            }
        }
    }
}
