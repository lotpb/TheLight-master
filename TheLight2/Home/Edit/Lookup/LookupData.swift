//
//  LookupData.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/10/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

protocol LookupDataDelegate: class {
    func cityFromController(_ passedData: String)
    func stateFromController(_ passedData: String)
    func zipFromController(_ passedData: String)
    func salesFromController(_ passedData: String)
    func salesNameFromController(_ passedData: String)
    func jobFromController(_ passedData: String)
    func jobNameFromController(_ passedData: String)
    func productFromController(_ passedData: String)
    func productNameFromController(_ passedData: String)
}


@available(iOS 13.0, *)
final class LookupData: UIViewController {
    
    weak var delegate:LookupDataDelegate?
    
    @IBOutlet weak var tableView: UITableView?

    public var lookupItem : String?
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = NSMutableArray()
    private var isFilltered = false

    //firebase
    private var ziplist = [ZipModel]()
    private var saleslist = [SalesModel]()
    private var joblist = [JobModel]()
    private var prodlist = [ProdModel]()
    private var adlist = [AdModel]()
    private var defaults = UserDefaults.standard
    //parse
    private var zipArray = NSMutableArray()
    private var salesArray = NSMutableArray()
    private var jobArray = NSMutableArray()
    private var adproductArray = NSMutableArray()

    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        loadData()
        setupNavigation()
        setupTableView()
        tableView!.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = ColorX.DGrayColor
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
        navigationItem.title = String(format: "%@ %@", "Lookup", (self.lookupItem)!)
        
