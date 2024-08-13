import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Image("Blank BG") // Use the name of the image in your Assets folder
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
}
