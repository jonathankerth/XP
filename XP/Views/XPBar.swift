import SwiftUI

struct XPBar: View {
    var accumulatedXP: Int
    var earnedXP: Int
    var maxXP: Int
    var level: Int
    var reward: String

    var body: some View {
        VStack {
            Text("Level \(level)")
                .font(.title)
                .foregroundColor(.white)
            Text("Total XP: \(accumulatedXP + earnedXP)/\(maxXP)")
                .font(.headline)
                .foregroundColor(.white)
            ProgressView(value: Double(accumulatedXP + earnedXP), total: Double(maxXP))
                .progressViewStyle(LinearProgressViewStyle())
                .padding([.leading, .trailing])
            if !reward.isEmpty {
                Text("Reward: \(reward)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
        .padding([.leading, .trailing])
    }
}
