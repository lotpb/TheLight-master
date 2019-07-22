//
//  MainVC.swift
//  places
//
//  Created by Ashish Verma on 11/6/17.
//  Copyright © 2017 Ashish Verma. All rights reserved.
//

import UIKit
import MapKit

class MapsearchVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISplitViewControllerDelegate {
    
    //@IBOutlet weak var destinationSearchBarContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0 //added
    
    var selectedPin:MKPlacemark? = nil
    var mapHasCenteredOnce = false
    var resultSearchController: UISearchController? = nil
    let locationManager = CLLocationManager()
    var buttonSize: CGFloat = 0.0
    
    lazy var floatingBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("+", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(maptype), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var floatingZoomBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "CurrentLocation").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func floatButton() {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            buttonSize = 50
        } else {
            buttonSize = 50
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

        //fixed - remove bottom bar
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
        
        // Track user location
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        
        setupNavigation()
        setupSearch()
        
        floatButton()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        DispatchQueue.main.async {
            self.resultSearchController?.searchBar.becomeFirstResponder()
        } */
        
        self.tabBarController?.tabBar.isHidden = false
        locationAuthStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false

        /// MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(MapsearchVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
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
    
    func setupSearch() {

        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.hidesBackButton = true
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.searchBar.placeholder = "Search for places"
        resultSearchController?.searchBar.isUserInteractionEnabled = true
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = false
        resultSearchController?.searchBar.returnKeyType = UIReturnKeyType.done
        resultSearchController?.loadViewIfNeeded()
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func setupNavigation() {

        navigationController?.navigationBar.prefersLargeTitles = true
        let backItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(setbackButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        navigationItem.leftBarButtonItems = [backItem]
        navigationItem.title = "Places"
    }
    
    func setupConstraints() {

        view.addSubview(floatingBtn)
        view.addSubview(floatingZoomBtn)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            floatingBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            floatingBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -15),
            floatingBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingBtn.heightAnchor.constraint(equalToConstant: buttonSize),
            
            floatingZoomBtn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            floatingZoomBtn.bottomAnchor.constraint(equalTo: floatingBtn.topAnchor, constant: -15),
            floatingZoomBtn.widthAnchor.constraint(equalToConstant: buttonSize),
            floatingZoomBtn.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
    }
    
    // MARK: - Button
    @objc func setbackButton() {
        dismiss(animated: true)
    }
    
    @objc func maptype() { //floatbutton
        
        if self.mapView.mapType == MKMapType.standard {
            self.mapView.mapType = MKMapType.hybridFlyover
        } else {
            self.mapView.mapType = MKMapType.standard
        }
    }
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) { //floatbutton
        mapView.zoomToUserLocation()
    }
    
    //function called for Tap gesture
    @objc func handleSingleTap(gesture: UITapGestureRecognizer){
        view.endEditing(true)
    }

    //Request user Auth to use location services
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    //display user location(blue dot) in mapView
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    // Center mapView on userLocation
    func centerMapOnLocation(location : CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // checks mapHasCenteredOnce Flag
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    //Creates custom AnnotationView when Clicked on the pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = .systemOrange
        pinView?.canShowCallout = true
        pinView?.isDraggable = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: .init(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: [])
        button.addTarget(self, action: #selector(MapsearchVC.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
    
    //Launches driving directions with AppleMaps
    @objc func getDirections() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    /// MARK: - NavigationController Hidden
    
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
}
//Drops Cutsom Pin Annotation In the mapView
extension MapsearchVC: HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

}

