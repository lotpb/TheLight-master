//
//  RegionsListController.swift
//  Coldest Places On Earth
//
//  Created by Malek T. on 12/4/15.
//  Copyright © 2015 Medigarage Studios LTD. All rights reserved.
//

import UIKit


protocol RegionsProtocol{
    func loadOverlayForRegionWithLatitude(_ latitude:Double, andLongitude longitude:Double)
}

@available(iOS 13.0, *)
final class RegionsListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate:RegionsProtocol!
    @IBOutlet weak var tableView: UITableView!
    
    private var regions = ["New York (United States)","San Francisco (United States)","Verkhoyansk (Russia)","Fraser, Colo (United States)","Hell (Norway)","Barrow (Alaska)","Oymyakon (Russia)"]
    private var latitudes = [40.7128,37.7749,67.550592,39.944987,63.445171,71.290556,63.464138]
    private var longitudes = [-74.0060,-122.4194,133.399340,-105.817232,10.905217,-156.788611,142.773727]
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        setupNavigation()
        setupTableView()
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
        NotificationCenter.default.addObserver(self, selector: #selector(RegionsListVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
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
        
        navigationItem.title = "Regions"
        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.sizeToFit()
        self.tableView!.clipsToBounds = true
        self.tableView!.backgroundColor = .systemGray4
        self.tableView!.tableFooterView = UIView(frame: .zero)
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
    
    //MARK: UITableViewDataSource Protocol
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "regionCell")
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.textLabel?.textColor = .label
        cell?.textLabel!.text = regions[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    //MARK: UITableViewDelegate Protocol
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        navigationController!.popViewController(animated: true)
        self.dismiss(animated: true)
        delegate.loadOverlayForRegionWithLatitude(latitudes[indexPath.row], andLongitude: longitudes[indexPath.row])
    }

}
