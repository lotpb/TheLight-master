//
//  SnapshotController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/21/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Parse
import EventKit
import MobileCoreServices
import AVFoundation

@available(iOS 13.0, *)
class SnapshotVC: UIViewController, UISplitViewControllerDelegate {

    fileprivate var collapseDetailViewController = true
    @IBOutlet weak var tableView: UITableView!

    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0

    var defaults = UserDefaults.standard
    private let cellId = "cellId"
    //search
    private var menuItems = ["Snapshot","Statistics","Leads"]
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredMenu = [String]()
    
    //firebase
    var newslist = [NewsModel]()
    var joblist = [JobModel]()
    var userlist = [UserModel]()
    var saleslist = [SalesModel]()
    var employlist = [EmployModel]()
    
    var newsStr : String!
    var newsdateStr : Date!
    var newsdetailStr : String!
    var blogStr : String!
    var blogdateStr : Date!
    var blogpostStr : String!
    
    //parse
    var _feedNews = NSMutableArray() //news
    var _feedJob = NSMutableArray() //job
    var _feedUser = NSMutableArray() //user
    var _feedSales = NSMutableArray() //salesman
    var _feedItems5 = NSMutableArray() //employee
    var _feedItems6 = NSMutableArray() //blog
    var imageObject: PFObject!
    var imageFile: PFFileObject!
    
    var selectedImage : UIImage!

    var selectedObjectId : String!
    var selectedTitle : String!
    var selectedName : String!
    var selectedCreate : String!
    var selectedEmail : String!
    var selectedPhone : String!
    var selectedDate : Date!
    
    var selectedState : String!
    var selectedZip : String!
    var selectedAmount : String!
    var selectedComments : String!
    var selectedActive : String!

    var selected11 : String!
    var selected12 : String!
    var selected13 : String!
    var selected14 : String!
    var selected15 : NSString!
    var selected16 : String!
    var selected21 : NSString!
    var selected22 : String!
    var selected23 : String!
    var selected24 : String!
    var selected25 : String!
    var selected26 : NSString!
    var selected27 : String!
    
    var resultDateDiff : String!
    var imageDetailurl : String?
    
    var maintitle : UILabel!
    var datetitle : UILabel!
    var myLabel1 : UILabel!

    var calendar: EKCalendar!
    var events: [EKEvent]?

