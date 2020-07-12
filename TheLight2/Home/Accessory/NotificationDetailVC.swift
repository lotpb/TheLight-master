//
//  NotificationDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/27/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import  UserNotifications

final class NotificationDetailVC: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    let ipadtitle = UIFont.systemFont(ofSize: 20)
    let ipadsubtitle = UIFont.systemFont(ofSize: 16)
    
    let celltitle = UIFont.systemFont(ofSize: 16)
    let cellsubtitle = UIFont.systemFont(ofSize: 12)
    
    private let center = UNUserNotificationCenter.current()
    private var filteredString = NSMutableArray()
    private var objects = [AnyObject]()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        setupNavigationButtons()
        setupTableView()
        
        tableView!.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //navigationController?.navigationBar.barTintColor = .systemOrange
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationButtons() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        navigationItem.rightBarButtonItems = [trashButton]
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Notifications"
        } else {
            navigationItem.title = "Notifications"
        }
    }
    
    func setupTableView() {
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.rowHeight = 85
        if #available(iOS 13.0, *) {
            tableView!.backgroundColor = .systemGray4
        } else {
            tableView!.backgroundColor = ColorX.LGrayColor
        }
        tableView!.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - refresh
    @objc func refreshData(_ sender:AnyObject) {
        tableView!.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Buttons
    @objc func deleteButton(_ sender:UIButton) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllPendingNotificationRequests()
        //UIApplication.shared.cancelAllLocalNotifications()
        tableView!.reloadData()
    }
}
extension NotificationDetailVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // (UIApplication.shared.currentUserNotificationSettings?.categories!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier: String = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell
        
        cell.textLabel!.textColor = .systemGray
        cell.detailTextLabel!.textColor = .systemGray
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.textLabel!.font = ipadtitle
            cell.detailTextLabel!.font = ipadsubtitle
        } else {
            cell.textLabel!.font = celltitle
            cell.detailTextLabel!.font = celltitle
        }
        // FIXME: shouldn't crash
        center.getPendingNotificationRequests { (requests) in
            //if let requests > 0
        }
        //cell.textLabel!.text = "You have \(requests) Notifications :)"
        //cell.detailTextLabel!.text = "You have \(requests) Notifications :)"
        return cell
    }
}
extension NotificationDetailVC: UITableViewDelegate {
    /*
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 90.0
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     
     let vw = UIView()
     vw.backgroundColor = .systemOrange
     //tableView.tableHeaderView = vw
     
     return vw
     }
     */
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.refreshData(self)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
