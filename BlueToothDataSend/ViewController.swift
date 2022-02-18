//
//  ViewController.swift
//  BlueToothDataSend
//
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate , CBPeripheralManagerDelegate{
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print(peripheral)
    }
    

    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    private var cbP : CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        cbP = CBPeripheralManager(delegate: self, queue: nil)
    }

    // MARK:- CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particleLEDServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true,
                                                        CBConnectPeripheralOptionEnableTransportBridgingKey: true])
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name!)
        print(peripheral.state)
        //CBAdvertisementDataLocalNameKey
        // We've found it so stop scan
        self.centralManager.stopScan()

        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self

        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(peripheral.name!)
        if peripheral == self.peripheral {
            print("Connected to your Particle Board")
            peripheral.discoverServices([ParticlePeripheral.particleLEDServiceUUID])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral.services!)
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.particleLEDServiceUUID {
                    print("LED service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ParticlePeripheral.redLEDCharacteristicUUID,
                                                             ParticlePeripheral.greenLEDCharacteristicUUID,
                                                             ParticlePeripheral.blueLEDCharacteristicUUID], for: service)
                    return
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print(peripheral.services!)
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.redLEDCharacteristicUUID {
                    print("Red LED characteristic found")
                } else if characteristic.uuid == ParticlePeripheral.greenLEDCharacteristicUUID {
                    print("Green LED characteristic found")
                } else if characteristic.uuid == ParticlePeripheral.blueLEDCharacteristicUUID {
                    print("Blue LED characteristic found");
                }
            }
        }
    }
    
    private func writeLEDValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {

        // Check if it has the write property
        if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {

            peripheral.writeValue(value, for: characteristic, type: .withoutResponse)

        }

    }
}

