//
//  Customer.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/13/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

final class Customer: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [CustModel]()
    private let searchScope = ["name", "city", "phone", "date", "active"]
    
    //firebase
    var custlist = [CustModel]()
    var activeCount: Int?
    var defaults = UserDefaults.standard
    //parse
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()

    var pasteBoard = UIPasteboard.general
    var objectIdLabel = String()
    var titleLabel = String()
    var dateLabel = String()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.Cust.navColor
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

        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(Customer.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newDataBtn))
        navigationItem.title = "Customers"
        //self.navigationItem.largeTitleDisplayMode = .always
        
        searchController = UISearchController(searchResultsController: resultsController)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = .white
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }
        
        self.definesPresentationContext = true
    }
    
    func setupTableView() {
        // MARK: - TableHeader
        tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.sizeToFit()
        self.tableView!.clipsToBounds = true
        if #available(iOS 13.0, *) {
            let bgView = UIView()
            bgView.backgroundColor = .secondarySystemGroupedBackground
            tableView!.backgroundView = bgView
        } else {
            // Fallback on earlier versions
            self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        }
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = Color.LGrayColor
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        if UIDevice.current.userInterfaceIdiom == .phone {
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
    
    // MARK: - refresh
    @objc func refreshData(_ sender:AnyObject) {
        custlist.removeAll() //fix
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newDataBtn() {
        
        self.performSegue(withIdentifier: "newcustSegue", sender: self)
    }

    // MARK: - Parse
    func loadData() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
            let query = PFQuery(className:"Customer")
            query.limit = 1000
            query.cachePolicy = .cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error3")
                }
            }
            
            let query1 = PFQuery(className:"Customer")
            query1.whereKey("Active", equalTo:1)
            query1.cachePolicy = .cacheThenNetwork
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error4")
                }
            }
        } else {
            
            //firebase
            FirebaseRef.databaseRoot.child("Customer")
                .observe(.childAdded , with:{ (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let post = CustModel(dictionary: dictionary)
                    self.custlist.append(post)
                    
                    self.custlist.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                }) { (err) in
                    print("Failed to fetch posts:", err)
            }
            
            FirebaseRef.databaseRoot.child("Customer")
                .queryOrdered(byChild: "active") //inludes reply likes
                .queryStarting(atValue: 1)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    self.activeCount = Int(snapshot.childrenCount)
                    self.tableView?.reloadData()
                })
        }
    }
    
    func deleteData(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            if (self.defaults.bool(forKey: "parsedataKey")) {
                
                let query = PFQuery(className:"Customer")
                query.whereKey("objectId", equalTo: name)
                query.findObjectsInBackground(block: { objects, error in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
                            self.refreshData(self)
                        }
                    }
                })
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Customer").child(name).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                })
            }
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.success)
            self.refreshData(self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.refreshData(self)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }
    
    // MARK: - imgLoadSegue
    @objc func imgLoadSegue(_ sender: UITapGestureRecognizer) {
        if (defaults.bool(forKey: "parsedataKey")) {
            objectIdLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "objectId") as? String)!
            dateLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "Date") as? String)!
            titleLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "LastName") as? String)!
        } else {
            //firebase
            objectIdLabel = custlist[(sender.view!.tag)].custId!
            dateLabel = custlist[(sender.view!.tag)].creationDate.timeAgoDisplay()
            titleLabel = custlist[(sender.view!.tag)].lastname
            
        }
        self.performSegue(withIdentifier: "custuserSeque", sender: self)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "custdetailSegue" {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            controller.formController = "Customer"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            var CustNo:Int?
            var LeadNo:Int?
            var Zip:Int?
            var Amount:Int?
            var SalesNo:Int?
            var JobNo:Int?
            var AdNo:Int?
            var Active:Int?
            var Quan:Int?
            var dateUpdated:Date?
            var indexPath: Int?
            
            if navigationItem.searchController?.isActive == true {
                //search
                indexPath = self.resultsController.tableView?.indexPathForSelectedRow?.row
                dateUpdated = filteredTitles[indexPath!].lastUpdate
                CustNo = filteredTitles[indexPath!].custNo as? Int
                LeadNo = filteredTitles[indexPath!].leadNo as? Int
                Zip = filteredTitles[indexPath!].zip as? Int
                Amount = filteredTitles[indexPath!].amount as? Int
                SalesNo = filteredTitles[indexPath!].salesNo as? Int
                JobNo = filteredTitles[indexPath!].jobNo as? Int
                AdNo = filteredTitles[indexPath!].adNo as? Int
                Active = filteredTitles[indexPath!].active as? Int
                Quan = filteredTitles[indexPath!].quan as? Int
                
            } else {
 
                indexPath = self.tableView?.indexPathForSelectedRow?.row
                if (defaults.bool(forKey: "parsedataKey")) {
                    
                    dateUpdated = (_feedItems[indexPath!] as AnyObject).value(forKey: "updatedAt") as? Date
                    CustNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "CustNo") as? Int
                    LeadNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "LeadNo") as? Int
                    Zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip")as? Int
                    Amount = (_feedItems[indexPath!] as AnyObject).value(forKey: "Amount")as? Int
                    SalesNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "SalesNo")as? Int
                    JobNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "JobNo")as? Int
                    AdNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "AdNo")as? Int
                    Active = (_feedItems[indexPath!] as AnyObject).value(forKey: "Active")as? Int
                    Quan = (_feedItems[indexPath!] as AnyObject).value(forKey: "Quan")as? Int
                    
                } else {
                    
                    dateUpdated = custlist[indexPath!].lastUpdate
                    CustNo = custlist[indexPath!].custNo as? Int
                    LeadNo = custlist[indexPath!].leadNo as? Int
                    Zip = custlist[indexPath!].zip as? Int
                    Amount = custlist[indexPath!].amount as? Int
                    SalesNo = custlist[indexPath!].salesNo as? Int
                    JobNo = custlist[indexPath!].jobNo as? Int
                    AdNo = custlist[indexPath!].adNo as? Int
                    Active = custlist[indexPath!].active as? Int
                    Quan = custlist[indexPath!].quan as? Int
                }
            }
            
            if CustNo == nil {
                CustNo = 0
            }
            if LeadNo == nil {
                LeadNo = 0
            }
            if Zip == nil {
                Zip = 0
            }
            if Amount == nil {
                Amount = 0
            }
            if SalesNo == nil {
                SalesNo = 0
            }
            if JobNo == nil {
                JobNo = 0
            }
            if AdNo == nil {
                AdNo = 0
            }
            if Active == nil {
                Active = 0
            }
            if Quan == nil {
                Quan = 0
            }
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            controller.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated!)) as String
            
            
            if navigationItem.searchController?.isActive == true {
                //search
                let cust: CustModel
                cust = filteredTitles[indexPath!]
                
                controller.leadNo = formatter.string(from: LeadNo! as NSNumber)
                controller.zip = formatter.string(from: Zip! as NSNumber)
                controller.amount = formatter.string(from: Amount! as NSNumber)
                controller.tbl22 = formatter.string(from: SalesNo! as NSNumber)
                controller.tbl23 = formatter.string(from: JobNo! as NSNumber)
                controller.tbl24 = formatter.string(from: AdNo! as NSNumber)
                controller.tbl25 = formatter.string(from: Quan! as NSNumber)
                controller.active = formatter.string(from: Active! as NSNumber)
                controller.objectId = cust.custId
                controller.date = dateFormat.string(from: cust.creationDate as Date)
                controller.name = cust.lastname
                controller.address = cust.address
                controller.city = cust.city
                controller.state = cust.state
                controller.tbl11 = cust.first
                controller.tbl12 = cust.phone
                controller.tbl13 = cust.contractor
                controller.tbl14 = cust.spouse
                controller.tbl15 = cust.email as NSString
                controller.tbl21 = dateFormat.string(from: cust.start as Date) as NSString
                controller.tbl26 = cust.rate as NSString
                controller.complete = dateFormat.string(from: cust.completion as Date)
                controller.photo = cust.photo
                controller.comments = cust.comments
                
            } else {
                
                if (defaults.bool(forKey: "parsedataKey")) {
                    
                    controller.custNo = formatter.string(from: CustNo! as NSNumber)
                    controller.leadNo = formatter.string(from: LeadNo! as NSNumber)
                    controller.zip = formatter.string(from: Zip! as NSNumber)
                    controller.amount = formatter.string(from: Amount! as NSNumber)
                    controller.tbl22 = formatter.string(from: SalesNo! as NSNumber)
                    controller.tbl23 = formatter.string(from: JobNo! as NSNumber)
                    controller.tbl24 = formatter.string(from: AdNo! as NSNumber)
                    controller.tbl25 = formatter.string(from: Quan! as NSNumber)
                    controller.active = formatter.string(from: Active! as NSNumber)
                    controller.objectId = (_feedItems[indexPath!] as AnyObject).value(forKey: "objectId") as? String
                    controller.date = (_feedItems[indexPath!] as AnyObject).value(forKey: "Date") as? String
                    controller.name = (_feedItems[indexPath!] as AnyObject).value(forKey: "LastName") as? String
                    controller.address = (_feedItems[indexPath!] as AnyObject).value(forKey: "Address") as? String
                    controller.city = (_feedItems[indexPath!] as AnyObject).value(forKey: "City") as? String
                    controller.state = (_feedItems[indexPath!] as AnyObject).value(forKey: "State") as? String
                    controller.tbl11 = (_feedItems[indexPath!] as AnyObject).value(forKey: "First") as? String
                    controller.tbl12 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone") as? String
                    controller.tbl13 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Contractor") as? String
                    controller.tbl14 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Spouse") as? String
                    controller.tbl15 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? NSString
                    controller.tbl21 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Start") as? NSString
                    controller.tbl26 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Rate") as? NSString
                    controller.complete = (_feedItems[indexPath!] as AnyObject).value(forKey: "Completion") as? String
                    controller.photo = (_feedItems[indexPath!] as AnyObject).value(forKey: "Photo") as? String
                    controller.comments = (_feedItems[indexPath!] as AnyObject).value(forKey: "Comments") as? String
                } else {
                    //firebase
                    controller.leadNo = custlist[indexPath!].custId
                    controller.zip = formatter.string(from: Zip! as NSNumber)
                    controller.amount = formatter.string(from: Amount! as NSNumber)
                    controller.tbl22 = formatter.string(from: SalesNo! as NSNumber)
                    controller.tbl23 = formatter.string(from: JobNo! as NSNumber)
                    controller.tbl24 = formatter.string(from: AdNo! as NSNumber)
                    controller.tbl25 = formatter.string(from: Quan! as NSNumber)
                    controller.active = formatter.string(from: Active! as NSNumber)
                    controller.objectId = custlist[indexPath!].custId
                    controller.date = dateFormat.string(from: custlist[indexPath!].creationDate as Date)
                    controller.name = custlist[indexPath!].lastname
                    controller.address = custlist[indexPath!].address
                    controller.city = custlist[indexPath!].city
                    controller.state = custlist[indexPath!].state
                    controller.tbl11 = custlist[indexPath!].first
                    controller.tbl12 = custlist[indexPath!].phone
                    controller.tbl13 = custlist[indexPath!].contractor
                    controller.tbl14 = custlist[indexPath!].spouse
                    controller.tbl15 = custlist[indexPath!].email as NSString
                    controller.tbl21 = dateFormat.string(from: custlist[indexPath!].start as Date) as NSString
                    controller.tbl26 = custlist[indexPath!].rate as NSString
                    controller.complete = dateFormat.string(from: custlist[indexPath!].completion as Date)
                    controller.photo = custlist[indexPath!].photo
                    controller.comments = custlist[indexPath!].comments
                }
                
            }
            
            controller.l11 = "First"; controller.l12 = "Phone"
            controller.l13 = "Contractor"; controller.l14 = "Spouse"
            controller.l15 = "Email"; controller.l21 = "Start date"
            controller.l22 = "Salesman"; controller.l23 = "Job"
            controller.l24 = "Product"; controller.l25 = "Quan"
            controller.l16 = "Last Updated"; controller.l26 = "Rate"
            controller.l1datetext = "Sale Date:"
            controller.lnewsTitle = Config.NewsCust
        }
        
        if segue.identifier == "custuserSeque" { // FIXME: This needs to replaced next sprint
            //guard let controller = (segue.destination as! UINavigationController).topViewController as? LeadUserVC else { return }
            guard let controller = segue.destination as? LeadUserVC else { return }
            controller.formController = "Customer"
            controller.objectId = objectIdLabel
            controller.postBy = titleLabel
            controller.leadDate = dateLabel
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
        if segue.identifier == "newcustSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! EditData
            controller.formController = "Customer"
            controller.status = "New"
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
    // MARK: - search
    func filterContentForSearchText(searchText: String, scope: String = "name") {
        
        filteredTitles = custlist.filter { (cust: CustModel) in
            let target: String
            switch(scope.lowercased()) {
            case "name":
                target = cust.lastname
            case "city":
                target = cust.city
            case "phone":
                target = cust.phone
            case "active":
                target = ""
            default:
                target = cust.lastname
            }
            return target.lowercased().contains(searchText.lowercased())
        }
        
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
        }
    }
}
//-----------------------end------------------------------
// MARK: Table View Data Source
extension Customer: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "custdetailSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if (defaults.bool(forKey: "parsedataKey")) {
                return _feedItems.count
            } else {
                //firebase
                return custlist.count
            }
        } else {
            return filteredTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
 
        if (tableView == self.tableView) {
            
            cellIdentifier = "Cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                
                cell.custtitleLabel!.font = Font.celltitle20m
                cell.custsubtitleLabel!.font = Font.celltitle16r
                cell.custreplyLabel.font = Font.celltitle16r
                cell.custlikeLabel.font = Font.celltitle18m
                cell.myLabel10.font = Font.celltitle16r
                cell.myLabel20.font = Font.celltitle18m
                
            } else {
                
                cell.custtitleLabel!.font = Font.celltitle20m
                cell.custsubtitleLabel!.font =  Font.celltitle16r
                cell.custreplyLabel.font = Font.celltitle16r
                cell.custlikeLabel.font = Font.celltitle16r
                cell.myLabel10.font = Font.celltitle16r
                cell.myLabel20.font = Font.celltitle18m
            }
            
            cell.selectionStyle = .none
            if #available(iOS 13.0, *) {
                cell.custtitleLabel.textColor = .label
                cell.myLabel20.textColor = .label
                cell.custsubtitleLabel!.textColor = .systemGray
            } else {
                // Fallback on earlier versions
            }
            
            cell.myLabel10.backgroundColor = .systemGray //Color.Cust.labelColor
            cell.custlikeButton.tintColor = .lightGray
            cell.custlikeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            
            cell.custreplyButton.tintColor = .lightGray
            cell.custreplyButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
            
            cell.customImagelabel.text = "Cust"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.frame = .init(x: 10, y: 10, width: 50, height: 50)
            cell.customImagelabel.backgroundColor = Color.Cust.labelColor1
            cell.customImagelabel.layer.cornerRadius = 25.0
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgLoadSegue))
            cell.customImagelabel.addGestureRecognizer(tap)
            cell.addSubview(cell.customImagelabel)
            
            if (defaults.bool(forKey: "parsedataKey")) {
                
                cell.custtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "LastName") as? String
                cell.custsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "City") as? String
                cell.custlikeLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Rate") as? String
                cell.myLabel10.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Date") as? String
                
                var Amount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Amount")as? Int
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                if Amount == nil {
                    Amount = 0
                }
                cell.myLabel20.text = formatter.string(from: Amount! as NSNumber)
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == "") {
                    cell.custreplyButton!.tintColor = .lightGray
                } else {
                    cell.custreplyButton!.tintColor = Color.Cust.buttonColor
                }
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
                    cell.custreplyLabel.text! = "Active"
                    cell.custreplyLabel.adjustsFontSizeToFitWidth = true
                } else {
                    cell.custreplyLabel.text! = ""
                }
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Rate") as? String == "A" ) {
                    cell.custlikeButton!.tintColor = Color.Cust.buttonColor
                } else {
                    cell.custlikeButton!.tintColor = .lightGray
                }
                
            } else {
                //firebase
                cell.custpost = custlist[indexPath.row]
            }
            
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if (defaults.bool(forKey: "parsedataKey")) {
                //parse
                cell.textLabel!.text = (filteredTitles[indexPath.row] as AnyObject).value(forKey: "LastName") as? String
                
            } else {
                
                let cust: CustModel
                cust = filteredTitles[indexPath.row]
                cell.textLabel!.text = cust.lastname
            }
            
            return cell
        }
    }
    
}
// MARK: Table View Delegate
extension Customer: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.tableView) {
            if (section == 0) {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    //return 85.0
                    return self._feedItems.count > 0 ? 0 : 85
                } else {
                    return CGFloat.leastNormalMagnitude
                }
            }
            return 0
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (tableView == self.tableView) {
            if (section == 0) {
                guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
                
                if (defaults.bool(forKey: "parsedataKey")) {
                    header.myLabel1.text = String(format: "%@%d", "Cust\n", _feedItems.count)
                    header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                    header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
                } else {
                    //firebase
                    header.myLabel1.text = String(format: "%@%d", "Cust\n", custlist.count)
                    header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                    header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
                }
                header.contentView.backgroundColor = .systemBlue //Color.Cust.labelColor1
                self.tableView!.tableHeaderView = nil //header.header
                
                return header.contentView
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var deleteStr : String?
            if (defaults.bool(forKey: "parsedataKey")) {
                deleteStr = ((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!
                _feedItems.removeObject(at: indexPath.row)
            } else {
                //firebase
                deleteStr = custlist[indexPath.row].custId!
                self.custlist.remove(at: indexPath.row)
            }
            self.deleteData(name: deleteStr!)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.refreshData(self)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
}

extension Customer: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)    }
}


