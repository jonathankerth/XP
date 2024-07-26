import SwiftUI

struct ProfileView: View {
    var tasks: [XPTask]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            List {
                Section(header: Text("Past Tasks")) {
                    ForEach(tasks) { task in
                        Text(task.name)
                    }
                }
                Section(header: Text("Past Rewards")) {
                    // Add logic to display past rewards if stored
                }
                Section(header: Text("Edit Future Rewards")) {
                    // Add logic to edit future rewards if needed
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Home") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
