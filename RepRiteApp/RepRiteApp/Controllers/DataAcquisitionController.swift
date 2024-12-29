import CoreBluetooth
import Foundation
import CoreData

class DataAquisitionModel: NSObject, ObservableObject, CBPeripheralDelegate {
    // MARK: - Properties
    @Published var XrawDataPoints: [Float] = []
    @Published var YrawDataPoints: [Float] = []
    @Published var ZrawDataPoints: [Float] = []
    @Published var XfilteredDataPoints: [Float] = []
    @Published var YfilteredDataPoints: [Float] = []
    @Published var ZfilteredDataPoints: [Float] = []
    @Published var angleDataPoints: [Float] = []
    @Published var isToSave = false


    @Published var isRecording = false
    private var csvRows: [CSVModel] = []             // Array to hold CSV rows

    let dataProcessor = DataManipulationController()

    var connectedPeripheral: CBPeripheral?

    private let GATTService = CBUUID(
        string: "34802252-7185-4d5d-b431-630e7050e8f0")
    private let GATTCommand = CBUUID(
        string: "34800001-7185-4d5d-b431-630e7050e8f0")
    private let GATTData = CBUUID(
        string: "34800002-7185-4D5D-B431-630E7050E8F0")

    private var commandSent = false

    // MARK: - Configuration
    func configurePeripheral(_ peripheral: CBPeripheral) {
        print("Configuring peripheral: \(peripheral.name ?? "Unknown Device")")
        if connectedPeripheral == nil {
            self.connectedPeripheral = peripheral
            self.connectedPeripheral?.delegate = self
            self.connectedPeripheral?.discoverServices([GATTService])
        }
    }

    // MARK: - Start and Stop Recording
    func startRecording() {
        guard let peripheral = connectedPeripheral else { return }
        print("Starting data recording...")

        // Enable notifications for GATT Data characteristic
        if let services = peripheral.services {
            for service in services {
                for characteristic in service.characteristics ?? [] {
                    if characteristic.uuid == GATTData {
                        peripheral.setNotifyValue(true, for: characteristic)
                        print("Enabled notifications for GATT Data")
                    }
                }
            }
        }
        // Send IMU6/52 command
        sendCommand(to: peripheral, command: "IMU6/52")
    }

