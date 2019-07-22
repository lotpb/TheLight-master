//
//  Employee.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/24/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
//import SwiftUI
import Parse
import FirebaseDatabase

class Employee: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [EmployModel]()
    private let searchScope = ["name", "city", "phone", "title"]
    
    //firebase
    var employlist = [EmployModel]()
    var activeCount: Int?
    var defaults = UserDefaults.standard
    //parse
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()

    var pasteBoard = UIPasteboard.general
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.Employ.navColor
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
        NotificationCenter.default.addObserver(self, selector: #selector(Employee.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.Employ.navColor
        }
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
            self.tableView!.backgroundColor = .systemGray4
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
        employlist  .removeAll() //fix
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newData() {
        self.performSegue(withIdentifier: "newemploySegue", sender: self)
    }

    // MARK: - Parse
    func loadData() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
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
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
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
        alertController.addAction(cancelAction)
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "employdetailSegue" {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            controller.formController = "Employee"
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
                indexPath = resultsController.tableView!.indexPathForSelectedRow!.row
                
                dateUpdated = filteredTitles[indexPath!].lastUpdate
                LeadNo = filteredTitles[indexPath!].employeeNo as? Int
                Zip = filteredTitles[indexPath!].zip as? Int
                Active = filteredTitles[indexPath!].active as? Int
                
            } else {
                
                indexPath = self.tableView?.indexPathForSelectedRow?.row
                if (defaults.bool(forKey: "parsedataKey")) {
                    
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
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            controller.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            if navigationItem.searchController?.isActive == true {
                //search
                let employ: EmployModel
                employ = filteredTitles[indexPath!]
                
                controller.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                controller.active = formatter.string(from: Active! as NSNumber)
                controller.zip = formatter.string(from: Zip! as NSNumber)
                controller.objectId = employlist[indexPath!].employeeId
                controller.date = employlist[indexPath!].email
                controller.name = String(format: "%@ %@ %@", employ.first, employ.lastname, employ.company).removeWhiteSpace()
                controller.address = employ.address
                controller.city = employ.city
                controller.state = employ.state
                controller.amount = employ.country
                controller.tbl11 = employ.homephone
                controller.tbl12 = employ.workphone
                controller.tbl13 = employ.cellphone
                controller.tbl14 = employ.ss
                controller.tbl15 = employ.middle as NSString
                controller.tbl21 = employ.email as NSString
                controller.tbl22 = employ.department
                controller.tbl23 = employ.title
                controller.tbl24 = employ.manager
                controller.tbl25 = employ.country
                controller.tbl26 = employ.first as NSString
                controller.tbl27 = employ.company
                controller.custNo = employ.lastname
                controller.comments = employ.comments
                
            } else {
                
                if (defaults.bool(forKey: "parsedataKey")) {
                    
                    controller.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                    controller.active = formatter.string(from: Active! as NSNumber)
                    controller.objectId = (_feedItems[indexPath!] as AnyObject).value(forKey: "objectId") as? String
                    controller.date = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? String
                    controller.name = String(format: "%@ %@ %@", ((_feedItems[indexPath!] as AnyObject).value(forKey: "First") as? String)!, ((_feedItems[indexPath!] as AnyObject).value(forKey: "Last") as? String)!, ((_feedItems[indexPath!] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
                    controller.address = (_feedItems[indexPath!] as AnyObject).value(forKey: "Street") as? String
                    controller.city = (_feedItems[indexPath!] as AnyObject).value(forKey: "City") as? String
                    controller.state = (_feedItems[indexPath!] as AnyObject).value(forKey: "State") as? String
                    controller.zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip") as? String
                    controller.amount = (_feedItems[indexPath!] as AnyObject).value(forKey: "Title") as? String
                    controller.tbl11 = (_feedItems[indexPath!] as AnyObject).value(forKey: "HomePhone") as? String
                    controller.tbl12 = (_feedItems[indexPath!] as AnyObject).value(forKey: "WorkPhone") as? String
                    controller.tbl13 = (_feedItems[indexPath!] as AnyObject).value(forKey: "CellPhone") as? String
                    controller.tbl14 = (_feedItems[indexPath!] as AnyObject).value(forKey: "SS") as? String
                    controller.tbl15 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Middle") as? NSString
                    controller.tbl21 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? NSString
                    controller.tbl22 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Department") as? String
                    controller.tbl23 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Title") as? String
                    controller.tbl24 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Manager") as? String
                    controller.tbl25 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Country") as? String
                    controller.tbl26 = (_feedItems[indexPath!] as AnyObject).value(forKey: "First") as? NSString
                    controller.tbl27 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Company") as? String
                    controller.custNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "Last") as? String
                    controller.comments = (_feedItems[indexPath!] as AnyObject).value(forKey: "Comments") as? String
                    
                } else {
                    
                    //firebase
                    controller.leadNo =  formatter.string(from: LeadNo! as NSNumber)
                    controller.active = formatter.string(from: Active! as NSNumber)
                    controller.zip = formatter.string(from: Zip! as NSNumber)
                    controller.objectId = employlist[indexPath!].employeeId
                    controller.date = employlist[indexPath!].email
                    controller.name = String(format: "%@ %@ %@", employlist[indexPath!].first, employlist[indexPath!].lastname, employlist[indexPath!].company).removeWhiteSpace()
                    controller.address = employlist[indexPath!].address
                    controller.city = employlist[indexPath!].city
                    controller.state = employlist[indexPath!].state
                    controller.amount = employlist[indexPath!].title
                    controller.tbl11 = employlist[indexPath!].homephone
                    controller.tbl12 = employlist[indexPath!].workphone
                    controller.tbl13 = employlist[indexPath!].cellphone
                    controller.tbl14 = employlist[indexPath!].ss
                    controller.tbl15 = employlist[indexPath!].middle as NSString
                    controller.tbl21 = employlist[indexPath!].email as NSString
                    controller.tbl22 = employlist[indexPath!].department
                    controller.tbl23 = employlist[indexPath!].title
                    controller.tbl24 = employlist[indexPath!].manager
                    controller.tbl25 = employlist[indexPath!].country
                    controller.tbl26 = employlist[indexPath!].first as NSString
                    controller.tbl27 = employlist[indexPath!].company
                    controller.custNo = employlist[indexPath!].lastname
                    controller.comments = employlist[indexPath!].comments
                }
            }
            
            controller.l11 = "Home"; controller.l12 = "Work"
            controller.l13 = "Mobile"; controller.l14 = "Social"
            controller.l15 = "Middle"; controller.l21 = "Email"
            controller.l22 = "Department"; controller.l23 = "Title"
            controller.l24 = "Manager"; controller.l25 = "Country"
            controller.l16 = "Last Updated"; controller.l26 = "First"
            controller.l1datetext = "Email:"
            controller.lnewsTitle = "Employee News: Health benifits cancelled immediately, ineffect starting today."
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
                target = employ.title //fix
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
extension Employee: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "employdetailSegue", sender: self)
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
            if #available(iOS 13.0, *) {
                cell.employtitleLabel.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            cell.employsubtitleLabel!.textColor = .systemGray
            cell.employreplyButton.tintColor = .lightGray
            cell.employreplyButton.setImage(#imageLiteral(resourceName: "Commentfilled").withRenderingMode(.alwaysTemplate), for: .normal)
            cell.employreplyLabel.text! = ""
            
            cell.employlikeButton.tintColor = .lightGray
            cell.employlikeButton.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
            
            cell.customImagelabel.text = "Employ"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.frame = .init(x: 10, y: 10, width: 50, height: 50)
            cell.customImagelabel.backgroundColor = Color.Employ.labelColor
            cell.customImagelabel.layer.cornerRadius = 25.0
            
            if (defaults.bool(forKey: "parsedataKey")) {
                
                cell.employtitleLabel!.text = String(format: "%@ %@ %@", ((_feedItems[indexPath.row] as AnyObject).value(forKey: "First") as? String)!,
                                                     ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!,
                                                     ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
                cell.employsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Title") as? String
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == "") {
                    cell.employreplyButton!.tintColor = .lightGray
                } else {
                    cell.employreplyButton!.tintColor = Color.Employ.buttonColor
                }
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
                    cell.employlikeButton!.tintColor = Color.Employ.buttonColor
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
            
            if (defaults.bool(forKey: "parsedataKey")) {
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
            
            if (defaults.bool(forKey: "parsedataKey")) {
                header.myLabel1.text = String(format: "%@%d", "Employ\n", _feedItems.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
            } else {
                header.myLabel1.text = String(format: "%@%d", "Employ\n", employlist.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
            }
            header.separatorView1.backgroundColor = Color.Employ.buttonColor
            header.separatorView2.backgroundColor = Color.Employ.buttonColor
            header.separatorView3.backgroundColor = Color.Employ.buttonColor
            header.contentView.backgroundColor = Color.Lead.navColor
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
extension Employee: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
