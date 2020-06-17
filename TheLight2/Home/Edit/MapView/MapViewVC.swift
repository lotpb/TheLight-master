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

    var cardMapController: CardMapController!
    var visualEffectView: UIVisualEffectView!

    var endCardHeight:CGFloat = 0 //700
    var startCardHeight:CGFloat = 0

    var cardVisible = false
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    //--------------------------------------------------------------------------------

    var formController : String?
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []

    var dest: String?
    var startPoint: String?

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
    
    lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleBtn: UIButton = {
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

    let userImageview: CustomImageView = { //firebase
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill // .scaleAspectFill //.scaleAspectFit
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
        return imageView
    }()

    lazy var floatingSearchBtn: UIButton = {
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
    
    lazy var floatingBtn: UIButton = {
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
    
    var floatingZoomBtn: UIButton = {
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

        floatButton()
        setupNavigationButtons()
        setupUserImage()
        addActivityIndicator()

        setupConstraints()
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
    
    func setupMap() {
        
        self.mapView.delegate = self
        if !(self.formController == "MileIQ") {
            self.mapView.userTrackingMode = .follow //.followWithHeading
        }
        self.mapView.alpha = 0.8
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.showsCompass = true
        self.mapView.showsScale = true

        //self.visualEffectView.removeFromSuperview() //fix
    }
    
    func setupForm() {
        self.allSteps = ""
        self.cardMapController.textView.font = cellsteps
    }

    @objc func maptype() {

        if self.mapView.mapType == MKMapType.standard {
            self.mapView.mapType = MKMapType.hybridFlyover
        } else {
            self.mapView.mapType = MKMapType.standard
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

    func setupUserImage() {
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

        if (self.formController == "CustMap") {
            dest = String(format: "%@ %@ %@ %@", self.mapaddress!, self.mapcity!, self.mapstate!, self.mapzip!)
            startPoint = String(format: "%@ %@ %@", self.mapcity!, self.mapstate!, self.mapzip!)
        } else {
            dest = ""
            startPoint = ""
        }
        
        geoCoder.geocodeAddressString(dest!) { (placemarks, error) in
            
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
        
        self.view.addSubview(mapView)
        mapView.addSubview(titleBtn)
        mapView.addSubview(userImageview)
        mapView.addSubview(floatingBtn)
        mapView.addSubview(floatingZoomBtn)
        mapView.addSubview(floatingSearchBtn)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([

            mapView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),

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
        self.titleBtn.setTitle(String(format:"%0.1f miles", route.distance/1609.344) as String, for: .normal)
        self.cardMapController.timeLabel.text = String(format:"Time: %0.1f min", route.expectedTravelTime/60) as String
        self.cardMapController.distanceLabel.text = String(format:"Distance: %0.1f miles", route.distance/1609.344) as String

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
        self.cardMapController.textView.text = self.allSteps

        let speechUtterance = AVSpeechUtterance(string: String(format:"Time: %0.1f min", route.expectedTravelTime/60) as String)
        speechSynthesizer.speak(speechUtterance)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) //device vibrate
    }
    
    // MARK: - Map Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
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

        let filter = MKPointOfInterestFilter(including: [.gasStation, .cafe, .police, .bank])
        mapView.pointOfInterestFilter = filter
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

    // MARK: - Card Setup
    func setupCard() {

        endCardHeight = self.view.frame.height * 0.9 - 20
        startCardHeight = self.view.frame.height * 0.1 + 44

        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame

        cardMapController = CardMapController(nibName:"CardMapVC", bundle:nil)
        self.addChild(cardMapController)
        self.view.addSubview(cardMapController.view)

        cardMapController.view.frame = CGRect(x: 0, y: self.view.frame.height - startCardHeight, width: self.view.bounds.width, height: endCardHeight)

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

    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {

        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)

        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:

                    self.cardMapController.chevronBtn.setImage(UIImage(systemName: "chevron.compact.down", withConfiguration: configuration), for: .normal)
                    self.cardMapController.startLabel.text = self.dest

                    self.cardMapController.view.frame.origin.y = self.view.frame.height - self.endCardHeight + 55
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    self.mapView.addSubview(self.visualEffectView)

                case .collapsed:

                    self.visualEffectView.removeFromSuperview()
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

    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }

    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    func continueInteractiveTransition (){
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
            
            DispatchQueue.main.async {
                self.cardMapController.titleLabel.text = "\(streetNumber) \(streetName) \(cityName)"
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
