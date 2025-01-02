//
//  DeviceManager.swift
//  RepRiteApp
//
//  Created by lorewnzo  on 2024-12-29.
//


import CoreBluetooth
import Foundation
import SwiftUI

class DeviceManager: NSObject, ObservableObject, CBCentralManagerDelegate,
    CBPeripheralDelegate
{
    static let shared = DeviceManager()
    let dataProcessor = DataManipulationController()
    var selectedDataModel: DataAquisitionModel? = nil

    private var centralManager: CBCentralManager!
    private(set) var discoveredDevices: [CBPeripheral] = []
    @Published var pairedDevices: [CBPeripheral] = []
    
    let moveSenseServiceUUID = CBUUID(
        string: "34802252-7185-4d5d-b431-630e7050e8f0")
    private let GATTService = CBUUID(
        string: "34802252-7185-4d5d-b431-630e7050e8f0")
    
    @Published var isScanning = false
    @Published var deviceName = ""
    @Published var isConnected = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Start scanning
    func startScanning() {
        isScanning = true
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        for family in UIFont.familyNames {
            print("Font Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  Font Name: \(name)")
            }
        }
    }
    
    // Stop scanning
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    // CBCentralManager Delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not enabled.")
        }
    }
    
    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        if let deviceName = advertisementData[CBAdvertisementDataLocalNameKey]
            as? String
        {
            // Check if the name starts with "movesense" ignoring case
            if deviceName.lowercased().hasPrefix("movesense") || deviceName.lowercased().hasPrefix("polar") {                if !discoveredDevices.contains(peripheral) {
                    discoveredDevices.append(peripheral)
                    objectWillChange.send()
                }
            }
        }
    }
    
    func centralManager(
        _ central: CBCentralManager, didConnect peripheral: CBPeripheral
    ) {
        pairedDevices.append(peripheral)
        objectWillChange.send()
        peripheral.discoverServices(nil)
        central.scanForPeripherals(withServices: [GATTService], options: nil)
        deviceName = peripheral.name ?? "Unknown Device"
        isConnected = true
        let dataModel = DataAquisitionModel()
        dataModel.configurePeripheral(peripheral) // Directly call configurePeripheral
        selectedDataModel = dataModel
        print("Connected to \(peripheral.name ?? "Unknown Device")")
    }
    
    func disconnectAllDevices() {
        for peripheral in pairedDevices {
            centralManager.cancelPeripheralConnection(peripheral)
            print("Disconnected from \(peripheral.name ?? "Unknown Device")")
        }
        isConnected = false
        deviceName = ""
        pairedDevices.removeAll() // Clear connected peripherals
        objectWillChange.send()
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Services modified: \(invalidatedServices)")

        // Check connection state
        if peripheral.state != .connected {
            print("Peripheral disconnected, attempting to reconnect...")
            centralManager.connect(peripheral, options: nil)
        } else {
            // Rediscover services if still connected
            peripheral.discoverServices(nil)
        }
    }
}
