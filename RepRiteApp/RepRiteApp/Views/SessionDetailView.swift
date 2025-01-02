import SwiftUI
import Charts

struct SessionDetailView: View {
    let file: URL
    @State private var session: ExerciseSession?
    @State private var loadingError: String?

    var body: some View {
        VStack {
            if let session = session {
                Text("Session Details")
                    .font(.title)
                    .padding()

                // List of exercises
                List {
                    Section(header: Text("Exercises")) {
                        ForEach(session.exercises, id: \.typeOfExercise) { exercise in
                            VStack(alignment: .leading) {
                                Text(exercise.typeOfExercise)
                                    .font(.headline)
                                Text("Repetitions: \(exercise.numberOfRepetitions)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // Plot for angles
                    Section(header: Text("Angle Data Plot")) {
                        Chart {
                            ForEach(Array(session.angles.enumerated()), id: \.offset) { index, angle in
                                LineMark(
                                    x: .value("Index", index),
                                    y: .value("Angle", angle)
                                )
                            }
                        }
                        .frame(height: 200)
                        .padding()
                    }
                }
            } else if let error = loadingError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Loading...")
                    .padding()
            }
        }
        .onAppear {
            loadSession()
        }
    }

    private func loadSession() {
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            session = try decoder.decode(ExerciseSession.self, from: data)
        } catch {
            loadingError = error.localizedDescription
        }
    }
}