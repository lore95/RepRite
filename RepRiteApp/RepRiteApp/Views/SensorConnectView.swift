import SwiftUI

struct SensorConnectView: View {
    @ObservedObject var deviceManager: DeviceManager
    @State private var isPopupVisible = false
    @State private var selectedExercise: String? = nil
    @State private var numberOfRepetitions: String = ""
    @State private var exercises:
        [(typeOfExercise: String, numberOfRepetitions: Int)] = []
    @State private var isSearching = false
    @State private var animateImage = false
    @State private var showFoundDevices = false
    @State private var searchStatusMessage = "Search for devices"
    @State private var showNoDeviceFound = false
    @State private var navigateToExerciseView = false

    var body: some View {
        VStack(spacing: 20) {
            // Connected Sensor or Search View
            if deviceManager.isConnected {
                connectedSensorView
            } else {
                searchSensorView
            }

            Divider()

            // Exercise Options if Connected
            if deviceManager.isConnected {
                exerciseOptionsView
            }

            // Added Exercises and Start Button
            if !exercises.isEmpty {
                exerciseListView
                NavigationLink(
                    destination: ExerciseView(exercises: exercises),
                    isActive: $navigateToExerciseView
                ) {
                    EmptyView()
                }
                startButton
            }

            Spacer()

            // Disconnect Button
            if deviceManager.isConnected {
                disconnectButton
            }
        }
        .sheet(isPresented: $showFoundDevices) {
            FoundDevicesView(onDeviceSelected: stopSearch)
            
        }
        .sheet(isPresented: $isPopupVisible) {
            popupForRepetitions
        }

    }

    // MARK: - Subviews

    /// Connected Sensor View
    private var connectedSensorView: some View {
        VStack {
            Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            Text(deviceManager.deviceName ?? "Connected Sensor")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }

    /// Search Sensor View
    private var searchSensorView: some View {
        VStack {
            Image("movesenseIcon")
                .resizable()
                .frame(
                    width: animateImage ? 360 : 280,
                    height: animateImage ? 360 : 280
                )
                .clipShape(Circle())
                .rotationEffect(.degrees(animateImage ? 360 : 0))
                .animation(
                    animateImage
                        ? Animation.linear(duration: 2.0).repeatForever(
                            autoreverses: false) : .default, value: animateImage
                )
                .onTapGesture {
                    startSearch()
                }
                .disabled(isSearching)

            Text(searchStatusMessage)
                .font(Font.custom("SpotLight-Regular", size: 10)) // Custom Font for Repetitions
                .foregroundColor(.gray)

            if showNoDeviceFound {
                Text("No device found")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    /// Exercise Options View
    private var exerciseOptionsView: some View {
        List(["Pushups", "Pullups", "Snatches"], id: \.self) { exercise in
            Button(action: {
                selectedExercise = exercise
                isPopupVisible = true
            }) {
                HStack {
                    Text(exercise)
                    .font(Font.custom("SpotLight-Regular", size: 15)) // Custom Font for Repetitions

                    Spacer()
                    Image(systemName: "plus.circle")
                }
            }
        }
    }

    /// List of Added Exercises
    private var exerciseListView: some View {
        VStack(alignment: .leading) {
            Text("Exercises Added:")
                .font(Font.custom("SpotLight-Regular", size: 10)) // Custom Font for Repetitions
            ForEach(exercises, id: \.typeOfExercise) { exercise in
                HStack {
                    Text("\(exercise.typeOfExercise):")
                    Spacer()
                    Text("\(exercise.numberOfRepetitions) reps")
                }
            }
        }
        .padding(.horizontal)
    }

    private var startButton: some View {
        Button(action: {
            navigateToExerciseView = true
            if let dataModel = deviceManager.selectedDataModel
            {
                dataModel.stopRecording()
            }
        }) {
            Text("Set Up session")
                .font(Font.custom("SpotLight-Regular", size: 10)) // Custom Font for Repetitions
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
    }

    /// Disconnect Button
    private var disconnectButton: some View {
        Button(action: {
            deviceManager.disconnectAllDevices()
            exercises = []
        }) {
            Text("Disconnect")
                .font(Font.custom("SpotLight-Regular", size: 10)) // Custom Font for Repetitions
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
    }
    private var popupForRepetitions: some View {
            VStack {
                Text("Number of Reps")
                    .padding(.top, 20)
                    .font(Font.custom("SpotLight-Regular", size: 15)) // Custom Font for Repetitions


                TextField("Enter number of reps", text: $numberOfRepetitions)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)


                HStack {
                    Button("Cancel") {
                        isPopupVisible = false
                        numberOfRepetitions = ""
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .font(Font.custom("SpotLight-Regular", size: 15)) // Custom Font for Repetitions


                    Button("Add") {
                        if let exercise = selectedExercise, let reps = Int(numberOfRepetitions), reps > 0 {
                            exercises.append((typeOfExercise: exercise, numberOfRepetitions: reps))
                        }
                        isPopupVisible = false
                        numberOfRepetitions = ""
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .font(Font.custom("SpotLight-Regular", size: 15)) // Custom Font for Repetitions

                }
                .padding(.top, 20)
            }
            .padding()
        }
    // MARK: - Start Scanning
    private func startSearch() {
        isSearching = true
        animateImage = true
        searchStatusMessage = "Looking for devices..."
        showNoDeviceFound = false
        deviceManager.startScanning()

        DispatchQueue.global().async {
            let startTime = Date()
            while isSearching {
                DispatchQueue.main.async {
                    if !deviceManager.discoveredDevices.isEmpty {
                        showFoundDevices = true
                    } else if Date().timeIntervalSince(startTime) >= 10 {
                        if deviceManager.discoveredDevices.isEmpty {
                            showNoDeviceFound = true
                        }
                        stopSearch()
                    }
                }
                sleep(1)
            }
        }
    }

    private func stopSearch() {
        isSearching = false
        animateImage = false
        showFoundDevices = false
        searchStatusMessage = "Search for devices"
        deviceManager.stopScanning()
        
    }
}
