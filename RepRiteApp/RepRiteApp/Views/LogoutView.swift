
import SwiftUI


// MARK: - Logout View
struct LogoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack {
            Text("Logout")
                .font(Font.custom("SpotLight-Regular", size: 40)) // Custom Font for Repetitions
                .padding()
            
            Button(action: {
                viewModel.signOut()
                presentationMode.wrappedValue.dismiss()
                
            }) {
                Text("Confirm Logout")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
}
