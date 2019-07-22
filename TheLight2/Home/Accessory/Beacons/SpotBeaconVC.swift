//
//  SpotBeaconController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
//import QuartzCore


class SpotBeaconVC: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var btnSwitchSpotting: UIButton!
    @IBOutlet weak var lblBeaconReport: UILabel!
    @IBOutlet weak var lblBeaconDetails: UILabel!
    @IBOutlet weak var beaconspotLabel: UILabel!
    @IBOutlet weak var beaconlocateLabel: UILabel!
    @IBOutlet weak var lblBTStatus: UILabel!

    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false

    var beaconPeripheralData: NSDictionary! //added bluetooth
    var peripheralManager: CBPeripheralManager! //added bluetooth
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        lblBeaconDetails.isHidden = false
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            //self.beaconspotLabel?.font = Font.Snapshot.celltitlePad
            self.beaconlocateLabel?.font = Font.Snapshot.celltitlePad
            self.lblBeaconDetails?.font = Font.News.newstitlePad
            self.lblBeaconReport?.font = Font.Snapshot.celltitlePad
            self.lblBTStatus?.font = Font.celltitle18l
        } else {
    
        }
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Spot Beacon"
        } else {
            navigationItem.title = "Spot Beacon"
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
    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(_ sender: AnyObject) {
        
        let uuid = UUID(uuidString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "com.TheLight.beacon")
      //beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 100, minor: 1, identifier: "com.TheLight.beacon")
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
        if !isSearchingForBeacons {
            btnSwitchSpotting.setTitle("Stop Spotting", for: .normal)
            lblBeaconReport.text = "Spotting beacons..."
        }
        else {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", for: .normal)
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.isHidden = false
            self.view.backgroundColor = UIColor.white
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    //startScanning()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
    func updateDistance(_ distance: CLProximity) {
        
        var proximityMessage: String!
        
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                proximityMessage = "Where's the beacon?"
                self.view.backgroundColor = .systemGray
                self.btnSwitchSpotting?.titleLabel?.textColor = .white
                self.btnSwitchSpotting?.backgroundColor = .systemOrange
                self.beaconspotLabel.textColor = .systemOrange
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .black
                
            case .far:
                proximityMessage = "Far"
                self.view.backgroundColor = .systemBlue
                self.btnSwitchSpotting?.titleLabel?.textColor = .white
                self.btnSwitchSpotting?.backgroundColor = .systemOrange
                self.beaconspotLabel.textColor = .systemOrange
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .white
                
            case .near:
                proximityMessage = "Near"
                self.view.backgroundColor = .systemOrange
                self.btnSwitchSpotting?.titleLabel?.textColor = .systemOrange
                self.btnSwitchSpotting?.backgroundColor = .white
                self.beaconspotLabel.textColor = .white
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .black
                
            case .immediate:
                proximityMessage = "Very close"
                self.view.backgroundColor = .systemRed
                self.btnSwitchSpotting?.titleLabel?.textColor = .white
                self.btnSwitchSpotting?.backgroundColor = .systemOrange
                self.beaconspotLabel.textColor = .systemOrange
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .black
            @unknown default: break
                //<#fatalError()#>
            }
        }
        lblBeaconDetails.text = "Beacon Details:\nDistance From iBeacon = " + proximityMessage
    }
    
    // MARK: CBPeripheralManagerDelegate //added bluetooth
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
