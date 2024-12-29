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
                        .font(Font.custom("SpotLight-Regular", size: 20)) // Use the PostScript name here
                        .bold()
                    Text("Events Partecipated")
                        .font(.headline)

                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("350")
                        .font(Font.custom("SpotLight-Regular", size: 20)) // Use the PostScript name here
                        .bold()
                    Text("Repetitions Done")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
          
            Spacer()
            
            // Activity Section
            VStack(alignment: .leading) {
                Text("Activity")
                    .font(Font.custom("SpotLight-Regular", size: 25)) // Use the PostScript name here
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
