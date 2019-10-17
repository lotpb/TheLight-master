//
//  StatisticController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/10/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse


@available(iOS 13.0, *)
final class StatisticVC: UIViewController, UITextFieldDelegate, UISplitViewControllerDelegate {

    @IBOutlet weak var scrollWall: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: NavigationController Hidden
    var lastContentOffset: CGFloat = 0.0
    
    @IBOutlet weak var contentView: UIView!
    private var searchController: UISearchController!
    private var resultsController: UITableViewController!
    private var filteredTitles = [String]()

    var _feedCustItems = NSMutableArray()
    var _feedLeadItems = NSMutableArray()
    
    //var segmentedControl : UISegmentedControl!
    let defaults = UserDefaults.standard
    
    weak var dayYQL: NSArray!
    weak var textYQL: NSArray!
    
    weak var symYQL: NSArray!
    weak var tradeYQL: NSArray!
    weak var changeYQL: NSArray!

    var tempYQL: String!
    var weathYQL: String!
    var riseYQL: String!
    var setYQL: String!
    var humYQL: String!
    var cityYQL: String!
    var updateYQL: String!

    var label1: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .right
        label.font = Font.celltitle16r
        return label
    }()
    
    var label2: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = Font.celltitle18m
        return label
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.Stat.navColor
        refreshControl.tintColor = .white
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - SplitView
        self.extendedLayoutIncludesOpaqueBars = true
        // FIXME: - remove bottom bar'
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        setupTableView()
        setupNavigation()
        //setupSearch() //dont work
        self.scrollWall!.addSubview(self.refreshControl)
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
        NotificationCenter.default.addObserver(self, selector: #selector(StatisticVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        refreshData(self) //dont move
        setMainNavItems() //setupNewsNavigationItems()
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
    
    private func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        self.navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }
 
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .secondarySystemGroupedBackground
        self.contentView.backgroundColor = .systemGroupedBackground
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight Software - Statistics"
        } else {
            navigationItem.title = "Statistics"
        }
    }
    
    func setupTableView() {
        // MARK: - TableHeader
        self.tableView?.register(StatHeaderViewCell.self, forCellReuseIdentifier: "Header")

        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.sizeToFit()
        self.tableView!.clipsToBounds = true
        self.tableView!.backgroundColor = .systemGroupedBackground
        self.tableView!.tableFooterView = UIView(frame: .zero)
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
    
    // MARK: - Refresh
    @objc func refreshData(_ sender:AnyObject) {
        self.YahooFinanceLoad()
        //self.tableView!.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    /*
    // MARK: - SegmentedControl
    @objc func segmentedControlAction(_ sender: UISegmentedControl) {
        
        if(segmentedControl.selectedSegmentIndex == 0) {
            myLabel3.text = "$100,000"
        }
        else if(segmentedControl.selectedSegmentIndex == 1) {
            myLabel3.text = "$200,000"
        }
        else if(segmentedControl.selectedSegmentIndex == 2) {
            myLabel3.text = "$300,000"
        }
    } */
    
    // MARK: - YahooFinance
    func YahooFinanceLoad() {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        //weather
        let results = YQL.query(statement: String(format: "%@%@", "select * from weather.forecast where woeid=", self.defaults.string(forKey: "weatherKey")!))
      //let results = YQL.query(statement: "select * from weather.forecast where woeid=2446726")
        let queryResults = results?.value(forKeyPath: "query.results.channel") as? NSDictionary
        if queryResults != nil {
            
            let arr = queryResults!.value(forKeyPath: "item.condition") as? NSDictionary
            tempYQL = arr!.value(forKey: "temp") as? String
            weathYQL = arr!.value(forKey: "text") as? String
            let arr1 = queryResults!.value(forKeyPath: "astronomy") as? NSDictionary
            riseYQL = arr1!.value(forKey: "sunrise") as? String
            setYQL = arr1!.value(forKey: "sunset") as? String
            let arr2 = queryResults!.value(forKeyPath: "atmosphere") as? NSDictionary
            humYQL = arr2!.value(forKey: "humidity") as? String
            let arr3 = queryResults!.value(forKeyPath: "location") as? NSDictionary
            cityYQL = arr3!.value(forKey: "city") as? String
            updateYQL = queryResults!.value(forKey: "lastBuildDate") as? String
            
            //5 day Forcast
            dayYQL = queryResults!.value(forKeyPath: "item.forecast.day") as? NSArray
            textYQL = queryResults!.value(forKeyPath: "item.forecast.text") as? NSArray
        }
        //stocks
        let stockresults = YQL.query(statement: "select * from yahoo.finance.quote where symbol in (\"^IXIC\",\"SPY\",\"FB\",\"VCSY\",\"GPRO\",\"VXX\",\"UPL\",\"SWKS\",\"AAPL\",\"^XOI\")")
        
        let querystockResults = stockresults?.value(forKeyPath: "query.results") as? NSDictionary
        if querystockResults != nil {
            
            symYQL = querystockResults!.value(forKeyPath: "quote.symbol") as? NSArray
            tradeYQL = querystockResults!.value(forKeyPath: "quote.LastTradePriceOnly") as? NSArray
            changeYQL = querystockResults!.value(forKeyPath: "quote.Change") as? NSArray
        }
    }
}
@available(iOS 13.0, *)
extension StatisticVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 7
        } else if (section == 1) {
            return 5
        } else if (section == 2) {
            return 10
        } else if (section == 3) {
            return 8
        } else if (section == 4) {
            return 8
        } else {
            if (section == 3) {
                return _feedLeadItems.count
            } else if (section == 4) {
                return _feedCustItems.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier: String = "Cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as UITableViewCell? else { fatalError("Unexpected Index Path") }

        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.textLabel!.textColor = .systemBlue
        cell.detailTextLabel!.textColor = .label
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cell.textLabel!.font = Font.Stat.celltitlePad
            cell.detailTextLabel!.font = Font.Stat.celltitlePad
            label1 = UILabel(frame: .init(x: tableView.frame.width-195, y: 5, width: 100, height: 25))
            label2 = UILabel(frame: .init(x: tableView.frame.width-80, y: 5, width: 70, height: 25))
            label1.font = Font.Stat.celltitlePad
            label2.font = Font.Stat.celltitlePad
        } else {
            cell.textLabel!.font = Font.celltitle16r
            cell.detailTextLabel!.font = Font.celltitle16r
            label1 = UILabel(frame: .init(x: tableView.frame.width-160, y: 5, width: 77, height: 25))
            label2 = UILabel(frame: .init(x: tableView.frame.width-70, y: 5, width: 65, height: 25))
        }
        
        cell.selectionStyle = .none
        cell.accessoryType = .none
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                if (tempYQL != nil) {
                    cell.detailTextLabel!.text = "\(tempYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Todays Temperature"
                return cell
                
            } else if (indexPath.row == 1) {
                if (weathYQL != nil) {
                    cell.detailTextLabel!.text = "\(weathYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Todays Weather"
                return cell
                
            } else if (indexPath.row == 2) {
                if (riseYQL != nil) {
                    cell.detailTextLabel!.text = "\(riseYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Sunrise"
                return cell
                
            } else if (indexPath.row == 3) {
                if (setYQL != nil) {
                    cell.detailTextLabel!.text = "\(setYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Sunset"
                return cell
            } else if (indexPath.row == 4) {
                if (humYQL != nil) {
                    cell.detailTextLabel!.text = "\(humYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Humidity"
                return cell
            } else if (indexPath.row == 5) {
                if (cityYQL != nil) {
                    cell.detailTextLabel!.text = "\(cityYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "City"
                return cell
            } else if (indexPath.row == 6) {
                if (updateYQL != nil) {
                    cell.detailTextLabel!.text = "\(updateYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Last Update"
                return cell
            }
            
        } else if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[0])"
                    cell.detailTextLabel!.text = "\(textYQL[0])"
                } else {
                    cell.textLabel!.text = "Day 1"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
                
            } else if (indexPath.row == 1) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[1])"
                    cell.detailTextLabel!.text = "\(textYQL[1])"
                } else {
                    cell.textLabel!.text = "Day 2"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
                
            } else if (indexPath.row == 2) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[2])"
                    cell.detailTextLabel!.text = "\(textYQL[2])"
                } else {
                    cell.textLabel!.text = "Day 3"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
                
            } else if (indexPath.row == 3) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[3])"
                    cell.detailTextLabel!.text = "\(textYQL[3])"
                } else {
                    cell.textLabel!.text = "Day 4"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
            } else if (indexPath.row == 4) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[4])"
                    cell.detailTextLabel!.text = "\(textYQL[4])"
                } else {
                    cell.textLabel!.text = "Day 5"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
            }
            
        } else if (indexPath.section == 2) {
            
            cell.detailTextLabel!.text = ""
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "\(symYQL?[0] ?? "na")"
                label2.text = "\(changeYQL?[0] ?? "0")"
                label1.text = "\(tradeYQL?[0] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel!.text = "\(symYQL?[1] ?? "na")"
                label2.text = "\(changeYQL?[1] ?? "0")"
                label1.text = "\(tradeYQL?[1] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.text = "\(symYQL?[2] ?? "na")"
                label2.text = "\(changeYQL?[2] ?? "0")"
                label1.text = "\(tradeYQL?[2] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                cell.textLabel!.text = "\(symYQL?[3] ?? "na")"
                label2.text = "\(changeYQL?[3] ?? "0")"
                label1.text = "\(tradeYQL?[3] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 4) {
                
                cell.textLabel!.text = "\(symYQL?[4] ?? "na")"
                label2.text = "\(changeYQL?[4] ?? "0")"
                label1.text = "\(tradeYQL?[4] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 5) {
                
                cell.textLabel!.text = "\(symYQL?[5] ?? "na")"
                label2.text = "\(changeYQL?[5] ?? "0")"
                label1.text = "\(tradeYQL?[5] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 6) {
                
                cell.textLabel!.text = "\(symYQL?[6] ?? "na")"
                label2.text = "\(changeYQL?[6] ?? "0")"
                label1.text = "\(tradeYQL?[6] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 7) {
                
                cell.textLabel!.text = "\(symYQL?[7] ?? "na")"
                label2.text = "\(changeYQL?[7] ?? "0")"
                label1.text = "\(tradeYQL?[7] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 8) {
                
                cell.textLabel!.text = "\(symYQL?[8] ?? "na")"
                label2.text = "\(changeYQL?[8] ?? "0")"
                label1.text = "\(tradeYQL?[8] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 9) {
                
                cell.textLabel!.text = "\(symYQL?[9] ?? "na")"
                label2.text = "\(changeYQL?[9] ?? "0")"
                label1.text = "\(tradeYQL?[9] ?? "")"
                if (label2.text?.contains("-"))! {
                    label2.backgroundColor = .systemRed
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
            }
            
        } else if (indexPath.section == 3) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Leads Today"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel!.text = "Appointment's Today"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.text = "Appointment's Tomorrow"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                cell.textLabel!.text = "Leads Active"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 4) {
                
                cell.textLabel!.text = "Leads Year"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 5) {
                
                cell.textLabel!.text = "Leads Avg"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 6) {
                
                cell.textLabel!.text = "Leads High"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 7) {
                
                cell.textLabel!.text = "Leads Low"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            }
            
        } else if (indexPath.section == 4) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Customers Today"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel!.text = "Customers Yesterday"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.text = "Windows Sold"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                cell.textLabel!.text = "Customers Active"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 4) {
                
                cell.textLabel!.text = "Customers Year"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 5) {
                
                cell.textLabel!.text = "Customers Avg"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 6) {
                
                cell.textLabel!.text = "Customers High"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 7) {
                
                cell.textLabel!.text = "Customers Low"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            }
        }
        return cell
    }
}
@available(iOS 13.0, *)
extension StatisticVC: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            return 275
        } else if (section == 1) {
            return 44
        } else if (section == 2) {
            return 44
        } else if (section == 3) {
            return 44
        } else if (section == 4) {
            return 44
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return nil
        } else if (section == 1) {
            return "Weather Forecast"
        } else if (section == 2) {
            return "Stocks"
        } else if (section == 3) {
            return "Leads"
        } else if (section == 4) {
            return "Customer"
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if (tableView == self.tableView) {

            if (section == 0) {
                //tableView.tableHeaderView = header
                guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? StatHeaderViewCell else { fatalError("Unexpected Index Path") }

                header.myLabel1.text = String(format: "%@%d", "COUNT\n", (_feedLeadItems.count + _feedCustItems.count))
                header.myLabel2.text = "NASDAQ \n \(tradeYQL?[0] ?? "00")"
                header.myLabel15.text = "\(changeYQL?[0] ?? "0")"
                header.myLabel25.text = "\(changeYQL?[0] ?? "0")"
                header.myLabel3.text = "S&P 500 \n \(tradeYQL?[1] ?? "00")"
                header.myLabel35.text = "\(changeYQL?[1] ?? "0")"

                if (header.myLabel15.text?.contains("-"))! {
                    header.separatorLine3.backgroundColor = .systemRed
                    header.myLabel15.backgroundColor = .systemRed
                } else {
                    header.separatorLine3.backgroundColor = .systemGreen
                    header.myLabel15.backgroundColor = .systemGreen
                }

                if (header.myLabel25.text?.contains("-"))! {
                    header.separatorLine2.backgroundColor = .systemRed
                    header.myLabel25.backgroundColor = .systemRed
                } else {
                    header.separatorLine2.backgroundColor = .systemGreen
                    header.myLabel25.backgroundColor = .systemGreen
                }

                if (header.myLabel35.text?.contains("-"))! {
                    header.separatorLine3.backgroundColor = .systemRed
                    header.myLabel35.backgroundColor = .systemRed
                } else {
                    header.separatorLine3.backgroundColor = .systemGreen
                    header.myLabel35.backgroundColor = .systemGreen
                }

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
                    header.titleLabeltxt2.textColor = .systemBlue
                }

                header.myListLbl.text = String(format: "%@ %@", "Weather ", "")

                return header
            }
        } else if (section == 1) {
            // MARK: - below don't work
            let view = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
            view.backgroundColor = .systemGroupedBackground //.red

            return view
        }
        return nil
    }
}
@available(iOS 13.0, *)
extension StatisticVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        if text.isEmpty {
            //filteredTitles = leadlist.
        } else {
            //filteredTitles = leadlist.filter { $0.contains(text) }
        }
        tableView?.reloadData()
    }
}
