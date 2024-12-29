import Combine
import SwiftUI

struct ExerciseView: View {
    @ObservedObject var deviceManager = DeviceManager.shared

    var color: Color = Color.green
    @State private var cancellable: AnyCancellable? = nil
    @State private var progress: Double = 0.0

    let exercises: [(typeOfExercise: String, numberOfRepetitions: Int)]

    var body: some View {
        VStack(spacing: 0) {
            // Top Section: First Exercise with Remaining Exercises Below
            VStack {
                if let firstExercise = exercises.first {
                    VStack {
                        // First Exercise Details
                        Text(firstExercise.typeOfExercise)
                            .font(Font.custom("SpotLight-Regular", size: 60))  // Custom Font for Repetitions
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .padding(.horizontal)

                        // Remaining Exercises
                        VStack {
                            ForEach(exercises.dropFirst(), id: \.typeOfExercise)
                            { exercise in
                                Text(
                                    "\(exercise.typeOfExercise): \(exercise.numberOfRepetitions)"
                                )
                                .font(
                                    Font.custom("SpotLight-Regular", size: 10)
                                )  // Custom Font for Repetitions
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                } else {
                    Text("No exercises available")
                        .font(Font.custom("sportFont", size: 18))  // Custom Font for Placeholder
                }

            }
            VStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20.0)
                        .opacity(0.20)
                        .foregroundColor(Color.gray)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 12.0, lineCap: .round,
                                lineJoin: .round)
                        )
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.easeInOut(duration: 0.1))
                }.frame(width: 160.0, height: 160.0)
            }
            // Middle Section: Huge Number
            if let firstExercise = exercises.first {

                Text("\(firstExercise.numberOfRepetitions)")
                    .font(Font.custom("SpotLight-Regular", size: 150))  // Custom Font for Repetitions
                    .foregroundColor(.white)
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
                dataModel.updateIsRecording()
                cancellable = dataModel.$angleDataPoints
                    .map { Double($0.last ?? 0.0) }  // Ensure the result is Double
                    .map { min($0 / 180.0, 1.0) }  // Normalize to [0, 1]
                    .assign(to: \.progress, on: self)
            }
        }) {
            Text("Start")
                .foregroundColor(.green)
                .font(Font.custom("SpotLight-Regular", size: 40))  // Custom Font for Repetitions
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
                dataModel.updateIsRecording()
            }
        }) {
            Text("Give Up")
                .foregroundColor(.red)
                .font(Font.custom("SpotLight-Regular", size: 40))  // Custom Font for Repetitions
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
        }
    }
}
