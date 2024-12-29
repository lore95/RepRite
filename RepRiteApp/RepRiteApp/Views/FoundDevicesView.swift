import SwiftUI
import CoreBluetooth
struct FoundDevicesView: View {
    @ObservedObject var deviceManager = DeviceManager.shared
    var onDeviceSelected: () -> Void

    @State private var showDataView = false

    var body: some View {
        VStack(spacing: 0) {
            // Found Devices Section
            VStack(alignment: .leading) {
                Text("Found Devices")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Divider()
                
                ScrollView {
                    VStack {
                        ForEach(deviceManager.discoveredDevices.filter { !deviceManager.pairedDevices.contains($0) }, id: \.identifier) { device in
                            Button(action: {
                                deviceManager.connect(to: device)
                                onDeviceSelected() // Notify parent view
                            }) {
                                HStack {
                                    Text(device.name ?? "Unnamed Device")
                                    Spacer()
                                    Image(systemName: "arrow.right.circle")
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)

            Divider()

            // Paired Devices Section
            VStack(alignment: .leading) {
                Text("Paired Devices")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 10)

                Divider()

                ScrollView {
                    VStack {
                        ForEach(deviceManager.pairedDevices, id: \.identifier) { device in
                            Button(action: {
                                deviceManager.connect(to: device)
                                showDataView = true
                            }) {
                                HStack {
                                    Text(device.name ?? "Unnamed Device")
                                    Spacer()
                                    Image(systemName: "checkmark.circle")
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .navigationTitle("Devices")
        
    }
}
