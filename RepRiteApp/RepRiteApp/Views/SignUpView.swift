import SwiftUI

struct SignupView: View {
    @State private var userName = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var sex = ""
    @State private var age = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var signupSuccess = false
    @State private var errorMessage = ""
    @State private var usernameErrorMessage = ""
    @ObservedObject var viewModel: AuthenticationViewModel

    @FocusState private var isUsernameFieldFocused: Bool  // Focus tracking

    var body: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Signup")
                        .font(Font.custom("SpotLight-Regular", size: 40))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    if viewModel.displayName.isEmpty {
                        TextField("Email", text: $email)  // Editable field when displayName is empty
                            .textFieldStyle()
                    } else {
                        TextField(
                            "Email", text: .constant(viewModel.displayName)
                        )  // Non-editable field
                        .textFieldStyle()
                        .disabled(true)  // Disable editing
                    }

                    Group {
                        TextField("Username", text: $userName)
                            .textFieldStyle()
                            .focused($isUsernameFieldFocused)
                            .onChange(of: isUsernameFieldFocused) { isFocused in
                                if !isFocused {  // Check username only when focus is lost
                                    checkIfUsernameExists()
                                }
                            }

                        // Username Error Message
                        if !usernameErrorMessage.isEmpty {
                            Text(usernameErrorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        TextField("First Name", text: $firstName)
                            .textFieldStyle()
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle()
                        TextField("Sex", text: $sex)
                            .textFieldStyle()
                        TextField("Age", text: $age)
                            .textFieldStyle()

                        TextField("Phone Number", text: $phoneNumber)
                            .textFieldStyle()

                        SecureField("Password", text: $password)
                            .textFieldStyle()
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle()
                    }

                    Button(action: validateAndRegister) {
                        Text("Register")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    if signupSuccess {
                        Text("Signup Successful!")
                            .foregroundColor(.green)
                            .padding()
                        if !viewModel.displayName.isEmpty
                        {
                            var isActive = true
                            NavigationLink(
                                destination: WelcomeView(userName: userName),
                                label: { EmptyView()}
                            )
                        }
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
        }

    }

    private func validateAndRegister() {
        errorMessage = ""  // Reset error message

        guard !userName.isEmpty else {
            errorMessage = "Username is required."
            return
        }
        guard usernameErrorMessage.isEmpty else {
            errorMessage = "Please choose a different username."
            return
        }
        guard !firstName.isEmpty else {
            errorMessage = "First Name is required."
            return
        }
        if viewModel.displayName.isEmpty && email.isEmpty {
            errorMessage = "Email is required."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        if !isValidPassword(password) {
            errorMessage =
                "Password must have:\n- At least 1 uppercase letter\n- 1 special character\n- 2 numbers"
            return
        }
        if !viewModel.displayName.isEmpty
        {
            email = viewModel.displayName
        }
            
        let success = DBController.shared.saveUser(
            userName: userName,
            firstName: firstName,
            lastName: lastName,
            sex: sex,
            age: Int(age) ?? 0,
            email: email,
            phoneNumber: phoneNumber,
            password: password
        )

        if success {
            signupSuccess = true
        } else {
            errorMessage =
                "Signup failed. Username or Email might already exist."
        }
    }

    private func checkIfUsernameExists() {
        if DBController.shared.doesUsernameExist(userName: userName) {
            usernameErrorMessage =
                "Username already exists. Please choose another."
        } else {
            usernameErrorMessage = ""
        }
    }

    private func isValidPassword(_ password: String) -> Bool {
        let pattern =
            #"^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d.*\d).{8,}$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: password.utf16.count)
        return regex.firstMatch(in: password, options: [], range: range) != nil
    }

}
// MARK: - TextFieldStyle Modifier
extension View {
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.white)
            .autocapitalization(.none)
    }
}
