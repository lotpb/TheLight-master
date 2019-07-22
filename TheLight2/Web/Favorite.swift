//
//  FavoriteController.swift
//  TheLight
//
//  Created by Peter Balsamo on 12/29/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit

class Favorite: UITableViewController {
    
    var pasteBoard = UIPasteboard.general
    //lazy var refreshControl: UIRefreshControl!
    //var collapseDetailViewController: Bool  = true

    var detailViewController: Web? = nil
    var objects = NSMutableArray()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 100, height: self.view.frame.height)
        button.setTitle("Favorites", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let siteNames = ["Ray Wenderlich", "Use Your Loaf", "IOS Dev Feed", "Stackflow", "Letsbuildthatapp", "Cocoacasts", "Little bites of cocoa", "GitHub", "iOS Goodies", "Swift"]
    
    let siteAddresses = ["https://www.raywenderlich.com",
    "https://useyourloaf.com",
    "https://twitter.com/iOSDevFeed",
    "https://stackoverflow.com/questions/tagged/swift4",
    "https://videos.letsbuildthatapp.com",
    "https://cocoacasts.com/blog/",
    "https://littlebitesofcocoa.com",
    "https://github.com",
    "https://ios-goodies.com",
    "https://swift.org/blog/"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? Web
        } */
        
        setupTableView()
        self.navigationItem.titleView = self.titleButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.LGrayColor
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableView.automaticDimension
        self.tableView!.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siteNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.textLabel!.font = Font.celltitle20r
        } else {
            cell.textLabel!.font = Font.celltitle18l
        }

        cell.textLabel!.text = siteNames[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //self.refreshData(self)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Segues
    // Had to Segue from the tablecell to work
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = self.tableView?.indexPathForSelectedRow {
                let urlString = siteAddresses[indexPath.row]
                
                let controller = (segue.destination as! UINavigationController).topViewController as! Web
                controller.detailItem = urlString as AnyObject
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}