    weak var textYQL: NSArray!
    var tempYQL: String!
    var weathYQL: String!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - SplitView
        self.extendedLayoutIncludesOpaqueBars = true
        //fixed - remove bottom bar
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        loadData()
        setupTableView()
        setupNavigation()
        setupNewsNavigationItems()
        loadEvents()
        self.tableView.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(SnapshotVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .allVisible
            }
        }
        setupNewsNavigationItems()
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
    
    func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight Software - Snapshot"
        } else {
            navigationItem.title = "Snapshot"
        }
    }
    
    func setupTableView() {
        // MARK: - TableHeader
        self.tableView?.register(SnapHeaderviewCell.self, forCellReuseIdentifier: "Header")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .systemGroupedBackground
        self.tableView.separatorColor = .red
        self.tableView.separatorInset = .init(top: 0, left: 5, bottom: 0, right: 5) // .zero
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
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
    
    // MARK: - refresh
    @objc func refreshData(_ sender:AnyObject) {
        newslist.removeAll()
        joblist.removeAll()
        userlist.removeAll()
        saleslist.removeAll()
        employlist.removeAll()
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Load Data
    func loadData() {
        
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }

        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFQuery(className:"Newsios")
            query.limit = 1000
            query.order(byDescending: "createdAt")
            query.cachePolicy = .cacheThenNetwork
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedNews = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query2 = PFQuery(className:"jobPhoto")
            query2.limit = 1000
            query2.order(byDescending: "createdAt")
            query2.cachePolicy = .cacheThenNetwork
            query2.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedJob = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query3 = PFUser.query()
            query3?.limit = 1000
            query3?.order(byDescending: "createdAt")
            query3?.cachePolicy = .cacheThenNetwork
            query3?.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedUser = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query4 = PFQuery(className:"Salesman")
            query4.limit = 1000
            query4.order(byAscending: "Salesman")
            query4.cachePolicy = .cacheThenNetwork
            query4.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedSales = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query5 = PFQuery(className:"Employee")
            query5.limit = 1000
            query5.order(byAscending: "createdAt")
            query5.cachePolicy = .cacheThenNetwork
            query5.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems5 = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query6 = PFQuery(className:"Blog")
            query6.whereKey("ReplyId", equalTo:NSNull())
            query6.order(byDescending: "createdAt")
            query6.cachePolicy = .cacheThenNetwork
            query6.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems6 = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("News").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let newsTxt = NewsModel(dictionary: dictionary)
                self.newslist.append(newsTxt)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("users").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let post = UserModel(dictionary: dictionary)
                self.userlist.append(post)
                
                self.userlist.sort(by: { (u1, u2) -> Bool in
                    return u1.username.compare(u2.username) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("Job").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let employTxt = JobModel(dictionary: dictionary)
                self.joblist.append(employTxt)
                
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("Salesman").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let employTxt = SalesModel(dictionary: dictionary)
                self.saleslist.append(employTxt)
                
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("Employee").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let employTxt = EmployModel(dictionary: dictionary)
                self.employlist.append(employTxt)
                
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("News")
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let userDict = userSnap.value as! [String: Any]
                        self.newsdetailStr = userDict["newsDetail"] as? String
                        let secondsFrom1970 = userDict["creationDate"] as? Double ?? 0
                        self.newsdateStr = Date(timeIntervalSince1970: secondsFrom1970)
                        self.newsStr = userDict["newsTitle"] as? String
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                })
            
            FirebaseRef.databaseBlog
                .queryOrdered(byChild: "replyId")
                .queryEqual(toValue: "")
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let userDict = userSnap.value as! [String: Any]
                        self.blogpostStr = userDict["postBy"] as? String
                        let secondsFrom1970 = userDict["creationDate"] as? Double ?? 0
                        self.blogdateStr = Date(timeIntervalSince1970: secondsFrom1970)
                        self.blogStr = userDict["subject"] as? String
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                })
        }
    }
    
    // MARK: - Calender Events
    // MARK: fix dont work
    func loadEvents() {
        
        // Create a date formatter instance to use for converting a string to a date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = dateFormatter.date(from: "2016-01-01")
        let endDate = dateFormatter.date(from: "2017-12-31")
        
        if let startDate = startDate, let endDate = endDate {
            let eventStore = EKEventStore()
            
            // Use an event store instance to create and properly configure an NSPredicate
            let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
            
            // Use the configured NSPredicate to find and return events in the store that match
            self.events = eventStore.events(matching: eventsPredicate).sorted(){
                (e1: EKEvent, e2: EKEvent) -> Bool in
                return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
            }
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "snapvideoSegue" {
            guard let vc = segue.destination as? PlayVC else { return }
            vc.videoURL = self.imageFile.url ?? ""
            
        } else if segue.identifier == "snapuploadSegue" {
            guard let VC = segue.destination as? NewsDetailVC else { return }
            VC.objectId = self.selectedObjectId ?? ""
            VC.newsTitle = self.selectedTitle ?? ""
            VC.newsDetail = self.selectedEmail ?? ""
            VC.newsDate = self.selectedDate ?? Date()
            VC.newsStory = self.selectedPhone ?? ""
            VC.image = self.selectedImage ?? nil
            VC.videoURL = self.imageDetailurl ?? ""
            VC.SnapshotBool = true //hide leftBarButtonItems
            
        } else if segue.identifier == "userdetailSegue" {
            let storyboard = UIStoryboard(name:"Supporting", bundle: nil)
            let VC = storyboard.instantiateViewController(withIdentifier: "userDetailVC") as! UserDetailController
            VC.status = "Edit"
            VC.objectId = self.selectedObjectId ?? ""
            VC.username = self.selectedName ?? ""
            VC.create = self.selectedCreate ?? ""
            VC.email = self.selectedEmail ?? ""
            VC.phone = self.selectedPhone ?? ""
            VC.userimage = self.selectedImage ?? nil
            
        } else if segue.identifier == "snapemployeeSegue" {
            guard let VC = segue.destination as? LeadDetail else { return }
            VC.formController = "Employee"
            VC.objectId = self.selectedObjectId ?? ""
            VC.leadNo = self.selectedPhone ?? ""
            VC.date = self.selectedCreate ?? ""
            VC.name = self.selectedName ?? ""
            VC.custNo = self.selectedTitle ?? ""
            VC.address = self.selectedEmail ?? ""
            VC.city = self.imageDetailurl ?? ""
            VC.state = self.selectedState ?? ""
            VC.zip = self.selectedZip ?? ""
            VC.amount = self.selectedAmount ?? ""
            VC.tbl11 = self.selected11 ?? ""
            VC.tbl12 = self.selected12 ?? ""
            VC.tbl13 = self.selected13 ?? ""
            VC.tbl14 = self.selected14 ?? ""
            VC.tbl15 = self.selected15 ?? ""
            VC.tbl21 = self.selected21 ?? ""
            VC.tbl22 = self.selected22 ?? ""
            VC.tbl23 = self.selected23 ?? ""
            VC.tbl24 = self.selected24 ?? ""
            VC.tbl25 = self.selected25 ?? ""
            VC.tbl16 = self.selected16 ?? ""
            VC.tbl26 = self.selected26 ?? ""
            VC.tbl27 = self.selected27 ?? ""
            VC.comments = self.selectedComments ?? ""
            VC.active = self.selectedActive ?? ""
            
            VC.l11 = "Home"; VC.l12 = "Work"
            VC.l13 = "Mobile"; VC.l14 = "Social"
            VC.l15 = "Middle "; VC.l21 = "Email"
            VC.l22 = "Department"; VC.l23 = "Title"
            VC.l24 = "Manager"; VC.l25 = "Country"
            VC.l16 = "Last Updated"; VC.l26 = "First"
            VC.l1datetext = "Email:"
            VC.lnewsTitle = Config.NewsEmploy
        }
    }
}
//-----------------------end------------------------------
@available(iOS 13.0, *)
extension SnapshotVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 5, bottom: 0, right: 5)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 0) {
            if UIDevice.current.userInterfaceIdiom == .pad  {
                return .init(width: 250, height: 180)
            } else {
                return .init(width: 190, height: 140)
            }
        } else if (collectionView.tag == 1) {
            return .init(width: 155, height: 140)
        } else if (collectionView.tag == 2) {
            return .init(width: 125, height: 140)
        }
        return .init(width: 95, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        if (collectionView.tag == 0) {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedNews.count
            } else {
                //firebase
                return newslist.count
            }
        } else if (collectionView.tag == 1) {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedJob.count
            } else {
                //firebase
                return joblist.count
            }
        } else if (collectionView.tag == 2) {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedUser.count
            } else {
                //firebase
                return userlist.count
            }
        } else if (collectionView.tag == 3) {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedSales.count
            } else {
                //firebase
                return saleslist.count
            }
        } else if (collectionView.tag == 4) {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedItems5.count
            } else {
                //firebase
                return employlist.count
            }
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath)->UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CollectionViewCell
            cell.backgroundColor = .systemGray


        if (UIDevice.current.userInterfaceIdiom == .pad) && (collectionView.tag == 0) {
            myLabel1 = UILabel(frame: .init(x: 0, y: cell.bounds.size.height-20, width: cell.bounds.size.width, height: 20))
        } else {
            myLabel1 = UILabel(frame: .init(x: 0, y: cell.bounds.size.height-20, width: cell.bounds.size.width, height: 20))
        }

        myLabel1.font = Font.Snapshot.cellLabel
        myLabel1.backgroundColor = .secondarySystemGroupedBackground
        myLabel1.textColor = .label
        myLabel1.textAlignment = .center
        myLabel1.clipsToBounds = true
        myLabel1.adjustsFontSizeToFitWidth = true

        var photoImage: UIImage?
        
        if (collectionView.tag == 0) {
            
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedNews.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    guard let imageData = imageData else {return}
                    DispatchQueue.main.async {
                        photoImage = UIImage(data: imageData)
                        cell.snapImageView.image = photoImage ?? #imageLiteral(resourceName: "profile-rabbit-toy")
                    }
                }
                
                myLabel1.text = (_feedNews[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String
                
                imageDetailurl = self.imageFile.url ?? ""
                let result1 = imageDetailurl?.contains("movie.mp4")
                cell.playBtn.isHidden = result1 == false
                cell.playBtn.setTitle(imageDetailurl, for: .normal)
                cell.videoLengthLabel.isHidden = result1 == false

            } else {
                //firebase
                let newsImageUrl = newslist[indexPath.item].imageUrl
                cell.snapImageView.loadImage(urlString: newsImageUrl)
                myLabel1.text = newslist[indexPath.item].newsTitle

                let videoDetailurl = newslist[indexPath.item].videoUrl
                cell.playBtn.isHidden = newslist[indexPath.item].videoUrl == ""
                cell.playBtn.setTitle(videoDetailurl, for: .normal)
                cell.videoLengthLabel.isHidden = newslist[indexPath.item].videoUrl == ""
            }
            
            cell.snapImageView.addSubview(cell.playBtn)
            cell.snapImageView.addSubview(cell.videoLengthLabel)
            
            NSLayoutConstraint.activate([
                cell.playBtn.centerXAnchor.constraint(equalTo: cell.snapImageView.centerXAnchor),
                cell.playBtn.centerYAnchor.constraint(equalTo: cell.snapImageView.centerYAnchor),
                cell.playBtn.widthAnchor.constraint(equalToConstant: 30),
                cell.playBtn.heightAnchor.constraint(equalToConstant: 30),
                
                cell.videoLengthLabel.rightAnchor.constraint(equalTo: cell.snapImageView.rightAnchor, constant: -8),
                cell.videoLengthLabel.bottomAnchor.constraint(equalTo: cell.snapImageView.bottomAnchor, constant: -2),
                cell.videoLengthLabel.heightAnchor.constraint(equalToConstant: 30)
                ])

            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 1) {
            
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedJob.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    guard let imageData = imageData else {return}
                    DispatchQueue.main.async {
                        photoImage = UIImage(data: imageData)
                        cell.snapImageView.image = photoImage ?? #imageLiteral(resourceName: "profile-rabbit-toy")
                    }
                }
                myLabel1.text = (_feedJob[indexPath.row] as AnyObject).value(forKey: "imageGroup") as? String
            } else {
                //firebase
                let jobImageUrl = joblist[indexPath.item].imageUrl
                cell.snapImageView.loadImage(urlString: jobImageUrl)
                myLabel1.text = joblist[indexPath.item].description
                
            }
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 2) {
            
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedUser.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    guard let imageData = imageData else {return}
                    DispatchQueue.main.async {
                        photoImage = UIImage(data: imageData)
                        cell.snapImageView.image = photoImage ?? #imageLiteral(resourceName: "profile-rabbit-toy")
                    }
                }
                myLabel1.text = (_feedUser[indexPath.row] as AnyObject).value(forKey: "username") as? String
            } else {
                //firebase
                let newsImageUrl = userlist[indexPath.item].profileImageUrl
                cell.snapImageView.loadImage(urlString: newsImageUrl)
                myLabel1.text = userlist[indexPath.item].username
                
            }
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 3) {
            
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedSales.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    guard let imageData = imageData else {return}
                    DispatchQueue.main.async {
                        photoImage = UIImage(data: imageData)
                        cell.snapImageView.image = photoImage ?? #imageLiteral(resourceName: "profile-rabbit-toy")
                    }
                }
                myLabel1.text = (_feedSales[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
            } else {
                //firebase
                let newsImageUrl = saleslist[indexPath.item].imageUrl
                cell.snapImageView.loadImage(urlString: newsImageUrl)
                myLabel1.text = saleslist[indexPath.item].salesman
                
            }
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 4) {
            
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedItems5.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    guard let imageData = imageData else {return}
                    DispatchQueue.main.async {
                        photoImage = UIImage(data: imageData)
                        cell.snapImageView.image = photoImage ?? #imageLiteral(resourceName: "profile-rabbit-toy")
                    }
                }
                
                myLabel1.text = String(format: "%@ %@ %@ ", ((_feedItems5[indexPath.row] as AnyObject).value(forKey: "First") as? String)!, ((_feedItems5[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!, ((_feedItems5[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!)
            } else {
                //firebase
                let newsImageUrl = employlist[indexPath.item].imageUrl
                cell.snapImageView.loadImage(urlString: newsImageUrl)
                myLabel1.text = employlist[indexPath.item].lastname
                
            }
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.addSubview(myLabel1)
            
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 0) {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedNews.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    let imageDetailurl = self.imageFile.url
                    let result1 = imageDetailurl!.contains("movie.mp4")
                    if (result1 == true) {
                        //fix
                        self.performSegue(withIdentifier: "snapvideoSegue", sender: self)
                        
                        let storyboard = UIStoryboard(name: "News", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "PlayVC") as! PlayVC
                        vc.videoURL = imageDetailurl
                        
                        NotificationCenter.default.post(name: NSNotification.Name("open"), object: nil)
                        
                    } else {
                        
                        self.selectedImage = UIImage(data: imageData!)
                        self.selectedObjectId = (self._feedNews[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                        self.selectedTitle = (self._feedNews[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String
                        self.selectedEmail = (self._feedNews[indexPath.row] as AnyObject).value(forKey: "newsDetail") as? String
                        self.selectedPhone = (self._feedNews[indexPath.row] as AnyObject).value(forKey: "storyText") as? String
                        self.imageDetailurl = self.imageFile.url
                        self.selectedDate = (self._feedNews[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
                        
                        self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
                    }
                }
            } else {
                //firebase
            }
        } else if (collectionView.tag == 1) {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedJob.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    self.selectedImage = UIImage(data: imageData!)
                    self.selectedTitle = (self._feedJob[indexPath.row] as AnyObject).value(forKey: "imageGroup") as? String
                    self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
                }
            } else {
                //firebase
            }
            
        } else if (collectionView.tag == 2) {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedUser.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    self.selectedImage = UIImage(data: imageData!)
                    self.selectedObjectId = (self._feedUser[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                    self.selectedName = (self._feedUser[indexPath.row] as AnyObject).value(forKey: "username") as? String
                    self.selectedEmail = (self._feedUser[indexPath.row] as AnyObject).value(forKey: "email") as? String
                    self.selectedPhone = (self._feedUser[indexPath.row] as AnyObject).value(forKey: "phone") as? String
                    
                    let updated:Date = (self._feedUser[indexPath.row] as AnyObject).value(forKey: "createdAt") as! Date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd, yyyy"
                    let createString = dateFormatter.string(from: updated)
                    self.selectedCreate = createString
                    
                    self.performSegue(withIdentifier: "userdetailSegue", sender:self)
                }
            } else {
                //firebase
            }
        } else if (collectionView.tag == 3) {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedSales.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    self.selectedImage = UIImage(data: imageData!)
                    self.selectedObjectId = (self._feedSales[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                    self.selectedEmail = (self._feedSales[indexPath.row] as AnyObject).value(forKey: "SalesNo") as? String
                    self.selectedPhone = (self._feedSales[indexPath.row] as AnyObject).value(forKey: "Active") as? String
                    self.selectedTitle = (self._feedSales[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
                    
                    self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
                }
            } else {
                //firebase
            }
        } else if (collectionView.tag == 4) {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedItems5.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    self.selectedObjectId = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                    self.selectedPhone = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "EmployeeNo") as? String
                    self.selectedCreate = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Email") as? String
                    
                    self.selectedName = String(format: "%@ %@ %@", ((self._feedItems5[indexPath.row] as AnyObject).value(forKey: "First") as? String)!, ((self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!, ((self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
                    
                    self.selectedTitle = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Last") as? String
                    self.selectedEmail = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Street") as? String
                    self.imageDetailurl = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "City") as? String
                    self.selectedState = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "State") as? String
                    self.selectedZip = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Zip") as? String
                    
                    self.selectedAmount = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Title") as? String
                    self.selected11 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "HomePhone") as? String
                    self.selected12 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "WorkPhone") as? String
                    self.selected13 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "CellPhone") as? String
                    self.selected14 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "SS") as? String
                    self.selected15 = ((self._feedItems5[indexPath.row]) as AnyObject).value(forKey: "Middle") as? NSString
                    
                    self.selected21 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Email") as? NSString
                    self.selected22 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Department") as? String
                    self.selected23 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Title") as? String
                    self.selected24 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Manager") as? String
                    self.selected25 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Country") as? String
                    
                    self.selected16 = String(describing:(self._feedItems5[indexPath.row] as AnyObject).value(forKey: "updatedAt") as? Date)
                    self.selected26 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "First") as? NSString
                    self.selected27 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Company") as? String
                    self.selectedComments = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Comments") as? String
                    self.selectedActive = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Active") as? String
                    
                    self.performSegue(withIdentifier: "snapemployeeSegue", sender:self)
                }
            }
        } else {
            //firebase
        }
    }
}
// MARK: - UISearchBar Delegate
@available(iOS 13.0, *)
extension SnapshotVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.filteredMenu.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.menuItems as NSArray).filtered(using: searchPredicate)
        self.filteredMenu = array as! [String]
        //self.resultsController = self.filteredMenu
        self.resultsController.tableView.reloadData()
    }
}
@available(iOS 13.0, *)
extension SnapshotVC: UITableViewDataSource {

