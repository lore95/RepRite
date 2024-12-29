import SwiftUI

// MARK: - Settings View
struct ProfileInfoView: View {
    var body: some View {
        VStack {
            Text("Profile Info")
                .font(.largeTitle)
                .padding()
                .font(Font.custom("SpotLight-Regular", size: 24)) // Use the PostScript name here
            Spacer()
        }
    }
}
