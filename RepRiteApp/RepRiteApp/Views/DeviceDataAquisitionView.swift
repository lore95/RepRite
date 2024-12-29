import SwiftUI

struct DataAcquisitionView: View {
    @ObservedObject var dataModel: DataAquisitionModel
    @State private var showResultsView = false  // State to navigate to ResultsView
    @State private var showPlotView = false  // State to navigate to ResultsView

    var deviceName: String

    var body: some View {
        VStack(spacing: 20) {
            // Title with Device Name
            Text("Connected to \(deviceName)")
                .font(.title)
                .bold()
                .padding(.top, 20)

            // Start/Stop Button
            VStack {
                Text("Data Recording")
                    .font(.headline)
                    .foregroundColor(.gray)
                Button(action: {
                    dataModel.updateIsRecording()
                    if dataModel.isRecording {
                        dataModel.startRecording()
                        startPrintingData()
                    } else {
                        showPlotView.toggle()
                    }
                }) {
                    Text(
                        dataModel.isRecording ? "Stop" : "Start Recording Data"
                    )
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(dataModel.isRecording ? Color.red : Color.green)
                    .cornerRadius(10)
                }
            }

            // Real-time Data Plot
            VStack {
                Text("Live Angle Plot")
                    .font(.headline)
                    .padding(.bottom, 10)
                DataPlotView(dataPoints: dataModel.angleDataPoints)
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
            }
            .padding()

            Spacer()
            // Button to Open ResultsView
            Button(action: {
                showResultsView.toggle()
            }) {
                Text("View Results")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .fullScreenCover(isPresented: $showResultsView) {
                ResultsView()  // Present the ResultsView
            }
            .fullScreenCover(isPresented: $showPlotView) {
                PlotAndSaveView(dataModel: dataModel)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Print Data to Console
    private func startPrintingData() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if dataModel.isRecording {
                print("Current Data Points: \(dataModel.angleDataPoints)")
            } else {
                timer.invalidate()
            }
        }
    }
}
