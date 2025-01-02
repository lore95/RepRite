import Combine
import SwiftUI

struct ExerciseView: View {
    @ObservedObject var deviceManager = DeviceManager.shared
    @EnvironmentObject var repositoryController: RepositoryController
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var lastAngleValue: Double = 0.0
    var color: Color = Color.green
    @State private var cancellable: AnyCancellable? = nil
    @State private var progress: Double = 0.0
    @State private var repetitionsLeft: Int = 0
    @State private var currentExerciseIndex: Int = 0
    @State private var isAboveThreshold = false
    @State private var saveSessionPopUp = false  // Controls the confirmation dialog
    @State private var currentExerciseType = ""
    @Binding var exercises: [(typeOfExercise: String, numberOfRepetitions: Int)]

    var body: some View {
        VStack(spacing: 0) {
            // Top Section: Exercise Info
            VStack {
                if currentExerciseIndex < exercises.count {
                    let currentExercise = exercises[currentExerciseIndex]
                    VStack {
                        Text(currentExercise.typeOfExercise)
                            .font(Font.custom("SpotLight-Regular", size: 60))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .padding(.horizontal)

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

            // Progress Circle and Remaining Reps
            if currentExerciseIndex < exercises.count {
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
                Text("\(repetitionsLeft)")
                    .font(Font.custom("SpotLight-Regular", size: 150))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()

                // Buttons
                HStack(spacing: 20) {
                    startButton
                    stopButton
                }
                .padding()
                .background(Color.black.shadow(radius: 5))
            }

        }
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupInitialState()
        }
        .alert(isPresented: $saveSessionPopUp) {
            Alert(
                title: Text("Save Session"),
                message: Text("Would you like to save this session?"),
                primaryButton: .default(Text("Save")) {
                    saveSession()
                },
                secondaryButton: .cancel(Text("Don't Save")) {
                    discardSession()
                }
            )
        }
    }

    // MARK: - Setup
    private func setupInitialState() {
        if let firstExercise = exercises.first {
            repetitionsLeft = firstExercise.numberOfRepetitions
            currentExerciseType = exercises[currentExerciseIndex].typeOfExercise
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
            currentExerciseType = exercises[currentExerciseIndex].typeOfExercise
            repetitionsLeft =
                exercises[currentExerciseIndex].numberOfRepetitions
        } else {
            endTraining()
        }
    }

    // MARK: - End Training
    private func endTraining() {
        saveSessionPopUp = true  // Show the confirmation popup
        if let dataModel = deviceManager.selectedDataModel {
            dataModel.stopRecording()
            dataModel.updateIsRecording()
        }
    }

    private func discardSession() {
        print("Session discarded.")
        if let dataModel = deviceManager.selectedDataModel {
            dataModel.resetData()
        }
        exercises = []
        dismiss()  // Navigate back to FoundDevicesView
    }

    // MARK: - Start Button
    private var startButton: some View {
        Button(action: {
            if let dataModel = deviceManager.selectedDataModel {
                dataModel.startRecording()
                dataModel.updateIsRecording()
                cancellable = dataModel.$angleDataPoints
                    .map { rawValue -> Double in
                        // Normalize based on the current exercise type
                        let normalizedValue = normalizeValue(
                            rawValue: Double(rawValue.last ?? 0.0),
                            exerciseType: currentExerciseType
                        )
                        return normalizedValue
                    }
                    .sink { newProgress in
                        updateProgress(newProgress)
                    }
            }
        }) {
            Text("Start")
                .foregroundColor(.green)
                .font(Font.custom("SpotLight-Regular", size: 40))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
        }
    }

    // MARK: - Stop Button
    private var stopButton: some View {
        Button(action: {
            endTraining()  // Show the confirmation popup
        }) {
            Text("Give Up")
                .foregroundColor(.red)
                .font(Font.custom("SpotLight-Regular", size: 40))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
        }
    }
    private func saveSession() {
        // Gather data for the session
        let completedExercises = exercises.prefix(currentExerciseIndex + 1).map
        {
            ExerciseData(
                typeOfExercise: $0.typeOfExercise,
                numberOfRepetitions: $0.numberOfRepetitions
            )
        }
        let angleData = deviceManager.selectedDataModel?.angleDataPoints ?? []
        //print(angleData)
        // Create the session
        let session = ExerciseSession(
            date: Date(),
            exercises: Array(completedExercises),
            angles: angleData.map { Double($0) }
        )

        // Save the session
        repositoryController.saveSession(
            session, forUser: viewModel.displayName)
        print("Session saved successfully!")
        if let dataModel = deviceManager.selectedDataModel {
            dataModel.resetData()
        }
        exercises = []
        dismiss()  // Navigate back to FoundDevicesView
    }
    func normalizeValue(rawValue: Double, exerciseType: String) -> Double {
        // Define the range for each exercise
        print(rawValue)
        let range: (min: Double, max: Double) = {
            switch exerciseType {
            case "Pullups":
                return (40.0, 120.0)
            case "Pushups":
                return (20.0, 70.0)
            case "Snatches":
                return (0.0, 180.0)
            default:
                return (0.0, 180.0) // Default range if type is unknown
            }
        }()
        
        // Calculate normalized value
        let normalized: Double
        
        if abs(rawValue - lastAngleValue) > 20 { // Check if the difference exceeds the threshold
            normalized = max(0, min(1, (lastAngleValue - range.min) / (range.max - range.min)))
        } else {
            normalized = max(0, min(1, (rawValue - range.min) / (range.max - range.min)))
            lastAngleValue = rawValue
        }
        
        return normalized
    }
}
