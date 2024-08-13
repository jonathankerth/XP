import SwiftUI

struct XPBar: View {
    var totalXP: Int
    var maxXP: Int
    var level: Int
    var reward: String

    var body: some View {
        VStack {
            Text("Level \(level)")
                .font(.title)
                .foregroundColor(.white) // Change text color to white
            Text("Total XP: \(totalXP)/\(maxXP)")
                .font(.headline)
                .foregroundColor(.white) // Change text color to white
            ProgressView(value: Double(totalXP), total: Double(maxXP))
                .progressViewStyle(LinearProgressViewStyle())
                .padding([.leading, .trailing])
            if !reward.isEmpty {
                Text("Reward: \(reward)")
                    .font(.subheadline)
                    .foregroundColor(.white) // Change text color to white
            }
        }
        .padding([.leading, .trailing])
    }
}
