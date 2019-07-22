//
//  AdController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/8/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

class AdVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0

    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [AdModel]()
    private let searchScope = ["advertiser", "adNo", "active"]
    
    //firebase
    var adlist = [AdModel]()
    var activeCount: Int?
    var defaults = UserDefaults.standard
    //parse
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()

    var isFormStat = false
    var pasteBoard = UIPasteboard.general
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Table.navColor
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
        loadData()
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
        self.tabBarController?.tabBar.isHidden = false
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(AdVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        navigationItem.title = "Advertisers"
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
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = Color.LGrayColor
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
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
    
    // MARK: - Refresh
    @objc func refreshData(_ sender: AnyObject) {
        adlist.removeAll() //fix
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newData() {
        isFormStat = true
        self.performSegue(withIdentifier: "adDetailSegue", sender: self)
    }
    
    // MARK: - Parse
    func loadData() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
            let query = PFQuery(className:"Advertising")
            query.limit = 1000
            query.order(byAscending: "Advertiser")
            query.cachePolicy = .cacheThenNetwork
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query1 = PFQuery(className:"Advertising")
            query1.whereKey("Active", equalTo:"Active")
            query1.cachePolicy = .cacheThenNetwork
            query1.order(byDescending: "createdAt")
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Advertising").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let adTxt = AdModel(dictionary: dictionary)
                self.adlist.append(adTxt)
                
                self.adlist.sort(by: { (p1, p2) -> Bool in
                    return p1.advertiser.compare(p2.advertiser) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("Advertising")
                .queryOrdered(byChild: "active") //inludes reply likes
                .queryStarting(atValue: "Active")
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
                
                let query = PFQuery(className:"Advertising")
                query.whereKey("objectId", equalTo: name)
                query.findObjectsInBackground(block: { objects, error in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
                        }
                    }
                })
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Advertising").child(name).removeValue(completionBlock: { (error, ref) in
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
        
        if segue.identifier == "adDetailSegue" {
            let VC = (segue.destination as! UINavigationController).topViewController as! NewEditData
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
            
            VC.formController = "Advertiser"
            if (isFormStat == true) {
                
                VC.formStatus = "New"
                
            } else {
                
                VC.formStatus = "Edit"
                
                if navigationItem.searchController?.isActive == true {
                    //search
                    let indexPath = resultsController.tableView!.indexPathForSelectedRow!.row
                    
                    VC.objectId = filteredTitles[indexPath].adNo
                    VC.frm11 = filteredTitles[indexPath].active
                    VC.frm12 = filteredTitles[indexPath].adNo
                    VC.frm13 = filteredTitles[indexPath].advertiser
                    
                } else {
                    
                    let indexPath = self.tableView!.indexPathForSelectedRow!.row
                    if (defaults.bool(forKey: "parsedataKey")) {
                        VC.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
                        VC.frm11 = (_feedItems[indexPath] as AnyObject).value(forKey: "Active") as? String
                        VC.frm12 = (_feedItems[indexPath] as AnyObject).value(forKey: "AdNo") as? String
                        VC.frm13 = (_feedItems[indexPath] as AnyObject).value(forKey: "Advertiser") as? String
                        
                    } else {
                        //firebase
                        VC.objectId = adlist[indexPath].adNo
                        VC.frm11 = adlist[indexPath].active
                        VC.frm12 = adlist[indexPath].adNo
                        VC.frm13 = adlist[indexPath].advertiser
                    }
                }
            }
            
        }
    }
    
    // MARK: - search
    func filterContentForSearchText(searchText: String, scope: String = "advertiser") {
        
        filteredTitles = adlist.filter { (ad: AdModel) in
            let target: String
            switch(scope.lowercased()) {
            case "advertiser":
                target = ad.advertiser
            case "adNo":
                target = ad.adNo!
            case "active":
                target = ad.active
            default:
                target = ad.advertiser
            }
            return target.lowercased().contains(searchText.lowercased())
        }
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
        }
    }
}
//-----------------------end------------------------------
extension AdVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isFormStat = false
        self.performSegue(withIdentifier: "adDetailSegue", sender: self)
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
                return adlist.count
            }
        }
        return filteredTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if (tableView == self.tableView) {
            
            cellIdentifier = "Cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
            
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            cell.customImagelabel.text = "Ad"
            cell.customImagelabel.tag = indexPath.row
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                cell.adtitleLabel!.font = Font.celltitle22m
            } else {
                cell.adtitleLabel!.font = Font.celltitle20l
            }
            
            if (defaults.bool(forKey: "parsedataKey")) {
                cell.adtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String
            } else {
                //firebase
                cell.adpost = adlist[indexPath.row]
            }
            
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if (defaults.bool(forKey: "parsedataKey")) {
                //parse
                cell.textLabel!.text = (filteredTitles[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String
                
            } else {
                
                let ad: AdModel
                ad = filteredTitles[indexPath.row]
                cell.textLabel!.text = ad.advertiser
            }
            
            return cell
        }
    }
}
extension AdVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.tableView) {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return 85.0
            } else {
                return CGFloat.leastNormalMagnitude
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(section == 0) {
            if (tableView == self.tableView) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
                
                if (defaults.bool(forKey: "parsedataKey")) {
                    cell.myLabel1.text = String(format: "%@%d", "Ad's\n", _feedItems.count)
                    cell.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                    cell.myLabel3.text = String(format: "%@%d", "Event\n", 0)
                } else {
                    cell.myLabel1.text = String(format: "%@%d", "Ad's\n", adlist.count)
                    cell.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                    cell.myLabel3.text = String(format: "%@%d", "Event\n", 0)
                }
                cell.separatorView1.backgroundColor = Color.Table.labelColor
                cell.separatorView2.backgroundColor = Color.Table.labelColor
                cell.separatorView3.backgroundColor = Color.Table.labelColor
                cell.contentView.backgroundColor = Color.Table.navColor
                self.tableView!.tableHeaderView = nil //cell.header
                
                return cell.contentView
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (tableView == self.tableView) {
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
            } else {
                cell.backgroundColor = UIColor.white
            }
        }
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
                deleteStr = adlist[indexPath.row].adNo!
                self.adlist.remove(at: indexPath.row)
            }
            self.deleteData(name: deleteStr!)
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
extension AdVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
