//
//  GeotificationsViewController.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
//import UserNotifications

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

final class GeotificationVC: UIViewController, UISplitViewControllerDelegate, RegionsProtocol {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    var geotifications: [Geotification] = []
    let locationManager = CLLocationManager()
    var circle:MKCircle! //setup GetRegion
    private var buttonSize: CGFloat = 0.0
    
    //mileIQ
    //var previousLocation: CLLocation? // for distance calculation
    //var distance = 0.0
    //let dateFormatter = DateFormatter()
    
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
    var geoSubtitle: String?
    
    lazy var floatingBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("+", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 5, right: 0)
        button.addTarget(self, action: #selector(maptype), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var floatingZoomBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    static let numberFormatter: NumberFormatter =  { //speed label
        let mf = NumberFormatter()
        mf.minimumFractionDigits = 0
        mf.maximumFractionDigits = 0
        return mf
    }()
    
    let speedLabel: UILabel = {
        let label = UILabel()
        label.text = "---"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let altitudeLabel: UILabel = {
        let label = UILabel()
        label.text = "searching..."
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let coarseLabel: UILabel = {
        let label = UILabel()
        label.text = "searching..."
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func floatButton() {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            buttonSize = 50
        } else {
            buttonSize = 40
        }
        floatingBtn.titleLabel?.font = UIFont(name: floatingBtn.titleLabel!.font.familyName , size: buttonSize)
        let btnLayer: CALayer = floatingBtn.layer
        btnLayer.cornerRadius = buttonSize / 2
        btnLayer.masksToBounds = true
        
        let btnLayer1: CALayer = floatingZoomBtn.layer
        btnLayer1.cornerRadius = buttonSize / 2
        btnLayer1.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIToolbar.appearance().barTintColor = .red 
        self.extendedLayoutIncludesOpaqueBars = true
        UIApplication.shared.isIdleTimerDisabled = true //added
        //fixed - remove bottom bar
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        mapView.delegate = self //added
        mapView.userTrackingMode = .follow //added
        mapView.alpha = 0.8

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.activityType = .automotiveNavigation
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.allowsBackgroundLocationUpdates = true //added
        }
        //journal
        let annotations = LocationsStorage.shared.locations.map { annotationForLocation($0) }
        mapView.addAnnotations(annotations)
        NotificationCenter.default.addObserver(self, selector: #selector(newLocationAdded(_:)), name: .newLocationSaved, object: nil)
        
        setupNavigation()
        floatButton()
        setupConstraints() //below floatbutton
        loadAllGeotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        UIToolbar.appearance().barTintColor = .red //Color.toolbarColor
        
        locationManager.requestAlwaysAuthorization()
        // Setup GetAddress
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(GeotificationVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        segmentedControl.selectedSegmentIndex = 0
        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        
        if UIDevice.current.userInterfaceIdiom == .phone  {
            let state = notification.object as! Bool
            self.navigationController?.setNavigationBarHidden(state, animated: true)
            UIView.animate(withDuration: 0.2, animations: {
                self.tabBarController?.hideTabBarAnimated(hide: state) //added
            }, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    func setupConstraints() {
        
        self.view.addSubview(altitudeLabel)
        self.view.addSubview(speedLabel)
        self.view.addSubview(coarseLabel)
        self.view.addSubview(floatingBtn)
        self.view.addSubview(floatingZoomBtn)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            altitudeLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 15),
            altitudeLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            altitudeLabel.heightAnchor.constraint(equalToConstant: 25),
            
            speedLabel.topAnchor.constraint(equalTo: altitudeLabel.bottomAnchor, constant: 5),
            speedLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            speedLabel.heightAnchor.constraint(equalToConstant: 25),
            
            coarseLabel.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 5),
            coarseLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            coarseLabel.heightAnchor.constraint(equalToConstant: 25),
            
            floatingBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            floatingBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -60),
            floatingBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingBtn.heightAnchor.constraint(equalToConstant: buttonSize),
            
            floatingZoomBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            floatingZoomBtn.bottomAnchor.constraint(equalTo: floatingBtn.topAnchor, constant: -25),
            floatingZoomBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingZoomBtn.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
    }
    
    @objc func maptype() {
        
        if self.mapView.mapType == MKMapType.standard {
            self.mapView.mapType = MKMapType.hybridFlyover
        } else {
            self.mapView.mapType = MKMapType.standard
        }
    }
    
    // MARK: - SegmentedControl
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: break;
            
        case 1:
            self.performSegue(withIdentifier: "getregionSegue", sender: self)
            
        case 2:
            self.performSegue(withIdentifier: "getaddressSegue", sender: self)
            
        case 3:
            let storyboard = UIStoryboard(name: "MileIQ", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MileVC") as! PlacesCollectionView
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.present(vc, animated: true)
        default:
            break;
        }
    }
    
    // Get Address Button
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            thoroughfare = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            subThoroughfare = (containsPlacemark.subThoroughfare != nil) ? containsPlacemark.subThoroughfare : ""
            locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            sublocality = (containsPlacemark.subLocality != nil) ? containsPlacemark.subLocality : ""
            postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            subAdministrativeArea = (containsPlacemark.subAdministrativeArea != nil) ? containsPlacemark.subAdministrativeArea : ""
            country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            ISOcountryCode = (containsPlacemark.isoCountryCode != nil) ? containsPlacemark.isoCountryCode : ""
            
        }
    }
    
