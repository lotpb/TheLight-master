//
//  Employee.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/24/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

@available(iOS 13.0, *)
final class Employee: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [EmployModel]()
    private let searchScope = ["name", "city", "phone", "title"]
    
    //firebase
    private var employlist = [EmployModel]()
    private var activeCount: Int?
    private var defaults = UserDefaults.standard
    //parse
    private var _feedItems = NSMutableArray()
    private var _feedheadItems = NSMutableArray()

    private var pasteBoard = UIPasteboard.general
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.Employ.navColor
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
        
        tableView!.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(Employee.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationController?.navigationBar.barTintColor = .black
        } else {
            navigationController?.navigationBar.barTintColor = ColorX.Employ.navColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        navigationItem.title = "Employee"
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
        if (lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        lastContentOffset = scrollView.contentOffset.y;
    }
    
    // MARK: - refresh
    @objc func refreshData(_ sender:AnyObject) {
        employlist  .removeAll() // FIXME: shouldn't crash
        loadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newData() {
        self.performSegue(withIdentifier: "newemploySegue", sender: self)
    }

    // MARK: - Parse
    func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFQuery(className:"Employee")
            query.limit = 100
            query.order(byAscending: "createdAt")
            query.cachePolicy = .cacheThenNetwork
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error7")
                }
            }
            
            let query1 = PFQuery(className:"Employee")
            query1.whereKey("Active", equalTo:1)
            query1.cachePolicy = .cacheThenNetwork
            //query1.orderByDescending("createdAt")
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error8")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Employee").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let employTxt = EmployModel(dictionary: dictionary)
                self.employlist.append(employTxt)
                
                self.employlist.sort(by: { (p1, p2) -> Bool in
                    return p1.lastname.compare(p2.lastname) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("Employee")
                .queryOrdered(byChild: "active")
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
                
                let query = PFQuery(className:"Employee")
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
                FirebaseRef.databaseRoot.child("Employee").child(name).removeValue(completionBlock: { (error, ref) in
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
        alert.addAction(cancelAction)
        alert.addAction(destroyAction)
        self.present(alert, animated: true) {
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "employdetailSegue" {
            
            MasterViewController.numberFormatter.numberStyle = .none
            
            let VC = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            VC.formController = "Employee"
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
                indexPath = resultsController.tableView!.indexPathForSelectedRow!.row
                
                dateUpdated = filteredTitles[indexPath!].lastUpdate
                LeadNo = filteredTitles[indexPath!].employeeNo as? Int
                Zip = filteredTitles[indexPath!].zip as? Int
                Active = filteredTitles[indexPath!].active as? Int
                
            } else {
                
                indexPath = tableView?.indexPathForSelectedRow?.row
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    
                    dateUpdated = (_feedItems[indexPath!] as AnyObject).value(forKey: "updatedAt") as! Date
                    LeadNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "EmployeeNo") as? Int
                    Zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip")as? Int
                    Active = (_feedItems[indexPath!] as AnyObject).value(forKey: "Active")as? Int
                    
                } else {
                    
                    dateUpdated = employlist[indexPath!].lastUpdate
                    LeadNo = employlist[indexPath!].employeeNo as? Int
                    Zip = employlist[indexPath!].zip as? Int
                    Active = employlist[indexPath!].active as? Int
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
                let employ: EmployModel
                employ = filteredTitles[indexPath!]
                
                VC.leadNo =  MasterViewController.numberFormatter.string(from: LeadNo! as NSNumber)
                VC.active = MasterViewController.numberFormatter.string(from: Active! as NSNumber)
                VC.zip = MasterViewController.numberFormatter.string(from: Zip! as NSNumber)
                VC.objectId = employlist[indexPath!].employeeId
                VC.date = employlist[indexPath!].email
                VC.name = String(format: "%@ %@ %@", employ.first, employ.lastname, employ.company).removeWhiteSpace()
                VC.address = employ.address
                VC.city = employ.city
                VC.state = employ.state
                VC.amount = employ.country
                VC.tbl11 = employ.homephone
                VC.tbl12 = employ.workphone
                VC.tbl13 = employ.cellphone
                VC.tbl14 = employ.ss
                VC.tbl15 = employ.middle as NSString
                VC.tbl21 = employ.email as NSString
                VC.tbl22 = employ.department
                VC.tbl23 = employ.title
                VC.tbl24 = employ.manager
                VC.tbl25 = employ.country
                VC.tbl26 = employ.first as NSString
                VC.tbl27 = employ.company
                VC.custNo = employ.lastname
                VC.comments = employ.comments
                
            } else {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    
                    VC.leadNo =  MasterViewController.numberFormatter.string(from: LeadNo! as NSNumber)
                    VC.active = MasterViewController.numberFormatter.string(from: Active! as NSNumber)
                    VC.objectId = (_feedItems[indexPath!] as AnyObject).value(forKey: "objectId") as? String
                    VC.date = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? String
                    VC.name = String(format: "%@ %@ %@", ((_feedItems[indexPath!] as AnyObject).value(forKey: "First") as? String)!, ((_feedItems[indexPath!] as AnyObject).value(forKey: "Last") as? String)!, ((_feedItems[indexPath!] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
                    VC.address = (_feedItems[indexPath!] as AnyObject).value(forKey: "Street") as? String
                    VC.city = (_feedItems[indexPath!] as AnyObject).value(forKey: "City") as? String
                    VC.state = (_feedItems[indexPath!] as AnyObject).value(forKey: "State") as? String
                    VC.zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip") as? String
                    VC.amount = (_feedItems[indexPath!] as AnyObject).value(forKey: "Title") as? String
                    VC.tbl11 = (_feedItems[indexPath!] as AnyObject).value(forKey: "HomePhone") as? String
                    VC.tbl12 = (_feedItems[indexPath!] as AnyObject).value(forKey: "WorkPhone") as? String
                    VC.tbl13 = (_feedItems[indexPath!] as AnyObject).value(forKey: "CellPhone") as? String
                    VC.tbl14 = (_feedItems[indexPath!] as AnyObject).value(forKey: "SS") as? String
                    VC.tbl15 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Middle") as? NSString
                    VC.tbl21 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? NSString
                    VC.tbl22 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Department") as? String
                    VC.tbl23 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Title") as? String
                    VC.tbl24 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Manager") as? String
                    VC.tbl25 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Country") as? String
                    VC.tbl26 = (_feedItems[indexPath!] as AnyObject).value(forKey: "First") as? NSString
                    VC.tbl27 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Company") as? String
                    VC.custNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "Last") as? String
                    VC.comments = (_feedItems[indexPath!] as AnyObject).value(forKey: "Comments") as? String
                    
                } else {
                    
                    //firebase
                    VC.leadNo =  MasterViewController.numberFormatter.string(from: LeadNo! as NSNumber)
                    VC.active = MasterViewController.numberFormatter.string(from: Active! as NSNumber)
                    VC.zip = MasterViewController.numberFormatter.string(from: Zip! as NSNumber)
                    VC.objectId = employlist[indexPath!].employeeId
                    VC.leadNo = employlist[indexPath!].employeeId
                    VC.date = employlist[indexPath!].email
                    VC.first = employlist[indexPath!].first
                    VC.lastname = employlist[indexPath!].lastname
                    VC.company = employlist[indexPath!].company
                    VC.name = String(format: "%@ %@ %@", employlist[indexPath!].first, employlist[indexPath!].lastname, employlist[indexPath!].company).removeWhiteSpace()
                    VC.address = employlist[indexPath!].address
                    VC.city = employlist[indexPath!].city
                    VC.state = employlist[indexPath!].state
                    VC.amount = employlist[indexPath!].title
                    VC.tbl11 = employlist[indexPath!].homephone
                    VC.tbl12 = employlist[indexPath!].workphone
                    VC.tbl13 = employlist[indexPath!].cellphone
                    VC.tbl14 = employlist[indexPath!].ss
                    VC.tbl15 = employlist[indexPath!].middle as NSString
                    VC.tbl16 = MasterViewController.dateFormatter.string(from: employlist[indexPath!].lastUpdate as Date) as String
                    VC.tbl17 = employlist[indexPath!].photo
                    VC.tbl21 = employlist[indexPath!].email as NSString
                    VC.tbl22 = employlist[indexPath!].department
                    VC.tbl23 = employlist[indexPath!].title
                    VC.tbl24 = employlist[indexPath!].manager
                    VC.tbl25 = employlist[indexPath!].country
                    VC.tbl26 = employlist[indexPath!].first as NSString
                    VC.tbl27 = employlist[indexPath!].uid
                    VC.custNo = employlist[indexPath!].lastname
                    VC.imageUrl = employlist[indexPath!].imageUrl
                    VC.photo = employlist[indexPath!].photo
                    VC.comments = employlist[indexPath!].comments
                }
            }
            
            VC.l11 = "Home"; VC.l12 = "Work"
            VC.l13 = "Mobile"; VC.l14 = "Social"
            VC.l15 = "Middle"; VC.l21 = "Email"
            VC.l22 = "Department"; VC.l23 = "Title"
            VC.l24 = "Manager"; VC.l25 = "Country"
            VC.l16 = "Last Updated"; VC.l26 = "First"
            VC.l17 = "photo"; VC.l27 = "uid"
            VC.l1datetext = "Email:"
            VC.lnewsTitle = "Employee News: Health benifits cancelled immediately, ineffect starting today."
        }
        
        if segue.identifier == "newemploySegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! EditData
            controller.formController = "Employee"
            controller.status = "New"
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    // MARK: - search
    
    func filterContentForSearchText(searchText: String, scope: String = "name") {
        
        filteredTitles = employlist.filter { (employ: EmployModel) in
            let target: String
            switch(scope.lowercased()) {
            case "name":
                target = String(format: "%@ %@ %@", employ.first, employ.lastname, employ.company).removeWhiteSpace()
            case "city":
                target = employ.city
            case "phone":
                target = employ.homephone
            case "title":
                target = employ.title // FIXME: shouldn't crash
            default:
                target = String(format: "%@ %@ %@", employ.first, employ.lastname, employ.company).removeWhiteSpace()
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
extension Employee: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "employdetailSegue", sender: self)
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
                return employlist.count
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
                
                cell.employtitleLabel!.font = Font.celltitle20m
                cell.employsubtitleLabel!.font = Font.celltitle16r
                cell.employlikeLabel!.font = Font.celltitle16r
                
            } else {
                
                cell.employtitleLabel!.font = Font.celltitle20m
                cell.employsubtitleLabel!.font = Font.celltitle16r
                cell.employlikeLabel!.font = Font.celltitle16r
            }
            
            cell.selectionStyle = .none
            cell.employtitleLabel.textColor = .label
            cell.employsubtitleLabel!.textColor = .systemGray
            cell.employreplyButton.tintColor = .lightGray
            cell.employreplyButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
            cell.employreplyLabel.text! = ""
            
            
            cell.employlikeButton.tintColor = .lightGray
            cell.employlikeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            
            cell.customImagelabel.text = "Employ"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.frame = .init(x: 10, y: 10, width: 50, height: 50)
            cell.customImagelabel.backgroundColor = ColorX.Employ.labelColor
            cell.customImagelabel.layer.cornerRadius = 25.0
            cell.customImagelabel.adjustsFontSizeToFitWidth = true
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                cell.employtitleLabel!.text = String(format: "%@ %@ %@", ((_feedItems[indexPath.row] as AnyObject).value(forKey: "First") as? String)!,
                                                     ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!,
                                                     ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
                cell.employsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Title") as? String
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == "") {
                    cell.employreplyButton!.tintColor = .lightGray
                } else {
                    cell.employreplyButton!.tintColor = ColorX.Employ.buttonColor
                }
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
                    cell.employlikeButton!.tintColor = ColorX.Employ.buttonColor
                    cell.employlikeLabel.text! = "Active"
                    cell.employlikeLabel.adjustsFontSizeToFitWidth = true
                } else {
                    cell.employlikeButton!.tintColor = .lightGray
                    cell.employlikeLabel.text! = ""
                }
            } else {
                //firebase
                cell.employpost = employlist[indexPath.row]
            }
            
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                //parse
                cell.textLabel!.text = String(format: "%@ %@ %@", ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "First") as? String)!, ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!, ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
                
            } else {
                
                let emply: EmployModel
                emply = filteredTitles[indexPath.row]
                cell.textLabel!.text = String(format: "%@ %@ %@", emply.first, emply.lastname, emply.company).removeWhiteSpace()
            }
            
            return cell
        }
    }
}
@available(iOS 13.0, *)
extension Employee: UITableViewDelegate {
    
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
                header.myLabel1.text = String(format: "%@%d", "Employ\n", _feedItems.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
            } else {
                header.myLabel1.text = String(format: "%@%d", "Employ\n", employlist.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
            }
            header.contentView.backgroundColor = ColorX.Employ.buttonColor //Color.Lead.navColor
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
                deleteStr = employlist[indexPath.row].employeeId!
                self.employlist.remove(at: indexPath.row)
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
extension Employee: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
