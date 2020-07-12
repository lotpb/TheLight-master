 //
//  UserViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/17/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation
import GeoFire
 

@available(iOS 13.0, *)
final class UserViewVC: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainView: UIView!
    
    private var defaults = UserDefaults.standard
    
    private var formController: String?
    private var isFormStat = false
    private var selectedImage: UIImage?
    private let cellId = "Cell"

    //parse
    private var _feedItems = NSMutableArray()
    private var filteredString = NSMutableArray()
    private var user: PFUser?
    
    //firebase
    private var userlist = [UserModel]()

    private var objects = [AnyObject]()
    private var pasteBoard = UIPasteboard.general

    
    let userImageview: CustomImageView = { //firebase
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill // .scaleAspectFill //.scaleAspectFit
        imageView.layer.cornerRadius = (imageView.frame.size.width) / 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = ColorX.Cust.navColor
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        setupNavigation()
        setupTableView()
        loadData()
        view.backgroundColor = .systemGroupedBackground
        scrollView!.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .allVisible
            }
        } */
        setMainNavItems()
        setupMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupNavigation() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Current Users"
        } else {
            navigationItem.title = "Current Users"
        }
        navigationItem.largeTitleDisplayMode = .always
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        navigationItem.rightBarButtonItems = [addButton, searchButton]
    }
    
    func setupMap() {
        
        mapView!.delegate = self
        mapView!.layer.borderColor = UIColor.lightGray.cgColor
        mapView!.layer.borderWidth = 0.5
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            PFGeoPoint.geoPointForCurrentLocation {(geoPoint: PFGeoPoint?, error: Error?) in
                let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.40, longitudeDelta: 0.40)
                let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(geoPoint!.latitude, geoPoint!.longitude)
                let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
                self.mapView!.setRegion(region, animated: true)
            }
            
        } else {
            //firebase
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let geofireRef = FirebaseRef.databaseRoot.child("users_locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            
            geoFire.getLocationForKey(uid, withCallback: { (location, error) in
                
                let center = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                
                let circleQuery = geoFire.query(at: center, withRadius: 50)
                circleQuery.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
                    
                    print("Key '\(key!)' entered the search are and is at location '\(location!)'")
                    
                    let distanceFromUser = center.distance(from: location!)
                    print("distance", distanceFromUser)
                    
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
                    
                    let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.40, longitudeDelta: 0.40)
                    let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
                    self.mapView!.setRegion(region, animated: true)
                    
                    //for (key,_) in KeyValue {
                    let annotation = MKPointAnnotation()
                    annotation.title = String(distanceFromUser) //object["username"] as? String
                    annotation.coordinate = location
                    self.mapView!.addAnnotation(annotation)
                    //}
                })
            }) 
        }
        self.mapView!.showsUserLocation = true //added
        self.retrieveMapPins()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView!.dataSource = self
        tableView!.estimatedRowHeight = 110
        tableView!.rowHeight = UITableView.automaticDimension
        tableView!.backgroundColor = .systemGroupedBackground
        tableView!.tableFooterView = UIView(frame: .zero)
        
        collectionView.register(UserViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - Refresh
    @objc func refreshData(_ sender:AnyObject) {
        userlist.removeAll()
        loadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - RefreshMap
    func retrieveMapPins() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let geoPoint = PFGeoPoint(latitude: self.mapView!.centerCoordinate.latitude, longitude:self.mapView!.centerCoordinate.longitude)
            
            let query = PFUser.query()
            query?.whereKey("currentLocation", nearGeoPoint: geoPoint, withinMiles:50.0)
            query?.limit = 20
            query?.findObjectsInBackground { (objects:[PFObject]?, error:Error?) in
                for object in objects! {
                    let annotation = MKPointAnnotation()
                    annotation.title = object["username"] as? String
                    let geoPoint = object["currentLocation"] as! PFGeoPoint
                    annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                    self.mapView!.addAnnotation(annotation)
                }
            }
        } else {
            //firebase
        }
    }
    
    // MARK: - LoadData
    func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFUser.query()
            query!.order(byDescending: "createdAt")
            query!.cachePolicy = .cacheThenNetwork
            query!.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        self.collectionView!.reloadData()
                    })
                } else {
                    print("Error")
                }
            }
        } else {
            //firebase
            let ref = FirebaseRef.databaseRoot.child("users")
            ref.observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let post = UserModel(dictionary: dictionary)
                self.userlist.append(post)
                
                self.userlist.sort(by: { (u1, u2) -> Bool in
                    return u1.username.compare(u2.username) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    self.tableView.reloadData()
                })
            }) { (err) in
                print("Failed to fetch users for search:", err)
            }
        }

    }
    
    // MARK: - Button
    @objc func newData() {
        isFormStat = true
        self.performSegue(withIdentifier: "userdetailSegue", sender: self)
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 130
        return .init(width: width, height: width)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            return self._feedItems.count
        } else {
            return self.userlist.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserViewCell

        cell.backgroundColor = .label
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            cell.usertitleLabel.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "username") as? String
            
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            
            cell.loadingSpinner.isHidden = true
            cell.loadingSpinner.startAnimating()
            
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.customImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.customImageView.image = UIImage(data: imageData!)
                }, completion: nil)
                
                cell.loadingSpinner.stopAnimating()
                cell.loadingSpinner.isHidden = true
            }
        } else {
            //firebase
            cell.user = userlist[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name:"Me", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "MeProfileID") as! MeProfileVC
        VC.isFormMe = false

        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            VC.objectId = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
            VC.username = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "username") as? String
        } else {
            VC.objectId = self.userlist[indexPath.row].uid
            VC.username = self.userlist[indexPath.row].username

            let navController = UINavigationController(rootViewController: VC)
            self.present(navController, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let create: Date?
        let updated: Date?

        MasterViewController.dateFormatter.dateFormat = "MMM dd, yyyy"

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        if segue.identifier == "userdetailSegue" {
            guard let VC = segue.destination as? UserDetailController else { return }
            
            if self.formController == "TableView" {
                if (isFormStat == true) {
                    VC.status = "New"
                } else {
                    VC.status = "Edit"
                    let indexPath = (tableView!.indexPathForSelectedRow! as NSIndexPath).row
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        create = ((self._feedItems[indexPath] as AnyObject).value(forKey: "createdAt") as? Date)!
                        updated = ((self._feedItems[indexPath] as AnyObject).value(forKey: "createdAt") as? Date)!
                        VC.objectId = (self._feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
                        VC.username = (self._feedItems[indexPath] as AnyObject).value(forKey: "username") as? String
                        VC.email = (self._feedItems[indexPath] as AnyObject).value(forKey: "email") as? String
                        VC.phone = (self._feedItems[indexPath] as AnyObject).value(forKey: "phone") as? String
                        VC.userimage = self.selectedImage
                    } else {
                        //firebase
                        create = userlist[indexPath].creationDate
                        updated = userlist[indexPath].lastUpdate
                        VC.objectId = userlist[indexPath].uid
                        VC.username = userlist[indexPath].username
                        VC.email = userlist[indexPath].email
                        VC.phone = userlist[indexPath].phone
                        VC.userimage = self.selectedImage
                    }
                    let createString = MasterViewController.dateFormatter.string(from: create!)
                    VC.create = createString
                    let updatedString = MasterViewController.dateFormatter.string(from: updated!)
                    VC.update = updatedString
                }
            } else if self.formController == "CollectionView" {

            }
        }
    }

}
 @available(iOS 13.0, *)
 extension UserViewVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.formController = "TableView"
        isFormStat = false
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile!.getDataInBackground { imageData, error in
                self.selectedImage = UIImage(data: imageData!)
            }
        } else {
            //firebase
            let newsImageUrl = userlist[indexPath.item].profileImageUrl
            self.userImageview.loadImage(urlString: newsImageUrl)
            self.selectedImage = self.userImageview.image
        }
        self.performSegue(withIdentifier: "userdetailSegue", sender: tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            return self._feedItems.count
        } else {
            return self.userlist.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        
        cell.selectionStyle = .none
        cell.usertitleLabel!.textColor = .label
        
        cell.usersubtitleLabel!.textColor = .systemGray
        cell.customImagelabel.backgroundColor = .clear // FIXME: shouldn't crash
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.usertitleLabel!.font = Font.celltitle20r
            cell.usersubtitleLabel!.font = Font.celltitle16r
        } else {
            cell.usertitleLabel!.font = Font.celltitle16r
            cell.usersubtitleLabel!.font = Font.celltitle12r
        }
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            cell.customImageView.frame = .init(x: 0, y: 0, width: 0, height: 0) //fix
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.userImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.userImageView.image = UIImage(data: imageData!)
                }, completion: nil)
            }
            
            let dateUpdated = (_feedItems[indexPath.row] as AnyObject).value(forKey: "createdAt") as! Date

            MasterViewController.dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
            
            cell.usertitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "username") as? String
            cell.usersubtitleLabel!.text = String(format: "%@", MasterViewController.dateFormatter.string(from: dateUpdated)) as String
            
        } else {
            //firebase
            cell.userpost = userlist[indexPath.item]
        }
        return cell
    }
 }
 @available(iOS 13.0, *)
 extension UserViewVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = .systemGray6
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: .init(x: 10, y: 5, width: tableView.frame.width-10, height: 20))
        myLabel1.numberOfLines = 1
        myLabel1.backgroundColor = .clear
        myLabel1.textColor = .label
        myLabel1.font = Font.celltitle18m
        vw.addSubview(myLabel1)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            myLabel1.text = String(format: "%@%d", "Users ", _feedItems.count)
        } else {
            //firebase
            myLabel1.text = String(format: "%@%d", "Users ", userlist.count)
        }
        
        return vw
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.refreshData(self)
            
        } else if editingStyle == .insert {
            
        }
    }
    
    // MARK: - Content Menu
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    // MARK: - Segues
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
 }
