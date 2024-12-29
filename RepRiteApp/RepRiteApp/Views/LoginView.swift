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
                Text("Sports App Login")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                TextField("Username", text: $userName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                SecureField("Password", text: $password) // Hide password input
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                Button(action: {
                    if DBController.shared.validateUser(userName: userName, password: password) {
                        isLoggedIn = true
                    } else {
                        loginFailed = true
                    }
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                
                NavigationLink("Create Account", destination: SignupView())
                    .foregroundColor(.white)
                
                if loginFailed {
                    Text("Invalid Credentials!")
                        .foregroundColor(.red)
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
}
