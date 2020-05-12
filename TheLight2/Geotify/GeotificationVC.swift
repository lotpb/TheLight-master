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
import FirebaseDatabase
import FirebaseAuth
//import UserNotifications

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

@available(iOS 13.0, *)
final class GeotificationVC: UIViewController, UISplitViewControllerDelegate, RegionsProtocol {

     // MARK: - Card Setup
    enum CardState {
        case expanded
        case collapsed
    }

    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView!

    let cardHeight:CGFloat = 780//600
    let cardHandleAreaHeight:CGFloat = 130 //65

    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }

    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
 //--------------------------------------------------------------------------------
    //@IBOutlet weak var mapView: MKMapView!
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    private var buttonSize: CGFloat = 0.0
    private var goBtnSize: CGFloat = 0.0
    var geotifications: [Geotification] = []
    let locationManager = CLLocationManager()
    var circle:MKCircle! //setup GetRegion

    //firebase
    var users: UserModel?
    
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

    lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Geotify: 0", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(UIColor.label, for: .normal)
        //button.addTarget(self, action: #selector(), for: .touchUpInside)
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

    lazy var goBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("GO", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.8).cgColor
        button.layer.borderWidth = 2.0
        button.addTarget(self, action: #selector(maptype), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var floatingBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.setTitle("+", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 6, right: 0)
        button.layer.borderColor = UIColor.secondarySystemGroupedBackground.cgColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(maptype), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var floatingZoomBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.tintColor = .systemBlue
        button.layer.borderColor = UIColor.secondarySystemGroupedBackground.cgColor
        button.layer.borderWidth = 1.0
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var floatingSearchBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.tintColor = .label
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
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
            buttonSize = 60
            goBtnSize = 80
        } else {
            buttonSize = 50
            goBtnSize = 80
        }
        floatingBtn.titleLabel?.font = UIFont(name: floatingBtn.titleLabel!.font.familyName , size: buttonSize)
        goBtn.titleLabel?.font = UIFont(name: goBtn.titleLabel!.font.familyName , size: 32)

        let btnLayer: CALayer = floatingBtn.layer
        btnLayer.cornerRadius = buttonSize / 2
        btnLayer.masksToBounds = true
        
        let btnLayer1: CALayer = floatingZoomBtn.layer
        btnLayer1.cornerRadius = buttonSize / 2
        btnLayer1.masksToBounds = true

        let btnLayer2: CALayer = goBtn.layer
        btnLayer2.cornerRadius = goBtnSize / 2
        btnLayer2.masksToBounds = true

        let btnLayer3: CALayer = userImageview.layer
        btnLayer3.cornerRadius = buttonSize / 2
        btnLayer3.masksToBounds = true

        let btnLayer4: CALayer = floatingSearchBtn.layer
        btnLayer4.cornerRadius = buttonSize / 2
        btnLayer4.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //UIToolbar.appearance().barTintColor = .red
        self.extendedLayoutIncludesOpaqueBars = true
        UIApplication.shared.isIdleTimerDisabled = true //added
        //fixed - remove bottom bar
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.activityType = .automotiveNavigation
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.allowsBackgroundLocationUpdates = true //added
            locationManager.pausesLocationUpdatesAutomatically = false
        }
        //journal
        let annotations = LocationsStorage.shared.locations.map { annotationForLocation($0) }
        mapView.addAnnotations(annotations)
        NotificationCenter.default.addObserver(self, selector: #selector(newLocationAdded(_:)), name: .newLocationSaved, object: nil)

        setupNavigation()
        setupUserImage()
        floatButton()
        setupConstraints() //below floatbutton
        loadAllGeotifications()
        setupCard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false

        //UIToolbar.appearance().barTintColor = .red //Color.toolbarColor
        
        locationManager.requestAlwaysAuthorization()
        // Setup GetAddress
        locationManager.startUpdatingLocation()

        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(GeotificationVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

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

    func setupMap() {

        self.mapView.delegate = self //added
        self.mapView.userTrackingMode = .follow //.followWithHeading //added
        self.mapView.alpha = 0.8
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isRotateEnabled = true
        //self.mapViewshowsPointsOfInterest = true
        //self.mapView.showsCompass = true
        self.mapView.showsScale = true
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
    
    func setupConstraints() {

        self.view.addSubview(mapView)
        self.view.addSubview(titleBtn)
        self.view.addSubview(userImageview)
        self.view.addSubview(altitudeLabel)
        self.view.addSubview(speedLabel)
        self.view.addSubview(coarseLabel)
        self.view.addSubview(floatingBtn)
        self.view.addSubview(floatingZoomBtn)
        self.view.addSubview(floatingSearchBtn)
        self.view.addSubview(goBtn)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([

            mapView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -40),

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
            floatingBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -60),
            floatingBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingBtn.heightAnchor.constraint(equalToConstant: buttonSize),
            
            floatingZoomBtn.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -15),
            floatingZoomBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -60),
            floatingZoomBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingZoomBtn.heightAnchor.constraint(equalToConstant: buttonSize),

            altitudeLabel.topAnchor.constraint(equalTo: floatingSearchBtn.bottomAnchor, constant: 15),
            altitudeLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            altitudeLabel.heightAnchor.constraint(equalToConstant: 25),

            speedLabel.topAnchor.constraint(equalTo: altitudeLabel.bottomAnchor, constant: 5),
            speedLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            speedLabel.heightAnchor.constraint(equalToConstant: 25),

            coarseLabel.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 5),
            coarseLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            coarseLabel.heightAnchor.constraint(equalToConstant: 25),

            goBtn.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            goBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -60),
            goBtn.widthAnchor.constraint(equalToConstant: 80),
            goBtn.heightAnchor.constraint(equalToConstant: 80)
            ])
    }
    
    @objc func maptype() {
        
        if self.mapView.mapType == MKMapType.standard {
            self.mapView.mapType = MKMapType.hybridFlyover
        } else {
            self.mapView.mapType = MKMapType.standard
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

        // MARK: - Card Setup
        func setupCard() {
            visualEffectView = UIVisualEffectView()
            visualEffectView.frame = self.view.frame
            self.view.addSubview(visualEffectView)

            cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
            self.addChild(cardViewController)
            self.view.addSubview(cardViewController.view)

            cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)

            cardViewController.view.clipsToBounds = true

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GeotificationVC.handleCardTap(recognzier:)))
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GeotificationVC.handleCardPan(recognizer:)))

            cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
            cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        }

        @objc
        func handleCardTap(recognzier:UITapGestureRecognizer) {
            switch recognzier.state {
            case .ended:
                animateTransitionIfNeeded(state: nextState, duration: 0.9)
            default:
                break
            }
        }

        @objc
        func handleCardPan (recognizer:UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                startInteractiveTransition(state: nextState, duration: 0.9)
            case .changed:
                let translation = recognizer.translation(in: self.cardViewController.handleArea)
                var fractionComplete = translation.y / cardHeight
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
            case .ended:
                continueInteractiveTransition()
            default:
                break
            }
        }

        func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
            if runningAnimations.isEmpty {
                let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.mapView.isHidden = true
                        self.cardViewController.titleLabel.text = "Trip Planner"
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                        self.altitudeLabel.isHidden = true
                        self.speedLabel.isHidden = true
                        self.coarseLabel.isHidden = true
                        self.floatingBtn.isHidden = true
                        self.floatingZoomBtn.isHidden = true
                        self.goBtn.isHidden = true
                        self.titleBtn.isHidden = true
                    case .collapsed:
                        self.mapView.isHidden = false
                        self.cardViewController.titleLabel.text = "You're offline"
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - 75 //- self.cardHandleAreaHeight
                        self.altitudeLabel.isHidden = false
                        self.speedLabel.isHidden = false
                        self.coarseLabel.isHidden = false
                        self.floatingBtn.isHidden = false
                        self.floatingZoomBtn.isHidden = false
                        self.goBtn.isHidden = false
                        self.titleBtn.isHidden = false
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
                        self.cardViewController.view.layer.cornerRadius = 12
                    case .collapsed:
                        self.cardViewController.view.layer.cornerRadius = 0
                    }
                }

                cornerRadiusAnimator.startAnimation()
                runningAnimations.append(cornerRadiusAnimator)

                let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    case .collapsed:
                        self.visualEffectView.effect = nil
                    }
                }

                blurAnimator.startAnimation()
                runningAnimations.append(blurAnimator)
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
            navigationItem.title = "Geotify"
        }
        //limit the number of geotifications user can set, disables the Add button in the navigation bar whenever the app reaches the limit.
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
        self.titleBtn.setTitle("Geotify: \(geotifications.count)", for: .normal)
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        let overlays = mapView.overlays
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView.removeOverlay(circleOverlay)
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
@available(iOS 13.0, *)
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
@available(iOS 13.0, *)
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
@available(iOS 13.0, *)
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
            renderer.lineWidth = 0.5
            renderer.strokeColor = .systemOrange
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

