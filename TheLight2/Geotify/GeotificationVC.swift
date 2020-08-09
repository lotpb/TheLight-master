//
//  GeotificationsViewController.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
//import CoreLocation
//import UserNotifications

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

protocol RegionsProtocol{
    func loadOverlayForRegionWithLatitude(_ latitude:Double, andLongitude longitude:Double)
}

@available(iOS 13.0, *)
final class GeotificationVC: UIViewController, UISplitViewControllerDelegate, UIGestureRecognizerDelegate, RegionsProtocol {

    // MARK: - Card Setup
    enum CardState {
        case expanded
        case collapsed
    }

    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }

    private var cardViewController: CardViewController!
    private var visualEffectView: UIVisualEffectView!

    private var endCardHeight:CGFloat = 0 //700
    private var startCardHeight:CGFloat = 0

    private var cardVisible = false
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted:CGFloat = 0
    //--------------------------------------------------------------------------------

    private var delegate:RegionsProtocol!
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    private var buttonSize: CGFloat = 0.0
    private var goBtnSize: CGFloat = 0.0
    private var geotifications: [Geotification] = []
    private let locationManager = CLLocationManager()
    private var circle:MKCircle! //setup GetRegion
    //firebase
    private var users: UserModel?
    //Get Address
    private var thoroughfare: String?
    private var subThoroughfare: String?
    private var locality: String?
    private var sublocality: String?
    private var postalCode: String?
    private var administrativeArea: String?
    private var subAdministrativeArea: String?
    private var country: String?
    private var ISOcountryCode: String?
    private var geoTitle: String?
    private var geoSubtitle: String?

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    private let titleBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Geotify: 0", for: .normal)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(UIColor.label, for: .normal)
        button.addTarget(self, action: #selector(addGeotifation), for: .touchUpInside)
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

    private let goBtn: UIButton = {
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
    
    private let floatingBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.tintColor = .black
        //button.setTitle("+", for: .normal)
        //button.setTitleColor(.black, for: .normal)
        //button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 6, right: 0)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.addTarget(self, action: #selector(maptype), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let floatingZoomBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.tintColor = .black
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let floatingSearchBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.tintColor = .black
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.addTarget(self, action: #selector(handleOpen), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
//    static let numberFormatter: NumberFormatter =  { //speed label
//        let mf = NumberFormatter()
//        mf.minimumFractionDigits = 0
//        mf.maximumFractionDigits = 0
//        return mf
//    }()
    
    private let speedLabel: UILabel = {
        let label = UILabel()
        label.text = "---"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let altitudeLabel: UILabel = {
        let label = UILabel()
        label.text = "searching..."
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coarseLabel: UILabel = {
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
        } else {
            buttonSize = 50
        }
        goBtnSize = 80

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

        self.extendedLayoutIncludesOpaqueBars = true
        UIApplication.shared.isIdleTimerDisabled = true //added
        // FIXME: - remove bottom bar
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.activityType = .automotiveNavigation
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.allowsBackgroundLocationUpdates = true //added
            locationManager.pausesLocationUpdatesAutomatically = false

            locationManager.distanceFilter = 1.0
            locationManager.headingFilter = 0.1
        }
        //journal
        let annotations = LocationsStorage.shared.locations.map { annotationForLocation($0) }
        mapView.addAnnotations(annotations)
        NotificationCenter.default.addObserver(self, selector: #selector(newLocationAdded(_:)), name: .newLocationSaved, object: nil)

        setupContraints()
        setupNavigation()
        setupUserImage()
        floatButton()
        setupCard()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Setup GetAddress
        locationManager.startUpdatingLocation()

        loadAllGeotifications()
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.navigationItem.largeTitleDisplayMode = .always
            navigationItem.title = "TheLight Software - Geotify: \(geotifications.count)"
        } else {
            self.navigationItem.largeTitleDisplayMode = .never
            navigationItem.title = "Geotify"
        }

        let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        let addBtn = UIBarButtonItem(title: "📌", style: .plain, target: self, action: #selector(addItemBtn))
        navigationItem.rightBarButtonItems = [shareBtn, addBtn]
    }

    private func setupMap() {

        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        centerViewOnUser()
        self.mapView.userTrackingMode = .follow //.followWithHeading
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.showsCompass = false
        self.mapView.showsScale = false
        //self.mapView.alpha = 0.8
        let filter = MKPointOfInterestFilter(including: [.gasStation, .cafe, .police, .bank])
        mapView.pointOfInterestFilter = filter
    }

    @objc func maptype() {

        if self.mapView.mapType == MKMapType.standard {
            self.mapView.mapType = MKMapType.satellite
        } else {
            self.mapView.mapType = MKMapType.standard
        }
    }

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
    
    override func viewDidLayoutSubviews() { // FIXME: CardViewController dont work
        super.viewDidLayoutSubviews()

        mapView.addSubview(titleBtn)
        mapView.addSubview(userImageview)
        mapView.addSubview(altitudeLabel)
        mapView.addSubview(speedLabel)
        mapView.addSubview(coarseLabel)
        mapView.addSubview(floatingBtn)
        mapView.addSubview(floatingZoomBtn)
        mapView.addSubview(floatingSearchBtn)
        mapView.addSubview(goBtn)
        
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
            floatingBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingBtn.heightAnchor.constraint(equalToConstant: buttonSize),
            
            floatingZoomBtn.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -15),
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
            goBtn.widthAnchor.constraint(equalToConstant: 80),
            goBtn.heightAnchor.constraint(equalToConstant: 80)
        ])

        if UIDevice.current.userInterfaceIdiom == .pad  {
            NSLayoutConstraint.activate([
                floatingZoomBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -95),
                floatingBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -95),
                goBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -95),
            ])
        } else {
            NSLayoutConstraint.activate([
                floatingZoomBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -65),
                floatingBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -65),
                goBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -65),
            ])
        }
    }
    
    // MARK: - Get Address

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

    // MARK: - Side Menu

    @objc private func handleTapDismiss() {
        handleHide()
    }

    let menuController = GeoMenuController()
    fileprivate let menuWidth: CGFloat = 300.0

    @objc func handleOpen() {

        menuController.view.frame = .init(x: -300, y: 55, width: 300, height: view.frame.height)
        let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        windows?.addSubview(menuController.view)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuController.view.transform = CGAffineTransform(translationX: 300, y: 0)
        }, completion: nil)
        addChild(menuController)
    }

    @objc func handleHide() {

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuController.view.transform = .identity
        }, completion: nil)
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {

        } else if gesture.state == .ended {
            handleHide()
        }
    }

    // MARK: - Card Setup

    private func setupCard() {

        endCardHeight = self.view.frame.height * 0.9 - 20
        startCardHeight = self.view.frame.height * 0.1 + 44

        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame

        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)

        cardViewController.view.frame = CGRect(x: 0, y: view.frame.height - startCardHeight, width: view.bounds.width, height: endCardHeight)

        cardViewController.view.clipsToBounds = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GeotificationVC.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GeotificationVC.handleCardPan(recognizer:)))

        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
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
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
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

                    self.cardViewController.titleLabel.text = "Trip Planner"
                    self.cardViewController.chevronBtn.setImage(UIImage(systemName: "chevron.compact.down", withConfiguration: configuration), for: .normal)

                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.endCardHeight + 0
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    self.mapView.addSubview(self.visualEffectView)

                case .collapsed:

                    self.visualEffectView.removeFromSuperview()
                    self.cardViewController.chevronBtn.setImage(UIImage(systemName: "chevron.compact.up", withConfiguration: configuration), for: .normal)
                    self.cardViewController.titleLabel.text = "You're offline"
                    
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.startCardHeight + 55
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
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
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
    // MARK: - AddGeotification

    private func loadAllGeotifications() {
        geotifications.removeAll()
        let allGeotifications = Geotification.allGeotifications()
        allGeotifications.forEach { add(geotification: $0) }
    }
    
    private func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifications)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }

    private func add(geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    private func remove(geotification: Geotification) {
        guard let index = geotifications.firstIndex(of: geotification) else { return }
        geotifications.remove(at: index)
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    private func updateGeotificationsCount() {

        //limit the number of geotifications user can set, disables the Add button in the navigation bar whenever the app reaches the limit.
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
        self.titleBtn.setTitle("Geotify: \(geotifications.count)", for: .normal)
    }
    
    // MARK: - Map overlay
    private func addRadiusOverlay(forGeotification geotification: Geotification) {
        mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    private func removeRadiusOverlay(forGeotification geotification: Geotification) {
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

    private func region(with geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    private func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(title:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
            showAlert(title:"Warning", message: message)
        }
        
        let fenceRegion = region(with: geotification)
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    private func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }

    private func centerViewOnUser() {
        guard let location = locationManager.location?.coordinate else {return}

        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

        let coordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: - Regions

    public func loadOverlayForRegionWithLatitude(_ latitude: Double, andLongitude longitude: Double) {
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        circle = MKCircle(center: coordinates, radius: 200000)
        //self.mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        self.mapView.addOverlay(circle)
    }

    @objc func addGeotifation() {
        self.performSegue(withIdentifier: "addGeotification", sender: self)
    }

    func openRegion() {
        self.performSegue(withIdentifier: "getregionSegue", sender: self)
    }

    func openAddress() {
        self.performSegue(withIdentifier: "getaddressSegue", sender: self)
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

    // MARK: - Journal

    @objc func addItemBtn(_ sender: Any) {
        guard let currentLocation = mapView.userLocation.location else {
            return
        }
        LocationsStorage.shared.saveCLLocationToDisk(currentLocation)
    }
    
    private func annotationForLocation(_ location: Location) -> MKAnnotation {
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

    // MARK: - UIAlertController

    @objc func shareButton(_ sender: AnyObject) {

        let alert = UIAlertController(title:"", message:"Menu", preferredStyle: .actionSheet)

        let buttonOne = UIAlertAction(title: "Show Traffic", style: .default, handler: { (action) in
            //self.trafficBtnTapped(self)
        })
        let buttonTwo = UIAlertAction(title: "Show Scale", style: .default, handler: { (action) in
            //self.scaleBtnTapped()
        })
        let buttonThree = UIAlertAction(title: "Show Compass", style: .default, handler: { (action) in
            //self.compassBtnTapped()
        })
        let buttonFour = UIAlertAction(title: "Show Buildings", style: .default, handler: { (action) in
            //self.buildingBtnTapped()
        })
        let buttonFive = UIAlertAction(title: "Show User Location", style: .default, handler: { (action) in
            //self.userlocationBtnTapped()
        })
        let buttonSix = UIAlertAction(title: "Show Points of Interest", style: .default, handler: { (action) in
            //self.pointsofinterestBtnTapped()
        })
        let buttonSeven = UIAlertAction(title: "Alternate Routes", style: .default, handler: { (action) in
            //self.requestsAlternateRoutesBtnTapped()
        })
        let buttonEight = UIAlertAction(title: "Show Call Out", style: .default, handler: { (action) in
            //self.displayInFlyoverMode()
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

}

//---------------------------------------------------------------------
// MARK: - AddGeotification
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // MARK: - getAddress
        AppDelegate.geoCoder.reverseGeocodeLocation(manager.location!) { [weak self] (placemarks, error)->Void in
            guard let self = self else { return }
            if (error != nil) {
                self.showAlert(title: "Alert", message: "Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
            } else {
                self.showAlert(title: "Alert", message: "Problem with the data received from geocoder")
            }
        }

        // MARK: - Map Info
        if let location = locations.last { //locations.first
            altitudeLabel.text = String(format: "Alt: %.2f", location.altitude)
            speedLabel.text = String(format: "Speed: %.0f", manager.location!.speed)
            coarseLabel.text = String(format: "Course: %.0f", location.course) //"\(location.course)˚"
        }
    }
}

// MARK: - MapView Delegate
@available(iOS 13.0, *)
extension GeotificationVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        if annotation is Geotification {
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.image = #imageLiteral(resourceName: "AddPin")
                pinView?.animatesDrop = true
                pinView?.pinTintColor = .systemBlue
                pinView?.canShowCallout = true
                pinView?.isSelected = false
                //pinView?.isMultipleTouchEnabled = false
                pinView?.isDraggable = true

                let removeButton = UIButton(type: .custom)
                removeButton.frame = .init(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(systemName: "x.circle"), for: .normal) //x.circle
                pinView?.leftCalloutAccessoryView = removeButton

            } else {
                pinView?.annotation = annotation
            }
            return pinView
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
        } else if overlay is MKPolygon{
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }

        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        // MARK: - Delete Geotification
        let geotification = view.annotation as! Geotification
        stopMonitoring(geotification: geotification)
        remove(geotification: geotification)
        saveAllGeotifications()
    }
}

