import SwiftUI

struct XPBar: View {
    var totalXP: Int
    var maxXP: Int
    var level: Int

    var body: some View {
        VStack {
            Text("Level \(level)")
                .font(.title)
            Text("Total XP: \(totalXP)/\(maxXP)")
                .font(.headline)
            ProgressView(value: Double(totalXP), total: Double(maxXP))
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
        }
    }
}
