
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct RepRiteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = AuthenticationViewModel() // Initialize ViewModel
    @StateObject private var repositoryController = RepositoryController(userIdentifier: "defaultUser")

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(viewModel) // Provide the environment object
                .environmentObject(repositoryController) // Provide RepositoryController
        }
    }
}
