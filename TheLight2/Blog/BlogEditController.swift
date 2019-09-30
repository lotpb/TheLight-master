//
//  BlogEditViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/14/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

final class BlogEditController: UIViewController {
    
    var replylist = [BlogModel]()
    var user: UserModel?
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var listTableView: UITableView?
    @IBOutlet weak var toolBar: UIToolbar?
    @IBOutlet weak var Like: UIButton?
    @IBOutlet weak var update: UIButton?
    
    var _feedItems = NSMutableArray()
    var _feedItems1 = NSMutableArray()
    var filteredString = NSMutableArray()
    var objects = [AnyObject]()
    var pasteBoard = UIPasteboard.general
 
    var objectId : String?
    var msgNo : String?
    var postby : String?
    var subject : String?
    var msgDate : String?
    var rating : String?
    var replyId : String?
    var uid : String?
    var liked : Int?
    var commentNum : Int?
    
    // listTableView Reply
    var posttoIndex: String?
    var userIndex: String?
    var isReplyClicked = false
    var defaults = UserDefaults.standard
    
    // listTableView NSDataDetector
    var myText: NSString = ""
    var myInput: String = ""
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.twitterText
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationButtons()
        setupTableView()
        setupForm()
        loadData()
        self.tableView!.addSubview(self.refreshControl)
        self.listTableView!.register(ReplyTableCell.self, forCellReuseIdentifier: "ReplyCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(sender: self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTwitterNavigationBarItems()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false //fix
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationButtons() {
        let actionBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        let trashBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        navigationItem.rightBarButtonItems = [actionBtn,trashBtn]
    }
    
    func setupForm() {
        
        self.view.backgroundColor = .lightGray
        if #available(iOS 13.0, *) {
            self.toolBar!.barTintColor = .systemGray
        } else {
            self.toolBar!.barTintColor = .white
        }
        //self.toolBar!.isTranslucent = false set in AppDelegate
        self.toolBar!.layer.masksToBounds = true
        
        self.Like!.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        if #available(iOS 13.0, *) {
            self.Like!.setTitleColor(.label, for: .normal)
        } else {
            self.Like!.setTitleColor(.systemGray, for: .normal)
        }
        self.Like?.frame = .init(x: 0, y: 0, width: 90, height: 30)
        if (self.liked == nil) || (self.liked == 0)  {
            self.Like!.tintColor = .lightGray
            self.Like!.setTitle(" Like", for: .normal)
        } else {
            self.Like!.tintColor = Color.Blog.buttonColor
            self.Like!.setTitle(" Likes \(liked!)", for: .normal)
        }
        
        self.update?.frame = .init(x: 0, y: 0, width: 60, height: 30)
        self.update?.backgroundColor = Color.twitterBlue
        self.update?.setTitleColor(.white, for: .normal)
        let btnLayer: CALayer = self.update!.layer
        btnLayer.cornerRadius = 9.0
        btnLayer.masksToBounds = true
        
        let width = CGFloat(2.0)
        let topBorder = CALayer()
        topBorder.borderColor = UIColor.lightGray.cgColor
        topBorder.frame = .init(x: 0, y: 0, width: view.bounds.width, height: 0.5)
        topBorder.borderWidth = width
        self.toolBar!.layer.addSublayer(topBorder)
        
        let bottomBorder = CALayer()
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        bottomBorder.frame = .init(x: 0, y: 43, width: view.bounds.width, height: 0.5)
        bottomBorder.borderWidth = width
        self.toolBar!.layer.addSublayer(bottomBorder)
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableView.automaticDimension
        
        
        self.listTableView!.delegate = self
        self.listTableView!.dataSource = self
        self.listTableView!.estimatedRowHeight = 75
        self.listTableView!.rowHeight = UITableView.automaticDimension
        self.listTableView!.tableFooterView = UIView(frame: .zero)
        
