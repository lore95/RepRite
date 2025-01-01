import SwiftUI

struct WelcomeView: View {
    let userName: String
    @ObservedObject private var deviceManager = DeviceManager.shared
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            HomeView(user: DBController.shared.getUserByEmail(email: viewModel.displayName) ?? RepRiteAuthUser.defaultUser)
                .tabItem {
                    Label(
                        "Home",
                        systemImage: "figure.strengthtraining.traditional")
                }

            ProfileInfoView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

            VStack {
                SensorConnectView(deviceManager: deviceManager)
            }
            .tabItem {
                Label("Activity", systemImage: "figure.walk")
            }

            LogoutView()
                .tabItem {
                    Label("Logout", systemImage: "arrowshape.turn.up.left")
                }
        }
        .navigationBarBackButtonHidden(true)
    }
}
