//
//  Lead.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

@available(iOS 13.0, *)
final class Lead: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [LeadModel]()
    private let searchScope = ["name", "city", "phone", "date", "active"]
    
    //firebase
    private var leadlist = [LeadModel]()
    private var activeCount: Int?
    private var defaults = UserDefaults.standard
    //parse
    private var _feedItems = NSMutableArray()
    private var _feedheadItems = NSMutableArray()
  
    private var pasteBoard = UIPasteboard.general
    private var objectIdLabel = String()
    private var titleLabel = String()
    private var dateLabel = String()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.Lead.navColor
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
        NotificationCenter.default.addObserver(self, selector: #selector(Lead.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

        setMainNavItems()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newDataBtn))
        navigationItem.title = "Leads"
        
        searchController = UISearchController(searchResultsController: resultsController)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
    }
    
    private func setupTableView() {
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
        tableView!.reloadData()
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = ColorX.LGrayColor
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification) {
        if UIDevice.current.userInterfaceIdiom == .phone {
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
    
    // MARK: - Refresh
    @objc func refreshData(_ sender:AnyObject) {
        leadlist.removeAll() // FIXME: shouldn't crash
        loadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newDataBtn() {
        
        self.performSegue(withIdentifier: "newleadSegue", sender: self)
    }
    
    // MARK: - Parse
    private func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {

            let query = PFQuery(className:"Leads")
            query.limit = 1000
            query.order(byDescending: "createdAt")
            query.cachePolicy = .cacheThenNetwork
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error1")
                }
            }
            
            let query1 = PFQuery(className:"Leads")
            query1.whereKey("Active", equalTo:1)
            query1.cachePolicy = .cacheThenNetwork
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error2")
                }
            }
        } else {
            
            //firebase
            FirebaseRef.databaseRoot.child("Leads")
                .observe(.childAdded , with:{ (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let post = LeadModel(dictionary: dictionary)
                    self.leadlist.append(post)
                    
                    self.leadlist.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                }) { (err) in
                    print("Failed to fetch posts:", err)
            }
            
            FirebaseRef.databaseRoot.child("Leads")
                .queryOrdered(byChild: "active") //inludes reply likes
                .queryStarting(atValue: 1)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    self.activeCount = Int(snapshot.childrenCount)
                    self.tableView?.reloadData()
                })
        }
    }
    
    private func deleteData(name: String) {
        
        let alert = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Leads")
                query.whereKey("objectId", equalTo: name)
                query.findObjectsInBackground(block: { objects, error in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
                            //self.refreshData(self)
                        }
                    }
                })
            } else {
                //firebase
                FirebaseRef.databaseLeads.child(name).removeValue(completionBlock: { (error, ref) in
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
    
    // MARK: - imgLoadSegue
    @objc func imgLoadSegue(_ sender: UITapGestureRecognizer) {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            objectIdLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "objectId") as? String)!
            dateLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "Date") as? String)!
            titleLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "LastName") as? String)!
        } else {
            //firebase
            objectIdLabel = leadlist[(sender.view!.tag)].leadId!
            dateLabel = leadlist[(sender.view!.tag)].creationDate.timeAgoDisplay()
            titleLabel = leadlist[(sender.view!.tag)].lastname
        }
        self.performSegue(withIdentifier: "leaduserSegue", sender: self)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        MasterViewController.dateFormatter.dateFormat = "MMM dd yyyy"
        
        if segue.identifier == "leaddetailSegue" {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let VC = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            VC.formController = "Leads"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
            
            var LeadNo:Int?
            var Zip:Int?
            var Amount:Int?
            var SalesNo:Int?
            var JobNo:Int?
            var AdNo:Int?
            var Active:Int?
            var dateUpdated: Date
            var indexPath: Int?
            
            if navigationItem.searchController?.isActive == true {
                //search
                indexPath = self.resultsController.tableView?.indexPathForSelectedRow?.row
                dateUpdated = filteredTitles[indexPath!].lastUpdate
                LeadNo = filteredTitles[indexPath!].leadNo as? Int
                Zip = filteredTitles[indexPath!].zip as? Int
                Amount = filteredTitles[indexPath!].amount as? Int
                SalesNo = filteredTitles[indexPath!].salesNo as? Int
                JobNo = filteredTitles[indexPath!].jobNo as? Int
                AdNo = filteredTitles[indexPath!].adNo as? Int
                Active = filteredTitles[indexPath!].active as? Int
                
            } else {
                
                indexPath = tableView?.indexPathForSelectedRow?.row
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    dateUpdated = (_feedItems[indexPath!] as AnyObject).value(forKey: "updatedAt") as! Date
                    LeadNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "LeadNo") as? Int
                    Zip = (_feedItems[indexPath!] as AnyObject).value(forKey: "Zip")as? Int
                    Amount = (_feedItems[indexPath!] as AnyObject).value(forKey: "Amount")as? Int
                    SalesNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "SalesNo")as? Int
                    JobNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "JobNo")as? Int
                    AdNo = (_feedItems[indexPath!] as AnyObject).value(forKey: "AdNo")as? Int
                    Active = (_feedItems[indexPath!] as AnyObject).value(forKey: "Active")as? Int
                } else {
                    dateUpdated = leadlist[indexPath!].lastUpdate
                    LeadNo = leadlist[indexPath!].leadNo as? Int
                    Zip = leadlist[indexPath!].zip as? Int
                    Amount = leadlist[indexPath!].amount as? Int
                    SalesNo = leadlist[indexPath!].salesNo as? Int
                    JobNo = leadlist[indexPath!].jobNo as? Int
                    AdNo = leadlist[indexPath!].adNo as? Int
                    Active = leadlist[indexPath!].active as? Int
                }
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

            VC.tbl16 = String(format: "%@", MasterViewController.dateFormatter.string(from: dateUpdated)) as String
            
            if navigationItem.searchController?.isActive == true {
                //search
                let lead: LeadModel
                lead = filteredTitles[indexPath!]
                
                VC.objectId = lead.leadId
                VC.leadNo = formatter.string(from: LeadNo! as NSNumber)
                VC.zip = formatter.string(from: Zip! as NSNumber)
                VC.amount = formatter.string(from: Amount! as NSNumber)
                VC.tbl22 = formatter.string(from: SalesNo! as NSNumber)
                VC.tbl23 = formatter.string(from: JobNo! as NSNumber)
                VC.tbl24 = formatter.string(from: AdNo! as NSNumber)
                VC.active = formatter.string(from: Active! as NSNumber)
                VC.tbl25 = formatter.string(from: Active! as NSNumber)
                VC.tbl21 = MasterViewController.dateFormatter.string(from: lead.aptdate as Date) as NSString
                VC.date = MasterViewController.dateFormatter.string(from: lead.creationDate as Date)
                VC.name = lead.lastname
                VC.address = lead.address
                VC.city = lead.city
                VC.state = lead.state
                VC.tbl11 = lead.callback
                VC.tbl12 = lead.phone
                VC.tbl13 = lead.first
                VC.tbl14 = lead.spouse
                VC.tbl15 = lead.email as NSString
                VC.tbl26 = lead.photo as NSString
                VC.photo = lead.photo
                VC.comments = lead.comments
                
            } else {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    VC.leadNo = formatter.string(from: LeadNo! as NSNumber)
                    VC.zip = formatter.string(from: Zip! as NSNumber)
                    VC.amount = formatter.string(from: Amount! as NSNumber)
                    VC.tbl22 = formatter.string(from: SalesNo! as NSNumber)
                    VC.tbl23 = formatter.string(from: JobNo! as NSNumber)
                    VC.tbl24 = formatter.string(from: AdNo! as NSNumber)
                    VC.active = formatter.string(from: Active! as NSNumber)
                    VC.tbl25 = formatter.string(from: Active! as NSNumber)
                    VC.tbl21 = (_feedItems[indexPath!] as AnyObject).value(forKey: "AptDate") as? NSString
                    VC.objectId = (_feedItems[indexPath!] as AnyObject).value(forKey: "objectId") as? String
                    VC.date = (_feedItems[indexPath!] as AnyObject).value(forKey: "Date") as? String
                    VC.name = (_feedItems[indexPath!] as AnyObject).value(forKey: "LastName") as? String
                    VC.address = (_feedItems[indexPath!] as AnyObject).value(forKey: "Address") as? String
                    VC.city = (_feedItems[indexPath!] as AnyObject).value(forKey: "City") as? String
                    VC.state = (_feedItems[indexPath!] as AnyObject).value(forKey: "State") as? String
                    VC.tbl11 = (_feedItems[indexPath!] as AnyObject).value(forKey: "CallBack") as? String
                    VC.tbl12 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Phone") as? String
                    VC.tbl13 = (_feedItems[indexPath!] as AnyObject).value(forKey: "First") as? String
                    VC.tbl14 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Spouse") as? String
                    VC.tbl15 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Email") as? NSString
                    VC.tbl26 = (_feedItems[indexPath!] as AnyObject).value(forKey: "Photo") as? NSString
                    VC.comments = (_feedItems[indexPath!] as AnyObject).value(forKey: "Coments") as? String
                    
                } else {
                    //firebase
                    VC.objectId = leadlist[indexPath!].leadId
                    VC.leadNo = leadlist[indexPath!].leadId
                    VC.zip = formatter.string(from: Zip! as NSNumber)
                    VC.amount = formatter.string(from: Amount! as NSNumber)
                    VC.date = MasterViewController.dateFormatter.string(from: leadlist[indexPath!].creationDate as Date)
                    VC.lastname = leadlist[indexPath!].lastname
                    VC.name = String(format: "%@ %@", leadlist[indexPath!].first, leadlist[indexPath!].lastname).removeWhiteSpace()
                    //controller.name = leadlist[indexPath!].lastname
                    VC.address = leadlist[indexPath!].address
                    VC.city = leadlist[indexPath!].city
                    VC.state = leadlist[indexPath!].state
                    VC.active = formatter.string(from: Active! as NSNumber)
                    VC.tbl11 = leadlist[indexPath!].callback
                    VC.tbl12 = leadlist[indexPath!].phone
                    VC.tbl13 = leadlist[indexPath!].first
                    VC.tbl14 = leadlist[indexPath!].spouse
                    VC.tbl15 = leadlist[indexPath!].email as NSString
                    VC.tbl17 = leadlist[indexPath!].photo

                    VC.tbl21 = MasterViewController.dateFormatter.string(from: leadlist[indexPath!].aptdate as Date) as NSString
                    VC.tbl22 = formatter.string(from: SalesNo! as NSNumber)
                    VC.tbl23 = formatter.string(from: JobNo! as NSNumber)
                    VC.tbl24 = formatter.string(from: AdNo! as NSNumber)
                    VC.tbl25 = formatter.string(from: Active! as NSNumber)
                    VC.tbl26 = leadlist[indexPath!].leadId as NSString?
                    VC.tbl27 = leadlist[indexPath!].uid
                    VC.photo = leadlist[indexPath!].photo
                    VC.comments = leadlist[indexPath!].comments
                }
            }
            
            VC.l11 = "Call Back"; VC.l12 = "Phone"
            VC.l13 = "First"; VC.l14 = "Spouse"
            VC.l15 = "Email"; VC.l21 = "Apt Date"
            VC.l22 = "Salesman"; VC.l23 = "Job"
            VC.l24 = "Advertiser"; VC.l25 = "Active"
            VC.l16 = "Last Updated"; VC.l26 = "LeadID"
            VC.l17 = "Photo"; VC.l27 = "uid"
            VC.l1datetext = "Lead Date:"
            VC.lnewsTitle = Config.NewsLead
        }

        if segue.identifier == "leaduserSegue" { // TODO:
            //guard let controller = (segue.destination as! UINavigationController).topViewController as? LeadUserVC else { return }
            guard let VC = segue.destination as? LeadUserVC else { return }
            VC.formController = "Leads"
            VC.objectId = objectIdLabel
            VC.postBy = titleLabel
            VC.leadDate = dateLabel
            //controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            //controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
        if segue.identifier == "newleadSegue" {
            let VC = (segue.destination as! UINavigationController).topViewController as! EditData
            VC.formController = "Leads"
            VC.status = "New"
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}
@available(iOS 13.0, *)
extension Lead: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "leaddetailSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.tableView) {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedItems.count
            } else {
                //firebase
                return leadlist.count
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
                
                cell.leadtitleLabel!.font = Font.celltitle20m
                cell.leadsubtitleLabel!.font = Font.celltitle16r
                cell.leadreplyLabel.font = Font.celltitle16r
                cell.leadlikeLabel.font = Font.celltitle16r
                cell.myLabel10.font = Font.celltitle16r
                cell.myLabel20.font = Font.celltitle18m
            }
            
            cell.selectionStyle = .none
            cell.leadtitleLabel.textColor = .label
            cell.myLabel20.textColor = .label
            
            cell.leadsubtitleLabel!.textColor = .systemGray
            cell.myLabel10.backgroundColor = .systemGray//Color.Lead.labelColor1
            
            cell.leadreplyButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
            cell.leadreplyLabel.text! = ""
            
            cell.leadlikeButton.tintColor = .systemYellow
            cell.leadlikeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            
            cell.customImagelabel.text = "Lead"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.frame = .init(x: 10, y: 10, width: 50, height: 50)
            cell.customImagelabel.backgroundColor = .systemRed //Color.Lead.buttonColor
            cell.customImagelabel.layer.cornerRadius = 25.0
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgLoadSegue))
            cell.customImagelabel.addGestureRecognizer(tap)
            cell.addSubview(cell.customImagelabel)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                //cell.feedItems = _feedItems[indexPath.row] as? Database

                cell.leadtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "LastName") as? String ?? ""
                cell.leadsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "City") as? String ?? ""
                cell.myLabel10.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Date") as? String ?? ""
                cell.myLabel20.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "CallBack") as? String ?? ""
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Coments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Coments") as? String == "") {
                    
                    cell.leadreplyButton!.tintColor = .lightGray
                } else {
                    cell.leadreplyButton!.tintColor = ColorX.Lead.buttonColor
                }
                
                if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
                    cell.leadlikeButton!.tintColor = ColorX.Lead.buttonColor
                    cell.leadlikeLabel.text! = "Active"
                    cell.leadlikeLabel.adjustsFontSizeToFitWidth = true
                } else {
                    cell.leadlikeButton!.tintColor = .lightGray
                    cell.leadlikeLabel.text! = ""
                }
                
            } else {
                //firebase
                cell.leadpost = leadlist[indexPath.row]
                cell.configureLeadEntry(cell.leadpost!)
            }

            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                //parse
                cell.textLabel!.text = (filteredTitles[indexPath.row] as AnyObject).value(forKey: "LastName") as? String
                
            } else {
                
                let lead: LeadModel
                lead = filteredTitles[indexPath.row]
                cell.textLabel!.text = lead.lastname
            }
            
            return cell
        }
    }
}
@available(iOS 13.0, *)
extension Lead: UITableViewDelegate {
    // MARK: - TableView
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
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    header.myLabel1.text = String(format: "%@%d", "Leads\n", _feedItems.count)
                    header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                    header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
                } else {
                    //firebase
                    header.myLabel1.text = String(format: "%@%d", "Leads\n", leadlist.count)
                    header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                    header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
                }
                header.contentView.backgroundColor = .systemRed  //Color.Lead.buttonColor //Color.Lead.navColor
                
                return header
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var deleteStr : String?
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                deleteStr = ((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!
                _feedItems.removeObject(at: indexPath.row)
            } else {
                //firebase
                deleteStr = leadlist[indexPath.row].leadId!
                leadlist.remove(at: indexPath.row)
            }
            deleteData(name: deleteStr!)
            tableView.deleteRows(at: [indexPath], with: .left)
            refreshData(self)
            
        } else if editingStyle == .insert {
            
        }
    }

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
    
    // MARK: - search
    func filterContentForSearchText(searchText: String, scope: String = "name") {
        
        filteredTitles = leadlist.filter { (lead: LeadModel) in
            let target: String
            switch(scope.lowercased()) {
            case "name":
                target = lead.lastname
            case "city":
                target = lead.city
            case "phone":
                target = lead.phone
            case "active":
                target = ""
            default:
                target = lead.lastname
            }
            return target.lowercased().contains(searchText.lowercased())
        }
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
        }
    }
}
@available(iOS 13.0, *)
extension Lead: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}


