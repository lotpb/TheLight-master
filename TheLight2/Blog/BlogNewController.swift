//
//  BlogNewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/14/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseAuth
import UserNotifications
import MessageUI


@available(iOS 13.0, *)
final class BlogNewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    let CharacterLimit = 140
    
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var subject: UITextView?
    @IBOutlet weak var placeholderlabel: UILabel?
    @IBOutlet weak var characterCountLabel: UILabel?
    @IBOutlet weak var toolBar: UIToolbar?
    @IBOutlet weak var Share: UIButton?
    @IBOutlet weak var Like: UIButton?
    @IBOutlet weak var tableView: UITableView?
    
    public var objectId : String?
    public var msgNo : String?
    public var postby : String?
    public var msgDate : String?
    public var rating : String?
    public var liked : Int?
    public var replyId : String?
    public var lastUpdate : Date? //firebase
    
    public var textcontentobjectId : String?
    public var textcontentuid : String? //firebase
    public var textcontentmsgNo : String?
    public var textcontentdate : String?
    public var textcontentpostby : String?
    public var textcontentsubject : String?
    public var textcontentrating : String?
    public var textcontentreplyId : String?
    
    public var formStatus : String?
    private let defaults = UserDefaults.standard
    
//------inlineDatePicker---------
    private let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker
    private let kDatePickerTag           = 99   // view tag identifiying the date picker view
 
    private let kTitleKey = "title" // key for obtaining the data source item's title
    private let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    private let kDateStartRow = 1
    private let kDateEndRow   = 1
    
    private let kTitleCellID      = "titleCell"
    private let kDateCellID       = "dateCell" // the cells with the start or end date
    private let kDatePickerCellID = "datePickerCell"
    
    private var dataArray: [[String: AnyObject]] = []
    
    // keep track which indexPath points to the cell with UIDatePicker
    private var datePickerIndexPath: IndexPath?
    private var pickerCellRowHeight: CGFloat = 216
   //-------------------------------------
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.frame = .init(x: 0, y: 0, width: 100, height: 32)
        if UIDevice.current.userInterfaceIdiom == .pad  {
            button.setTitle("TheLight Software - New Message", for: .normal)
        } else {
            button.setTitle("New Message", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let imageProfile: CustomImageView = {
        let imageView = CustomImageView()
        imageView.frame = .init(x: 15, y: 12, width: 50, height: 50)
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemRed
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let activeImage: CustomImageView = { //tableheader
        let imageView = CustomImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        loadImageProfile()
        configureTextView()
        setupForm()
        setupDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setupTwitterNavigationBarItems()
        tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = false // FIXME: shouldn't crash
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        tabBarController?.tabBar.isHidden = false
        //UIApplication.shared.isStatusBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(shootPhoto))
        navigationItem.rightBarButtonItems = [cameraButton]
        navigationItem.titleView = titleButton
    }
    
     private func setupForm() {
        
        view.backgroundColor = .systemBackground
        subject!.backgroundColor = .systemBackground
        photoView.backgroundColor = .systemBackground
        photoView.addSubview(imageProfile)
        imageProfile.translatesAutoresizingMaskIntoConstraints = true
        imageProfile.layer.cornerRadius = 5
        imageProfile.layer.masksToBounds = true
        imageProfile.contentMode = .scaleAspectFill

        tableView!.backgroundColor = .systemGray4
        tableView!.tableFooterView = UIView(frame: .zero)
        
        Like!.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        Like!.setTitleColor(.white, for: .normal)
        Like!.frame = .init(x: 0, y: 0, width: 90, height: 30)
        Share!.setTitleColor(ColorX.twitterBlue, for: .normal)
        Share!.backgroundColor = .white
        Share!.frame = .init(x: 0, y: 0, width: 60, height: 30)
        let btnLayer: CALayer = Share!.layer
        btnLayer.cornerRadius = 9.0
        btnLayer.masksToBounds = true
        toolBar!.barTintColor = ColorX.twitterBlue
        
        subject?.textContainerInset = .init(top: 15, left: 5, bottom: 0, right: 0)
        
        if ((formStatus == "New") || (formStatus == "Reply")) {
            
            placeholderlabel!.textColor = .lightGray
            rating = "4"
            postby = textcontentpostby
            MasterViewController.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = MasterViewController.dateFormatter.string(from: (Date()) as Date)
            msgDate = dateString
 
        } else if ((self.formStatus == "None")) { //set in BlogEdit
            
            placeholderlabel!.isHidden = true
            objectId = textcontentobjectId
            msgNo = textcontentmsgNo
            msgDate = textcontentdate
            subject!.text = textcontentsubject
            postby = textcontentpostby
            rating = textcontentrating
            replyId = textcontentreplyId
            if (liked == nil || liked == 0) {
                Like!.tintColor = .white
            } else {
                Like!.tintColor = ColorX.Blog.buttonColor
            }
        }
        
        if (formStatus == "New") {
            placeholderlabel!.text = "Share an idea?"
            Like!.tintColor = .white
            
        } else if (formStatus == "Reply") {
            placeholderlabel!.isHidden = true
            subject!.text = textcontentsubject
            subject!.becomeFirstResponder()
            subject!.isUserInteractionEnabled = true
        }
        subject!.keyboardAppearance = .dark
    }
    
    private func setupDatePicker() {

        let itemOne = [kTitleKey : "Tap a cell to change its date:", kDateKey : ""]
        let itemTwo = [kTitleKey : "Date", kDateKey : Date()] as [String : Any]
        let itemThree = [kTitleKey : "Name", kDateKey : self.postby]
      //let itemFour = [kTitleKey : "Date", kDateKey : Date()] as [String : Any]
        dataArray = [itemOne as Dictionary<String, AnyObject>, itemTwo as Dictionary<String, AnyObject>, itemThree as Dictionary<String, AnyObject>]
        
        MasterViewController.dateFormatter.dateStyle = .medium
        MasterViewController.dateFormatter.timeStyle = .short
        
        NotificationCenter.default.addObserver(self, selector: #selector(localeChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    
    private func showBadgeHighLight() {
        //TabBar Badge
        let tabArray = self.tabBarController?.tabBar.items as NSArray?
        let tabItem = tabArray?.object(at: 1) as? UITabBarItem
        tabItem?.badgeValue = "New"
    }

    // MARK: - textView delegate
    public func textViewDidBeginEditing(_ textView:UITextView) {
        
        if subject!.text.isEmpty {
            placeholderlabel?.isHidden = true
        }
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemClicked))
        
        navigationItem.setRightBarButton(doneBarButtonItem, animated: true)
        
        if (formStatus == "Reply") {
            //Change font and color @links in TextView
            subject?.textColor = ColorX.twitterline
            let attrStr = NSMutableAttributedString(string:(subject?.text)!)
            let inputLength = attrStr.string.count
            let searchString = String(format: "%@", "\(textcontentsubject!.removingWhitespaces())")
            let searchLength = searchString.count
            var range = NSRange(location: 0, length: attrStr.length)
            while (range.location != NSNotFound) {
                range = (attrStr.string as NSString).range(of: searchString, options: [], range: range)
                if (range.location != NSNotFound) {
                    attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorX.Blog.weblinkText, range: NSRange(location: range.location, length: searchLength))
                    attrStr.addAttribute(NSAttributedString.Key.font, value: Font.Blog.cellsubject, range: NSRange(location: 0, length: (inputLength)))
                    range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
                    subject?.attributedText = attrStr
                }
            }
        }
    }
    
    public func textViewDidEndEditing(_ textView:UITextView) {
        
        if subject!.text.isEmpty {
         placeholderlabel?.isHidden = false
        }
    }
    
    // MARK: Characters Limit
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textView.text ?? ""
        characterCountLabel!.text = "\(CharacterLimit - (currentText.count))"
        guard let stringRange = range.range(for: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= CharacterLimit
    }
    
    // MARK: TextView configure
    private func configureTextView() {
        
        subject?.delegate = self
        subject?.isSelectable = true //added
        subject?.autocorrectionType = .yes
        subject?.dataDetectorTypes = .all //.link
        characterCountLabel!.text = ""
        characterCountLabel!.textColor = .systemGray
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            subject!.font = Font.celltitle22l
        } else {
            subject!.font = Font.Blog.cellsubject
        }
    }
    
    // MARK: - Buttons
    @IBAction func like(sender:UIButton) {
        
        if(rating == "4") {
            rating = "5"
            liked = 1
        } else {
            rating = "4"
            liked = 0
        }
        tableView!.reloadData()
    }
    
    @objc func doneBarButtonItemClicked() {
        // Dismiss the keyboard by removing it as the first responder.
        subject?.resignFirstResponder()
        navigationItem.setRightBarButton(nil, animated: true)
    }

//------------------------------------------------------------------
    // MARK: - Inline Pickdate
    @objc func localeChanged(_ notif: Notification) {

        tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath!.row == indexPath.row
    }
    
    func indexPathHasDate(_ indexPath: IndexPath) -> Bool {
        var hasDate = false
        
        if (indexPath.row == kDateStartRow) || (indexPath.row == kDateEndRow || (hasInlineDatePicker() && (indexPath.row == kDateEndRow + 1))) {
            hasDate = true
        }
        return hasDate
    }
    
    func displayInlineDatePickerForRowAtIndexPath(_ indexPath: IndexPath) {

        tableView?.beginUpdates()
        
        var before = false
        
        if hasInlineDatePicker() {
            before = (datePickerIndexPath?.row)! < indexPath.row
        }
        
        let sameCellClicked = ((datePickerIndexPath as NSIndexPath?)?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            tableView?.deleteRows(at: [IndexPath(row: datePickerIndexPath!.row, section: 0)], with: .fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = IndexPath(row: rowToReveal, section: 0)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = IndexPath(row: indexPathToReveal.row + 1, section: 0)
        }

        tableView?.deselectRow(at: indexPath, animated:true)
        tableView?.endUpdates()
        updateDatePicker()
    }
    
    private func toggleDatePickerForSelectedIndexPath(_ indexPath: IndexPath) {
        
        tableView?.beginUpdates()
        
        let indexPaths = [IndexPath(row: indexPath.row + 1, section: 0)]

        if hasPickerForIndexPath(indexPath) {
            tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView?.insertRows(at: indexPaths, with: .fade)
        }
        tableView?.endUpdates()
    }
    
    private func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView?.cellForRow(at: indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate(itemData[kDateKey] as! Date, animated: false)
            }
        }
    }
    
    private func hasPickerForIndexPath(_ indexPath: IndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView?.cellForRow(at: IndexPath(row: targetedRow, section: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    @IBAction func dateAction(_ sender: UIDatePicker) {
        
        var targetedCellIndexPath: IndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = IndexPath(row: datePickerIndexPath!.row - 1, section: 0)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView?.indexPathForSelectedRow!
        }
        
        let cell = tableView?.cellForRow(at: targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date as AnyObject?
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        cell?.detailTextLabel?.text = MasterViewController.dateFormatter.string(from: targetedDatePicker.date)
        
        // update the parse date string
        MasterViewController.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"


        let strDate = MasterViewController.dateFormatter.string(from: (targetedDatePicker.date))
        self.msgDate = strDate
    }
    
    // MARK: Camera
    @objc func shootPhoto(_ sender: AnyObject) {
        let layout = UICollectionViewFlowLayout()
        let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
        
        let navController = UINavigationController(rootViewController: photoSelectorController)
        present(navController, animated: true)
    }
//------------------------------------------------------------------
    // MARK: - Load Data
    private func loadImageProfile() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo: self.textcontentpostby!)
            query.cachePolicy = .cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                        imageFile.getDataInBackground { imageData, error in
                            self.imageProfile.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("users")
                .queryOrdered(byChild: "uid")
                .queryEqual(toValue: self.textcontentuid)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let userDict = userSnap.value as! [String: Any]
                        let blogImageUrl = userDict["profileImageUrl"] as? String
                        self.imageProfile.loadImage(urlString: blogImageUrl!)
                    }
                })
        }
    }
    
    // MARK: - Notification
    private func newBlogNotification() {
        
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        guard self.defaults.bool(forKey: "pushnotifyKey") == true else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Blog Post 🏀"
        content.body = "New Blog Posted by \(self.postby!) at TheLight"
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        content.sound = .default
        content.categoryIdentifier = "status"
        
        let imageName = "applelogo"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        content.userInfo = ["link":""]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        //UIFeedbackGenerator
        let FeedbackGenerator = UINotificationFeedbackGenerator()
        FeedbackGenerator.notificationOccurred(.success)
    }
    
    private func newBlogEmail() {
        
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        guard self.defaults.bool(forKey: "emailnotifyKey") == true else { return }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["eunited@optonline.net"])
        mail.setSubject("New Blog Posted by \(self.postby!)")
        mail.setMessageBody(subject!.text, isHTML: true)
        let imageData: NSData = imageProfile.image!.pngData()! as NSData
        mail.addAttachmentData(imageData as Data, mimeType: "image/jpg", fileName: "imageName")
        self.present(mail, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    // MARK: - Save Data
    @IBAction func saveData(sender: UIButton) {
        
        guard let text = self.subject?.text else { return }
        
        if text == "" {
            self.showAlert(title: "Oops!", message: "No text entered.")
        } else {
            if (self.formStatus == "None") {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    let query = PFQuery(className:"Blog")
                    query.whereKey("objectId", equalTo:self.objectId!)
                    query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                        if error == nil {
                            updateblog!.setObject(self.msgDate ?? NSNull(), forKey:"MsgDate")
                            updateblog!.setObject(self.postby ?? NSNull(), forKey:"PostBy")
                            updateblog!.setObject(self.rating ?? NSNull(), forKey:"Rating")
                            updateblog!.setObject(self.subject?.text ?? NSNull(), forKey:"Subject")
                            updateblog!.setObject(self.msgNo ?? NSNumber(value:-1), forKey:"MsgNo")
                            updateblog!.setObject(self.replyId ?? NSNull(), forKey:"ReplyId")
                            updateblog!.saveEventually()
                            
                            self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                        } else {
                            self.showAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                } else {
                    //firebase
                    //let dateString = dateFormatter.date(from: self.msgDate ?? "")
                    let userRef = FirebaseRef.databaseBlog.child(self.textcontentobjectId!)
                    let values = ["subject": self.subject?.text ?? "",
                                  //"replyId": self.replyId ?? "",
                        "rating": self.rating  ?? "",
                        "postBy": self.postby ?? "",
                        "liked": self.liked ?? 0,
                        "lastUpdate": Date().timeIntervalSince1970,
                        //"creationDate": dateString?.timeIntervalSince1970 ?? "",
                        "blogId": self.objectId ?? ""] as [String: Any]
                    
                    userRef.updateChildValues(values) { (err, ref) in
                        if err != nil {
                            self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            return
                        }
                        self.showAlert(title: "update Complete", message: "Successfully updated the data")
                    }
                }
                
            } else if (self.formStatus == "New" || self.formStatus == "Reply") {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    
                    let saveblog: PFObject = PFObject(className:"Blog")
                    saveblog.setObject(self.msgDate ?? NSNull(), forKey:"MsgDate")
                    saveblog.setObject(self.postby ?? NSNull(), forKey:"PostBy")
                    saveblog.setObject(self.rating ?? NSNull(), forKey:"Rating")
                    saveblog.setObject(self.subject?.text ?? NSNull(), forKey:"Subject")
                    saveblog.setObject(self.msgNo ?? NSNumber(value:-1), forKey:"MsgNo")
                    saveblog.setObject(self.replyId ?? NSNull(), forKey:"ReplyId")
                    saveblog.setObject(self.liked ?? NSNumber(value:0), forKey:"Liked")
                    
                    if (self.formStatus == "Reply") {
                        let query = PFQuery(className:"Blog")
                        query.whereKey("objectId", equalTo:self.replyId!)
                        query.getFirstObjectInBackground { (updateReply: PFObject?, error: Error?) in
                            if error == nil {
                                updateReply!.incrementKey("CommentCount")
                                updateReply!.saveEventually()
                            }
                        }
                    }
                    
                    saveblog.saveInBackground { (success: Bool, error: Error?) in
                        if success == true {
                            self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                        } else {
                            self.showAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                    
                } else {
                    
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    let key = FirebaseRef.databaseBlog.childByAutoId().key
                    let values = ["subject": self.subject?.text ?? "",
                                  "replyId": self.replyId ?? "",
                                  "rating": self.rating  ?? "",
                                  "postBy": self.postby ?? "",
                                  "liked": self.liked ?? 0,
                                  "blogId": key!,
                                  "creationDate": Date().timeIntervalSince1970,
                                  "uid": uid ] as [String: Any]
                    
                    let childUpdates = ["/Blog/\(String(key!))": values]
                    FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                        if err != nil {
                            self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                            return
                        }
                        
                        if (self.formStatus == "Reply") {//update commentCount
                            
                            let refReservations = ref.child("Blog").child(self.replyId!).child("commentCount")
                            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                                
                                var value = currentData.value as? Int
                                if value == nil {
                                    value = 0
                                }
                                currentData.value = value! + 1
                                return TransactionResult.success(withValue: currentData)
                            }
                        }
                        self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                    }
                }
            }
        }
        
        //DispatchQueue.main.async {
        navigationController!.popViewController(animated: true)
        self.dismiss(animated: true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "blogId")
        self.show(vc!, sender: self)
        //}
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
        newBlogNotification()
        newBlogEmail()
        showBadgeHighLight()
    }
}
@available(iOS 13.0, *)
extension BlogNewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasInlineDatePicker() {
            return dataArray.count + 1
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        var cellID = kTitleCellID
        
