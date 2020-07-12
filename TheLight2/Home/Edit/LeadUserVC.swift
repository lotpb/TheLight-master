//
//  LeadUserController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/2/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse


@available(iOS 13.0, *)
final class LeadUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?

    public var objectId : String?
    public var leadDate : String?
    public var postBy : String?
    public var comments : String?
    public var formController : String?

    private var defaults = UserDefaults.standard
    private var _feedItems = NSMutableArray()
    private var _feedheadItems = NSMutableArray()
    private var filteredString = NSMutableArray()
    private var objects = [AnyObject]()
    private var pasteBoard = UIPasteboard.general
    private var emptyLabel : UILabel?
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 100, height: 32)
        button.setTitle(self.formController, for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = ColorX.Lead.navColor
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationButtons()

        emptyLabel = UILabel(frame: view.bounds)
        emptyLabel!.textAlignment = .center
        emptyLabel!.textColor = .lightGray
        emptyLabel!.text = "You have no customer data :)"
        
        loadData()
        setupTableView()
        navigationItem.titleView = self.titleButton
        tableView!.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationButtons() {
        let backItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(setbackButton))
        
        if formController == "Blog" {
            navigationItem.leftBarButtonItems = [backItem]
            self.comments = "90 percent of my picks made $$$. The stock whisper has traded over 1000 traders worldwide"
        } else {
            navigationItem.leftBarButtonItems = nil
        }
    }
    
    // MARK: - refresh
    @objc func refreshData(_ sender:AnyObject) {
        tableView!.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func setbackButton() {
        dismiss(animated: true)
    }
    
    // MARK: - Table View
    func setupTableView() {
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.estimatedRowHeight = 110
        //tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.backgroundColor = .white
        tableView!.tableFooterView = UIView(frame: .zero)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return _feedItems.count 
        }
        //return foundUsers.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TableViewCell
        
        cell.selectionStyle = .none
        cell.blogsubtitleLabel!.textColor = .systemGray
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.blogtitleLabel!.font = Font.celltitle20r
            cell.blogsubtitleLabel!.font = Font.celltitle18r
            cell.blogmsgDateLabel!.font = Font.celltitle16r
            cell.commentLabel!.font = Font.celltitle16r
        } else {
            cell.blogtitleLabel!.font = Font.celltitle20l
            cell.blogsubtitleLabel!.font = Font.celltitle16r
            cell.blogmsgDateLabel!.font = Font.celltitle16r
            cell.commentLabel!.font = Font.celltitle16r
        }
        
        let dateStr : String
        
        if (self.formController == "Blog") {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                dateStr = ((_feedItems[indexPath.row] as AnyObject).value(forKey: "MsgDate") as? String)!
                MasterViewController.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            } else {
                //firebase
                dateStr = ""
            }
        } else {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                dateStr = ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Date") as? String)!
                MasterViewController.dateFormatter.dateFormat = "yyyy-MM-dd"
            } else {
                //firebase
                dateStr = ""
            }
        }
        
        let date:Date = (MasterViewController.dateFormatter.date(from: dateStr)as Date?)!
        MasterViewController.dateFormatter.dateFormat = "MMM dd, yyyy"
        
        if (self.formController == "Blog") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                cell.blogtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "PostBy") as? String
                cell.blogsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Subject") as? String
                cell.blogmsgDateLabel!.text = MasterViewController.dateFormatter.string(from: date)as String?
                var CommentCount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey: "CommentCount")as? Int
                if CommentCount == nil { CommentCount = 0 }
                cell.commentLabel?.text = "\(CommentCount!)"
            } else {
                //firebase
                
            }
            
        } else {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                cell.blogtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "LastName") as? String
                cell.blogsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "City") as? String
                cell.blogmsgDateLabel!.text = (MasterViewController.dateFormatter.string(from: date)as String??)!
                var CommentCount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Amount")as? Int
                if CommentCount == nil { CommentCount = 0 }
                cell.commentLabel?.text = formatter.string(from: CommentCount! as NSNumber)
            } else {
                //firebase
                
            }
        }
        
        cell.actionBtn.tintColor = .lightGray
        cell.actionBtn.setImage(UIImage(systemName: "square and.arrowup.fill"), for: .normal)
        
        cell.replyButton.tintColor = .lightGray
        cell.replyButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
        
        if !(cell.commentLabel.text! == "0") {
            cell.commentLabel.textColor = .lightGray
        } else {
            cell.commentLabel.text! = ""
        }
        
        if (cell.commentLabel.text! == "") {
            cell.replyButton.tintColor = .lightGray
        } else {

            if (self.formController == "Leads") {
                cell.replyButton.tintColor = ColorX.youtubeRed
            } else if (self.formController == "Customer") {
                cell.replyButton.tintColor = ColorX.BlueColor
            } else if (self.formController == "Blog") {
                cell.replyButton.tintColor = ColorX.twitterBlue
            }
        }
        
        let imageLabel:UILabel = UILabel(frame: .init(x: 10, y: 10, width: 50, height: 50))
        if (self.formController == "Leads") {
            imageLabel.text = "Cust"
            imageLabel.backgroundColor = ColorX.youtubeRed
        } else if (self.formController == "Customer") {
            imageLabel.text = "Lead"
            imageLabel.backgroundColor = ColorX.BlueColor
        } else if (self.formController == "Blog") {
            imageLabel.text = "Blog"
            imageLabel.backgroundColor = ColorX.twitterBlue
        }
        imageLabel.textColor = .white
        imageLabel.textAlignment = .center
        imageLabel.font = Font.celltitle14m
        imageLabel.layer.cornerRadius = 25.0
        imageLabel.layer.masksToBounds = true
        imageLabel.isUserInteractionEnabled = true
        cell.addSubview(imageLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = ColorX.LGrayColor
        //tableView.tableHeaderView = vw
        
        let myLabel4:UILabel = UILabel(frame: .init(x: 10, y: 70, width: tableView.frame.size.width-20, height: 50))
        let myLabel5:UILabel = UILabel(frame: .init(x: 10, y: 105, width: tableView.frame.size.width-20, height: 50))
        let myLabel6:UILabel = UILabel(frame: .init(x: 10, y: 140, width: tableView.frame.size.width-20, height: 50))
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            myLabel4.font = Font.celltitle22m
            myLabel5.font = Font.celltitle18l
            myLabel6.font = Font.celltitle18r
        } else {
            myLabel4.font = Font.celltitle22m
            myLabel5.font = Font.celltitle18l
            myLabel6.font = Font.celltitle18r
        }
        
        let myLabel1:UILabel = UILabel(frame: .init(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = .center
        myLabel1.text = String(format: "%@%d", "Count\n", _feedItems.count)
        myLabel1.font = Font.celltitle14m
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.layer.masksToBounds = true
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separator = UIView(frame: .init(x: 10, y: 75, width: 50, height: 2.5))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .white
        vw.addSubview(separator)
        
        let myLabel2:UILabel = UILabel(frame: .init(x: 80, y: 15, width: 50, height: 50))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = .center
        myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
        myLabel2.font = Font.celltitle14m
        myLabel2.layer.cornerRadius = 25.0
        myLabel2.layer.masksToBounds = true
        myLabel2.isUserInteractionEnabled = true
        vw.addSubview(myLabel2)
        
        let separatorLineView2 = UIView(frame: .init(x: 80, y: 75, width: 50, height: 2.5))
        separatorLineView2.backgroundColor = .white
        vw.addSubview(separatorLineView2)
        
        let myLabel3:UILabel = UILabel(frame: .init(x: 150, y: 15, width: 50, height: 50))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = .white
        myLabel3.textColor = .black
        myLabel3.textAlignment = .center
        myLabel3.text = "Active"
        myLabel3.font = Font.celltitle14m
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.layer.masksToBounds = true
        myLabel3.isUserInteractionEnabled = true
        vw.addSubview(myLabel3)
        
        myLabel4.numberOfLines = 1
        myLabel4.backgroundColor = .clear
        myLabel4.textColor = .black
        myLabel4.layer.masksToBounds = true
        myLabel4.text = self.postBy
        vw.addSubview(myLabel4)
        
        myLabel5.numberOfLines = 0
        myLabel5.backgroundColor = .clear
        myLabel5.textColor = .black
        myLabel5.layer.masksToBounds = true
        myLabel5.text = self.comments
        vw.addSubview(myLabel5)
        
        if (self.formController == "Leads") || (self.formController == "Customer") {
            
            var dateStr = self.leadDate
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                MasterViewController.dateFormatter.dateFormat = "yyyy-MM-dd"
            } else {
                //firebase
                MasterViewController.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
            }
            
            let date:Date = (MasterViewController.dateFormatter.date(from: dateStr!) as Date?)!
            MasterViewController.dateFormatter.dateFormat = "MMM dd, yyyy"
            dateStr = MasterViewController.dateFormatter.string(from: date)as String?
        
            var newString6 : String
            if (self.formController == "Leads") {
                newString6 = String(format: "%@%@", "Lead since ", dateStr!)
                myLabel6.text = newString6
            } else if (self.formController == "Customer") {
                newString6 = String(format: "%@%@", "Customer since ", dateStr!)
                myLabel6.text = newString6
            } else if (self.formController == "Blog") {
                newString6 = String(format: "%@%@", "Member since ", (self.leadDate)!)
                myLabel6.text = newString6
            }
        }
    
        myLabel6.numberOfLines = 1
        myLabel6.backgroundColor = .clear
        myLabel6.textColor = .black
        myLabel6.layer.masksToBounds = true
        vw.addSubview(myLabel6)
        
        let separatorLineView3 = UIView(frame: .init(x: 150, y: 75, width: 50, height: 2.5))
        separatorLineView3.backgroundColor = .white
        vw.addSubview(separatorLineView3)
        
        return vw
    }
    
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
    
    // MARK: - Parse
    func loadData() {
        
        if (self.formController == "Leads") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Customer")
                query.limit = 1000
                query.whereKey("LastName", equalTo:self.postBy!)
                query.cachePolicy = .cacheThenNetwork
                query.order(byDescending: "createdAt")
                query.findObjectsInBackground { objects, error in
                    if error == nil {
                        let temp: NSArray = objects! as NSArray
                        self._feedItems = temp.mutableCopy() as! NSMutableArray
                        
                        if (self._feedItems.count == 0) {
                            self.tableView!.addSubview(self.emptyLabel!)
                        } else {
                            self.emptyLabel!.removeFromSuperview()
                        }
                        
                        self.tableView!.reloadData()
                    } else {
                        print("Error")
                    }
                }
                
                let query1 = PFQuery(className:"Leads")
                query1.limit = 1
                query1.whereKey("objectId", equalTo:self.objectId!)
                query1.cachePolicy = .cacheThenNetwork
                query1.order(byDescending: "createdAt")
                query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.comments = object!.object(forKey: "Coments") as? String
                        self.leadDate = object!.object(forKey: "Date") as? String
                        self.tableView!.reloadData()
                    } else {
                        print("Error")
                    }
                }
            } else {
                //firebase
                
            }
        } else if (self.formController == "Customer") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Leads")
                query.limit = 1000
                query.whereKey("LastName", equalTo:self.postBy!)
                query.cachePolicy = .cacheThenNetwork
                query.order(byDescending: "createdAt")
                query.findObjectsInBackground { objects, error in
                    if error == nil {
                        let temp: NSArray = objects! as NSArray
                        self._feedItems = temp.mutableCopy() as! NSMutableArray
                        
                        if (self._feedItems.count == 0) {
                            self.tableView!.addSubview(self.emptyLabel!)
                        } else {
                            self.emptyLabel!.removeFromSuperview()
                        }
                        
                        self.tableView!.reloadData()
                    } else {
                        print("Error")
                    }
                }
                
                let query1 = PFQuery(className:"Customer")
                query1.limit = 1
                query1.whereKey("objectId", equalTo:self.objectId!)
                query1.cachePolicy = .cacheThenNetwork
                query1.order(byDescending: "createdAt")
                query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.comments = object!.object(forKey: "Comments") as? String
                        self.leadDate = object!.object(forKey: "Date") as? String
                        self.tableView!.reloadData()
                    } else {
                        print("Error")
                    }
                }
            } else {
                //firebase
                
            }
        } else if (self.formController == "Blog") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Blog")
                query.limit = 1000
                query.whereKey("PostBy", equalTo:self.postBy!)
                query.cachePolicy = .cacheThenNetwork
                query.order(byDescending: "createdAt")
                query.findObjectsInBackground { objects, error in
                    if error == nil {
                        let temp: NSArray = objects! as NSArray
                        self._feedItems = temp.mutableCopy() as! NSMutableArray
                        
                        if (self._feedItems.count == 0) {
                            self.tableView!.addSubview(self.emptyLabel!)
                        } else {
                            self.emptyLabel!.removeFromSuperview()
                        }
                        
                        self.tableView!.reloadData()
                    } else {
                        print("Error")
                    }
                }
                
                let query1:PFQuery = PFUser.query()!
                query1.whereKey("username",  equalTo:self.postBy!)
                query1.limit = 1
                query1.cachePolicy = .cacheThenNetwork
                query1.getFirstObjectInBackground { object, error in
                    if error == nil {
                        
                        self.postBy = object!.object(forKey: "username") as? String
                        /*
                         let dateStr = (object!.objectForKey("createdAt") as? NSDate)!
                         let dateFormatter = NSDateFormatter()
                         dateFormatter.dateFormat = "MMM dd, yyyy"
                         let createAtString = dateFormatter.stringFromDate(dateStr)as String!
                         self.leadDate = createAtString */
                        
                        /*
                         if let imageFile = object!.objectForKey("imageFile") as? PFFile {
                         imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) in
                         self.selectedImage = UIImage(data: imageData!)
                         self.tableView!.reloadData()
                         }
                         } */
                    }
                }
            } else {
                //firebase
                
            }
        }
    }
}
