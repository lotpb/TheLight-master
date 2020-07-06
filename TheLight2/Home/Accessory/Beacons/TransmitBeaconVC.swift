//
//  TransmitBeaconController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
//import QuartzCore
import CoreLocation
import CoreBluetooth


final class TransmitBeaconVC: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var txtMajor: UITextField!
    @IBOutlet weak var txtMinor: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBTStatus: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var beaconBroadlabel: UILabel!
    
    var localBeaconUUID = "F34A1A1F-500F-48FB-AFAA-9584D641D7B1"
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    var dataDictionary = NSDictionary()
    var beaconRegion: CLBeaconRegion!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemGroupedBackground
        lblBTStatus.textColor = .systemOrange
        beaconBroadlabel.textColor = .label
        lblStatus.textColor = .label

        if UIDevice.current.userInterfaceIdiom == .pad  {
            lblStatus?.font = Font.Snapshot.celltitlePad
            txtMajor?.font = Font.Snapshot.celltitlePad
            txtMinor?.font = Font.Snapshot.celltitlePad
            majorLabel?.font = Font.Snapshot.celltitlePad
            minorLabel?.font = Font.Snapshot.celltitlePad
            beaconBroadlabel?.font = Font.Snapshot.celltitlePad
            lblBTStatus?.font = Font.celltitle18l
        } else {
            
        }
        
        btnAction.layer.cornerRadius = btnAction.frame.size.width/2
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(TransmitBeaconVC.handleSwipeGestureRecognizer))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Transmit Beacon"
        } else {
            navigationItem.title = "Transmit Beacon"
        }
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Custom method implementation
    
    @objc func handleSwipeGestureRecognizer(_ gestureRecognizer: UISwipeGestureRecognizer) {
        txtMajor.resignFirstResponder()
        txtMinor.resignFirstResponder()
    }
    
    // MARK: IBAction method implementation
    @IBAction func switchBroadcastingState(sender: AnyObject) {
        
        if txtMajor.text == "" || txtMinor.text == "" {
            return
        }
        
        if txtMajor.isFirstResponder || txtMinor.isFirstResponder {
            return
        }
        
        if !isBroadcasting {

            let localBeaconMajor: CLBeaconMajorValue = UInt16(Int(txtMajor.text!)!)
            let localBeaconMinor: CLBeaconMinorValue = UInt16(Int(txtMinor.text!)!)
            let uuid = UUID(uuidString: localBeaconUUID)!
            localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "com.TheLight.beacon")
            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
            
            btnAction.setTitle("Stop", for: .normal)
            lblStatus.text = "Broadcasting..."
            txtMajor.isEnabled = false
            txtMinor.isEnabled = false
            isBroadcasting = true
            view.backgroundColor = .systemGray


        } else {
            
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            localBeacon = nil
            
            btnAction.setTitle("Start", for: .normal)
            lblStatus.text = "Stopped"
            txtMajor.isEnabled = true
            txtMinor.isEnabled = true
            isBroadcasting = false
            view.backgroundColor = .secondarySystemGroupedBackground
        } 
    }
    
    // MARK: CBPeripheralManagerDelegat
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var statusMessage = ""
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]?)
            statusMessage = "Bluetooth Status: Turned On"
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
            statusMessage = "Bluetooth Status: Turned Off"
        } else if peripheral.state == .unsupported {
            statusMessage = "Bluetooth Status: Not Supported"
        }
        lblBTStatus.text = statusMessage
    }
}
