import SwiftUI

struct HomeView: View {
    let user: RepRiteAuthUser
    @StateObject private var repositoryController: RepositoryController

    init(user: RepRiteAuthUser) {
        _repositoryController = StateObject(wrappedValue: RepositoryController(userIdentifier: user.email))
        self.user = user
    }

    var body: some View {
        NavigationView {
            VStack {
                // Profile Header
                VStack(spacing: 10) {
                    Image("profpic")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                    
                    Text(user.userName)
                        .bold()
                        .font(Font.custom("SpotLight-Regular", size: 24))
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
                            .font(Font.custom("SpotLight-Regular", size: 20))
                            .bold()
                        Text("Events Participated")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("350")
                            .font(Font.custom("SpotLight-Regular", size: 20))
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
                        .font(Font.custom("SpotLight-Regular", size: 25))
                        .bold()
                        .padding(.bottom, 10)

                    // Horizontal Scrollable List
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(repositoryController.files, id: \.self) { file in
                                NavigationLink(destination: SessionDetailView(file: file)) {
                                    DocumentCard(file: file)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .padding()
            .onAppear {
                repositoryController.fetchJSONFiles()
            }
        }
    }
}
