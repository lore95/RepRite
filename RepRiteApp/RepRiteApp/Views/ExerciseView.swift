import Combine
import SwiftUI

struct ExerciseView: View {
    @ObservedObject var deviceManager = DeviceManager.shared

    var color: Color = Color.green
    @State private var cancellable: AnyCancellable? = nil
    @State private var progress: Double = 0.0
    @State private var repetitionsLeft: Int = 0
    @State private var currentExerciseIndex: Int = 0
    @State private var isAboveThreshold = false
    @State private var isProgessVisible = true
    @State private var saveSessionPopUp = false
    let exercises: [(typeOfExercise: String, numberOfRepetitions: Int)]

    var body: some View {
        VStack(spacing: 0) {
            // Top Section: First Exercise with Remaining Exercises Below
            VStack {
                // Top Section: Current Exercise
                if currentExerciseIndex < exercises.count {
                    let currentExercise = exercises[currentExerciseIndex]
                    VStack {
                        Text(currentExercise.typeOfExercise)
                            .font(Font.custom("SpotLight-Regular", size: 60))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .padding(.horizontal)

                        // Remaining Exercises
                        VStack {
                            ForEach(
                                exercises.dropFirst(currentExerciseIndex + 1),
                                id: \.typeOfExercise
                            ) { exercise in
                                Text(
                                    "\(exercise.typeOfExercise): \(exercise.numberOfRepetitions)"
                                )
                                .font(
                                    Font.custom("SpotLight-Regular", size: 10)
                                )
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                } else {
                    Text("All exercises completed!")
                        .font(Font.custom("SpotLight-Regular", size: 30))
                        .foregroundColor(.green)
                        .padding()                    
                }
            }
            if isProgessVisible {
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
                // Middle Section: Current Repetitions
                if currentExerciseIndex < exercises.count {
                    Text("\(repetitionsLeft)")
                        .font(Font.custom("SpotLight-Regular", size: 150))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                        .padding()
                }
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
        .onAppear {
            setupInitialState()
        }
    }
    // MARK: - Setup
    private func setupInitialState() {
        if let firstExercise = exercises.first {
            repetitionsLeft = firstExercise.numberOfRepetitions
        }
    }
    // MARK: - Update Progress and Repetitions
    private func updateProgress(_ newProgress: Double) {
        progress = newProgress

        if progress > 0.9 {
            isAboveThreshold = true
        }

        if progress < 0.05 && isAboveThreshold {
            isAboveThreshold = false
            repetitionsLeft -= 1

            if repetitionsLeft <= 0 {
                moveToNextExercise()
            }
        }
    }

    // MARK: - Move to Next Exercise
    private func moveToNextExercise() {
        currentExerciseIndex += 1
        if currentExerciseIndex < exercises.count {
            repetitionsLeft =
                exercises[currentExerciseIndex].numberOfRepetitions
        } else {
            // All exercises completed
            repetitionsLeft = 0
        }
    }
    private func endTraning()
    {
        isProgessVisible = false
        saveSessionPopUp = true
        if let dataModel = deviceManager.selectedDataModel {
            dataModel.stopRecording()
            dataModel.updateIsRecording()
        }
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
                    .sink { newProgress in
                        updateProgress(newProgress)
                    }
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
