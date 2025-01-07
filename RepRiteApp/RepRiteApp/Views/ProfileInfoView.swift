import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ProfileInfoView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var userName: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var age: String = ""
    @State private var phoneNumber: String = ""
    @State private var sex: String = ""
    @State private var showConfirmationDialog = false
    @State private var showSuccessAlert = false
    @State private var deletionSuccess = false

    var body: some View {
        VStack {
            Text("Profile Info")
                .font(.largeTitle)
                .padding()
                .font(Font.custom("SpotLight-Regular", size: 24))

            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Username", text: $userName)
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Sex", text: $sex)
                }

                Button(action: {
                    saveUserInfo()
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }

            Button(action: {
                showConfirmationDialog = true
            }) {
                Text("Delete Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            loadUserInfo()
        }
        .confirmationDialog(
            "Are you sure you want to delete your account? This action cannot be undone.",
            isPresented: $showConfirmationDialog
        ) {
            Button("Delete Account", role: .destructive) {
                deleteCurrentUser()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(
            "Changes Saved",
            isPresented: $showSuccessAlert,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text("Your changes have been successfully saved.")
            }
        )
    }

    private func loadUserInfo() {
        guard let user = DBController.shared.getUserByEmail(email: viewModel.displayName) else { return }
        userName = user.userName
        firstName = user.firstName
        lastName = user.lastName ?? ""
        age = "\(user.age)"
        phoneNumber = user.phoneNumber ?? ""
        sex = user.sex ?? ""
    }

    private func saveUserInfo() {
        guard let userAge = Int(age) else {
            print("Invalid age format")
            return
        }

        let success = DBController.shared.updateUserDetails(
            email: viewModel.displayName,
            userName: userName,
            firstName: firstName,
            lastName: lastName,
            age: userAge,
            phoneNumber: phoneNumber,
            sex: sex
        )

        if success {
            showSuccessAlert = true
            UIApplication.shared.endEditing() // Dismiss the keyboard
        } else {
            print("Failed to update user information.")
        }
    }

    private func deleteCurrentUser() {
        let email = viewModel.displayName
        let success = DBController.shared.deleteUserByEmail(email: email)
        if success {
            deletionSuccess = true
            print("User deleted successfully.")
        } else {
            print("Failed to delete the user.")
        }
    }
}
