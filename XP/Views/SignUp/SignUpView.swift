import SwiftUI

struct SignUpView: View {
    @StateObject var signUpViewModel = SignUpViewModel()

    var body: some View {
        NavigationView {
            FirstNameLastNameView()
                .environmentObject(signUpViewModel)
        }
    }
}