        if #available(iOS 13.0, *) {
            self.tableView!.backgroundColor = .systemGray4
            self.listTableView!.backgroundColor = .systemGray4
        } else {
            self.tableView!.backgroundColor = .white
            self.listTableView!.backgroundColor = .white
        }
    }
    
    @objc func refreshData(sender:AnyObject) {
        replylist.removeAll() //fix
        loadData()
        self.refreshControl.endRefreshing()
    }

    // MARK: - Button
    @IBAction func updateButton(sender: UIButton) {
        self.performSegue(withIdentifier: "blogeditSegue", sender: self)
    }
    
    @objc func likeButton(sender: UIButton) {
        
        sender.isSelected = true
        sender.tintColor = Color.twitterBlue
        let hitPoint = sender.convert(CGPoint.zero, to: self.listTableView)
        let indexPath = self.listTableView!.indexPathForRow(at: hitPoint)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query = PFQuery(className:"Blog")
            query.whereKey("objectId", equalTo: ((_feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    object!.incrementKey("Liked")
                    object!.saveInBackground()
                }
            }
        } else {
            //firebase
            let likeStr = replylist[(indexPath?.row)!].blogId
            let refReservations = FirebaseRef.databaseBlog.child(likeStr!).child("liked")
            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                var value = currentData.value as? Int
                if value == nil {
                    value = 0
                }
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }
        }
    }
    
    @objc func shareButton(_ sender: AnyObject) {
        
        let AV = UIActivityViewController (
            activityItems: [self.subject! as String],
            applicationActivities: nil)
        
        if let popoverController = AV.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(AV, animated: true)
    }
 
    @objc func deleteButton(_ sender: AnyObject) {
        
        if (commentNum == nil || commentNum == 0) {
            deleteBlog(name: self.objectId!)
        } else {
            self.simpleAlert(title: "Oops!", message: "Record can't be deleted.")
        }
    }
    
    func deleteBlog(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                let query = PFQuery(className:"Blog")
                query.whereKey("objectId", equalTo: name)
                query.findObjectsInBackground(block: { objects, error in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
                            self.navigationController?.popViewController(animated: true)
                            self.deincrementComment()
                        }
                    }
                })
            } else {
                //firebase
                Database.database().reference().child("Blog").child(name).removeValue(completionBlock: { (error, ref) in
                //FirebaseRef.databaseBlog.child(name).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                    self.navigationController?.popViewController(animated: true)
                    self.deincrementComment()
                    self.listTableView?.reloadData()
                })
            }
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.success)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            return
        }
        alertController.addAction(cancelAction)
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }
    
    // MARK: - AlertController
    @objc func replyShare(sender: UIButton) {
        
        let hitPoint = sender.convert(CGPoint.zero, to: self.listTableView)
        let indexPath = self.listTableView!.indexPathForRow(at: hitPoint)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let replyAction = UIAlertAction(title: "Reply", style: .default) { (alert: UIAlertAction!) in
            
            self.isReplyClicked = true
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                self.posttoIndex = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "PostBy") as? String
            } else {
                //firebase
                self.posttoIndex = self.replylist[(indexPath?.row)!].postBy
            }
            
            self.userIndex = self.objectId
            self.performSegue(withIdentifier: "blogeditSegue", sender: self)
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (alert: UIAlertAction!) in
        
            self.isReplyClicked = false
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                self.objectId = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String
                self.msgNo = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "MsgNo") as? String
                self.postby = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "PostBy") as? String
                self.subject = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Subject") as? String
                self.msgDate = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "MsgDate") as? String
                self.rating = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Rating") as? String
                self.liked = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Liked") as? Int
                self.replyId = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "ReplyId") as? String
            } else {
                //firebase
                self.objectId = self.replylist[(indexPath?.row)!].blogId
                self.msgNo = self.replylist[(indexPath?.row)!].blogId
                self.postby = self.replylist[(indexPath?.row)!].postBy
                self.subject = self.replylist[(indexPath?.row)!].subject
                self.msgDate = self.replylist[(indexPath?.row)!].creationDate.timeAgoDisplay()
                self.rating = self.replylist[(indexPath?.row)!].rating
                self.liked = self.replylist[(indexPath?.row)!].liked as? Int
                self.replyId = self.replylist[(indexPath?.row)!].replyId
            }
            
            self.performSegue(withIdentifier: "blogeditSegue", sender: self)
        }
        
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (alert: UIAlertAction!) in
            
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                self.pasteBoard.string = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Subject") as? String
            } else {
                //firebase
                self.pasteBoard.string = self.replylist[(indexPath?.row)!].subject
            }
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) in
            
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                self.deleteBlog(name: ((self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
            } else {
                //firebase
                self.deleteBlog(name: self.replylist[(indexPath?.row)!].blogId!)
            }
        }
        
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel) { (action) in
        }
        actionSheet.addAction(replyAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(copyAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(dismissAction)
        
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sender
            actionSheet.popoverPresentationController?.permittedArrowDirections = .any
            //actionSheet.popoverPresentationController?.sourceRect = .init(x: 0, y: 0, width: 0, height: 0)
        }
        self.present(actionSheet, animated: true)
    }
    
    // MARK: - Load Data
    func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query1 = PFQuery(className:"Blog")
            query1.whereKey("ReplyId", equalTo:self.objectId!)
            query1.cachePolicy = .cacheThenNetwork
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems1 = temp.mutableCopy() as! NSMutableArray
                    self.listTableView!.reloadData()
                } else {
                    print("Error")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Blog")
                .queryOrdered(byChild: "replyId")
                .queryEqual(toValue: self.objectId!)
                .observe(.childAdded , with:{ (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let post = BlogModel(dictionary: dictionary)
                    self.replylist.append(post)
                    
                    DispatchQueue.main.async(execute: {
                        self.listTableView?.reloadData()
                    })
                }) { (err) in
                    print("Failed to fetch posts:", err)
            }
        }
    }
    
    // MARK: Deincrement Comment
    func deincrementComment() {
        
        if (commentNum == nil || commentNum == 0) { return }
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query = PFQuery(className:"Blog")
            query.whereKey("objectId", equalTo: self.objectId!)
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    object?.incrementKey("CommentCount", byAmount: NSNumber(value: -1))
                    object?.saveInBackground()
                }
            }
        } else {
            //firebase
            let refReservations = FirebaseRef.databaseRoot.child("Blog").child(self.objectId!).child("commentCount")
            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                
                var value = currentData.value as? Int
                if value == nil {
                    value = 0
                }
                currentData.value = value! - 1
                return TransactionResult.success(withValue: currentData)
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blogeditSegue" {
            guard let VC = segue.destination as? BlogNewController else { return }
            if isReplyClicked == true {
                VC.formStatus = "Reply"
                VC.textcontentsubject = String(format: "%@", "@\(posttoIndex!.removingWhitespaces()) ")
                VC.textcontentpostby = defaults.string(forKey: "usernameKey")
                VC.replyId = String(format:"%@", userIndex!)
            } else {
                VC.formStatus = "None"
                VC.textcontentobjectId = self.objectId
                VC.textcontentuid = self.uid //firebase
                VC.textcontentmsgNo = self.msgNo
                VC.textcontentpostby = self.postby
                VC.textcontentsubject = self.subject
                VC.textcontentdate = self.msgDate
                VC.textcontentrating = self.rating
                VC.textcontentreplyId = self.replyId
                VC.liked = self.liked
            }
        }
    }
}
extension BlogEditController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.tableView) {
            return 1
        } else if (tableView == self.listTableView) {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedItems1.count
            } else {
                //firebase
                return replylist.count
            }
        } else {
          return filteredString.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableViewCell else { fatalError("Unexpected Index Path") }
            
            cell.selectionStyle = .none
            if #available(iOS 13.0, *) {
                cell.titleLabel?.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            cell.subtitleLabel?.textColor = Color.twitterText
            cell.customImageView.frame = .init(x: 15, y: 11, width: 50, height: 50)
            cell.customImageView.layer.cornerRadius = 0
            cell.customImageView.layer.borderWidth = 0
            cell.customImagelabel.backgroundColor = .clear //fix
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                
                cell.titleLabel!.font = Font.Blog.celltitlePad
                cell.subtitleLabel!.font = Font.Blog.cellsubtitlePad
                cell.msgDateLabel.font = Font.Blog.celldatePad
                
            } else {
                
                cell.titleLabel!.font = Font.Blog.celltitle
                cell.subtitleLabel!.font = Font.celltitle20r
                cell.msgDateLabel.font = Font.Blog.celldate
            }
            
            let dateFormatter = DateFormatter()
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query:PFQuery = PFUser.query()!
                query.whereKey("username",  equalTo:self.postby!)
                query.limit = 1
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                            imageFile.getDataInBackground { imageData, error in
                                cell.customImageView.image = UIImage(data: imageData!)
                            }
                        }
                    }
                }
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("users")
                    .queryOrdered(byChild: "uid")
                    .queryEqual(toValue: self.msgNo)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            let blogImageUrl = userDict["profileImageUrl"] as? String
                            cell.customImageView.loadImage(urlString: blogImageUrl!)
                        }
                    })
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
            }
            
            
            //fix date
            /*
            let dateStr = self.msgDate
            let date:Date = dateFormatter.date(from: "\(String(describing: dateStr))")!
            dateFormatter.dateFormat = "MM/dd/yy, h:mm a"
            cell.msgDateLabel.text = dateFormatter.string(from: (date) as Date) */
 
            cell.msgDateLabel.text = self.msgDate

            cell.titleLabel!.text = self.postby
            cell.subtitleLabel!.text = self.subject
 
            //---------------------NSDataDetector 1 of 2-----------------------------
 
            let myText = NSString(string: self.subject!)
            let attributedText = NSMutableAttributedString(string: myText as String)
            
            let boldRange = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: Color.Blog.weblinkText]
            let highlightedRange = [NSAttributedString.Key.backgroundColor: Color.Blog.phonelinkText]
            let underlinedRange = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let tintedRange1 = [NSAttributedString.Key.foregroundColor: Color.Blog.weblinkText]
            
            attributedText.addAttributes(boldRange, range: myText.range(of: "VCSY"))
            attributedText.addAttributes(highlightedRange, range: myText.range(of: "passed"))
            attributedText.addAttributes(underlinedRange, range: myText.range(of: "Lost", options: .caseInsensitive))
            attributedText.addAttributes(underlinedRange, range: myText.range(of: "Made", options: .caseInsensitive))
            
            let types: NSTextCheckingResult.CheckingType = [.date, .phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            let matches = detector?.matches(in: String(myText), options: [], range: NSMakeRange(0, (String(myText).count)))
            
            for match in matches! {
                let url = myText.substring(with: match.range)
                attributedText.addAttributes(tintedRange1, range: myText.range(of: url))
            }
            
            cell.subtitleLabel!.attributedText = attributedText
            
            //--------------------------------------------------
            
            return cell
            
        } else if tableView == self.listTableView {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as? ReplyTableCell else { fatalError("Unexpected Index Path") }
            
            cell.selectionStyle = .none
            cell.replydateLabel.textColor = .systemGray
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                
                cell.replytitleLabel.font = Font.BlogEdit.replytitlePad
                cell.replysubtitleLabel.font = Font.BlogEdit.replysubtitlePad
                cell.replylikeLabel.font = Font.BlogEdit.replytitlePad
                cell.replydateLabel.font = Font.BlogEdit.replysubtitlePad
                
            } else {
                
                cell.replytitleLabel.font = Font.BlogEdit.replytitle
                cell.replysubtitleLabel.font = Font.BlogEdit.replysubtitle
                cell.replylikeLabel.font = Font.BlogEdit.replytitle
                cell.replydateLabel.font = Font.BlogEdit.replysubtitle
            }
            
            cell.replylikeBtn.addTarget(self, action: #selector(likeButton), for: .touchUpInside)
            cell.replyactionBtn.addTarget(self, action: #selector(replyShare), for: .touchUpInside)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query:PFQuery = PFUser.query()!
                query.whereKey("username",  equalTo: (self._feedItems1[indexPath.row] as AnyObject).value(forKey: "PostBy") as! String)
                query.limit = 1
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                            imageFile.getDataInBackground { imageData, error in
                                cell.replyImageView.image = UIImage(data: imageData!)
                            }
                        }
                    }
                }
                
                cell.replytitleLabel.text = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "PostBy") as? String
                cell.replysubtitleLabel.text = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Subject") as? String
                
                var Liked:Int? = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Liked") as? Int
                if Liked == nil { Liked = 0 }
                cell.replylikeLabel.text = "\(Liked!)"
                
                let date1 = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
                let date2 = Date()
                let calendar = Calendar.current
                let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                cell.replydateLabel.text = String(format: "%d%@", diffDateComponents.day!," days ago" )
                
            } else {
                //firebase
                cell.postReply = replylist[indexPath.row]
            }
            
            if !(cell.replylikeLabel.text! == "0") { //dont move
                cell.replylikeLabel.textColor = Color.twitterBlue
            } else {
                cell.replylikeLabel.text! = ""
            }
            
            //---------------------NSDataDetector 2 of 2-----------------------------

            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                myText = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Subject") as! NSString
                myInput = ((_feedItems1[indexPath.row] as AnyObject).value(forKey: "Subject") as? String)!
            } else {
                //firebase
                myText = replylist[indexPath.row].subject as NSString
                myInput = replylist[indexPath.row].subject
            }
            
            let attributedText = NSMutableAttributedString(string: myText as String)
            let tintedRange1 = [NSAttributedString.Key.foregroundColor: Color.Blog.weblinkText]
            
            let textName = String(format: "%@", "@\(self.postby!.removingWhitespaces())")
            attributedText.addAttributes(tintedRange1, range: myText.range(of: textName))
            
            let types: NSTextCheckingResult.CheckingType = [.date, .phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            let matches = detector?.matches(in: myInput, options: [], range: NSRange(location: 0, length: (myInput.utf16.count)))
            
            for match in matches! {
                let url = (myInput as NSString).substring(with: match.range)
                attributedText.addAttributes(tintedRange1, range: myText.range(of: url))
            }
            
            cell.replysubtitleLabel.attributedText = attributedText
            //--------------------------------------------------
            return cell
        }
        return UITableViewCell()
    }
}

extension BlogEditController: UITableViewDelegate {
    // MARK: - Content Menu
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
