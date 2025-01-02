import SwiftUI

struct ProfileInfoView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var showConfirmationDialog = false
    @State private var deletionSuccess = false

    var body: some View {
        VStack {
            Text("Profile Info")
                .font(.largeTitle)
                .padding()
                .font(Font.custom("SpotLight-Regular", size: 24))  // Use the PostScript name here

            Spacer()

            Button(action: {
                showConfirmationDialog = true  // Show the confirmation dialog
            }) {
                Text("Delete Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()

                // Confirmation Alert
                .confirmationDialog(
                    "Are you sure you want to delete your account? This action cannot be undone.",
                    isPresented: $showConfirmationDialog
                ) {
                    Button("Delete Account", role: .destructive) {
                        deleteCurrentUser()
                    }
                    Button("Cancel", role: .cancel) {}
                }
        }
        .alert(
            "Account Deleted",
            isPresented: $deletionSuccess,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text("Your account has been successfully deleted.")
            }
        )
    }
    private func deleteCurrentUser() {
        // Use displayName directly if it's a non-optional String
        let email = viewModel.displayName
        let success = DBController.shared.deleteUserByEmail(email: email)
        if success {
            deletionSuccess = true
            print("User deleted successfully.")
            // Handle further actions like logging the user out
        } else {
            print("Failed to delete the user.")
        }
    }
}
