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


@available(iOS 13.0, *)
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
    private var vendlist = [VendModel]()
    private var activeCount: Int?
    private var defaults = UserDefaults.standard
    //parse
    private var _feedItems = NSMutableArray()
    private var _feedheadItems = NSMutableArray()
 
    private var pasteBoard = UIPasteboard.general
    
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
        
        tableView!.addSubview(refreshControl)
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
        self.definesPresentationContext = true
    }
    
    func setupTableView() {
        // MARK: - TableHeader
        tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.sizeToFit()
        tableView!.clipsToBounds = true
        let bgView = UIView()
        bgView.backgroundColor = .secondarySystemGroupedBackground
        tableView!.backgroundView = bgView
        tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = ColorX.LGrayColor
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
            navigationController?.setNavigationBarHidden(state, animated: true)
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
        vendlist.removeAll() // FIXME: shouldn't crash
        loadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newData() {
        self.performSegue(withIdentifier: "newvendSegue", sender: self)
    }
    
    // MARK: - Parse
    func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
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
        
        let alert = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
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
        alert.addAction(cancelAction)
        alert.addAction(destroyAction)
        self.present(alert, animated: true) {
        }
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        MasterViewController.dateFormatter.dateFormat = "MMM dd yyyy"
        if segue.identifier == "vendordetailSegue" {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let VC = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            VC.formController = "Vendor"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
            
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
                
                indexPath = tableView?.indexPathForSelectedRow?.row
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
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

            VC.tbl16 = String(format: "%@", MasterViewController.dateFormatter.string(from: dateUpdated)) as String
            
            if navigationItem.searchController?.isActive == true {
                //search
                let vend: VendModel
                vend = filteredTitles[indexPath!]
                
                VC.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                VC.active = formatter.string(from: Active! as NSNumber)
                VC.objectId = vend.vendId
                VC.date = vend.webpage
                VC.name = vend.vendor
                VC.address = vend.address
                VC.city = vend.city
                VC.state = vend.state
                VC.zip = formatter.string(from: Zip! as NSNumber)
                VC.amount = vend.profession
                VC.tbl11 = vend.phone
                VC.tbl12 = vend.phone1
                VC.tbl13 = vend.phone2
                VC.tbl14 = vend.phone3
                VC.tbl15 = vend.assistant as NSString
                VC.tbl21 = vend.email as NSString
                VC.tbl22 = vend.department
                VC.tbl23 = vend.office
                VC.tbl24 = vend.manager
                VC.tbl25 = vend.profession
                VC.tbl26 = vend.webpage as NSString
                VC.comments = vend.comments
                VC.photo = vend.photo
                
            } else {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    
                    VC.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                    VC.active = formatter.string(from: Active! as NSNumber)
                    VC.objectId = (_feedItems[indexPath!] as AnyObject).value(forKey: "objectId") as? String
                    VC.date = (_feedItems[indexPath!] as AnyObject).value(forKey: "WebPage") as? String
                    VC.name = (_feedItems[indexPath!] as AnyObject).value(forKey: "Vendor") as? String
                    VC.address = (_feedItems[indexPath!] as AnyObject).value(forKey: "Address") as? String
                    VC.city = (_feedItems[indexPath!] as AnyObject).value(forKey: "City") as? String
                    VC.state = (_feedItems[indexPath!] as AnyObject).value(forKey: "State") as? String
                    VC.zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip") as? String
                    VC.amount = (_feedItems[indexPath!] as AnyObject).value(forKey: "Profession") as? String
                    VC.tbl11 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone") as? String
                    VC.tbl12 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone1") as? String
                    VC.tbl13 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone2") as? String
                    VC.tbl14 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone3") as? String
                    VC.tbl15 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Assistant") as? NSString
                    VC.tbl21 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? NSString
                    VC.tbl22 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Department") as? String
                    VC.tbl23 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Office") as? String
                    VC.tbl24 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Manager") as? String
                    VC.tbl25 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Profession") as? String
                    VC.tbl26 = (_feedItems[indexPath!] as AnyObject).value(forKey: "WebPage") as? NSString
                    VC.comments = (_feedItems[indexPath!] as AnyObject).value(forKey: "Comments") as? String
                } else {
                    
                    //firebase
                    VC.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                    VC.active = formatter.string(from: Active! as NSNumber)
                    VC.leadNo = vendlist[indexPath!].vendId
                    VC.objectId = vendlist[indexPath!].vendId
                    VC.date = vendlist[indexPath!].webpage
                    VC.name = vendlist[indexPath!].vendor
                    VC.address = vendlist[indexPath!].address
                    VC.city = vendlist[indexPath!].city
                    VC.state = vendlist[indexPath!].state
                    VC.zip = formatter.string(from: Zip! as NSNumber)
                    VC.amount = vendlist[indexPath!].profession
                    VC.tbl11 = vendlist[indexPath!].phone
                    VC.tbl12 = vendlist[indexPath!].phone1
                    VC.tbl13 = vendlist[indexPath!].phone2
                    VC.tbl14 = vendlist[indexPath!].phone3
                    VC.tbl15 = vendlist[indexPath!].assistant as NSString
                    VC.tbl16 = MasterViewController.dateFormatter.string(from: vendlist[indexPath!].lastUpdate as Date) as String
                    VC.tbl21 = vendlist[indexPath!].email as NSString
                    VC.tbl22 = vendlist[indexPath!].department
                    VC.tbl23 = vendlist[indexPath!].office
                    VC.tbl24 = vendlist[indexPath!].manager
                    VC.tbl25 = vendlist[indexPath!].profession
                    VC.tbl26 = vendlist[indexPath!].webpage as NSString
                    VC.tbl17 = vendlist[indexPath!].photo
                    VC.tbl27 = vendlist[indexPath!].uid
                    VC.photo = vendlist[indexPath!].photo
                    VC.comments = vendlist[indexPath!].comments
                }
            }

            VC.l11 = "Phone"; VC.l12 = "Phone1"
            VC.l13 = "Phone2"; VC.l14 = "Phone3"
            VC.l15 = "Assistant"; VC.l21 = "Email"
            VC.l22 = "Department"; VC.l23 = "Office"
            VC.l24 = "Manager"; VC.l25 = "Profession"
            VC.l16 = "Last Updated"; VC.l26 = "Web Page"
            VC.l17 = "Photo"; VC.l27 = "uid"
            VC.l1datetext = "Web Page:"
            VC.lnewsTitle = Config.NewsVend
        }
        
        if segue.identifier == "newvendSegue" {
            let VC = (segue.destination as! UINavigationController).topViewController as! EditData
            VC.formController = "Vendor"
            VC.status = "New"
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
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
@available(iOS 13.0, *)
extension Vendor: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "vendordetailSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
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
            cell.vendtitleLabel.textColor = .label
            cell.vendsubtitleLabel!.textColor = .systemGray
            cell.vendreplyButton.tintColor = .lightGray
            cell.vendreplyButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
            cell.vendreplyLabel.text! = ""
            
            cell.vendlikeButton.tintColor = .lightGray
            cell.vendlikeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            
            cell.customImagelabel.text = "Vend"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.frame = .init(x: 10, y: 10, width: 50, height: 50)
            cell.customImagelabel.backgroundColor = ColorX.Vend.labelColor
            cell.customImagelabel.layer.cornerRadius = 25.0
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                cell.vendtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Vendor") as? String
                cell.vendsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Profession") as? String
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == "") {
                    cell.vendreplyButton!.tintColor = .lightGray
                } else {
                    cell.vendreplyButton!.tintColor = ColorX.Vend.buttonColor
                }
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
                    cell.vendlikeButton!.tintColor = ColorX.Vend.buttonColor
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
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
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
@available(iOS 13.0, *)
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
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                header.myLabel1.text = String(format: "%@%d", "Vendor\n", _feedItems.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 0)
            } else {
                header.myLabel1.text = String(format: "%@%d", "Vendor\n", vendlist.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 0)
            }
            header.contentView.backgroundColor = ColorX.Vend.buttonColor//.secondarySystemFill //Color.Lead.navColor
            tableView.tableHeaderView = nil //header.header
            
            return header.contentView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var deleteStr : String?
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
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
@available(iOS 13.0, *)
extension Vendor: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
