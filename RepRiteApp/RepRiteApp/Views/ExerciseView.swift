import SwiftUI

struct ExerciseView: View {
    @ObservedObject var deviceManager = DeviceManager.shared
    let exercises: [(typeOfExercise: String, numberOfRepetitions: Int)]

    var body: some View {
        VStack(spacing: 0) {
            // Top Section: First Exercise with Remaining Exercises Below
            VStack {
                if let firstExercise = exercises.first {
                    VStack {
                        // First Exercise Details
                        Text(firstExercise.typeOfExercise)
                            .font(Font.custom("sportFont", size: 28)) // Custom Font for Exercise Name
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .padding(.horizontal)

                        // Remaining Exercises
                        VStack {
                            ForEach(exercises.dropFirst(), id: \.typeOfExercise) { exercise in
                                Text("\(exercise.typeOfExercise): \(exercise.numberOfRepetitions)")
                                    .font(Font.custom("sportFont", size: 18)) // Custom Font for Remaining Exercises
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                } else {
                    Text("No exercises available")
                        .font(Font.custom("sportFont", size: 18)) // Custom Font for Placeholder
                }
            }

            // Middle Section: Huge Number
            if let firstExercise = exercises.first {
                
                Text("\(firstExercise.numberOfRepetitions)")
                    .font(Font.custom("SpotLight-Regular", size: 120)) // Custom Font for Repetitions
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            // Bottom Section: Start and Stop Buttons
            HStack(spacing: 20) {
                startButton
                stopButton
            }
            .padding()
            .background(Color.black.shadow(radius: 5))
        }
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Start Button
    private var startButton: some View {
        Button(action: {
            if let dataModel = deviceManager.selectedDataModel {
                dataModel.startRecording()
            }
        }) {
            Text("Start")
                .font(.headline)
                .foregroundColor(.green)
                .font(Font.custom("SpotLight-Regular", size: 40)) // Custom Font for Repetitions
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
        }
    }

    // MARK: - Stop Button
    private var stopButton: some View {
        Button(action: {
            if let dataModel = deviceManager.selectedDataModel {
                dataModel.stopRecording()
            }
        }) {
            Text("Give Up")
                .font(.headline)
                .foregroundColor(.red)
                .font(Font.custom("SpotLight-Regular", size: 40)) // Custom Font for Repetitions
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
        }
    }
}
