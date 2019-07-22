//
//  PlaceCell.swift
//  TheLight2
//
//  Created by Peter Balsamo on 3/26/19.
//  Copyright © 2019 Peter Balsamo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class PlaceCell: UICollectionViewCell {
    
    let geoCoder = CLGeocoder()
    var destLocation: CLLocation? // for distance calculation
    var startLocation: CLLocation? // for distance calculation
    var distance = 0.0
    var selectedPin:MKPlacemark? = nil
    var directionsArray: [MKDirections] = []
    var route: MKRoute!
    let defaults = UserDefaults.standard
    var startCoordinates = CLLocationCoordinate2D()
    var endCoordinates = CLLocationCoordinate2D()
    
    var streetNumber: String?
    var streetName: String?
    var cityName: String?
    
    var mapStart: Location? {
        didSet {
            
            let s = mapStart!.description
            let firstWord = s.components(separatedBy: ",")
            titleLabelnew.text = firstWord[2].removingWhitespaces()
            
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .medium
            let date1 = dateFormatter.date(from: (mapStart?.dateString)!)
            let calendar = Calendar.current
            let time = calendar.dateComponents([.month,.weekday,.day,.hour,.minute,.second], from: date1!)
            //cell header
            dayLabel.text = dateFormatter.shortWeekdaySymbols![time.weekday!-1]
            dayTextLabel.text = "\(time.day!)"
            
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            titleTimeLabel.text = dateFormatter.string(from: date1!)
            
            //mapView
            mapViewStart.removeAnnotations(mapViewStart.annotations)
            startCoordinates = CLLocationCoordinate2D(latitude: mapStart!.latitude, longitude: mapStart!.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let region = MKCoordinateRegion(center: startCoordinates, span: span)
            mapViewStart.setRegion(region, animated: true)
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = mapStart!.coordinates
            pointAnnotation.title = "Start" //location.dateString
            
            DispatchQueue.main.async {
                self.mapViewStart.addAnnotation(pointAnnotation)
            }
            startLocation = getCenterLocation(for: mapViewStart)
        }
    }
    
    var mapDest: Location? {
        didSet {
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .medium
            let date2 = dateFormatter.date(from: (mapDest?.dateString)!)
            
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            subtitleTimeLabel.text = dateFormatter.string(from: date2!)
            
            mapViewDest.removeAnnotations(mapViewStart.annotations)
            endCoordinates = CLLocationCoordinate2D(latitude: mapDest!.latitude, longitude: mapDest!.longitude)
            let span1 = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let region1 = MKCoordinateRegion(center: endCoordinates, span: span1)
            mapViewDest.setRegion(region1, animated: true)
            
            let pointAnnotation1 = MKPointAnnotation()
            pointAnnotation1.coordinate = endCoordinates
            pointAnnotation1.title = "End"
            
            DispatchQueue.main.async {
                self.mapViewDest.addAnnotation(pointAnnotation1)
            }
            destLocation = getCenterLocation(for: mapViewDest)
            getDirections()
        }
    }
    
    private func getDirections() {
        // MARK:  Directions
        let request = self.createDirectionsRequest(from: startCoordinates, destination: endCoordinates)
        let directions = MKDirections(request: request)
        self.resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            //TODO: Show response not available in an alert
            guard let response = response else { return }
            self.showRoute(response)
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
        request.requestsAlternateRoutes = true
        self.selectedPin = startingLocation //getAppleMaps()
        
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapViewStart.removeOverlays(mapViewStart.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    func showRoute(_ response: MKDirections.Response) {
        let mile = (defaults.object(forKey: "mileIQKey") as? String)!
        let temp: MKRoute = response.routes.first! as MKRoute
        self.route = temp
        self.costLabel.text = String(format:"$%0.2f",(route.distance/1609.344) * Double(mile)!) as String
        self.mileLabel.text = String(format:"%0.1f",route.distance/1609.344) as String
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = self.mapViewDest.centerCoordinate.latitude
        let longitude = self.mapViewDest.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    lazy var mapViewView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        //view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)     //Color.LGrayColor.cgColor
        //view.layer.borderWidth = 1.5
        //view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var mapViewStart: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var mapViewDest: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.tintColor = .white
        toolBar.barTintColor = .red //Color.Mile.toolbarColor
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()
    
    let mileLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0.0"
        label.textAlignment = .left
        return label
    }()
    
    var miletextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "MILES"
        label.textAlignment = .left
        return label
    }()
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.text = "Sat"
        label.numberOfLines = 1
        label.backgroundColor = .red
        label.textColor = .white
        label.textAlignment = .center
        label.layer.borderColor = Color.Mile.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dayTextLabel: UILabel = {
        let label = UILabel()
        label.text = "8"
        label.numberOfLines = 1
        label.backgroundColor = .white
        label.textAlignment = .center
        label.textColor = .black
        label.layer.borderColor = Color.Mile.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let costLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "$0.00"
        label.textAlignment = .right
        //label.textColor = .systemBlue
        return label
    }()
    
    let costTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "POTENTAL"
        label.textAlignment = .right
        //label.textColor = .systemBlue
        return label
    }()
    
    lazy var titleView: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGray6
            view.layer.borderColor = UIColor.systemGray6.cgColor
        } else {
            view.backgroundColor = .white
            view.layer.borderColor = Color.Mile.borderColor.cgColor
        }
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var subtitleView: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGray6
            view.layer.borderColor = UIColor.systemGray6.cgColor
        } else {
            view.backgroundColor = .white
            view.layer.borderColor = Color.Mile.borderColor.cgColor
        }
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabelnew: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleTimeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleTimeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .systemGreen
        button.setImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    let subtitleBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .red
        button.setImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    let likeBtn: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cloud30copy").withRenderingMode(.alwaysTemplate), for: .normal)
        //button.isUserInteractionEnabled = true
        //let tap = UITapGestureRecognizer(target: self, action: #selector(PlacesCollectionView.alertButton))
        //button.addGestureRecognizer(tap)
        return button
    }()
    
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        return formatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .init(width: 0, height: 2.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 10
        
        self.mapViewStart.delegate = self
        self.mapViewStart.isZoomEnabled = true //make map clickable
        self.mapViewStart.isScrollEnabled = false
        
        self.mapViewDest.delegate = self
        self.mapViewDest.isZoomEnabled = true //make map clickable
        self.mapViewDest.isScrollEnabled = false
        
        addSubview(mapViewView)
        addSubview(mileLabel)
        addSubview(miletextLabel)
        addSubview(dayLabel)
        addSubview(dayTextLabel)
        addSubview(costLabel)
        addSubview(costTextLabel)
        addSubview(titleView)
        addSubview(subtitleView)
        self.contentView.addSubview(toolBar)
        
        mapViewView.addSubview(mapViewStart)
        mapViewView.addSubview(mapViewDest)
        titleView.addSubview(titleBtn)
        titleView.addSubview(titleLabelnew)
        titleView.addSubview(titleTimeLabel)
        subtitleView.addSubview(subtitleBtn)
        subtitleView.addSubview(subtitleLabel)
        subtitleView.addSubview(subtitleTimeLabel)
        
        //if UI_USER_INTERFACE_IDIOM() == .pad {
            
        //} else {
            //header
            let height = ((self.frame.width) * 9 / 16) + 18
            let width = ((self.frame.width) / 2) - 25
            NSLayoutConstraint.activate([
                mileLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                mileLabel.leftAnchor.constraint(equalTo: mapViewDest.leftAnchor, constant: 0),
                mileLabel.widthAnchor.constraint(equalToConstant: 80),
                mileLabel.heightAnchor.constraint(equalToConstant: 20),
                
                miletextLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
                miletextLabel.leftAnchor.constraint(equalTo: mapViewDest.leftAnchor, constant: 0),
                miletextLabel.widthAnchor.constraint(equalToConstant: 50),
                miletextLabel.heightAnchor.constraint(equalToConstant: 20),
                
                dayLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                dayLabel.heightAnchor.constraint(equalToConstant: 20),
                dayLabel.widthAnchor.constraint(equalToConstant: 40),
                dayLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                
                dayTextLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 0),
                dayTextLabel.heightAnchor.constraint(equalToConstant: 20),
                dayTextLabel.widthAnchor.constraint(equalToConstant: 40),
                dayTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                
                costLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                costLabel.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: 0),
                costLabel.widthAnchor.constraint(equalToConstant: 80),
                costLabel.heightAnchor.constraint(equalToConstant: 20),
                
                costTextLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
                costTextLabel.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: 0),
                costTextLabel.widthAnchor.constraint(equalToConstant: 80),
                costTextLabel.heightAnchor.constraint(equalToConstant: 20),
                
                //collectionCell
                mapViewView.topAnchor.constraint(equalTo: self.topAnchor, constant: 58),
                mapViewView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
                mapViewView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
                mapViewView.heightAnchor.constraint(equalToConstant: height),
                
                //right map
                
                mapViewStart.topAnchor.constraint(equalTo: mapViewView.topAnchor, constant: 0),
                mapViewStart.trailingAnchor.constraint(equalTo: mapViewView.trailingAnchor, constant: 0),
                mapViewStart.bottomAnchor.constraint(equalTo: mapViewView.bottomAnchor, constant: 0),
                mapViewStart.widthAnchor.constraint(equalToConstant: width),
                
                //left map
                mapViewDest.topAnchor.constraint(equalTo: mapViewView.topAnchor, constant: 0),
                mapViewDest.leadingAnchor.constraint(equalTo: mapViewView.leadingAnchor, constant: 0),
                mapViewDest.bottomAnchor.constraint(equalTo: mapViewView.bottomAnchor, constant: 0),
                mapViewDest.rightAnchor.constraint(equalTo: mapViewStart.leftAnchor, constant: 0),
                //title
                titleView.topAnchor.constraint(equalTo: mapViewStart.bottomAnchor, constant: 15),
                titleView.leftAnchor.constraint(equalTo: mapViewDest.leftAnchor, constant: 0),
                titleView.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: 0),
                titleView.heightAnchor.constraint(equalToConstant: 30),
                
                titleBtn.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 7),
                titleBtn.leftAnchor.constraint(equalTo: mapViewDest.leftAnchor, constant: 5),
                titleBtn.widthAnchor.constraint(equalToConstant: 15),
                titleBtn.heightAnchor.constraint(equalToConstant: 15),
                
                titleLabelnew.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 1),
                titleLabelnew.leftAnchor.constraint(equalTo: titleBtn.rightAnchor, constant: 7),
                titleLabelnew.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: 0),
                titleLabelnew.heightAnchor.constraint(equalToConstant: 28),
                
                titleTimeLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 1),
                titleTimeLabel.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: -10),
                titleTimeLabel.heightAnchor.constraint(equalToConstant: 28),
                //subtitle
                subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 15),
                subtitleView.leftAnchor.constraint(equalTo: mapViewDest.leftAnchor, constant: 0),
                subtitleView.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: 0),
                subtitleView.heightAnchor.constraint(equalToConstant: 30),
                
                subtitleBtn.topAnchor.constraint(equalTo: subtitleView.topAnchor, constant: 7),
                subtitleBtn.leftAnchor.constraint(equalTo: mapViewDest.leftAnchor, constant: 5),
                subtitleBtn.widthAnchor.constraint(equalToConstant: 15),
                subtitleBtn.heightAnchor.constraint(equalToConstant: 15),
                
                subtitleLabel.topAnchor.constraint(equalTo: subtitleView.topAnchor, constant: 1),
                subtitleLabel.leftAnchor.constraint(equalTo: subtitleBtn.rightAnchor, constant: 7),
                subtitleLabel.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: 0),
                subtitleLabel.heightAnchor.constraint(equalToConstant: 28),
                
                subtitleTimeLabel.topAnchor.constraint(equalTo: subtitleView.topAnchor, constant: 1),
                subtitleTimeLabel.rightAnchor.constraint(equalTo: mapViewStart.rightAnchor, constant: -10),
                subtitleTimeLabel.heightAnchor.constraint(equalToConstant: 28)
                ])
            
            //toolBar
            var homeButton, infoButton, vehicleButton, doneButton, fixedSpace, flexibleSpace: UIBarButtonItem!
            homeButton = UIBarButtonItem(customView: likeBtn)
            infoButton = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: #selector(PlacesCollectionView.alertButton))
            vehicleButton = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: #selector(PlacesCollectionView.alertButton))
            doneButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: #selector(PlacesCollectionView.alertButton))
            fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
            fixedSpace.width = 15.0
            flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            toolBar.items = [homeButton, fixedSpace, infoButton, fixedSpace, vehicleButton, flexibleSpace, doneButton]
            
            NSLayoutConstraint.activate([
                toolBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                toolBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                toolBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
                toolBar.heightAnchor.constraint(equalToConstant: 50)
                ]) 
       // }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("Interface Builder is not supported!")
    }
}

extension PlaceCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "pin"
        var pinView: MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinView.canShowCallout = true
        pinView.isDraggable = false
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: .init(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: [])
        button.addTarget(self, action: #selector(PlaceCell.getAppleMaps), for: .touchUpInside)
        pinView.leftCalloutAccessoryView = button
        
        if annotation.title == "Start"  {
            pinView.pinTintColor = .systemGreen
        } else {
            pinView.pinTintColor = .red
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        guard let destLocation = self.destLocation else { return }
        
        guard center.distance(from: destLocation) > 50 else { return }
        self.destLocation = center
        
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {return}
            
            guard let placemark = placemarks?.first else {return}
            
            self.streetNumber = placemark.subThoroughfare ?? ""
            self.streetName = placemark.thoroughfare ?? ""
            self.cityName = placemark.locality ?? ""
            
            DispatchQueue.main.async {
                //self.subtitleLabel.text = "\(self.streetNumber ?? "") \(self.streetName ?? "") \(self.cityName ?? "")"
                self.subtitleLabel.text = "\(self.cityName ?? "")"
            }
        }
    }
    
    //Launches driving directions with AppleMaps //dont work
    @objc func getAppleMaps() {
        
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            mapItem.name = "Testing"
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}
