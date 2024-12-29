import SwiftUI

struct WelcomeView: View {
    let userName: String
       @ObservedObject private var deviceManager = DeviceManager.shared

       var body: some View {
           TabView {
               ProfileView(userName: userName)
                   .tabItem {
                       Label("Profile", systemImage: "person.crop.circle")
                   }

               SettingsView()
                   .tabItem {
                       Label("Settings", systemImage: "gearshape")
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
