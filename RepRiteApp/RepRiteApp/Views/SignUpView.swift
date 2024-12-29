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
    
    @FocusState private var isUsernameFieldFocused: Bool // Focus tracking
    
    var body: some View {
        ZStack {
            // Background Color
            Color.gray.edgesIgnoringSafeArea(.all)
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    Text("Signup")
                        .font(Font.custom("SpotLight-Regular", size: 40)) // Custom Font for Repetitions
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Username Field with Focus Tracking
                    TextField("Username", text: $userName)
                        .textFieldStyle()
                        .focused($isUsernameFieldFocused)
                        .onChange(of: isUsernameFieldFocused) { isFocused in
                            if !isFocused { // Check username only when focus is lost
                                checkIfUsernameExists()
                            }
                        }
                    
                    // Username Error Message
                    if !usernameErrorMessage.isEmpty {
                        Text(usernameErrorMessage)
                            .foregroundColor(.red)
                            .font(Font.custom("SpotLight-Regular", size: 20)) // Custom Font for Repetitions
                    }
                    
                    // Other Input Fields
                    Group {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle()
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle()
                        TextField("Sex", text: $sex)
                            .textFieldStyle()
                        TextField("Age", text: $age)
                            .textFieldStyle()
                        TextField("Email", text: $email)
                            .textFieldStyle()
                        TextField("Phone Number", text: $phoneNumber)
                            .textFieldStyle()
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle()
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle()
                    }
                    
                    // Register Button
                    Button(action: {
                        validateAndRegister()
                    }) {
                        Text("Register")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    
                    // Error or Success Messages
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
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Validation and Registration Logic
    
    private func validateAndRegister() {
        errorMessage = "" // Reset error message
        
        // Check mandatory fields
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
        guard !email.isEmpty else {
            errorMessage = "Email is required."
            return
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        // Validate password strength
        if !isValidPassword(password) {
            errorMessage = "Password must have:\n- At least 1 uppercase letter\n- 1 special character\n- 2 numbers"
            return
        }
        
        // Save user in the database
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
            errorMessage = "Signup failed. Username or Email might already exist."
        }
    }
    
    private func checkIfUsernameExists() {
        if DBController.shared.doesUsernameExist(userName: userName) {
            usernameErrorMessage = "Username already exists. Please choose another."
        } else {
            usernameErrorMessage = ""
        }
    }
    
    // MARK: - Password Validation Logic
    
    private func isValidPassword(_ password: String) -> Bool {
        let pattern = #"^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d.*\d).{8,}$"#
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
