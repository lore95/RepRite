
import SwiftUI


// MARK: - Logout View
struct LogoutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Logout")
                .font(Font.custom("SpotLight-Regular", size: 40)) // Custom Font for Repetitions
                .padding()
            
            Button(action: {
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
