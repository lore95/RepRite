import SwiftUI

// MARK: - Profile View
struct HomeView: View {
    let userName: String
    
    var body: some View {
        VStack {
            // Profile Header
            VStack(spacing: 10) {
                Image("profpic")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                
                Text(userName)
                    .font(.title)
                    .bold()
                    .font(Font.custom("SpotLight-Regular", size: 24)) // Use the PostScript name here
                
                Text("Basketball Player")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Stockholm, Sweden")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Metrics Section
            HStack(spacing: 20) {
                VStack {
                    Text("10")
                        .font(.title2)
                        .bold()
                    Text("Events Partecipated")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("350")
                        .font(.title2)
                        .bold()
                    Text("Repetitions Done")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
          
            Spacer()
            
            // Activity Section
            VStack(alignment: .leading) {
                Text("Activity")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 10)
                
                HStack {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Rectangle())
                    
                    VStack(alignment: .leading) {
                        Text("\(userName) published a post")
                            .bold()
                        Text("A week ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("To attract new app members and compel existing app members to renew, it’s important...")
                            .font(.body)
                            .lineLimit(2)
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}