        if indexPathHasPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        cell.textLabel?.textColor = .systemBlue
        cell.detailTextLabel?.textColor = .label
        
        if indexPath.row == 0 {
            
            self.activeImage.frame = .init(x: tableView.frame.width-35, y: 10, width: 18, height: 22)
            self.activeImage.image = UIImage(systemName: "star.fill")
            
            if (liked == nil || liked == 0) {
                Like!.tintColor = .white
                Like!.setTitle(" Like", for: .normal)
                activeImage.tintColor = .systemGray
                //self.activeImage.image = #imageLiteral(resourceName: "iosStarNA")
                
            } else {
                Like!.tintColor = ColorX.Blog.buttonColor
                Like!.setTitle(" Likes \(liked!)", for: .normal)
                activeImage.tintColor = .systemYellow
                //self.activeImage.image = #imageLiteral(resourceName: "iosStar")
            }
            cell.contentView.addSubview(self.activeImage)
            cell.selectionStyle = .none
        }
        
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && (datePickerIndexPath?.row)! <= indexPath.row) {
            modelRow -= 1
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kDateCellID {
            
            let dateCell : String
            if ((self.formStatus == "None")) {
                dateCell = self.msgDate!
            } else {
                dateCell = MasterViewController.dateFormatter.string(from: itemData[kDateKey] as! Date)
            }
            
            cell.textLabel?.text = itemData[kTitleKey] as? String
            cell.detailTextLabel?.text = dateCell
            
        } else if cellID == kTitleCellID {
            
            cell.textLabel!.text = itemData[kTitleKey] as? String
            cell.detailTextLabel?.text = itemData[kDateKey] as? String
            cell.selectionStyle = .none
        }
        return cell
    }
}
@available(iOS 13.0, *)
extension BlogNewController: UITableViewDelegate {
}

