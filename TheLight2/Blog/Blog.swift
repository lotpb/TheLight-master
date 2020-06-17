//
//  Blog.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseAuth
import Social


@available(iOS 13.0, *)
final class Blog: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [BlogModel]()
    private let searchScope = ["subject", "date", "rating", "postby"]

    //firebase
    var bloglist = [BlogModel]()
    var userlist = [UserModel]()
    var defaults = UserDefaults.standard
    private var userCount: Int?
    private var likeCount: Int?
    //parse
    var _feedItems = NSMutableArray()
    var _feedheadItems2 = NSMutableArray()
    var _feedheadItems3 = NSMutableArray()
    
    var pasteBoard = UIPasteboard.general
    var buttonView: UIView?
    var likeButton: UIButton?
    var isReplyClicked = true
    var posttoIndex: String?
    var userIndex: String?
    var titleLabel = String()
    var profileImageView : UIImageView?

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.twitterText
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
        setupSearch()
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
        
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(Blog.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        let tabArray = self.tabBarController?.tabBar.items as NSArray?
        let tabItem = tabArray?.object(at: 1) as? UITabBarItem
        tabItem?.badgeValue = nil
        
        setupBlogNavigationBar()
        setupTwitterNavigationBarItems()
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
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.tintColor = ColorX.twitterBlue
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = .white
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }
        searchController.searchResultsUpdater = self
        searchController.searchBar.scopeButtonTitles = searchScope
        
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationController?.navigationBar.topItem?.searchController = searchController

        self.navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        self.definesPresentationContext = true
    }
    
    func setupNavigation() {
        navigationItem.title = "Blog"
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    func setupTableView() {
        // MARK: - TableHeader
        tableView.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableView.automaticDimension
        self.tableView!.sizeToFit()
        self.tableView!.clipsToBounds = true
        self.tableView!.backgroundColor = .systemGray4
        self.tableView!.tableFooterView = UIView(frame: .zero)

        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.backgroundColor = ColorX.LGrayColor
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
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
    
    // MARK: - refresh
    @objc func refreshData(_ sender: AnyObject) {
        bloglist.removeAll() //fix
        userlist.removeAll() //fix
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newButton(_ sender: AnyObject) {
        isReplyClicked = false
        self.performSegue(withIdentifier: "blognewSegue", sender: self)
    }
    
    @objc func likeSetButton(_ sender: UIButton) {
        sender.isSelected = true
        sender.tintColor = ColorX.twitterBlue
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFQuery(className:"Blog")
            query.whereKey("objectId", equalTo:((_feedItems.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    object!.incrementKey("Liked")
                    object!.saveInBackground()
                }
            }
        } else {
            //firebase
            let likeStr = bloglist[(indexPath?.row)!].blogId
            let reflikes = FirebaseRef.databaseRoot.child("Blog").child(likeStr!).child("liked")
            reflikes.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                var value = currentData.value as? Int
                if value == nil {
                    value = 0
                }
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }
        }
    }
    
    @objc func replySetButton(_ sender:UIButton) {
 
        isReplyClicked = true
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            posttoIndex = (_feedItems.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "PostBy") as? String
            userIndex = (_feedItems.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String
        } else {
            //firebase
            posttoIndex = bloglist[(indexPath?.row)!].postBy
            userIndex = bloglist[(indexPath?.row)!].blogId
        }
        self.performSegue(withIdentifier: "blognewSegue", sender: self)
    }
    
    @objc func flagSetButton(_ sender:UIButton) {
        
    }

    // MARK: - Parse/Firebase
    private func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFQuery(className:"Blog")
            query.limit = 1000
            query.whereKey("ReplyId", equalTo:NSNull())
            query.cachePolicy = .cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp : NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.tableView?.reloadData()
                } else {
                    print("Error9")
                }
            }
            
            let query1 = PFQuery(className:"Blog")
            query1.limit = 1000
            //query1.whereKey("Rating", equalTo:"5")
            query1.whereKey("Liked", notEqualTo:NSNull())
            query1.cachePolicy = .cacheThenNetwork
            query1.order(byDescending: "createdAt")
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedheadItems2 = temp.mutableCopy() as! NSMutableArray
                    self.tableView?.reloadData()
                } else {
                    print("Error10")
                }
            }
            
            let query3 = PFUser.query()
            query3?.limit = 1000
            query3?.cachePolicy = .cacheThenNetwork
            query3?.order(byDescending: "createdAt")
            query3?.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedheadItems3 = temp.mutableCopy() as! NSMutableArray
                    self.tableView?.reloadData()
                } else {
                    print("Error11")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Blog")
                .queryOrdered(byChild: "replyId")
                .queryEqual(toValue: "")
                .observe(.childAdded , with:{ (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    //guard let user = self.user else {return}  //added
                    let post = BlogModel(dictionary: dictionary)
                    self.bloglist.append(post)
                    
                    self.bloglist.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
                }) { (err) in
                    print("Failed to fetch posts:", err)
            }
            
            FirebaseRef.databaseRoot.child("Blog")
                .queryOrdered(byChild: "liked") //inludes reply likes
                .queryStarting(atValue: 1)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    self.likeCount = Int(snapshot.childrenCount)
                    self.tableView?.reloadData()
                })
            
            FirebaseRef.databaseRoot.child("users")
                .queryOrdered(byChild: "username")
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    self.userCount = Int(snapshot.childrenCount)
                    self.tableView?.reloadData()
                })
        }
    }
    
    // MARK: - Delete
    func deleteBlog(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            if (self.defaults.bool(forKey: "parsedataKey")) {
                let query = PFQuery(className:"Blog")
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
                Database.database().reference().child("Blog").child(name).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                    self.refreshData(self)
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
    
    // MARK: - AlertController
    @objc func showShare(sender: UIButton) {
        
        let socialText: String?
        let url = URL.init(string: "http://lotpb.github.io/UnitedWebPage/index.html")!
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            socialText = (self._feedItems[indexPath!.row] as AnyObject).value(forKey: "Subject") as? String
        } else {
            //firebase
            socialText = bloglist[(indexPath?.row)!].subject
        }
        
        let share = [socialText!, url] as [Any]
        let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }
    
    // MARK: - imgLoadSegue
    @objc func imgLoadSegue(sender: UITapGestureRecognizer) {
    //@objc func imgLoadSegue(_ sender: UITapGestureRecognizer) {
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            titleLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "PostBy") as? String)!
        } else {
            titleLabel = bloglist[(sender.view!.tag)].postBy
        }
        self.performSegue(withIdentifier: "bloguserSegue", sender: self)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blogeditSegue" {
            guard let VC = segue.destination as? BlogEditController else { return }
            
            if navigationItem.searchController?.isActive == true {
                //search
                let indexPath = self.resultsController.tableView!.indexPathForSelectedRow!.row
                let blog: BlogModel
                blog = filteredTitles[indexPath]
                
                VC.objectId = blog.blogId
                VC.msgNo = blog.uid
                VC.uid = blog.uid
                VC.postby = blog.postBy
                VC.subject = blog.subject
                VC.msgDate = String(describing: blog.creationDate)
                VC.rating = blog.rating
                VC.liked = blog.liked as? Int
                VC.commentNum = blog.commentCount as? Int
                VC.replyId = blog.replyId
            } else {
                
                let indexPath = self.tableView!.indexPathForSelectedRow!.row
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    
                    VC.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
                    VC.msgNo = (_feedItems[indexPath] as AnyObject).value(forKey: "MsgNo") as? String
                    VC.postby = (_feedItems[indexPath] as AnyObject).value(forKey: "PostBy") as? String
                    VC.subject = (_feedItems[indexPath] as AnyObject).value(forKey: "Subject") as? String
                    VC.msgDate = (_feedItems[indexPath] as AnyObject).value(forKey: "MsgDate") as? String
                    VC.rating = (_feedItems[indexPath] as AnyObject).value(forKey: "Rating") as? String
                    VC.liked = (_feedItems[indexPath] as AnyObject).value(forKey: "Liked") as? Int
                    VC.commentNum = (_feedItems[indexPath] as AnyObject).value(forKey: "CommentCount") as? Int
                    VC.replyId = (_feedItems[indexPath] as AnyObject).value(forKey: "ReplyId") as? String
                } else {
                    //firebase
                    VC.objectId = bloglist[indexPath].blogId
                    VC.msgNo = bloglist[indexPath].uid
                    VC.uid = bloglist[indexPath].uid
                    VC.postby = bloglist[indexPath].postBy
                    VC.subject = bloglist[indexPath].subject
                    VC.msgDate = String(describing: bloglist[indexPath].creationDate)
                    VC.rating = bloglist[indexPath].rating
                    VC.liked = bloglist[indexPath].liked as? Int
                    VC.commentNum = bloglist[indexPath].commentCount as? Int
                    VC.replyId = bloglist[indexPath].replyId
                    //VC.profileImage = profileImageView?.image
                }
            }
        }
        if segue.identifier == "blognewSegue" {
            guard let VC = segue.destination as? BlogNewController else { return }
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                print("No Parse")
            } else {
                guard let uid = Auth.auth().currentUser?.uid else {return}
                VC.textcontentuid = uid
            }
            
            VC.textcontentpostby = defaults.string(forKey: "usernameKey")!

            if isReplyClicked == true {
                VC.formStatus = "Reply"
                VC.textcontentsubject = String(format: "%@", "@\(posttoIndex!.removingWhitespaces()) ")
                VC.replyId = String(format:"%@", userIndex!)
            } else {
                VC.formStatus = "New"
            }
        }
        if segue.identifier == "bloguserSegue" { //fix
            guard let VC = segue.destination as? LeadUserVC else { return }
            VC.formController = "Blog"
            VC.postBy = titleLabel
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}
@available(iOS 13.0, *)
extension Blog: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "blogeditSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return self._feedItems.count
            } else {
                return self.bloglist.count
            }
        } else {
            return filteredTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if (tableView == self.tableView) {
            
            cellIdentifier = "Cell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableViewCell else { fatalError("Unexpected Index Path") }
            
            cell.selectionStyle = .none
            cell.backgroundColor = .secondarySystemGroupedBackground
            cell.blogtitleLabel.textColor = .label
            cell.blogmsgDateLabel?.textColor = .systemGray
            cell.blogsubtitleLabel?.textColor = ColorX.twitterText
            cell.customImagelabel.backgroundColor = .clear //fix
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                
                cell.blogtitleLabel!.font =  Font.Blog.celltitlePad
                cell.blogsubtitleLabel!.font =  Font.Blog.cellsubtitlePad
                cell.blogmsgDateLabel.font = Font.Blog.celldatePad
                cell.numLabel.font = Font.Blog.cellLabel
                cell.commentLabel.font = Font.Blog.cellLabel
                
            } else {
                
                cell.blogtitleLabel!.font =  Font.Blog.celltitle
                cell.blogsubtitleLabel!.font =  Font.celltitle18r
                cell.blogmsgDateLabel.font = Font.Blog.celldate
                cell.numLabel.font = Font.Blog.cellLabel
                cell.commentLabel.font = Font.Blog.cellLabel
            }
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query:PFQuery = PFUser.query()!
                query.whereKey("username",  equalTo: (self._feedItems[indexPath.row] as AnyObject).value(forKey:"PostBy") as! String)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                            imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
                                cell.customImageView.image = UIImage(data: imageData! as Data)
                            }
                        }
                    }
                } 
                
                let dateStr = (_feedItems[indexPath.row] as AnyObject).value(forKey: "MsgDate") as? String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date:NSDate = (dateFormatter.date(from: dateStr!)as NSDate?)!
                
                dateFormatter.dateFormat = "h:mm a"
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                let secondInDays: TimeInterval = 60 * 60 * 24
                if elapsedTimeInSeconds > 7 * secondInDays {
                    dateFormatter.dateFormat = "MMM-dd"
                } else if elapsedTimeInSeconds > secondInDays {
                    dateFormatter.dateFormat = "EEE"
                }
                
                cell.blogtitleLabel?.text = (_feedItems[indexPath.row] as AnyObject).value(forKey:"PostBy") as? String
                cell.blogsubtitleLabel?.text = (_feedItems[indexPath.row] as AnyObject).value(forKey:"Subject") as? String
                cell.blogmsgDateLabel?.text = dateFormatter.string(from: date as Date)as String?
                
                var Liked:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey:"Liked")as? Int
                if Liked == nil { Liked = 0 }
                cell.numLabel?.text = "\(Liked!)"
                
                var CommentCount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey:"CommentCount") as? Int
                if CommentCount == nil { CommentCount = 0 }
                cell.commentLabel?.text = "\(CommentCount!)"
                
            } else {
                //firebase
                cell.blogpost = bloglist[indexPath.row]
                //self.profileImageView = cell.customImageView
            }
            
            cell.replyButton.tintColor = .lightGray
            cell.replyButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
            cell.replyButton .addTarget(self, action: #selector(replySetButton), for: .touchUpInside)
            
            cell.likeButton.tintColor = .lightGray
            cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            cell.likeButton.addTarget(self, action: #selector(likeSetButton), for: .touchUpInside)
            
            cell.flagButton.tintColor = .lightGray
            cell.flagButton.setImage(UIImage(systemName: "flag.fill"), for: .normal)
            cell.flagButton .addTarget(self, action: #selector(flagSetButton), for: .touchUpInside)
            
            cell.actionBtn.tintColor = .lightGray
            cell.actionBtn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            cell.actionBtn .addTarget(self, action: #selector(showShare), for: .touchUpInside)
            
            if !(cell.numLabel.text! == "0") {
                cell.numLabel.textColor = ColorX.Blog.buttonColor
            } else {
                cell.numLabel.text! = ""
            }
            
            if !(cell.commentLabel.text! == "0") {
                cell.commentLabel.textColor = .lightGray
            } else {
                cell.commentLabel.text! = ""
            }
            
            if (cell.commentLabel.text! == "") {
                cell.replyButton.tintColor = .lightGray
            } else {
                cell.replyButton.tintColor = ColorX.Blog.buttonColor
            }
            
            //fix dont work
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgLoadSegue))
            cell.customImageView.addGestureRecognizer(tap)
            
            //---------------------NSDataDetector-----------------------------

            let myText = NSString(string: cell.blogsubtitleLabel.text!)
            let attributedText = NSMutableAttributedString(string: myText as String)
            
            let boldRange = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: ColorX.Blog.weblinkText]
            let highlightedRange = [NSAttributedString.Key.backgroundColor: ColorX.Blog.phonelinkText]
            let underlinedRange = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let tintedRange1 = [NSAttributedString.Key.foregroundColor: ColorX.Blog.weblinkText]
            
            attributedText.addAttributes(boldRange, range: myText.range(of: "VCSY"))
            attributedText.addAttributes(highlightedRange, range: myText.range(of: "passed"))
            attributedText.addAttributes(underlinedRange, range: myText.range(of: "Lost", options: .caseInsensitive))
            attributedText.addAttributes(underlinedRange, range: myText.range(of: "Made", options: .caseInsensitive))

            let types: NSTextCheckingResult.CheckingType = [.date, .address, .phoneNumber, .link]
            let detector = try! NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: String(myText), options: [], range: NSMakeRange(0, String(myText).count))
            
            for match in matches {
                let url = myText.substring(with: match.range)
                attributedText.addAttributes(tintedRange1, range: myText.range(of: url))
            }
            
            cell.blogsubtitleLabel!.attributedText = attributedText
            
            //---------------------NSDataDetector-----------------------------
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            cell.textLabel!.numberOfLines = 3
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                //parse
                cell.textLabel!.text = (filteredTitles[indexPath.row] as AnyObject).value(forKey:"Subject") as? String

            } else {
                cell.textLabel!.numberOfLines = 3
                let blog: BlogModel
                blog = filteredTitles[indexPath.row]
                cell.textLabel!.text = blog.subject
            }
            
            return cell
        }
    }
}
@available(iOS 13.0, *)
extension Blog: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.tableView) {
            if UIDevice.current.userInterfaceIdiom == .phone  {
                return 85.0
            } else {
                return CGFloat.leastNormalMagnitude
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //if(section == 0) {
            if (tableView == self.tableView) {
                
                if UIDevice.current.userInterfaceIdiom == .phone  {
                    guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        header.myLabel1.text = String(format: "%@%d", "posts\n", _feedItems.count)
                        header.myLabel2.text = String(format: "%@%d", "likes\n", _feedheadItems2.count)
                        header.myLabel3.text = String(format: "%@%d", "users\n", _feedheadItems3.count)
                    } else {
                        header.myLabel1.text = String(format: "%@%d", "posts\n", bloglist.count)
                        header.myLabel2.text = String(format: "%@%d", "likes\n", likeCount ?? 0)
                        header.myLabel3.text = String(format: "%@%d", "users\n", userCount ?? 0)
                    }
                    header.separatorView1.backgroundColor = ColorX.Blog.borderColor
                    header.separatorView2.backgroundColor = ColorX.Blog.borderColor
                    header.separatorView3.backgroundColor = ColorX.Blog.borderColor
                    header.contentView.backgroundColor = ColorX.Blog.navColor
                    self.tableView!.tableHeaderView = nil //header.header
                    
                    return header.contentView
                    
                } else {
                    return nil
                }
            } else {
                return nil
            }
        // } else {
            //return nil
        //}
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
    