    func stopRecording() {
        print("Stopping data recording")

        guard let peripheral = connectedPeripheral else { return }

        // Disable notifications for the GATT Data characteristic
        if let services = peripheral.services {
            for service in services {
                for characteristic in service.characteristics ?? [] {
                    if characteristic.uuid == GATTData {
                        peripheral.setNotifyValue(false, for: characteristic)
                        print("Disabled notifications for GATT Data")
                    }
                }
            }
        }
        if isToSave
        {
            generateCSVData()
            saveJSONToFile()
        }
        isToSave = false
        // Clear data points or stop any timers if needed
        DispatchQueue.main.async {
            self.XrawDataPoints.removeAll()
            self.YrawDataPoints.removeAll()
            self.ZrawDataPoints.removeAll()
            self.XfilteredDataPoints.removeAll()
            self.YfilteredDataPoints.removeAll()
            self.ZfilteredDataPoints.removeAll()
            self.angleDataPoints.removeAll()
        }
    }
    // MARK: - Command Handling
    private func sendCommand(to peripheral: CBPeripheral, command: String) {
        guard let services = peripheral.services else { return }

        for service in services {
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == GATTCommand {
                    let commandData = command.data(using: .utf8)!
                    peripheral.writeValue(
                        commandData, for: characteristic, type: .withResponse)
                    print("Command Sent: \(command) to \(characteristic.uuid)")
                }
            }
        }
    }

    // MARK: - CBPeripheralDelegate Methods
    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverServices error: Error?
    ) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        print("Discovered Services:")
        for service in peripheral.services ?? [] {
            print("- \(service.uuid)")
            peripheral.discoverCharacteristics(
                [GATTCommand, GATTData], for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        print("didDiscoverCharacteristics")
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            //print(characteristic)

            if characteristic.uuid == GATTData {
                print("Data")
                peripheral.setNotifyValue(true, for: characteristic)
            }

            if characteristic.uuid == GATTCommand {
                print("Command")
                // Possible sample rates are [13 26 52 104 208 416 833]
                // Link to api https://bitbucket.org/suunto/movesense-device-lib/src/master/

                // The string 190/Meas/Gyro/52 to ascii
                //let parameter:[UInt8]  = [1, 90, 47, 77, 101, 97, 115, 47, 71, 121, 114, 111, 47, 53, 50]

                // The string 199/Meas/Acc/52 to ascii
                //let parameter:[UInt8] = [1, 99, 47, 77, 101, 97, 115, 47, 65, 99, 99, 47, 53, 50]

                //  IMU6 = 73 77 85 54
                let parameter: [UInt8] = [
                    1, 99, 47, 77, 101, 97, 115, 47, 73, 77, 85, 54, 47, 53, 50,
                ]

                //let parameter:[UInt8] = [2, 99]

                let data = NSData(bytes: parameter, length: parameter.count)

                peripheral.writeValue(
                    data as Data, for: characteristic,
                    type: CBCharacteristicWriteType.withResponse)

                print("Command3 \(parameter.count)")

            }
        }
    }


    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic, error: Error?
    ) {
        if let error = error {
            print("Error updating value: \(error.localizedDescription)")
            return
        }
        guard let value = characteristic.value else {
            print("No data received")
            return
        }

        switch characteristic.uuid {
        case GATTData:
            let data = characteristic.value

            var byteArray: [UInt8] = []
            for i in data! {
                let n: UInt8 = i
                byteArray.append(n)
            }
            
            let response = byteArray[0]
            let reference = byteArray[1]

            if response == 2 && reference == 99 {
                let array: [UInt8] = [
                    byteArray[2], byteArray[3], byteArray[4], byteArray[5],
                ]
                var time: UInt32 = 0
                let data = NSData(bytes: array, length: 4)
                data.getBytes(&time, length: 4)

                
                let Xacc = bytesToFloat(bytes: [
                    byteArray[9], byteArray[8], byteArray[7], byteArray[6],
                ])
                let Yacc = bytesToFloat(bytes: [
                    byteArray[13], byteArray[12], byteArray[11], byteArray[10],
                ])
                let Zacc = bytesToFloat(bytes: [
                    byteArray[17], byteArray[16], byteArray[15], byteArray[14],
                ])
                let filteredData = dataProcessor.filterIMUData(x: Xacc, y: Yacc, z: Zacc)
                let angle = dataProcessor.calculate2DAngle(x: filteredData.filteredX, y: filteredData.filteredY)
                let angle3d = dataProcessor.calculateVaried3dAngle(x: filteredData.filteredX, y: filteredData.filteredY, z: filteredData.filteredZ)

                //print("X:\(Xacc) Y:\(Yacc)  Z:\(Zacc)")
                //print("Filtered X:\(filteredData.filteredX) Y:\(filteredData.filteredY)  Z:\(filteredData.filteredZ)")
                /*let angleToAppend = (angle3d.tiltAngle + 90) <= 180
                    ? angle3d.tiltAngle + 90
                    : 180 - ((angle3d.tiltAngle + 90) - 180);
                print("3d angle: " + String(angleToAppend))*/
                
                //print("z value : " + String(filteredData.filteredZ))
                //print("3d angle: " + String(angle3d.zAngle))
                //print("roll : " + String(angle3d.roll))
                //print("pitch : " + String(angle3d.pitch))
                if isRecording
                {
                    XrawDataPoints.append(Xacc)
                    YrawDataPoints.append(Yacc)
                    ZrawDataPoints.append(Zacc)
                    XfilteredDataPoints.append(filteredData.filteredX)
                    YfilteredDataPoints.append(filteredData.filteredY)
                    ZfilteredDataPoints.append(filteredData.filteredZ)
                    angleDataPoints.append(angle3d.tiltAngle)
                }
            }

        case GATTCommand:
            print("Status uppdate")

        default:
            print("Unhandled Characteristic UUID:")
        }
        /*
        // Convert raw data to byte array
        let byteArray = [UInt8](value)

        // Parse IMU data
        if byteArray.count >= 18 {
            let x = bytesToFloat(bytes: Array(byteArray[6..<10]))
            let y = bytesToFloat(bytes: Array(byteArray[10..<14]))
            let z = bytesToFloat(bytes: Array(byteArray[14..<18]))

            self.rawDataPoints.append(x)  // Append X value to data points
            // Filter raw IMU data
            let filteredData = dataProcessor.filterIMUData(x: x, y: y, z: z)

            // Calculate angle
            let angle = dataProcessor.calculateAngle(x: filteredData.filteredX, y: filteredData.filteredY, z: filteredData.filteredZ)

            // Optional: Use complementary filter (assume gyroscopeZ is available)
            //let fusedZ = dataProcessor.fuseData(acceleration: filteredData.filteredZ, gyroscope: z)

            // Print processed data
            /*print("""
                Filtered Data -> X: \(filteredData.filteredX), Y: \(filteredData.filteredY), Z: \(filteredData.filteredZ)
                Angle: \(angle) degrees
                Fused Z: \(fusedZ)
            """)*/
            // Print processed data
            print("""
                Filtered Data -> X: \(filteredData.filteredX),
                Raw Data -> X: \(x)
                Angle: \(angle) degrees
            """)

            // Update UI or data storage
            DispatchQueue.main.async {
                self.angleDataPoints.append(angle) // Store angle or fused data for display
                self.filteredDataPoints.append(filteredData.filteredX) // Store angle or fused data for display
            }
        } else {
            print("Invalid data size: \(byteArray.count) bytes")
        }*/
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic, error: Error?
    ) {
        if let error = error {
            print("Error writing value: \(error.localizedDescription)")
        } else {
            print("Successfully wrote value to \(characteristic.uuid)")
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("Error enabling notifications: \(error.localizedDescription)")
        } else {
            print(
                "Notifications enabled for: \(characteristic.uuid), isNotifying: \(characteristic.isNotifying)"
            )
        }
    }

    // MARK: - Helper: Convert Bytes to Float
    private func bytesToFloat(bytes: [UInt8]) -> Float {
        let bigEndianValue = bytes.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) {
                $0.pointee
            }
        }
        let bitPattern = UInt32(bigEndian: bigEndianValue)
        return Float(bitPattern: bitPattern)
    }
    
    public func updateIsRecording(){
        isRecording.toggle()
    }
    
    private func generateCSVData() {
           csvRows.removeAll() // Clear any previous data

           let count = XrawDataPoints.count

           for i in 0..<count {
               let rawX = String(format: "%.3f", XrawDataPoints[i])
               let rawY = String(format: "%.3f", YrawDataPoints[i])
               let rawZ = String(format: "%.3f", ZrawDataPoints[i])
               let filteredX = String(format: "%.3f", XfilteredDataPoints[i])
               let filteredY = String(format: "%.3f", YfilteredDataPoints[i])
               let filteredZ = String(format: "%.3f", ZfilteredDataPoints[i])
               let angle = String(format: "%.3f", angleDataPoints[i])

               let csvRow = CSVModel(
                   accX: rawX,
                   accY: rawY,  // Replace with real data if available
                   accZ: rawZ,  // Replace with real data if available
                   filteredAccX: filteredX,
                   filteredAccY: filteredY, // Replace with real data if available
                   filteredAccZ: filteredZ, // Replace with real data if available
                   computedAngle: angle
               )
               csvRows.append(csvRow)
           }
           print("CSV Data Prepared: \(csvRows.count) rows")
       }

    private func saveJSONToFile() {
        let fileName = generateFileName()
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

        // Encode `csvRows` to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // For readable JSON
        do {
            let jsonData = try encoder.encode(csvRows)
            try jsonData.write(to: fileURL, options: .atomic)
            print("JSON saved successfully to \(fileURL)")
        } catch {
            print("Error saving JSON file: \(error.localizedDescription)")
        }
    }

    /// Get the app's Document Directory path
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func loadJSONFromFile() {
        let fileName = "imu_data.json" // File name
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

        let decoder = JSONDecoder()
        do {
            let jsonData = try Data(contentsOf: fileURL)
            csvRows = try decoder.decode([CSVModel].self, from: jsonData)
            print("JSON loaded successfully. Row count: \(csvRows.count)")
        } catch {
            print("Error loading JSON file: \(error.localizedDescription)")
        }
    }
    
    /// Generates a unique file name using the current date and time
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = formatter.string(from: Date())
        return "\(dateString)_imu_data.json"
    }

}