        searchController = UISearchController(searchResultsController: resultsController)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        
        self.definesPresentationContext = true
    }
    
    func setupTableView() {
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.sizeToFit()
        tableView!.clipsToBounds = true
        tableView!.backgroundColor = .secondarySystemGroupedBackground
        tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = ColorX.LGrayColor
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Refresh
    @objc func refreshData(sender:AnyObject) {
        loadData()
        refreshControl.endRefreshing()
    }

    // MARK: - Parse
    func loadData() {
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFQuery(className:"Zip")
            query.limit = 1000
            query.order(byAscending: "City")
            query.cachePolicy = .cacheThenNetwork
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self.zipArray = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query1 = PFQuery(className:"Salesman")
            query1.limit = 1000
            query1.order(byAscending: "Salesman")
            query1.cachePolicy = .cacheThenNetwork
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self.salesArray = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query2 = PFQuery(className:"Job")
            query2.limit = 1000
            query2.order(byAscending: "Description")
            query2.cachePolicy = .cacheThenNetwork
            query2.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self.jobArray = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Zip").observe(.childAdded , with:{ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let zipTxt = ZipModel(dictionary: dictionary)
                self.ziplist.append(zipTxt)
                
                self.ziplist.sort(by: { (p1, p2) -> Bool in
                    return p1.city.compare(p2.city) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
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
            
            FirebaseRef.databaseRoot.child("Job").observe(.childAdded , with:{ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let jobTxt = JobModel(dictionary: dictionary)
                self.joblist.append(jobTxt)
                
                self.joblist.sort(by: { (p1, p2) -> Bool in
                    return p1.description.compare(p2.description) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
        }
        
        if (lookupItem == "Product") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query3 = PFQuery(className:"Product")
                query3.limit = 1000
                query3.order(byDescending: "Products")
                query3.cachePolicy = .cacheThenNetwork
                query3.findObjectsInBackground { objects, error in
                    if error == nil {
                        let temp: NSArray = objects! as NSArray
                        self.adproductArray = temp.mutableCopy() as! NSMutableArray
                        self.tableView!.reloadData()
                    } else {
                        print("Error")
                    }
                }
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Product").observe(.childAdded , with:{ (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let prodTxt = ProdModel(dictionary: dictionary)
                    self.prodlist.append(prodTxt)
                    
                    self.prodlist.sort(by: { (p1, p2) -> Bool in
                        return p1.products.compare(p2.products) == .orderedAscending
                    })
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                })
            }
            
        } else {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query4 = PFQuery(className:"Advertising")
                query4.limit = 1000
                query4.order(byDescending: "Advertiser")
                query4.cachePolicy = .cacheThenNetwork
                query4.findObjectsInBackground { objects, error in
                    if error == nil {
                        let temp: NSArray = objects! as NSArray
                        self.adproductArray = temp.mutableCopy() as! NSMutableArray
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
            }
        }
    }
    
    // MARK: - Segues
    func passDataBack() {
        let indexPath = (tableView!.indexPathForSelectedRow! as NSIndexPath).row
        if (!isFilltered) {
            if (lookupItem == "City") {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    self.delegate? .cityFromController(((zipArray.object(at: indexPath) as AnyObject).value(forKey: "City") as? String)!)
                    self.delegate? .stateFromController(((zipArray[indexPath] as AnyObject).value(forKey: "State") as? String)!)
                    self.delegate? .zipFromController(((zipArray[indexPath] as AnyObject).value(forKey: "zipCode") as? String)!)
                } else {
                    //firebase
                    self.delegate? .cityFromController(ziplist[indexPath].city)
                    self.delegate? .stateFromController(ziplist[indexPath].state)
                    self.delegate? .zipFromController(ziplist[indexPath].zip)
                }
                
            } else if (lookupItem == "Salesman") {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    self.delegate? .salesFromController(((salesArray.object(at: indexPath) as AnyObject).value(forKey: "SalesNo") as? String)!)
                    self.delegate? .salesNameFromController(((salesArray[indexPath] as AnyObject).value(forKey: "Salesman") as? String)!)
                } else {
                    //firebase
                    self.delegate? .salesFromController(saleslist[indexPath].salesNo!)
                    self.delegate? .salesNameFromController(saleslist[indexPath].salesman)
                }
                
            } else if (lookupItem == "Job") {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    self.delegate? .jobFromController(((jobArray[indexPath] as AnyObject).value(forKey: "JobNo") as? String)!)
                    self.delegate? .jobNameFromController(((jobArray.object(at: indexPath) as AnyObject).value(forKey: "Description") as? String)!)
                } else {
                    //firebase
                    self.delegate? .jobFromController(joblist[indexPath].jobNo!)
                    self.delegate? .jobNameFromController(joblist[indexPath].description)
                }
                
            } else if (lookupItem == "Product") {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    self.delegate? .productFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "ProductNo") as? String)!)
                    self.delegate? .productNameFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "Products") as? String)!)
                } else {
                    //firebase
                    self.delegate? .productFromController(prodlist[indexPath].productNo!)
                    self.delegate? .productNameFromController(prodlist[indexPath].products)
                }
            } else {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    self.delegate? .productFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "AdNo") as? String)!)
                    self.delegate? .productNameFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "Advertiser") as? String)!)
                } else {
                    //firebase
                    self.delegate? .productFromController(adlist[indexPath].adNo!)
                    self.delegate? .productNameFromController(adlist[indexPath].advertiser)
                }
            }
            
        } else {
            
            if (lookupItem == "City") {
                self.delegate? .cityFromController((((filteredTitles.object(at: indexPath) as! NSObject).value(forKey: "City") as? String)! as NSString) as String)
                self.delegate? .stateFromController((((filteredTitles[indexPath] as! NSObject).value(forKey: "State") as? String)! as NSString) as String)
                self.delegate? .zipFromController(((filteredTitles[indexPath] as! NSObject).value(forKey: "zipCode") as? String)!)
                
            } else if (lookupItem == "Salesman") {
                self.delegate? .salesFromController(((filteredTitles.object(at: indexPath) as AnyObject).value(forKey: "SalesNo") as? String)!)
                self.delegate? .salesNameFromController(((filteredTitles[indexPath] as AnyObject).value(forKey: "Salesman") as? String)!)
                
            } else if (lookupItem == "Job") {
                self.delegate? .jobFromController(((filteredTitles[indexPath] as AnyObject).value(forKey: "JobNo") as? String)!)
                self.delegate? .jobNameFromController(((filteredTitles.object(at: indexPath) as AnyObject).value(forKey: "Description") as? String)!)
                
            } else if (lookupItem == "Product") {
                self.delegate? .productFromController(((filteredTitles[indexPath] as AnyObject).value(forKey: "ProductNo") as? String)!)
                self.delegate? .productNameFromController(((filteredTitles[indexPath] as AnyObject).value(forKey: "Products") as? String)!)
            } else {
                self.delegate? .productFromController(((filteredTitles[indexPath] as AnyObject).value(forKey: "AdNo") as? String)!)
                self.delegate? .productNameFromController(((filteredTitles[indexPath] as AnyObject).value(forKey: "Advertiser") as? String)!)
            }
        }
        let _ = navigationController?.popViewController(animated: true)
    }
}
@available(iOS 13.0, *)
extension LookupData: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!isFilltered) {
            if (lookupItem == "City") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    zipArray.object(at: indexPath.row)
                } else {
                    //firebase
                    //ziplist(indexPath.row)
                }
            } else if (lookupItem == "Salesman") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    salesArray.object(at: indexPath.row)
                } else {
                    //firebase
                }
            } else if (lookupItem == "Job") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    jobArray.object(at: indexPath.row)
                } else {
                    //firebase
                }
            } else if (lookupItem == "Product") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    adproductArray.object(at: indexPath.row)
                } else {
                    //firebase
                }
            } else if (lookupItem == "Advertiser") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    adproductArray.object(at: indexPath.row)
                } else {
                    //firebase
                }
            }
        } else {
            filteredTitles.object(at: indexPath.row)
        }
        passDataBack()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if (lookupItem == "City") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    return zipArray.count
                } else {
                    //firebase
                    return ziplist.count
                }
            } else if (lookupItem == "Salesman") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    return salesArray.count
                } else {
                    //firebase
                    return saleslist.count
                }
            } else if (lookupItem == "Job") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    return jobArray.count
                } else {
                    //firebase
                    return joblist.count
                }
            } else if (lookupItem == "Product") || (lookupItem == "Advertiser") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    return adproductArray.count
                } else {
                    //firebase
                    if (lookupItem == "Product") {
                        return prodlist.count
                    } else {
                        return adlist.count
                    }
                }
            }
        } else {
            //return foundUsers.count
            return filteredTitles.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        cellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.selectionStyle = .none
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.textLabel!.font = Font.celltitle20l
        } else {
            cell.textLabel!.font = Font.celltitle20l
        }
        cell.textLabel!.textColor = .label
        
        if (tableView == self.tableView) {
            if (lookupItem == "City") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = ((zipArray[indexPath.row] as AnyObject).value(forKey: "City") as? String)!
                } else {
                    //firebase
                    cell.textLabel!.text = ziplist[indexPath.row].city
                }
            } else if (lookupItem == "Salesman") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = ((salesArray[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String)!
                } else {
                    //firebase
                    cell.textLabel!.text = saleslist[indexPath.row].salesman
                }
            } else if (lookupItem == "Job") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = ((jobArray[indexPath.row] as AnyObject).value(forKey: "Description") as? String)!
                } else {
                    //firebase
                    cell.textLabel!.text = joblist[indexPath.row].description
                }
            } else if (lookupItem == "Product") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = ((adproductArray[indexPath.row] as AnyObject).value(forKey: "Products") as? String)!
                } else {
                    //firebase
                    cell.textLabel!.text = prodlist[indexPath.row].products
                }
            } else if (lookupItem == "Advertiser") {
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    cell.textLabel!.text = ((adproductArray[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String)!
                } else {
                    //firebase
                    cell.textLabel!.text = adlist[indexPath.row].advertiser
                }
            }
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            //let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                if (lookupItem == "City") {
                    //cell.textLabel!.text = foundUsers[indexPath.row]
                    cell.textLabel!.text = ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "City") as? String)!
                } else if (lookupItem == "Salesman") {
                    cell.textLabel!.text = ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String)!
                } else if (lookupItem == "Job") {
                    cell.textLabel!.text = ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "Description") as? String)!
                } else if (lookupItem == "Product") {
                    cell.textLabel!.text = ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "Products") as? String)!
                } else if (lookupItem == "Advertiser") {
                    cell.textLabel!.text = ((filteredTitles[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String)!
                }
            } else {
                //firebase
                if (lookupItem == "City") {
                    let lead: ZipModel
                    lead = filteredTitles[indexPath.row] as! ZipModel
                    cell.textLabel!.text = lead.city
         
                } else if (lookupItem == "Salesman") {
                    let lead: SalesModel
                    lead = filteredTitles[indexPath.row] as! SalesModel
                    cell.textLabel!.text = lead.salesman
                   
                } else if (lookupItem == "Job") {
                    let lead: JobModel
                    lead = filteredTitles[indexPath.row] as! JobModel
                    cell.textLabel!.text = lead.description
                   
                } else if (lookupItem == "Product") {
                    let lead: ProdModel
                    lead = filteredTitles[indexPath.row] as! ProdModel
                    cell.textLabel!.text = lead.products
                    
                } else if (lookupItem == "Advertiser") {
                    let lead: AdModel
                    lead = filteredTitles[indexPath.row] as! AdModel
                    cell.textLabel!.text = lead.advertiser
                }
            }
        }
        return cell
    }
}
@available(iOS 13.0, *)
extension LookupData: UITableViewDelegate {
    
}
@available(iOS 13.0, *)
extension LookupData: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        /*
        if (lookupItem == "City") {
            
            filteredTitles = filteredTitles.filter { (lead: ZipModel) in
                let target: String
                switch(scope.lowercased()) {
                case "name":
                    target = lead.city
                case "city":
                    target = lead.city
                case "phone":
                    target = lead.city
                case "active":
                    target = ""
                default:
                    target = lead.city
                }
                return target.lowercased().contains(searchText.lowercased())
         
            
        } else if (lookupItem == "Salesman") {
            
        } else if (lookupItem == "Job") {
            
        } else if (lookupItem == "Product") {
            
        } else if (lookupItem == "Advertiser") {
            
        } */
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
            }
    }
}




