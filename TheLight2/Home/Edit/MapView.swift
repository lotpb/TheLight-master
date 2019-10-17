//
//  MapView.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/7/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation


@available(iOS 13.0, *)
final class MapView: UIViewController {
    
    //@IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var travelTime: UILabel!
    @IBOutlet weak var travelDistance: UILabel!
    @IBOutlet weak var stepView: UITextView!
    @IBOutlet weak var routView: UIView!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!

    var formController : String?
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    var stepCounter = 0
    var steps = [MKRoute.Step]()
    var route: MKRoute!
    var allSteps : String?
    //placesFeedCell
    var startCoordinates: CLLocationCoordinate2D?
    var endCoordinates: CLLocationCoordinate2D?
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    let celllabel1 = UIFont.systemFont(ofSize: 18, weight: .medium)
    let cellsteps = UIFont.systemFont(ofSize: 18, weight: .light)

    var mapaddress : NSString?
    var mapcity : NSString?
    var mapstate : NSString?
    var mapzip : NSString?
    //var locationManager: CLLocationManager!
    var annotationPoint: MKPointAnnotation!
    var buttonSize: CGFloat = 0.0
    var selectedPin:MKPlacemark? = nil
    
    var routeviewHeight: CGFloat!
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    var mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textAlignment = .center
        label.backgroundColor = .systemRed
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var floatingBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("+", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 5, right: 0)
        button.addTarget(self, action: #selector(routehideView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var floatingZoomBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "searching..."
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timeLabel: UILabel = {
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
        
        if (self.formController == "MileIQ") {
            let backbutton = UIButton(type: .custom)
            backbutton.setTitle("Back", for: .normal)
            backbutton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
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
        
        self.extendedLayoutIncludesOpaqueBars = true
        floatButton()
        setupNavigationButtons()
        addActivityIndicator()
        setupForm()
        setupConstraints()
        if !(self.formController == "MileIQ") {
          checkLocationServices()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if (self.formController == "MileIQ") {
            self.addressLabel.isHidden = true
            getPlaceDirections()
        } else {
            self.addressLabel.isHidden = false
            setupLocationManager()
        }
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(MapView.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
        
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func backAction() -> Void {
        self.dismiss(animated: true)
    }
    
    private func setupNavigationButtons() {
        
        self.navigationItem.largeTitleDisplayMode = .always
        let actionBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        navigationItem.rightBarButtonItems = [actionBtn]
        navigationItem.title = "Map"
    }
    
    func setupMap() {
        
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isRotateEnabled = true
        //self.mapViewshowsPointsOfInterest = true
        self.mapView.showsCompass = true
        self.mapView.showsScale = true
        
        if !(self.formController == "MileIQ") {
            self.mapView.userTrackingMode = .followWithHeading
        }
    }
    
    func setupForm() {
        
        self.routView.isHidden = true
        self.routView.backgroundColor = Color.DGrayColor
        self.travelTime.textColor = .white
        self.travelDistance.textColor = .white
        self.stepView.textColor = .systemRed
        
        self.stepView.font = cellsteps
        self.stepView.isSelectable = false
        self.allSteps = ""
        self.travelTime.text = ""
        self.travelDistance.text = ""
        self.travelTime.font = celllabel1
        self.travelDistance.font = celllabel1
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
    
    // MARK: - SegmentedControl
    @IBAction func mapTypeChanged(_ sender: AnyObject) {
        
        if(mapTypeSegmentedControl.selectedSegmentIndex == 0) {
            self.mapView.mapType = .standard
        }
        else if(mapTypeSegmentedControl.selectedSegmentIndex == 1) {
            self.mapView.mapType = .hybridFlyover
        }
        else if(mapTypeSegmentedControl.selectedSegmentIndex == 2) {
            self.mapView.mapType = .satellite
        }
    }
    
    // MARK: - Button
    @objc func routehideView(_ sender: AnyObject) {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            routeviewHeight = 350
        } else {
            routeviewHeight = 220
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        if self.routView.isHidden == false {
            self.addressLabel.isHidden = false
            self.routView.isHidden = true
            //mapView.frame = .init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.bottomAnchor.constraint(equalTo: routView.bottomAnchor, constant: 0).isActive = true
            
        } else {
            self.addressLabel.isHidden = true
            self.routView.isHidden = false
            routView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 0).isActive = true
            //routView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.bottomAnchor.constraint(equalTo: routView.bottomAnchor, constant: -routeviewHeight).isActive = true
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //locationManager.requestAlwaysAuthorization()
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            startTackingUserLocation()
            break
        @unknown default: break
            //<#fatalError#>()
        }
    }
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
        getDirections()
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            //let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //====================================================================
    private func getPlaceDirections() {
        
        mapView.removeAnnotations(mapView.annotations)
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = startCoordinates!
        pointAnnotation.title = "Start"
        
        let pointAnnotation1 = MKPointAnnotation()
        pointAnnotation1.coordinate = endCoordinates!
        pointAnnotation1.title = "End"
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(pointAnnotation)
            self.mapView.addAnnotation(pointAnnotation1)
        }
        
        // MARK:  Directions
        let request = self.createDirectionsRequest(from: startCoordinates!, destination: endCoordinates!)
        let directions = MKDirections(request: request)
        self.resetMapView(withNew: directions)
        
        directions.calculate { (response, _) in
            
            guard let response = response else { return }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }

            self.showRoute(response)
            self.hideActivityIndicator()
        }
    }
    
    private func getDirections() {
        var dest: String?
        var pointdest: String?
        
        if (self.formController == "CustMap") {
            dest = String(format: "%@ %@ %@ %@", self.mapaddress!, self.mapcity!, self.mapstate!, self.mapzip!)
            pointdest = String(format: "%@ %@ %@", self.mapcity!, self.mapstate!, self.mapzip!)
        } else {
            dest = ""
            pointdest = ""
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(dest!) { (placemarks, error) in
            
            guard placemarks != nil else {
                return
            }
            
            let placemark = placemarks![0]
            self.locationManager.stopUpdatingLocation()
            
            guard let location = self.locationManager.location?.coordinate else {
                //TODO: Inform user we don't have their current location
                return
            }
            
            guard let destination = placemark.location?.coordinate else {
                //TODO: Inform user we don't have their current location
                return
            }
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = placemark.location!.coordinate
            pointAnnotation.title = self.mapaddress as String?
            pointAnnotation.subtitle = pointdest
            
            DispatchQueue.main.async {
                self.mapView.addAnnotation(pointAnnotation)
            }
            
            // MARK:  Directions
            let request = self.createDirectionsRequest(from: location, destination: destination)
            let directions = MKDirections(request: request)
            self.resetMapView(withNew: directions)
            
            directions.calculate { [unowned self] (response, error) in
                //TODO: Show response not available in an alert
                guard let response = response else { return }
                
                for route in response.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
                
                self.showRoute(response)
                self.hideActivityIndicator()
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> MKDirections.Request {
        //let destinationCoordinate       = getCenterLocation(for: mapView).coordinate
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destination)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .automobile
        if (self.formController == "MileIQ") {
            request.requestsAlternateRoutes = true
        } else {
            request.requestsAlternateRoutes = true
        }
        self.selectedPin = destination
        
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }

//====================================================================
    
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
        
        view.addSubview(mapView)
        view.addSubview(addressLabel)
        self.view.addSubview(timeLabel)
        self.view.addSubview(distanceLabel)
        view.addSubview(floatingBtn)
        view.addSubview(floatingZoomBtn)
        view.addSubview(routView)
        floatingBtn.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            addressLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            addressLabel.heightAnchor.constraint(equalToConstant: 50),
            
            timeLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 15),
            timeLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            timeLabel.heightAnchor.constraint(equalToConstant: 25),
            
            distanceLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),
            distanceLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            distanceLabel.heightAnchor.constraint(equalToConstant: 25),
            
            floatingBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            floatingBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -50),
            floatingBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingBtn.heightAnchor.constraint(equalToConstant: buttonSize),
            
            floatingZoomBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            floatingZoomBtn.bottomAnchor.constraint(equalTo: floatingBtn.topAnchor, constant: -25),
            floatingZoomBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingZoomBtn.heightAnchor.constraint(equalToConstant: buttonSize),
            
            routView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            routView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
            //routView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            //routView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        self.mapView.zoomToUserLocation()
    }
    
    // MARK: - ActivityIndicator
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.4)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    // MARK: - Routes
    func showRoute(_ response: MKDirections.Response) {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        
        let temp: MKRoute = response.routes.first! as MKRoute
        self.route = temp
        self.travelTime.text = String(format:"Time: %0.1f min drive", route.expectedTravelTime/60) as String
        self.travelDistance.text = String(format:"Distance: %0.1f miles", route.distance/1609.344) as String
        self.timeLabel.text = String(format:"Time: %0.1f min", route.expectedTravelTime/60) as String
        self.distanceLabel.text = String(format:"Distance: %0.1f miles", route.distance/1609.344) as String
        
        for i in 0 ..< self.route.steps.count {
            
            let step:MKRoute.Step = self.route.steps[i] as MKRoute.Step
            let newStep = (step.instructions)
            let distStep = String(format:"%0.2f miles", step.distance/1609.344)
            self.allSteps = self.allSteps!.appending( "\(i+1). ") as String?
            self.allSteps = self.allSteps!.appending(newStep) as String?
            self.allSteps = self.allSteps!.appending("\n") as String?
            self.allSteps = self.allSteps!.appending(distStep) as String?
            self.allSteps = self.allSteps!.appending("\n\n") as String?
            self.stepView.text = self.allSteps
        }
        
        let speechUtterance = AVSpeechUtterance(string: self.travelTime.text!)
        speechSynthesizer.speak(speechUtterance)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) //device vibrate
    }
    
