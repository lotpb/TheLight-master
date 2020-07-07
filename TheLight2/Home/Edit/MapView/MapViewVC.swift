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
import FirebaseDatabase
import FirebaseAuth


@available(iOS 13.0, *)
final class MapViewVC: UIViewController {

    // MARK: - Card Setup
    enum CardState {
        case expanded
        case collapsed
    }

    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }

    public var formController : String?
    //placesFeedCell
    public var startCoordinates: CLLocationCoordinate2D?
    public var endCoordinates: CLLocationCoordinate2D?

    public var mapaddress : NSString?
    public var mapcity : NSString?
    public var mapstate : NSString?
    public var mapzip : NSString?

    private var cardMapController: CardMapController!
    private var visualEffectView: UIVisualEffectView!

    private var endCardHeight:CGFloat = 0 //700
    private var startCardHeight:CGFloat = 0

    private var cardVisible = false
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted:CGFloat = 0
    //--------------------------------------------------------------------------------
    
    private let locationManager = CLLocationManager()
    private let regionInMeters: Double = 10000
    private var previousLocation: CLLocation?
    private let geoCoder = CLGeocoder()
    private var directionsArray: [MKDirections] = []

    private var destStr: String?
    private var startPoint: String?
    private var startStr: String?

    private var stepCounter = 0
    private var steps = [MKRoute.Step]()
    private var route: MKRoute!
    private var allSteps : String?
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    private let celllabel1 = UIFont.systemFont(ofSize: 18, weight: .medium)
    private let cellsteps = UIFont.systemFont(ofSize: 18, weight: .light)
    //var locationManager: CLLocationManager!
    private var annotationPoint: MKPointAnnotation!
    private var buttonSize: CGFloat = 0.0
    private var selectedPin:MKPlacemark? = nil
    
    private var routeviewHeight: CGFloat!
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    private let titleBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Distance", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = .black
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(UIColor.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let userImageview: CustomImageView = { //firebase
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill // .scaleAspectFill //.scaleAspectFit
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
        return imageView
    }()

    private let floatingSearchBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.tintColor = .black
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let floatingBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 6, right: 0)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(maptype), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let floatingZoomBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.tintColor = .black
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    private func floatButton() {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            buttonSize = 60
        } else {
            buttonSize = 50
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

        let btnLayer3: CALayer = userImageview.layer
        btnLayer3.cornerRadius = buttonSize / 2
        btnLayer3.masksToBounds = true

        let btnLayer4: CALayer = floatingSearchBtn.layer
        btnLayer4.cornerRadius = buttonSize / 2
        btnLayer4.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true

        setupContraints()
        floatButton()
        setupNavigationButtons()
        setupUserImage()
        addActivityIndicator()

        if !(self.formController == "MileIQ") {
            checkLocationServices()
        }
        setupCard()
        setupForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if (self.formController == "MileIQ") {
            getPlaceDirections()
        } else {
            setupLocationManager()
        }
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

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
    
    private func setupMap() {
        
        mapView.delegate = self
        if !(formController == "MileIQ") {
            mapView.userTrackingMode = .follow //.followWithHeading
        }
        mapView.alpha = 0.8
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.showsCompass = true
        mapView.showsScale = true
        //self.visualEffectView.removeFromSuperview() // FIXME: shouldn't crash
    }
    
    private func setupForm() {
        self.allSteps = ""
        cardMapController.directionTextView.font = cellsteps
    }

    @objc func maptype() {

        if mapView.mapType == MKMapType.standard {
            mapView.mapType = MKMapType.hybridFlyover
        } else {
            mapView.mapType = MKMapType.standard
        }
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        if UIDevice.current.userInterfaceIdiom == .phone  {
            let state = notification.object as! Bool
            navigationController?.setNavigationBarHidden(state, animated: true)
            UIView.animate(withDuration: 0.2, animations: {
                self.tabBarController?.hideTabBarAnimated(hide: state) //added
            }, completion: nil)
        }
    }
    
    // MARK: - SegmentedControl
    //    @IBAction func mapTypeChanged(_ sender: AnyObject) {
    //
    //        if(mapTypeSegmentedControl.selectedSegmentIndex == 0) {
    //            self.mapView.mapType = .standard
    //        }
    //        else if(mapTypeSegmentedControl.selectedSegmentIndex == 1) {
    //            self.mapView.mapType = .hybridFlyover
    //        }
    //        else if(mapTypeSegmentedControl.selectedSegmentIndex == 2) {
    //            self.mapView.mapType = .satellite
    //        }
    //    }

    private func setupUserImage() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        FirebaseRef.databaseRoot.child("users")
            .queryOrdered(byChild: "uid")
            .queryEqual(toValue: uid)
            .observeSingleEvent(of: .value, with:{ (snapshot) in
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    let userDict = userSnap.value as! [String: Any]
                    let blogImageUrl = userDict["profileImageUrl"] as? String
                    self.userImageview.loadImage(urlString: blogImageUrl!)
                }
            })
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //locationManager.requestAlwaysAuthorization()
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    private func checkLocationAuthorization() {
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
    
    private func startTackingUserLocation() {

        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
        getDirections()
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            //let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
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

        if (formController == "CustMap") {
            destStr = String(format: "%@ %@ %@ %@", self.mapaddress!, self.mapcity!, self.mapstate!, self.mapzip!)
            startPoint = String(format: "%@ %@ %@", self.mapcity!, self.mapstate!, self.mapzip!)
        } else {
            destStr = ""
            startPoint = ""
        }
        
        geoCoder.geocodeAddressString(destStr!) { (placemarks, error) in
            
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
            pointAnnotation.subtitle = self.startPoint
            
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
                    mapView.addOverlay(route.polyline)
                    mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
                
                self.showRoute(response)
                self.hideActivityIndicator()
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> MKDirections.Request {
        //let destinationCoordinate       = getCenterLocation(for: mapView).coordinate
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destination)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .automobile

        if (formController == "MileIQ") {
            request.requestsAlternateRoutes = true
        } else {
            request.requestsAlternateRoutes = true
        }
        selectedPin = destination
        
        return request
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }

    //====================================================================
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        lastContentOffset = scrollView.contentOffset.y;
    }

    func setupContraints() { // FIXME: Map Buttons

        view.addSubview(mapView)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    
    override func viewDidLayoutSubviews() { // CardViewController dont work
        super.viewDidLayoutSubviews()

        mapView.addSubview(titleBtn)
        mapView.addSubview(userImageview)
        mapView.addSubview(floatingBtn)
        mapView.addSubview(floatingZoomBtn)
        mapView.addSubview(floatingSearchBtn)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([

            titleBtn.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
            titleBtn.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            titleBtn.widthAnchor.constraint(equalToConstant: 120),
            titleBtn.heightAnchor.constraint(equalToConstant: 50),

            userImageview.topAnchor.constraint(equalTo: guide.topAnchor,  constant: 20),
            userImageview.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -15),
            userImageview.widthAnchor.constraint(equalToConstant: buttonSize),
            userImageview.heightAnchor.constraint(equalToConstant: buttonSize),

            floatingSearchBtn.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
            floatingSearchBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15),
            floatingSearchBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingSearchBtn.heightAnchor.constraint(equalToConstant: buttonSize),

            floatingBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15),
            floatingBtn.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -95),
            floatingBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingBtn.heightAnchor.constraint(equalToConstant: buttonSize),
            
            floatingZoomBtn.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -15),
            floatingZoomBtn.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -95),
            floatingZoomBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingZoomBtn.heightAnchor.constraint(equalToConstant: buttonSize),
        ])
    }
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
    // MARK: - ActivityIndicator
    private func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.4)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    // MARK: - Routes
    private func showRoute(_ response: MKDirections.Response) {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }

        let temp: MKRoute = response.routes.first! as MKRoute
        route = temp
        titleBtn.setTitle(String(format:"%0.1f miles", route.distance/1609.344) as String, for: .normal)
        cardMapController.timeLabel.text = String(format:"Time: %0.1f min", route.expectedTravelTime/60) as String
        cardMapController.distanceLabel.text = String(format:"Distance: %0.1f miles", route.distance/1609.344) as String

        self.allSteps = ""
        for i in 0 ..< self.route.steps.count {
            
            let step:MKRoute.Step = self.route.steps[i] as MKRoute.Step
            let newStep = (step.instructions)
            let distStep = String(format:"%0.2f miles", step.distance/1609.344)
            self.allSteps = self.allSteps!.appending( "\(i+1). ") as String?
            self.allSteps = self.allSteps!.appending(newStep) as String?
            self.allSteps = self.allSteps!.appending("\n") as String?
            self.allSteps = self.allSteps!.appending(distStep) as String?
            self.allSteps = self.allSteps!.appending("\n\n") as String?
        }
        cardMapController.directionTextView.text = self.allSteps

        let speechUtterance = AVSpeechUtterance(string: String(format:"Time: %0.1f min", route.expectedTravelTime/60) as String)
        speechSynthesizer.speak(speechUtterance)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) //device vibrate
    }
    
    // MARK: - Map Annotation
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "pin"
        var pinView: MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinView.canShowCallout = true
        pinView.isDraggable = false
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(systemName: "car.fill"), for: [])
        button.addTarget(self, action: #selector(MapViewVC.getAppleMaps), for: .touchUpInside)
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
    
    private func trafficBtnTapped(_ sender: AnyObject) {
        
        if mapView.showsTraffic == mapView.showsTraffic {
            mapView.showsTraffic = !mapView.showsTraffic
            //sender.setTitle("Hide Traffic", for: .normal)
        } else {
            mapView.showsTraffic = mapView.showsTraffic
            //sender.setTitle("Show Traffic", for: .normal)
        }
    }
    
    private func scaleBtnTapped() {
        
        if mapView.showsScale == mapView.showsScale {
            mapView.showsScale = !mapView.showsScale
        } else {
            mapView.showsScale = !mapView.showsScale
        }
    }
    
    private func compassBtnTapped() {
        
        if mapView.showsCompass == mapView.showsCompass {
            mapView.showsCompass = !mapView.showsCompass
        } else {
            mapView.showsCompass = mapView.showsCompass
        }
    }
    
    private func buildingBtnTapped() {
        
        if mapView.showsBuildings == mapView.showsBuildings {
            mapView.showsBuildings = !mapView.showsBuildings
        } else {
            mapView.showsBuildings = mapView.showsBuildings
        }
    }
    
    private func userlocationBtnTapped() {
        
        if mapView.showsUserLocation == mapView.showsUserLocation {
            mapView.showsUserLocation = !mapView.showsUserLocation
        } else {
            mapView.showsUserLocation = mapView.showsUserLocation
        }
    }
    
    private func pointsofinterestBtnTapped() {

        let filter = MKPointOfInterestFilter(including: [.gasStation, .cafe, .police, .bank])
        mapView.pointOfInterestFilter = filter
    }
    
    private func displayInFlyoverMode() {
        
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
        
        let alert = UIAlertController(title:"", message:"", preferredStyle: .actionSheet)
        
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
        
        alert.addAction(buttonOne)
        alert.addAction(buttonTwo)
        alert.addAction(buttonThree)
        alert.addAction(buttonFour)
        alert.addAction(buttonFive)
        alert.addAction(buttonSix)
        alert.addAction(buttonSeven)
        alert.addAction(buttonEight)
        alert.addAction(buttonCancel)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alert, animated: true)
    }

    // MARK: - Card Setup
    private func setupCard() {

        endCardHeight = view.frame.height * 0.9 - 20
        startCardHeight = view.frame.height * 0.1 + 44

        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = view.frame

        cardMapController = CardMapController(nibName:"CardMapVC", bundle:nil)
        self.addChild(cardMapController)
        view.addSubview(cardMapController.view)

        cardMapController.view.frame = CGRect(x: 0, y: view.frame.height - startCardHeight, width: view.bounds.width, height: endCardHeight)

        cardMapController.view.clipsToBounds = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewVC.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MapViewVC.handleCardPan(recognizer:)))

        cardMapController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardMapController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }

    @objc func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.cardMapController.handleArea)
            var fractionComplete = translation.y / endCardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }

    private func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {

        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)

        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:

                    self.cardMapController.titleLabel.text = "Trip Planner"
                    self.cardMapController.chevronBtn.setImage(UIImage(systemName: "chevron.compact.down", withConfiguration: configuration), for: .normal)
                    self.cardMapController.startLabel.text = String(format: "%@ %@","Start:", self.startStr!)
                    self.cardMapController.destLabel.text = String(format: "%@ %@","Dest:", self.destStr!)

                    self.cardMapController.view.frame.origin.y = self.view.frame.height - self.endCardHeight + 55
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    self.mapView.addSubview(self.visualEffectView)

                case .collapsed:

                    self.visualEffectView.removeFromSuperview()
                    self.cardMapController.titleLabel.text = self.startStr
                    self.cardMapController.chevronBtn.setImage(UIImage(systemName: "chevron.compact.up", withConfiguration: configuration), for: .normal)
                    self.cardMapController.view.frame.origin.y = self.view.frame.height - self.startCardHeight + 55
                    self.visualEffectView.effect = nil
                }
            }

            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }

            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)

            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardMapController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardMapController.view.layer.cornerRadius = 0
                }
            }

            cornerRadiusAnimator.startAnimation()

            runningAnimations.append(cornerRadiusAnimator)
        }
    }

    private func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }

    private func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    private func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    //--------------------------------------------------------------------------------
}
@available(iOS 13.0, *)
extension MapViewVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
@available(iOS 13.0, *)
extension MapViewVC: MKMapViewDelegate {
    
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
            let cityName = placemark.locality ?? ""
            
            DispatchQueue.main.async { [self] in
                self.startStr = "\(streetNumber) \(streetName) \(cityName)"
                self.cardMapController.titleLabel.text = self.startStr
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("ENTERED")
        stepCounter += 1
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            let message = "In \(currentStep.distance) meters, \(currentStep.instructions)"
            self.cardMapController.titleLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
        } else {
            let message = "Arrived at destination"
            self.cardMapController.titleLabel.text = message
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
                renderer.strokeColor = ColorX.BlueColor.withAlphaComponent(0.5)
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
