//
//  SalesmanController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/8/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase


@available(iOS 13.0, *)
final class SalesmanVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [SalesModel]()
    private let searchScope = ["salesman", "salesNo", "active"]
    
    //firebase
    var saleslist = [SalesModel]()
    var activeCount: Int?
    var defaults = UserDefaults.standard
    //parse
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    
    var isFormStat = false
    var selectedImage: UIImage?
    var pasteBoard = UIPasteboard.general
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = ColorX.Table.navColor
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

        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(SalesmanVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

        setMainNavItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func setupNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        navigationItem.title = "Salesman"
        self.navigationItem.largeTitleDisplayMode = .always
        
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
        self.tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.sizeToFit()
        self.tableView!.clipsToBounds = true
        let bgView = UIView()
        bgView.backgroundColor = .secondarySystemGroupedBackground
        tableView!.backgroundView = bgView
        self.tableView!.tableFooterView = UIView(frame: .zero)

        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = ColorX.LGrayColor
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
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

    // MARK: - Refresh
    @objc func refreshData(_ sender: AnyObject) {
        saleslist.removeAll() //fix
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newData() {
        isFormStat = true
        self.performSegue(withIdentifier: "salesDetailSegue", sender: self)
    }
    
    // MARK: - Parse
    func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFQuery(className:"Salesman")
            query.limit = 1000
            query.order(byAscending: "Salesman")
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
            
            let query1 = PFQuery(className:"Salesman")
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
            FirebaseRef.databaseRoot.child("Salesman").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let salesTxt = SalesModel(dictionary: dictionary)
                self.saleslist.append(salesTxt)
                
                self.saleslist.sort(by: { (p1, p2) -> Bool in
                    return p1.salesman.compare(p2.salesman) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("Salesman")
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
            
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Salesman")
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
                FirebaseRef.databaseRoot.child("Salesman").child(name).removeValue(completionBlock: { (error, ref) in
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
        
        if segue.identifier == "salesDetailSegue" {
            let VC = (segue.destination as! UINavigationController).topViewController as! NewEditData
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
            
            VC.formController = "Salesman"
            if (isFormStat == true) {
                VC.formStatus = "New"
            } else {
                VC.formStatus = "Edit"
                
                if navigationItem.searchController?.isActive == true {
                    //search
                    let indexPath = resultsController.tableView!.indexPathForSelectedRow!.row
                    
                    VC.objectId = filteredTitles[indexPath].salesId
                    VC.frm11 = filteredTitles[indexPath].active
                    VC.frm12 = filteredTitles[indexPath].salesNo
                    VC.frm13 = filteredTitles[indexPath].salesman
                    VC.imageUrl = filteredTitles[indexPath].imageUrl
                } else {
                    let indexPath = self.tableView!.indexPathForSelectedRow!.row
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        VC.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
                        VC.frm11 = (_feedItems[indexPath] as AnyObject).value(forKey: "Active") as? String
                        VC.frm12 = (_feedItems[indexPath] as AnyObject).value(forKey: "SalesNo") as? String
                        VC.frm13 = (_feedItems[indexPath] as AnyObject).value(forKey: "Salesman") as? String
                        VC.image = self.selectedImage
                    } else {
                        //firebase
                        VC.objectId = saleslist[indexPath].salesId
                        VC.frm11 = saleslist[indexPath].active
                        VC.frm12 = saleslist[indexPath].salesNo
                        VC.frm13 = saleslist[indexPath].salesman
                        VC.imageUrl = saleslist[indexPath].imageUrl
                    }
                }
            }
        }
    }
    
    // MARK: - search
    func filterContentForSearchText(searchText: String, scope: String = "salesman") {
        
        filteredTitles = saleslist.filter { (sales: SalesModel) in
            let target: String
            switch(scope.lowercased()) {
            case "salesman":
                target = sales.salesman
            case "salesNo":
                target = sales.salesNo!
            case "active":
                target = sales.active
            default:
                target = sales.salesman
            }
            return target.lowercased().contains(searchText.lowercased())
        }
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
        }
    }
}
@available(iOS 13.0, *)
extension SalesmanVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.selectedImage = nil
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let imageObject = _feedItems.object(at: indexPath.row) as? PFObject
            if let imageFile = imageObject!.object(forKey: "imageFile") as? PFFileObject {
                imageFile.getDataInBackground { imageData, error in
                    self.selectedImage = UIImage(data: imageData!)
                }
            }
        } else {
            //firebase
        }
        self.performSegue(withIdentifier: "salesDetailSegue", sender: self)
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
                return saleslist.count
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
            cell.customImagelabel.text = "Sales"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.backgroundColor = .systemPurple
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                cell.customtitleLabel.font = Font.celltitle22m
            } 
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                cell.customtitleLabel.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
                let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
                let imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    UIView.transition(with: (cell.customImageView), duration: 0.5, options: .transitionCrossDissolve, animations: {
                        cell.customImageView.image = UIImage(data: imageData!) ?? UIImage(named: "profile-rabbit-toy")
                    }, completion: nil)
                }
                
            } else {
                //firebase
                cell.salespost = saleslist[indexPath.row]
            }
            
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                //parse
                cell.textLabel!.text = (filteredTitles[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
                
            } else {
                
                let sales: SalesModel
                sales = filteredTitles[indexPath.row]
                cell.textLabel!.text = sales.salesman
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.tableView) {
            if UIDevice.current.userInterfaceIdiom == .phone  {
                return 85.0
            } else {
                return CGFloat.leastNormalMagnitude
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //if(section == 0) {
        if (tableView == self.tableView) {
            guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                header.myLabel1.text = String(format: "%@%d", "Sale's\n", _feedItems.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                header.myLabel3.text = String(format: "%@%d", "Event\n", 0)
            } else {
                //firebase
                header.myLabel1.text = String(format: "%@%d", "Sale's\n", saleslist.count)
                header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                header.myLabel3.text = String(format: "%@%d", "Event\n", 0)
            }
            header.contentView.backgroundColor = .systemPurple//Color.Table.labelColor
            self.tableView!.tableHeaderView = nil //header.header
            
            return header.contentView
        } else {
            return nil
        }
        // } else {
        //   return nil
        // }
    }
}
@available(iOS 13.0, *)
extension SalesmanVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (tableView == self.tableView) {
           if indexPath.row % 2 == 0 {
                cell.backgroundColor = .systemGroupedBackground
            } else {
                cell.backgroundColor = .secondarySystemGroupedBackground
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
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                deleteStr = ((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!
                _feedItems.removeObject(at: indexPath.row)
            } else {
                //firebase
                deleteStr = saleslist[indexPath.row].salesNo!
                self.saleslist.remove(at: indexPath.row)
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
        
        return action == #selector(copy(_:))
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
}
@available(iOS 13.0, *)
extension SalesmanVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