       // MARK: - Table View
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
       {
           let result:CGFloat = 140
           if (indexPath.section == 0) {

               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               case 1:
                   if UIDevice.current.userInterfaceIdiom == .pad  {
                       return 190
                   } else {
                       return result
                   }
               case 2:
                   return 0
               default:
                   return result
               }
           } else if (indexPath.section == 1) {

               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               case 2:
                   return 0
               default:
                   return result
               }

           } else if (indexPath.section == 2) {
               let result:CGFloat = 80
               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               default:
                   return result
               }
           } else if (indexPath.section == 3) {

               let result:CGFloat = 80
               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               default:
                   return result
               }

           } else if (indexPath.section == 4) {

               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               default:
                   return result
               }
           } else if (indexPath.section == 5) {

               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               default:
                   return result
               }
           } else if (indexPath.section == 6) {

               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               default:
                   return result
               }
           } else if (indexPath.section == 7) {
               let result:CGFloat = 110
               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               default:
                   return result
               }
           } else if (indexPath.section == 8) {
               let result:CGFloat = 110
               switch (indexPath.row % 4)
               {
               case 0:
                   return 44
               default:
                   return result
               }
           }
           return 0
       }

       func numberOfSections(in tableView: UITableView) -> Int {
           return 9
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

           if tableView == self.tableView {
               if (section == 0) {
                   return 3
               } else if (section == 1) {
                   return 3
               }
               return 2
           }
           return 0
       }

       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

           if (section == 0) {
               return 185
           }
           return 0
       }

       // create a seperator on bottom of tableview
       func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

           if (tableView == self.tableView) {

               if (section == 0) {
                       guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? SnapHeaderviewCell else { fatalError("Unexpected Index Path") }

                       //tableView.tableHeaderView = vw

                       if ((defaults.string(forKey: "backendKey")) == "Parse") {
                           header.titleLabeltxt1.text = "Parse"
                       } else {
                           header.titleLabeltxt1.text = "Firebase"
                       }

                       if (tempYQL != nil) && (textYQL != nil) {
                           header.titleLabeltxt2.text = String(format: "%@ %@ %@", "Weather:", "\(tempYQL!)°", "\(textYQL!)")
                           if (textYQL!.contains("Rain") ||
                               textYQL!.contains("Snow") ||
                               textYQL!.contains("Thunderstorms") ||
                               textYQL!.contains("Showers")) {
                               header.titleLabeltxt2.textColor = .systemRed
                           } else {
                               header.titleLabeltxt2.textColor = .systemGreen
                           }
                       } else {
                           header.titleLabeltxt2.text = "not available"
                           header.titleLabeltxt2.textColor = .systemRed
                       }

                      header.myListLbl.text = String(format: "%@%@", "MyGroups ", "9")

                       return header
                   }
           }
           return nil
       }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cellIdentifier: String!

        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell

        cell.collectionView.delegate =  nil
        cell.collectionView.dataSource = nil
        cell.collectionView.backgroundColor = .secondarySystemGroupedBackground
        cell.customImagelabel.backgroundColor = .clear //fixed
        cell.customImageView.layer.borderColor = UIColor.clear.cgColor //fixed
        cell.backgroundColor =  .secondarySystemGroupedBackground
        cell.accessoryType = .none

        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.textLabel!.font = Font.celltitle26r
            cell.snaptitleLabel.font = Font.celltitle20r
            cell.snapdetailLabel.font = Font.celltitle20r

        } else {
            cell.textLabel!.font = Font.celltitle18r
            cell.snaptitleLabel.font = Font.celltitle16r
            cell.snapdetailLabel.font = Font.celltitle18r
        }

        cell.textLabel!.textColor = .systemRed
        cell.snapdetailLabel?.textColor = .label
        cell.snaptitleLabel?.textColor = .systemGray //Color.Snap.textColor1

        cell.textLabel?.text = ""

        cell.snaptitleLabel?.frame = .init(x: 24, y: 11, width: view.frame.width-20, height: 21)
        cell.snaptitleLabel?.numberOfLines = 1
        cell.snaptitleLabel?.text = ""

        cell.snapdetailLabel?.frame = .init(x: 24, y: 38, width: view.frame.width-20, height: 21)
        cell.snapdetailLabel?.numberOfLines = 2
        cell.snapdetailLabel?.text = ""

        let date2 = Date()
        let calendar = Calendar.current

        if (indexPath.section == 0) {

            if (indexPath.row == 0) {

                let separator = UIView(frame: .init(x: 5, y: 1, width: view.frame.size.width-10, height: 0.5))
                separator.backgroundColor = .red
                cell.addSubview(separator)

                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.accessoryType = .disclosureIndicator
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = String(format: "%@%d", "Top News ", _feedNews.count)
                } else {
                    //firebase
                    cell.textLabel!.text = String(format: "%@%d", "Top News ", newslist.count)
                }
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 1) {

                cell.collectionView.tag = 0
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 2) {
                cell.accessoryType = .disclosureIndicator
                cell.textLabel!.font = Font.Snapshot.cellgallery
                cell.textLabel!.textColor = .systemGray
                cell.textLabel!.text = "See the full gallery"
                cell.collectionView.reloadData()
                return cell
            }

        } else if (indexPath.section == 1) {

            if (indexPath.row  == 0) {
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = String(format: "%@%d", "Top Jobs ", _feedJob.count)
                } else {
                    //firebase
                    cell.textLabel!.text = String(format: "%@%d", "Top Jobs ", joblist.count)
                }
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 1) {

                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 1
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 2) {

                cell.accessoryType = .disclosureIndicator
                cell.textLabel!.font = Font.Snapshot.cellgallery
                cell.textLabel!.textColor = .systemGray
                cell.textLabel!.text = "See the full gallery"
                cell.collectionView.reloadData()
                return cell
            }

        }  else if (indexPath.section == 2) {

            if (indexPath.row == 0) {
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.textLabel!.text = "Latest Blog"
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 1) {

                let date1 : Date?
                let blogString : String?

                if ((defaults.string(forKey: "backendKey")) == "Parse") {

                    date1 = (_feedItems6.firstObject as AnyObject).value(forKey: "createdAt") as? Date
                    blogString = (_feedItems6.firstObject as AnyObject).value(forKey: "PostBy") as? String
                    cell.snapdetailLabel?.text = (_feedItems6.firstObject as AnyObject).value(forKey: "Subject") as? String

                } else {
                    //firebase
                    date1 = blogdateStr
                    blogString = blogpostStr
                    cell.snapdetailLabel?.text = blogStr
                }

                if date1 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                    let daysCount1 = diffDateComponents.day

                    if blogString != nil {
                        cell.snaptitleLabel?.text = "\(blogString!), \(daysCount1!) days ago"
                    } else {
                        cell.snaptitleLabel?.text = "none"
                    }
                }

                cell.collectionView.backgroundColor = .clear
                cell.collectionView.reloadData()
                return cell
            }

        } else if (indexPath.section == 3) {

            if (indexPath.row == 0) {
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.textLabel!.text = "Latest News"
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 1) {

                let date1 : Date?
                let newsString : String?

                if ((defaults.string(forKey: "backendKey")) == "Parse") {

                    date1 = (_feedNews.firstObject as AnyObject).value(forKey: "createdAt") as? Date
                    newsString = (_feedNews.firstObject as AnyObject).value(forKey: "newsDetail") as? String
                    cell.snapdetailLabel?.text = (_feedNews.firstObject as AnyObject).value(forKey: "newsTitle") as? String
                } else {
                    //firebase
                    date1 = newsdateStr
                    newsString = newsdetailStr
                    cell.snapdetailLabel?.text = newsStr
                }

                if date1 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                    let daysCount = diffDateComponents.day

                    if newsString != nil {
                        cell.snaptitleLabel?.text = "\(newsString!), \(daysCount!) days ago"
                    } else {
                        cell.snaptitleLabel?.text = "none"
                    }
                }

                cell.collectionView.backgroundColor = .clear
                cell.collectionView.reloadData()
                return cell
            }

        } else if (indexPath.section == 4) {

            if (indexPath.row == 0) {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = String(format: "%@%d", "Top Users ", _feedUser.count)
                } else {
                    //firebase
                    cell.textLabel!.text = String(format: "%@%d", "Top Users ", userlist.count)
                }
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 1) {

                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 2
                cell.collectionView.reloadData()
                return cell
            }

        } else if (indexPath.section == 5) {

            if (indexPath.row == 0) {

                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = String(format: "%@%d", "Top Salesman ", _feedSales.count)
                } else {
                    //firebase
                    cell.textLabel!.text = String(format: "%@%d", "Top Salesman ", saleslist.count)
                }
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 1) {

                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 3
                cell.collectionView.reloadData()
                return cell
            }

        } else if (indexPath.section == 6) {

            if (indexPath.row == 0) {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = String(format: "%@%d", "Top Employee ", _feedItems5.count)
                } else {
                    //firebase
                    cell.textLabel!.text = String(format: "%@%d", "Top Employee ", employlist.count)
                }
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell

            } else if (indexPath.row == 1) {

                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 4
                cell.collectionView.reloadData()
                return cell
            }

        } else if (indexPath.section == 7) {

            if (indexPath.row == 0) {
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.textLabel!.text = "Top Notification"
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
            } else if (indexPath.row == 1) {

                cell.collectionView.backgroundColor = .clear
                cell.snapdetailLabel?.text = "You have no pending notifications :)"
                //cell.snaptitleLabel?.text = localNotification.fireDate?.description
                //cell.snapdetailLabel?.text = localNotification.alertBody
                cell.collectionView.reloadData()
                return cell
            }

        }  else if (indexPath.section == 8) {

            if (indexPath.row == 0) {
                cell.collectionView.backgroundColor = .systemGroupedBackground
                cell.backgroundColor = .systemGroupedBackground
                cell.textLabel!.text = String(format: "%@%d", "Top Event ", (events?.count)!)
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
            } else if (indexPath.row == 1) {

                cell.collectionView.backgroundColor = .clear
                if (events!.isEmpty) {
                    cell.snapdetailLabel?.text = "You have no pending events :)"
                } else {
                    cell.snapdetailLabel?.text = events?[0].title
                }
                cell.collectionView.reloadData()
                return cell
            }
        }
        return cell
    }
}
@available(iOS 13.0, *)
extension SnapshotVC: UITableViewDelegate {

}


