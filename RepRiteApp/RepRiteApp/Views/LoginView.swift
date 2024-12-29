import SwiftUI

struct LoginView: View {
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var loginFailed: Bool = false
    @State private var showSignup: Bool = false
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("RepRite")
                    .foregroundColor(.white)
                    .font(Font.custom("SpotLight-Regular", size: 80)) // Custom Font for Repetitions

                TextField("Username", text: $userName, onEditingChanged: { _ in
                    loginFailed = false // Clear error message when typing
                })
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                SecureField("Password", text: $password, onCommit: {
                    loginFailed = false // Clear error message when typing
                })
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                Button(action: {
                    if DBController.shared.validateUser(userName: userName, password: password) {
                        isLoggedIn = true
                    } else {
                        showLoginFailedMessage()
                    }
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                        .font(Font.custom("SpotLight-Regular", size: 20)) // Custom Font for Repetitions

                }
                
                NavigationLink("Create Account", destination: SignupView())
                    .foregroundColor(.white)
                    .font(Font.custom("SpotLight-Regular", size: 20)) // Custom Font for Repetitions

                
                if loginFailed {
                    Text("Invalid Credentials!")
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
                
                NavigationLink(
                    destination: WelcomeView(userName: userName),
                    isActive: $isLoggedIn,
                    label: { EmptyView() }
                )
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    // MARK: - Helper Methods
    private func showLoginFailedMessage() {
        loginFailed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if loginFailed {
                loginFailed = false // Hide the message after 1 second
            }
        }
    }
}