    // MARK: - AddGeotification
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geotifications.removeAll()
        let allGeotifications = Geotification.allGeotifications()
        allGeotifications.forEach { add(geotification: $0) }
    }
    
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifications)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func remove(geotification: Geotification) {
        guard let index = geotifications.firstIndex(of: geotification) else { return }
        geotifications.remove(at: index)
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func updateGeotificationsCount() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight Software - Geotify: \(geotifications.count)"
        } else {
            navigationItem.title = "Geotify: \(geotifications.count)"
        }
        //limit the number of geotifications user can set, disables the Add button in the navigation bar whenever the app reaches the limit.
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        mapView?.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView?.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
    // MARK: - Monitoring
    func region(with geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
            showAlert(withTitle:"Warning", message: message)
        }
        
        let fenceRegion = region(with: geotification)
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    //MARK:  RegionsProtocol
    //setup GetRegion
    func loadOverlayForRegionWithLatitude(_ latitude: Double, andLongitude longitude: Double) {
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        circle = MKCircle(center: coordinates, radius: 200000)
        self.mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        self.mapView.addOverlay(circle)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addGeotification" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeotificationVC
            vc.delegate = self
        }
        
        if segue.identifier == "getaddressSegue" {
            guard let VC = segue.destination as? GetAddress else { return }
            VC.thoroughfare = self.thoroughfare
            VC.subThoroughfare = self.subThoroughfare
            VC.locality = self.locality
            VC.sublocality = self.sublocality
            VC.postalCode = self.postalCode
            VC.administrativeArea = self.administrativeArea
            VC.subAdministrativeArea = self.subAdministrativeArea
            VC.country = self.country
            VC.ISOcountryCode = self.ISOcountryCode
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        if segue.identifier == "getregionSegue" {
            guard let regionsController = segue.destination as? RegionsListVC else { return }
            regionsController.delegate = self
        }
    }
//---------------------------------------------------------------------
    //added Journal
    @IBAction func addItemPressed(_ sender: Any) {
        guard let currentLocation = mapView.userLocation.location else {
            return
        }
        LocationsStorage.shared.saveCLLocationToDisk(currentLocation)
    }
    
    func annotationForLocation(_ location: Location) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = location.dateString
        annotation.coordinate = location.coordinates
        return annotation
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        guard let location = notification.userInfo?["location"] as? Location else {
            return
        }
        
        let annotation = annotationForLocation(location)
        mapView.addAnnotation(annotation)
    }
}
//---------------------------------------------------------------------

//AddGeotification
extension GeotificationVC: AddGeotificationsViewControllerDelegate {
    
    func addGeotificationViewController(controller: AddGeotificationVC, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: Geotification.EventType) {
        controller.dismiss(animated: true)
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        add(geotification: geotification)
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
}
// MARK: - Location Manager Delegate
//AddGeotification and GetAddress
extension GeotificationVC: CLLocationManagerDelegate {
    
    // MARK: - Geotify AddGeotification
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading locations: CLHeading) {
        coarseLabel.text = "\(locations.magneticHeading)˚"
    }
    
    //Get Address Button
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//--------------------------------------------------------------------------------
        
        if let location = locations.last { //locations.first
            altitudeLabel.text = String(format: "Alt: %.2f", location.altitude)
            speedLabel.text = String(format: "Speed: %.0f", location.speed)
            coarseLabel.text = String(format: "Course: %.0f", location.course) //"\(location.course)˚"
        }

        //Get Address Button
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                self.simpleAlert(title: "Alert", message: "Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
            } else {
                self.simpleAlert(title: "Alert", message: "Problem with the data received from geocoder")
            }
        })
    }
}

// MARK: - MapView Delegate
extension GeotificationVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.pinTintColor = .systemBlue
                annotationView?.isMultipleTouchEnabled = false
                annotationView?.isDraggable = true
                annotationView?.animatesDrop = true
                
                let removeButton = UIButton(type: .custom)
                removeButton.frame = .init(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(systemName: "x.circle"), for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.lineWidth = 2.0
            renderer.strokeColor = .systemBlue
            renderer.fillColor = UIColor.systemOrange.withAlphaComponent(0.3)
            return renderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.systemOrange
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        let geotification = view.annotation as! Geotification
        stopMonitoring(geotification: geotification)
        remove(geotification: geotification)
        saveAllGeotifications()
        
    }
    
}

