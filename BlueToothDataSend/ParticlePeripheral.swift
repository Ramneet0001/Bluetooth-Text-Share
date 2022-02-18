//
//  Peripheral.swift
//  BlueToothDataSend
//
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CoreBluetooth
import Foundation

class ParticlePeripheral: NSObject {

    // MARK:- Particle LED services and charcteristics Identifiers

    public static let particleLEDServiceUUID     = CBUUID.init(string: "b4250400-fb4b-4746-b2b0-93f0e61122c6")
    public static let redLEDCharacteristicUUID   = CBUUID.init(string: "b4250401-fb4b-4746-b2b0-93f0e61122c6")
    public static let greenLEDCharacteristicUUID = CBUUID.init(string: "b4250402-fb4b-4746-b2b0-93f0e61122c6")
    public static let blueLEDCharacteristicUUID  = CBUUID.init(string: "b4250403-fb4b-4746-b2b0-93f0e61122c6")

}

struct Device {
    
    var peripheral : CBPeripheral
    var name : String
    var messages = Array<String>()
    
    init(peripheral: CBPeripheral, name:String) {
        self.peripheral = peripheral
        self.name = name
    }
}

struct Constants {

    static let SERVICE_UUID = CBUUID(string: "4DF91029-B356-463E-9F48-BAB077BF3EF5")
    static let RX_UUID = CBUUID(string: "3B66D024-2336-4F22-A980-8095F4898C42")
    static let RX_PROPERTIES: CBCharacteristicProperties = .write
    static let RX_PERMISSIONS: CBAttributePermissions = .writeable
    
}



struct Message {
    
    var text : String
    var isSent : Bool
    
    init(text: String, isSent: Bool) {
        
        self.text = text
        self.isSent = isSent
    }
}

class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 10.0
    @IBInspectable var bottomInset: CGFloat = 10.0
    @IBInspectable var leftInset: CGFloat = 20.0
    @IBInspectable var rightInset: CGFloat = 20.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}

