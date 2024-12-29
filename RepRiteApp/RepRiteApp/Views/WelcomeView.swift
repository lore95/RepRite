import SwiftUI

struct WelcomeView: View {
    let userName: String
    @ObservedObject private var deviceManager = DeviceManager.shared

    var body: some View {
        TabView {
            HomeView(userName: userName)

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
