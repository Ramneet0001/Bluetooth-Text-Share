//
//  PopulateVC.swift
//  BlueToothDataSend
//
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CoreBluetooth

class PopulateVC: UIViewController, UITableViewDelegate ,UITableViewDataSource {
    
    

    @IBOutlet weak var tblvww: UITableView!
    
    var visibleDevices = Array<Device>()
    var cachedDevices = Array<Device>()
    var cachedPeripheralNames = Dictionary<String, String>()
    var timer = Timer()
    
    var peripheralManager = CBPeripheralManager()
    var centralManager: CBCentralManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblvww.tableFooterView = UIView()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        scheduledTimerWithTimeInterval()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        updateAdvertisingData()
    }
    
    func scheduledTimerWithTimeInterval(){
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.clearPeripherals), userInfo: nil, repeats: true)
    }
    
    @objc func clearPeripherals(){
        
        visibleDevices = cachedDevices
        cachedDevices.removeAll()
        self.tblvww.reloadData()
    }
    
    func updateAdvertisingData() {
        
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let advertisementData = "UserName..."
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[Constants.SERVICE_UUID], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    func addOrUpdatePeripheralList(device: Device, list: inout Array<Device>) {

        if !list.contains(where: { $0.peripheral.identifier == device.peripheral.identifier }) {
            
            list.append(device)
            self.tblvww.reloadData()
        }
        else if list.contains(where: { $0.peripheral.identifier == device.peripheral.identifier
            && $0.name == "unknown"}) && device.name != "unknown" {
            
            for index in 0..<list.count {
                
                if (list[index].peripheral.identifier == device.peripheral.identifier) {
                    
                    list[index].name = device.name
                    self.tblvww.reloadData()
                    break
                }
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TblvwCell
        let device = visibleDevices[indexPath.row]
        let advertisementData = device.name.components(separatedBy: "|")
        if (advertisementData.count > 1) {
            cell.lblName?.text! = advertisementData[0]
        } else {
            cell.lblName?.text! = device.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatViewController = ChatViewController()
        chatViewController.deviceUUID = visibleDevices[indexPath.row].peripheral.identifier
        chatViewController.deviceAttributes = visibleDevices[indexPath.row].name
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
}

extension PopulateVC : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            
            updateAdvertisingData()
        }
    }
}

extension PopulateVC : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            
            self.centralManager?.scanForPeripherals(withServices: [Constants.SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var peripheralName = cachedPeripheralNames[peripheral.identifier.description] ?? "unknown"
        
        if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            peripheralName = advertisementName
            cachedPeripheralNames[peripheral.identifier.description] = peripheralName
        }
        
        let device = Device(peripheral: peripheral, name: peripheralName)
        
        self.addOrUpdatePeripheralList(device: device, list: &visibleDevices)
        self.addOrUpdatePeripheralList(device: device, list: &cachedDevices)
    }
}
