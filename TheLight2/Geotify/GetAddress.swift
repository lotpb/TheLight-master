//
//  GetAddress.swift
//  Geotify
//
//  Created by Peter Balsamo on 2/22/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit
import MapKit


@available(iOS 13.0, *)
final class GetAddress: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    public var thoroughfare: String?
    public var subThoroughfare: String?
    public var locality: String?
    public var sublocality: String?
    public var postalCode: String?
    public var administrativeArea: String?
    public var subAdministrativeArea: String?
    public var country: String?
    public var ISOcountryCode: String?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(GetAddress.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        navigationController?.navigationBar.tintColor = UIColor.white
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
        
        navigationItem.title = "Locate Address"
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.largeTitleDisplayMode = .always
        } else {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    private func setupTableView() {
        
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.rowHeight = 65
        tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        tableView!.tableFooterView = UIView(frame: .zero)
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
    
    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 1
        } else {
            return 9
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel!.textColor = .label
        cell.detailTextLabel!.textColor = .lightGray
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            
            cell.textLabel!.font = Font.celltitle22m
            cell.detailTextLabel!.font = Font.celltitle16r
            
        } else {
            
            cell.textLabel!.font = Font.celltitle22m
            cell.detailTextLabel!.font =  Font.celltitle16r
        }
        
        if (indexPath.section == 0) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                //cell.textLabel!.font =  Font.celltitle22m
                cell.detailTextLabel!.font =  Font.celltitle22m
                cell.textLabel!.textColor = .systemRed
                cell.detailTextLabel!.textColor = .systemRed
                
                cell.textLabel!.text = subThoroughfare! + " " + thoroughfare!
                cell.detailTextLabel!.text = locality! + ", " + administrativeArea! + " " + postalCode!
            }
            
        } else if (indexPath.section == 1) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                cell.textLabel!.text = subThoroughfare
                cell.detailTextLabel!.text = "subThoroughfare"
            }
            
            if ((indexPath as NSIndexPath).row == 1) {
                cell.textLabel!.text = thoroughfare
                cell.detailTextLabel!.text = "thoroughfare"
            }
            
            if ((indexPath as NSIndexPath).row == 2) {
                cell.textLabel!.text = sublocality
                cell.detailTextLabel!.text = "sublocality"
            }
            
            if ((indexPath as NSIndexPath).row == 3) {
                cell.textLabel!.text = locality
                cell.detailTextLabel!.text = "locality"
            }
            
            if ((indexPath as NSIndexPath).row == 4) {
                cell.textLabel!.text = administrativeArea
                cell.detailTextLabel!.text = "administrativeArea"
            }
            
            if ((indexPath as NSIndexPath).row == 5) {
                cell.textLabel!.text = postalCode
                cell.detailTextLabel!.text = "postalCode"
            }
            
            if ((indexPath as NSIndexPath).row == 6) {
                cell.textLabel!.text = subAdministrativeArea
                cell.detailTextLabel!.text = "subAdministrativeArea"
            }
            
            if ((indexPath as NSIndexPath).row == 7) {
                cell.textLabel!.text = country
                cell.detailTextLabel!.text = "country"
            }
            
            if ((indexPath as NSIndexPath).row == 8) {
                cell.textLabel!.text = ISOcountryCode
                cell.detailTextLabel!.text = "countryCode"
            }
            
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {

            return 10
        } else if (section == 1) {
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            
            return 10
        } else if (section == 1) {
            return 0
        }
        return 0
    }
    
}
