import SwiftUI

struct ExerciseView: View {
    @ObservedObject var deviceManager = DeviceManager.shared

    let exercises: [(typeOfExercise: String, numberOfRepetitions: Int)]

    var body: some View {
        VStack(spacing: 20) {
            if let firstExercise = exercises.first {
                Text(firstExercise.typeOfExercise)
                    .font(.largeTitle)
                    .bold()

                Text("\(firstExercise.numberOfRepetitions) repetitions")
                    .font(.title2)
                    .foregroundColor(.gray)
            } else {
                Text("No exercises available")
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    private var startButton: some View {
        Button(action: {
            if let dataModel = deviceManager.selectedDataModel{
                dataModel.startRecording()
            }
        }) {
            Text("Start")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
    }

}
