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
 

class UserViewVC: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainView: UIView!
    
    var defaults = UserDefaults.standard
    
    var formController: String?
    var isFormStat = false
    var selectedImage: UIImage?
    private let cellId = "Cell"

    //parse
    var _feedItems = NSMutableArray()
    var filteredString = NSMutableArray()
    var user: PFUser?
    
    //firebase
    var userlist = [UserModel]()

    var objects = [AnyObject]()
    var pasteBoard = UIPasteboard.general
    
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
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Cust.navColor
        refreshControl.tintColor = .white
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        setupNavigation()
        setupTableView()
        loadData()
        
        self.scrollView!.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .allVisible
            }
        }
        setMainNavItems()
        setupMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Users"
        } else {
            navigationItem.title = "Users"
        }
        self.navigationItem.largeTitleDisplayMode = .always
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        navigationItem.rightBarButtonItems = [addButton, searchButton]
    }
    
    func setupMap() {
        
        mapView!.delegate = self
        mapView!.layer.borderColor = UIColor.lightGray.cgColor
        mapView!.layer.borderWidth = 0.5
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
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
        self.tableView.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableView.automaticDimension
        if #available(iOS 13.0, *) {
            self.tableView!.backgroundColor = .systemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        self.collectionView.register(UserViewCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        if #available(iOS 13.0, *) {
            self.collectionView!.backgroundColor = .systemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Refresh
    @objc func refreshData(_ sender:AnyObject) {
        userlist.removeAll()
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - RefreshMap
    func retrieveMapPins() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
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
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
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
        
        if (defaults.bool(forKey: "parsedataKey")) {
            return self._feedItems.count
        } else {
            return self.userlist.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserViewCell
        
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .label
        } else {
            // Fallback on earlier versions
        }
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
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
        
        self.formController = "CollectionView"
        isFormStat = false
        
        if (defaults.bool(forKey: "parsedataKey")) {
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            
            imageFile!.getDataInBackground { imageData, error in
                self.selectedImage = UIImage(data: imageData!)
            }
        } else {
            //firebase
            let userImageUrl = userlist[indexPath.item].profileImageUrl
            self.userImageview.loadImage(urlString: userImageUrl)
            self.selectedImage = self.userImageview.image
        }
        //fix
        let layout = UICollectionViewFlowLayout()
        let controller = UserProfileVC(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: controller)
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        //self.show(navController, sender: true)
        self.present(navController, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let updated: Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        if segue.identifier == "userdetailSegue" {
            guard let VC = segue.destination as? UserDetailController else { return }
            
            if self.formController == "TableView" {
                if (isFormStat == true) {
                    VC.status = "New"
                } else {
                    VC.status = "Edit"
                    let indexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        updated = ((self._feedItems[indexPath] as AnyObject).value(forKey: "createdAt") as? Date)!
                        VC.objectId = (self._feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
                        VC.username = (self._feedItems[indexPath] as AnyObject).value(forKey: "username") as? String
                        VC.email = (self._feedItems[indexPath] as AnyObject).value(forKey: "email") as? String
                        VC.phone = (self._feedItems[indexPath] as AnyObject).value(forKey: "phone") as? String
                        VC.userimage = self.selectedImage
                    } else {
                        //firebase
                        updated = userlist[indexPath].creationDate
                        VC.username = userlist[indexPath].username
                        VC.email = userlist[indexPath].email
                        VC.phone = userlist[indexPath].phone
                        VC.userimage = self.selectedImage
                    }
                    
                    let createString = dateFormatter.string(from: updated!)
                    VC.create = createString
                }
                
            } else if self.formController == "CollectionView" {
                
                if (isFormStat == true) {
                    VC.status = "New"
                } else {
                    VC.status = "Edit"
                    let indexPaths = self.collectionView!.indexPathsForSelectedItems!
                    let indexPath = indexPaths[0] as IndexPath
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        updated = ((self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "createdAt") as? Date)!
                        VC.objectId = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "objectId") as? String
                        VC.username = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "username") as? String
                        VC.email = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "email") as? String
                        VC.phone = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "phone") as? String
                        VC.userimage = self.selectedImage
                    } else {
                        //firebase
                        updated = userlist[indexPath.row].creationDate
                        VC.username = userlist[indexPath.row].username
                        VC.email = userlist[indexPath.row].email
                        VC.phone = userlist[indexPath.row].phone
                        VC.userimage = self.selectedImage
                    }
                    
                    let createString = dateFormatter.string(from: updated!)
                    VC.create = createString
                }
            }
        }
    }
}
 extension UserViewVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.formController = "TableView"
        isFormStat = false
        
        if (defaults.bool(forKey: "parsedataKey")) {
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
        self.performSegue(withIdentifier: "userdetailSegue", sender: self.tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            return self._feedItems.count
        } else {
            return self.userlist.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        
        cell.selectionStyle = .none
        
        if #available(iOS 13.0, *) {
            cell.usertitleLabel!.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        
        cell.usersubtitleLabel!.textColor = .systemGray
        cell.customImagelabel.backgroundColor = .clear //fix
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.usertitleLabel!.font = Font.celltitle20r
            cell.usersubtitleLabel!.font = Font.celltitle16r
        } else {
            cell.usertitleLabel!.font = Font.celltitle16r
            cell.usersubtitleLabel!.font = Font.celltitle12r
        }
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
            cell.customImageView.frame = .init(x: 0, y: 0, width: 0, height: 0) //fix
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.userImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.userImageView.image = UIImage(data: imageData!)
                }, completion: nil)
            }
            
            let dateUpdated = (_feedItems[indexPath.row] as AnyObject).value(forKey: "createdAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "EEE, MMM d, h:mm a"
            
            cell.usertitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "username") as? String
            cell.usersubtitleLabel!.text = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
        } else {
            //firebase
            cell.userpost = userlist[indexPath.item]
        }
        return cell
    }
 }
 extension UserViewVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        if #available(iOS 13.0, *) {
            vw.backgroundColor = .systemGray6
        } else {
            // Fallback on earlier versions
        }
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: .init(x: 10, y: 5, width: tableView.frame.width-10, height: 20))
        myLabel1.numberOfLines = 1
        myLabel1.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            myLabel1.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        myLabel1.font = Font.celltitle18m
        vw.addSubview(myLabel1)
        
        if (defaults.bool(forKey: "parsedataKey")) {
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