    // MARK: - Content Menu
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            let commentNum : Int?
            let deleteStr : String?
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                commentNum = (self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "CommentCount") as? Int
            } else {
                //firebase
                commentNum = bloglist[indexPath.row].commentCount as? Int
            }
            
            if (commentNum == nil || commentNum == 0) {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    deleteStr = ((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!
                    _feedItems.removeObject(at: indexPath.row)
                } else {
                    //firebase
                    deleteStr = bloglist[indexPath.row].blogId!
                    self.bloglist.remove(at: indexPath.row)
                }
                
                self.deleteBlog(name: deleteStr!)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } else {
                self.showAlert(title: "Oops!", message: "Record can't be deleted.")
            }
            
        } else if editingStyle == .insert {
            
        }
    }
    
    // MARK: - search
    func filterContentForSearchText(searchText: String, scope: String = "subject") {
        
        filteredTitles = bloglist.filter { (blog: BlogModel) in
            let target: String
            switch(scope.lowercased()) {
            case "subject":
                target = blog.subject
            case "date":
                target = String(describing: blog.creationDate) //fix
            case "rating":
                target = blog.rating
            case "postby":
                target = blog.postBy
            default:
                target = blog.subject
            }
            return target.lowercased().contains(searchText.lowercased())
        }
        
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
        }
    }
}
@available(iOS 13.0, *)
extension Blog: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}