    // MARK: - Map Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        /*
        if (annotation is MKUserLocation) { //added blue circle userlocation
        return nil
        } */
        
        let identifier = "pin"
        var pinView: MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinView.canShowCallout = true
        pinView.isDraggable = false
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(systemName: "car.fill"), for: [])
        button.addTarget(self, action: #selector(MapView.getAppleMaps), for: .touchUpInside)
        pinView.leftCalloutAccessoryView = button
        
        if annotation.title == "Start" {
            pinView.pinTintColor = .systemGreen
        } else {
            pinView.pinTintColor = .systemRed
        }
        
        return pinView
    }
    
    //Launches driving directions with AppleMaps
    @objc func getAppleMaps() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func trafficBtnTapped(_ sender: AnyObject) {
        
        if mapView.showsTraffic == mapView.showsTraffic {
            mapView.showsTraffic = !mapView.showsTraffic
            //sender.setTitle("Hide Traffic", for: .normal)
        } else {
            mapView.showsTraffic = mapView.showsTraffic
            //sender.setTitle("Show Traffic", for: .normal)
        }
    }
    
    func scaleBtnTapped() {
        
        if mapView.showsScale == mapView.showsScale {
            mapView.showsScale = !mapView.showsScale
        } else {
            mapView.showsScale = !mapView.showsScale
        }
    }
    
    func compassBtnTapped() {
        
        if mapView.showsCompass == mapView.showsCompass {
            mapView.showsCompass = !mapView.showsCompass
        } else {
            mapView.showsCompass = mapView.showsCompass
        }
    }
    
    func buildingBtnTapped() {
        
        if mapView.showsBuildings == mapView.showsBuildings {
            mapView.showsBuildings = !mapView.showsBuildings
        } else {
            mapView.showsBuildings = mapView.showsBuildings
        }
    }
    
    func userlocationBtnTapped() {
        
        if mapView.showsUserLocation == mapView.showsUserLocation {
            mapView.showsUserLocation = !mapView.showsUserLocation
        } else {
            mapView.showsUserLocation = mapView.showsUserLocation
        }
    }
    
    func pointsofinterestBtnTapped() {
        /*
        if mapView.showsPointsOfInterest == mapView.showsPointsOfInterest {
            mapView.showsPointsOfInterest = !mapView.showsPointsOfInterest
        } else {
            mapView.showsPointsOfInterest = mapView.showsPointsOfInterest
        } */
    }
    
    func displayInFlyoverMode() {
        
        if mapView.mapType == .satelliteFlyover {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .satelliteFlyover
            mapView.showsBuildings = true
            let location = CLLocationCoordinate2D(latitude: 51.50722, longitude: -0.12750)
            let altitude: CLLocationDistance  = 500
            let heading: CLLocationDirection = 90
            let pitch = CGFloat(45)
            let camera = MKMapCamera(lookingAtCenter: location, fromDistance: altitude, pitch: pitch, heading: heading)
            mapView.setCamera(camera, animated: true)
        }
    }
    
    @objc func shareButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title:"", message:"", preferredStyle: .actionSheet)
        
        let buttonOne = UIAlertAction(title: "Show Traffic", style: .default, handler: { (action) in
            self.trafficBtnTapped(self)
        })
        let buttonTwo = UIAlertAction(title: "Show Scale", style: .default, handler: { (action) in
            self.scaleBtnTapped()
        })
        let buttonThree = UIAlertAction(title: "Show Compass", style: .default, handler: { (action) in
            self.compassBtnTapped()
        })
        let buttonFour = UIAlertAction(title: "Show Buildings", style: .default, handler: { (action) in
            self.buildingBtnTapped()
        })
        let buttonFive = UIAlertAction(title: "Show User Location", style: .default, handler: { (action) in
            self.userlocationBtnTapped()
        })
        let buttonSix = UIAlertAction(title: "Show Points of Interest", style: .default, handler: { (action) in
            self.pointsofinterestBtnTapped()
        })
        let buttonSeven = UIAlertAction(title: "Alternate Routes", style: .default, handler: { (action) in
            //self.requestsAlternateRoutesBtnTapped()
        })
        let buttonEight = UIAlertAction(title: "Show Flyover", style: .default, handler: { (action) in
            self.displayInFlyoverMode()
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alertController.addAction(buttonOne)
        alertController.addAction(buttonTwo)
        alertController.addAction(buttonThree)
        alertController.addAction(buttonFour)
        alertController.addAction(buttonFive)
        alertController.addAction(buttonSix)
        alertController.addAction(buttonSeven)
        alertController.addAction(buttonEight)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true)
    }
}
@available(iOS 13.0, *)
extension MapView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
@available(iOS 13.0, *)
extension MapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("ENTERED")
        stepCounter += 1
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            let message = "In \(currentStep.distance) meters, \(currentStep.instructions)"
            self.addressLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
        } else {
            let message = "Arrived at destination"
            self.addressLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
            stepCounter = 0
            locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
            
        }
    }

    // MARK: - Map Overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            if mapView.overlays.count == 1 {
                renderer.strokeColor = Color.BlueColor.withAlphaComponent(0.5)
            }
            else if (mapView.overlays.count == 2) {
                renderer.strokeColor = UIColor.green.withAlphaComponent(0.5)
            }
            else if (mapView.overlays.count == 3) {
                renderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
            }

            renderer.lineWidth = 3
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .systemRed
            renderer.fillColor = .systemRed
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
