//
//  CardViewController.swift
//  CardViewAnimation
//
//  Created by Brian Advent on 26.10.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!

    /*
    //Get Address
    var thoroughfare: String?
    var subThoroughfare: String?
    var locality: String?
    var sublocality: String?
    var postalCode: String?
    var administrativeArea: String?
    var subAdministrativeArea: String?
    var country: String?
    var ISOcountryCode: String?
    var geoTitle: String?
    var geoSubtitle: String? */


    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addBtn.translatesAutoresizingMaskIntoConstraints = false
        //addBtn.backgroundColor = .systemBlue
        addBtn.addTarget(self, action: #selector(addButton), for: .touchUpInside)
    }

    // MARK: - SegmentedControl
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: break;

        case 1:
            segmentedControl.selectedSegmentIndex = 0
            //self.performSegue(withIdentifier: "getregionSegue", sender: self)
            let storyboard = UIStoryboard(name: "Geotify", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RegionVC") as! RegionsListVC
            //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.show(vc, sender: true)

        case 2:
            segmentedControl.selectedSegmentIndex = 0
            //self.performSegue(withIdentifier: "getaddressSegue", sender: self)
            let storyboard = UIStoryboard(name: "Geotify", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "getAddressVC") as! GetAddress
            self.show(vc, sender: true)
        case 3:
            segmentedControl.selectedSegmentIndex = 0
            let storyboard = UIStoryboard(name: "MileIQ", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MileVC") as! PlacesCollectionView
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.present(vc, animated: true)
        default:
            break;
        }
    }

    @objc func addButton() { //dont work fix

        let storyboard = UIStoryboard(name: "Geotify", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addGeotifyNC")
        self.present(vc, animated: true)
    }

    // MARK: - Segues
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
/*
           if segue.identifier == "addGeotification" {
               let navigationController = segue.destination as! UINavigationController
               let vc = navigationController.viewControllers.first as! AddGeotificationVC
               vc.delegate = self
           } */
        
/*
           if segue.identifier == "getaddressSegue" {
               guard let VC = segue.destination as? GetAddress else { return }
               VC.thoroughfare = GeotificationVC.thoroughfare
               VC.subThoroughfare = self.subThoroughfare
               VC.locality = self.locality
               VC.sublocality = self.sublocality
               VC.postalCode = self.postalCode
               VC.administrativeArea = self.administrativeArea
               VC.subAdministrativeArea = self.subAdministrativeArea
               VC.country = self.country
               VC.ISOcountryCode = self.ISOcountryCode
               navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
           } */

/*
           if segue.identifier == "getregionSegue" {
               guard let regionsController = segue.destination as? RegionsListVC else { return }
               regionsController.delegate = self
           } */
       }

}
