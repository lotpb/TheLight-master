//
//  Vendor.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/24/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

final class Vendor: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [VendModel]()
    private let searchScope = ["name", "city", "phone", "department"]
    
    //firebase
    var vendlist = [VendModel]()
    var activeCount: Int?
    var defaults = UserDefaults.standard
    //parse
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
 
    var pasteBoard = UIPasteboard.general
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.Vend.navColor
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
        NotificationCenter.default.addObserver(self, selector: #selector(Vendor.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        navigationItem.title = "Vendors"
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
        self.tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        
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
    
    // MARK: - refresh
    @objc func refreshData(_ sender:AnyObject) {
        vendlist.removeAll() //fix
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newData() {
        self.performSegue(withIdentifier: "newvendSegue", sender: self)
    }
    
    // MARK: - Parse
    func loadData() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
            let query = PFQuery(className:"Vendors")
            query.limit = 1000
            query.order(byAscending: "Vendor")
            query.cachePolicy = .cacheThenNetwork
            query.findObjectsInBackground { (objects, error)  in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                    
                } else {
                    print("Error5")
                }
            }
            
            let query1 = PFQuery(className:"Vendors")
            query1.whereKey("Active", equalTo:1)
            query1.cachePolicy = .cacheThenNetwork
            //query1.order(byDescending: "createdAt")
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error6")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Vendor")
               .observe(.childAdded , with:{ (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let post = VendModel(dictionary: dictionary)
                    self.vendlist.append(post)
                    
                    self.vendlist.sort(by: { (p1, p2) -> Bool in
                        return p1.vendor.compare(p2.vendor) == .orderedAscending
                    })
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                }) { (err) in
                    print("Failed to fetch posts:", err)
            }
            
            FirebaseRef.databaseRoot.child("Vendor")
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
                
                let query = PFQuery(className:"Vendors")
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
                FirebaseRef.databaseRoot.child("Vendor").child(name).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                })
            }
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.notificationOccurred(.success)
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

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "vendordetailSegue" {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            controller.formController = "Vendor"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            var LeadNo:Int?
            var Zip:Int?
            var Active:Int?
            var dateUpdated: Date
            var indexPath: Int?
            
            if navigationItem.searchController?.isActive == true {
                //search
                indexPath = self.resultsController.tableView?.indexPathForSelectedRow?.row
                dateUpdated = filteredTitles[indexPath!].lastUpdate
                LeadNo = filteredTitles[indexPath!].vendorNo as? Int
                Zip = filteredTitles[indexPath!].zip as? Int
                Active = filteredTitles[indexPath!].active as? Int
                
            } else {
                
                indexPath = self.tableView?.indexPathForSelectedRow?.row
                if (defaults.bool(forKey: "parsedataKey")) {
                    dateUpdated = (_feedItems[indexPath!] as AnyObject).value(forKey: "updatedAt") as! Date
                    LeadNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "VendorNo") as? Int
                    Zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip")as? Int
                    Active = (_feedItems[indexPath!] as AnyObject).value(forKey: "Active")as? Int
                    
                } else {
                    
                    dateUpdated = vendlist[indexPath!].lastUpdate
                    LeadNo = vendlist[indexPath!].vendorNo as? Int
                    Zip = vendlist[indexPath!].zip as? Int
                    Active = vendlist[indexPath!].active as? Int
                }
            }
            
            
            if LeadNo == nil {
                LeadNo = 0
            }
            if Zip == nil {
                Zip = 0
            }
            if Active == nil {
                Active = 0
            }
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            controller.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            if navigationItem.searchController?.isActive == true {
                //search
                let vend: VendModel
                vend = filteredTitles[indexPath!]
                
                controller.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                controller.active = formatter.string(from: Active! as NSNumber)
                controller.objectId = vend.vendId
                controller.date = vend.webpage
                controller.name = vend.vendor
                controller.address = vend.address
                controller.city = vend.city
                controller.state = vend.state
                controller.zip = formatter.string(from: Zip! as NSNumber)
                controller.amount = vend.profession
                controller.tbl11 = vend.phone
                controller.tbl12 = vend.phone1
                controller.tbl13 = vend.phone2
                controller.tbl14 = vend.phone3
                controller.tbl15 = vend.assistant as NSString
                controller.tbl21 = vend.email as NSString
                controller.tbl22 = vend.department
                controller.tbl23 = vend.office
                controller.tbl24 = vend.manager
                controller.tbl25 = vend.profession
                controller.tbl26 = vend.webpage as NSString
                controller.comments = vend.comments
                
            } else {
                
                if (defaults.bool(forKey: "parsedataKey")) {
                    
                    controller.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                    controller.active = formatter.string(from: Active! as NSNumber)
                    controller.objectId = (_feedItems[indexPath!] as AnyObject).value(forKey: "objectId") as? String
                    controller.date = (_feedItems[indexPath!] as AnyObject).value(forKey: "WebPage") as? String
                    controller.name = (_feedItems[indexPath!] as AnyObject).value(forKey: "Vendor") as? String
                    controller.address = (_feedItems[indexPath!] as AnyObject).value(forKey: "Address") as? String
                    controller.city = (_feedItems[indexPath!] as AnyObject).value(forKey: "City") as? String
                    controller.state = (_feedItems[indexPath!] as AnyObject).value(forKey: "State") as? String
                    controller.zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip") as? String
                    controller.amount = (_feedItems[indexPath!] as AnyObject).value(forKey: "Profession") as? String
                    controller.tbl11 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone") as? String
                    controller.tbl12 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone1") as? String
                    controller.tbl13 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone2") as? String
                    controller.tbl14 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone3") as? String
                    controller.tbl15 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Assistant") as? NSString
                    controller.tbl21 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? NSString
                    controller.tbl22 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Department") as? String
                    controller.tbl23 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Office") as? String
                    controller.tbl24 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Manager") as? String
                    controller.tbl25 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Profession") as? String
                    controller.tbl26 = (_feedItems[indexPath!] as AnyObject).value(forKey: "WebPage") as? NSString
                    controller.comments = (_feedItems[indexPath!] as AnyObject).value(forKey: "Comments") as? String
                } else {
                    
                    //firebase
                    controller.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                    controller.active = formatter.string(from: Active! as NSNumber)
                    controller.objectId = vendlist[indexPath!].vendId
                    controller.date = vendlist[indexPath!].webpage
                    controller.name = vendlist[indexPath!].vendor
                    controller.address = vendlist[indexPath!].address
                    controller.city = vendlist[indexPath!].city
                    controller.state = vendlist[indexPath!].state
                    controller.zip = formatter.string(from: Zip! as NSNumber)
                    controller.amount = vendlist[indexPath!].profession
                    controller.tbl11 = vendlist[indexPath!].phone
                    controller.tbl12 = vendlist[indexPath!].phone1
                    controller.tbl13 = vendlist[indexPath!].phone2
                    controller.tbl14 = vendlist[indexPath!].phone3
                    controller.tbl15 = vendlist[indexPath!].assistant as NSString
                    controller.tbl21 = vendlist[indexPath!].email as NSString
                    controller.tbl22 = vendlist[indexPath!].department
                    controller.tbl23 = vendlist[indexPath!].office
                    controller.tbl24 = vendlist[indexPath!].manager
                    controller.tbl25 = vendlist[indexPath!].profession
                    controller.tbl26 = vendlist[indexPath!].webpage as NSString
                    controller.comments = vendlist[indexPath!].comments
                }
            }

            controller.l11 = "Phone"; controller.l12 = "Phone1"
            controller.l13 = "Phone2"; controller.l14 = "Phone3"
            controller.l15 = "Assistant"; controller.l21 = "Email"
            controller.l22 = "Department"; controller.l23 = "Office"
            controller.l24 = "Manager"; controller.l25 = "Profession"
            controller.l16 = "Last Updated"; controller.l26 = "Web Page"
            controller.l1datetext = "Web Page:"
            controller.lnewsTitle = Config.NewsVend
        }
        
        if segue.identifier == "newvendSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! EditData
            controller.formController = "Vendor"
            controller.status = "New"
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
    // MARK: - search
    func filterContentForSearchText(searchText: String, scope: String = "name") {
        
        filteredTitles = vendlist.filter { (vend: VendModel) in
            let target: String
            switch(scope.lowercased()) {
            case "name":
                target = vend.vendor
            case "city":
                target = vend.city
            case "phone":
                target = vend.phone
            case "department":
                target = vend.department
            default:
                target = vend.vendor
            }
            return target.lowercased().contains(searchText.lowercased())
        }
        
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
        }
    }
}
//-----------------------end------------------------------
extension Vendor: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "vendordetailSegue", sender: self)
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
                return vendlist.count
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
                
                cell.vendtitleLabel!.font = Font.celltitle20m
                cell.vendsubtitleLabel!.font = Font.celltitle16r
                cell.vendlikeLabel.font = Font.celltitle16r
                
            } else {
                
                cell.vendtitleLabel!.font = Font.celltitle20m
                cell.vendsubtitleLabel!.font = Font.celltitle16r
                cell.vendlikeLabel.font = Font.celltitle16r
            }
            
            cell.selectionStyle = .none
            if #available(iOS 13.0, *) {
                cell.vendtitleLabel.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            cell.vendsubtitleLabel!.textColor = .systemGray
            cell.vendreplyButton.tintColor = .lightGray
            cell.vendreplyButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
            cell.vendreplyLabel.text! = ""
            
            cell.vendlikeButton.tintColor = .lightGray
            cell.vendlikeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            
            cell.customImagelabel.text = "Vend"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.frame = .init(x: 10, y: 10, width: 50, height: 50)
            cell.customImagelabel.backgroundColor = Color.Vend.labelColor
            cell.customImagelabel.layer.cornerRadius = 25.0
            
            if (defaults.bool(forKey: "parsedataKey")) {
                
                cell.vendtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Vendor") as? String
                cell.vendsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Profession") as? String
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == "") {
                    cell.vendreplyButton!.tintColor = .lightGray
                } else {
                    cell.vendreplyButton!.tintColor = Color.Vend.buttonColor
                }
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
                    cell.vendlikeButton!.tintColor = Color.Vend.buttonColor
                    cell.vendlikeLabel.text! = "Active"
                    cell.vendlikeLabel.adjustsFontSizeToFitWidth = true
                } else {
                    cell.vendlikeButton!.tintColor = .lightGray
                    cell.vendlikeLabel.text! = ""
                }
                
            } else {
                //firebase
                cell.vendpost = vendlist[indexPath.row]
            }
            
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if (defaults.bool(forKey: "parsedataKey")) {
                //parse
                cell.textLabel!.text = (filteredTitles[indexPath.row] as AnyObject).value(forKey: "Vendor") as? String
                
            } else {
                
                let vend: VendModel
                vend = filteredTitles[indexPath.row]
                cell.textLabel!.text = vend.vendor
            }
            
            return cell
        }
    }
    
}
extension Vendor: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.tableView) {
            if UIDevice.current.userInterfaceIdiom == .phone  {
                return 85.0
            } else {
                return CGFloat.leastNormalMagnitude
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (tableView == self.tableView) {
            guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
            
            if (defaults.bool(forKey: "parsedataKey")) {
                header.myLabel1.text = String(format: "%@%d", "Vendor\n", _feedItems.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 0)
            } else {
                header.myLabel1.text = String(format: "%@%d", "Vendor\n", vendlist.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 0)
            }
            header.contentView.backgroundColor = Color.Vend.buttonColor//.secondarySystemFill //Color.Lead.navColor
            self.tableView!.tableHeaderView = nil //header.header
            
            return header.contentView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var deleteStr : String?
            if (defaults.bool(forKey: "parsedataKey")) {
                deleteStr = ((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!
                _feedItems.removeObject(at: indexPath.row)
            } else {
                //firebase
                deleteStr = vendlist[indexPath.row].vendId!
                self.vendlist.remove(at: indexPath.row)
            }
            self.deleteData(name: deleteStr!)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.refreshData(self)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Content Menu
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        if (action == #selector(NSObject.copy)) {
            return true
        }
        return false
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
}
extension Vendor: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
