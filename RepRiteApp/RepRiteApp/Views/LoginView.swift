import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import Combine

struct LoginView: View {
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var loginFailed: Bool = false
    @State private var showSignup: Bool = false
    @State private var isLoggedIn: Bool = false
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("RepRite")
                    .foregroundColor(.white)
                    .font(Font.custom("SpotLight-Regular", size: 80)) // Custom Font for Repetitions

                TextField(
                    "Username", text: $userName,
                    onEditingChanged: { _ in
                        loginFailed = false // Clear error message when typing
                    }
                )
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.white)

                SecureField(
                    "Password", text: $password,
                    onCommit: {
                        loginFailed = false // Clear error message when typing
                    }
                )
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.white)

                Button(action: {
                    if DBController.shared.validateUser(
                        userName: userName, password: password
                    ) {
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

                NavigationLink(
                    "Create Account",
                    destination: SignupView(viewModel: viewModel)
                )
                .foregroundColor(.white)
                .font(Font.custom("SpotLight-Regular", size: 20)) // Custom Font for Repetitions

                Button(action: signInWithGoogle) {
                    Text("Sign in with Google")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 0)
                }
                .buttonStyle(.bordered)

                if loginFailed {
                    Text("Invalid Credentials!")
                        .foregroundColor(.red)
                        .transition(.opacity)
                }

                // Automatically navigate to SignupView when showSignup is true
                NavigationLink(
                    destination: SignupView(viewModel: viewModel),
                    isActive: $showSignup,
                    label: { EmptyView() }
                )

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

    private func signInWithGoogle() {
        Task {
            if await viewModel.signInWithGoogle() {
                let email = viewModel.user?.email ?? ""

                // Check if the email exists in the database
                if DBController.shared.doesEmailExist(email: email) {
                    isLoggedIn = true // Email exists, proceed to WelcomeView
                    if let email = viewModel.user?.email, let googleId = viewModel.user?.uid {
                        let success = DBController.shared.saveGoogleId(forEmail: email, googleId: googleId)
                        if success {
                            print("Google ID saved successfully.")
                        } else {
                            print("Failed to save Google ID.")
                        }
                    }
                } else {
                    // Email doesn't exist, redirect to SignupView
                    showSignup = true
                }
            } else {
                loginFailed = true // Handle sign-in failure
            }
        }
    }
}
