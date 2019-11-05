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


final class SpotBeaconVC: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
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
        view.backgroundColor = .secondarySystemGroupedBackground
        lblBTStatus.textColor = .systemOrange
        lblBeaconDetails.textColor = .label
        lblBeaconReport.textColor = .label
        beaconlocateLabel.textColor = .label
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager!.allowsBackgroundLocationUpdates = true
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        lblBeaconDetails.isHidden = false
        btnSwitchSpotting.layer.cornerRadius = 30.0
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        self.navigationItem.largeTitleDisplayMode = .always
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Spot Beacon"
            self.beaconlocateLabel?.font = Font.Snapshot.celltitlePad
            self.lblBeaconDetails?.font = Font.News.newstitlePad
            self.lblBeaconReport?.font = Font.Snapshot.celltitlePad
            self.lblBTStatus?.font = Font.celltitle18l
            self.beaconlocateLabel.text = "iBeacon ipad"
        } else {
            navigationItem.title = "Spot Beacon"
            self.beaconlocateLabel.text = "iBeacon iphone"
        }
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
            view.backgroundColor = .secondarySystemGroupedBackground
        }
        else {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", for: .normal)
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.isHidden = false
            view.backgroundColor = .secondarySystemGroupedBackground
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
                self.lblBeaconReport.textColor = .label
                self.lblBeaconDetails.textColor = .label
                self.beaconlocateLabel.textColor = .label
                
            case .far:
                proximityMessage = "within 20ft"
                self.view.backgroundColor = .systemBlue
                self.btnSwitchSpotting?.titleLabel?.textColor = .white
                self.btnSwitchSpotting?.backgroundColor = .systemOrange
                self.beaconspotLabel.textColor = .systemOrange
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .white
                
            case .near:
                proximityMessage = "within 5ft"
                self.view.backgroundColor = .systemOrange
                self.btnSwitchSpotting?.titleLabel?.textColor = .systemOrange
                self.btnSwitchSpotting?.backgroundColor = .white
                self.beaconspotLabel.textColor = .white
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .black
                
            case .immediate:
                proximityMessage = "within 3ft"
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
        lblBeaconDetails.text = "Distance From iBeacon = " + proximityMessage
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
