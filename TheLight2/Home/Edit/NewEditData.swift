//
//  NewEditData.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/9/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase

class NewEditData: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    var formController : String?
    var formStatus : String?
    var defaults = UserDefaults.standard
    
    var objectId : String?
    var active : String?
    var frm11 : String?
    var frm12 : String?
    var frm13 : String?
    var frm14 : Int?
    var frm15 : String?
    
    private var textframe: UITextField!
    private var salesNo : UITextField!
    private var salesman : UITextField!
    private var price: UITextField!
    private var zip: UITextField!
    
    var image : UIImage!
    var imageUrl: String?
    
    var objects = [AnyObject]()
    var pasteBoard = UIPasteboard.general
    
    let activeImage: CustomImageView = { //tableheader
        let imageView = CustomImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let customImageView: CustomImageView = { //firebase
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupImageView()
        setupNavigationButtons()
        if formStatus == "New" {
            self.frm11 = "Active"
        }

        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = String(format: "%@", "TheLight Software - \(self.formStatus!) \(self.formController!)")
        } else {
            navigationItem.title = String(format: "%@ %@", self.formStatus!, self.formController!)
        }
        self.navigationItem.largeTitleDisplayMode = .always
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.Table.labelColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupImageView() {
        
        if (formController == "Product") || (formController == "Jobs") || (formController == "Salesman") {
        UIView.transition(with: self.customImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            if (self.defaults.bool(forKey: "parsedataKey")) {

            } else {
                //firebase
                guard let newsImageUrl = self.imageUrl else { return }
                self.customImageView.loadImage(urlString: newsImageUrl)
            }
        }, completion: nil)
        }
        
    }
    
    private func setupNavigationButtons() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateData))
        navigationItem.rightBarButtonItems = [saveButton]
    }
    
    func setupTableView() {
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableView.automaticDimension
        self.tableView!.backgroundColor = .white
        self.tableView!.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Refresh
    @objc func refreshData(_ sender:AnyObject) {
        
        self.tableView!.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Switch
    @objc func changeSwitch(_ sender: UISwitch) {
        
        if (sender.isOn) {
            self.frm11 = "Active"
        } else {
            self.frm11 = ""
        }
        self.tableView!.reloadData()
        
    }
    
    // MARK: - Update Data
    @objc func updateData() {
        
        guard let textSales = self.salesman.text else { return }
        
        if textSales == "" {
            
            self.simpleAlert(title: "Oops!", message: "No text entered.")
            
        } else {
            
            if (self.formController == "Salesman") {
                
                if (self.formStatus == "Edit") { //Edit Salesman
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let query = PFQuery(className:"Salesman")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                            if error == nil {
                                updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"SalesNo")
                                updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Salesman")
                                updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                                updateblog!.saveEventually()
                                self.tableView!.reloadData()
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseRoot.child("Salesman").child(self.objectId!)
                        let values = ["salesNo": self.salesNo?.text ?? "",
                                      "salesman": self.salesman.text ?? "",
                                      "active": self.active ?? NSNull()] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "salesId")
                            self.show(vc!, sender: self)
                            self.simpleAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                    
                } else { //Save Salesman
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let saveblog:PFObject = PFObject(className:"Salesman")
                        saveblog.setObject("-1" , forKey:"SalesNo")
                        saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Salesman")
                        saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveblog.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully saved the data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure to save the data")
                            }
                        }
                    } else {
                        //firebase
                        let key = FirebaseRef.databaseRoot.child("Salesman").childByAutoId().key
                        let values = ["salesNo": self.salesNo.text ?? "",
                                      "salesman": self.salesman.text ?? "",
                                      "active": self.active ?? NSNull(),
                                      "salesId": key!] as [String: Any]
                        
                        let childUpdates = ["/Salesman/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                        }
                    }
                }
                
            } else  if (formController == "Jobs") {
                
                if (self.formStatus == "Edit") { //Edit Job
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let query = PFQuery(className:"Job")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                            if error == nil {
                                updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"JobNo")
                                updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Description")
                                updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                                updateblog!.saveEventually()
                                self.tableView!.reloadData()
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseRoot.child("Job").child(self.objectId!)
                        let values = ["jobNo": self.salesNo.text ?? "",
                                      "description": self.salesman.text ?? "",
                                      "active": self.active ?? NSNull()] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "jobId")
                            self.show(vc!, sender: self)
                            self.simpleAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                        
                    }
                    
                } else { //Save Job
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let saveblog:PFObject = PFObject(className:"Job")
                        saveblog.setObject("-1" , forKey:"JobNo")
                        saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Description")
                        saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveblog.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                            }
                        }
                    } else {
                        //firebase
                        let key = FirebaseRef.databaseRoot.child("Job").childByAutoId().key
                        let values = ["jobNo": "0",
                                      "description": self.salesman.text ?? "",
                                      "active": self.active ?? NSNull(),
                                      "jobId": key!] as [String: Any]
                        
                        let childUpdates = ["/Job/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                        }
                    }
                }
                
            } else if (self.formController == "Product") {
                
                let numberFormatter = NumberFormatter()
                let myPrice : NSNumber = numberFormatter.number(from: self.price.text!)!
                
                if (self.formStatus == "Edit") { //Edit Products
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let query = PFQuery(className:"Product")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                            if error == nil {
                                updateblog!.setObject(myPrice , forKey:"Price")
                                updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"ProductNo")
                                updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Products")
                                updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                                updateblog!.saveEventually()
                                self.tableView!.reloadData()
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseRoot.child("Product").child(self.objectId!)
                        let values = ["productNo": self.salesNo?.text ?? "",
                                      "products": self.salesman.text ?? "",
                                      "price": myPrice,
                                      "active": self.active ?? NSNull()] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "productId")
                            self.show(vc!, sender: self)
                            self.simpleAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                    
                } else { //Save Products
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let saveblog:PFObject = PFObject(className:"Product")
                        saveblog.setObject(myPrice , forKey:"Price")
                        saveblog.setObject("-1" , forKey:"ProductNo")
                        saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Products")
                        saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveblog.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure saving the data")
                            }
                        }
                    } else {
                        //firebase
                        let key = FirebaseRef.databaseRoot.child("Product").childByAutoId().key
                        let values = ["productNo": -1,
                                      "products": self.salesman.text ?? "",
                                      "price": myPrice,
                                      "active": self.active ?? NSNull(),
                                      "prodId": key!] as [String: Any]
                        
                        let childUpdates = ["/Product/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                        }
                    }
                }
                
            } else if (self.formController == "Advertiser") {
                
                if (self.formStatus == "Edit") { //Edit Advertising
                    if (defaults.bool(forKey: "parsedataKey")) {
                        let query = PFQuery(className:"Advertising")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                            if error == nil {
                                updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"AdNo")
                                updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Advertiser")
                                updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                                updateblog!.saveEventually()
                                self.tableView!.reloadData()
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseRoot.child("Advertising").child(self.objectId!)
                        let values = ["adNo": self.salesNo?.text ?? "",
                                      "advertiser": self.salesman.text ?? "",
                                      "active": self.active ?? NSNull()] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "adId")
                            self.show(vc!, sender: self)
                            self.simpleAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                    
                } else { //Save Advertising
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let saveblog:PFObject = PFObject(className:"Advertising")
                        saveblog.setObject("-1" , forKey:"AdNo")
                        saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Advertiser")
                        saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveblog.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure saving data")
                            }
                        }
                    } else {
                        //firebase
                        let key = FirebaseRef.databaseRoot.child("Advertising").childByAutoId().key
                        let values = ["adNo": key!,
                                      "advertiser": self.salesman.text ?? "",
                                      "active": self.active ?? NSNull(),
                                      "adId": key!] as [String: Any]
                        
                        let childUpdates = ["/Advertising/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                        }
                    }
                }
                
            } else if (self.formController == "Zip") {
                
                if (self.formStatus == "Edit") { //Edit Zip
                    if (defaults.bool(forKey: "parsedataKey")) {
                        let query = PFQuery(className:"Zip")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                            if error == nil {
                                updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"AdNo")
                                updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Advertiser")
                                updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                                updateblog!.saveEventually()
                                self.tableView!.reloadData()
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseRoot.child("Zip").child(self.objectId!)
                        let values = ["active": self.active ?? NSNull(),
                                      "city": self.salesman.text ?? "",
                                      "State": self.salesNo.text ?? "",
                                      "zip": self.price.text ?? "",
                                      "zipNo": self.zip.text ?? "",
                                      ] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "adId")
                            self.show(vc!, sender: self)
                            self.simpleAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                    
                } else { //Save Zip
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        
                        let saveblog:PFObject = PFObject(className:"Advertising")
                        saveblog.setObject("-1" , forKey:"AdNo")
                        saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Advertiser")
                        saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveblog.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                                
                            } else {
                                
                                self.simpleAlert(title: "Upload Failure", message: "Failure saving data")
                            }
                        }
                    } else {
                        //firebase
                        let key = FirebaseRef.databaseRoot.child("Advertising").childByAutoId().key
                        let values = ["zipNo": self.zip.text ?? "",
                                      "city": self.salesman.text ?? "",
                                      "state": self.salesNo.text ?? "",
                                      "zip": self.price.text ?? "",
                                      "active": self.active ?? NSNull(),
                                      "zipId": key!] as [String: Any]
                        
                        let childUpdates = ["/Zip/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: "Upload Failure", message: err as? String)
                                return
                            }
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully saved data")
                        }
                    }
                }
            }
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.success)
            
            navigationController!.popViewController(animated: true)
            self.dismiss(animated: true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeId")
            self.show(vc!, sender: self)
        }
    }
}
//-----------------------end------------------------------
extension NewEditData: UITableViewDataSource {
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (formController == "Product") || (formController == "Zip") {
            return 5
        } else if (formController == "Salesman") || (formController == "Jobs") {
            if formStatus == "New" {
                return 2
            } else {
                return 4
            }
        }
            
        else if (formController == "Advertiser") {
            if formStatus == "New" {
                return 2
            }
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (formController == "Product"), (indexPath.row == 4) {
            return 200
        } else if (formController == "Salesman") || (formController == "Jobs"), (indexPath.row == 3) {
            return 200
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier: String = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell
        
        cell.selectionStyle = .none
        
        textframe = UITextField(frame: .init(x: 130, y: 7, width: 175, height: 30))
        activeImage.frame = .init(x: 130, y: 10, width: 18, height: 22)
        customImageView.frame = .init(x: 130, y: 10, width: 180, height: 180)
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.textLabel!.font = Font.Stat.celltitlePad
            self.salesman?.font = Font.Stat.celltitlePad
            self.salesNo?.font = Font.Stat.celltitlePad
            self.price?.font = Font.Stat.celltitlePad
            self.zip?.font = Font.Stat.celltitlePad
        } else {
            cell.textLabel!.font = Font.celltitle20l
            self.salesman?.font = Font.celltitle20l
            self.salesNo?.font = Font.celltitle20l
            self.price?.font = Font.celltitle20l
            self.zip?.font = Font.celltitle20l
        }
        
        if (indexPath.row == 0) {
            
            let theSwitch = UISwitch(frame: .zero)
            theSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
            theSwitch.onTintColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha: 1.0)
            theSwitch.tintColor = .lightGray
            
            if self.frm11 == "Active" {
                theSwitch.isOn = true
                self.active = (self.frm11)!
                self.activeImage.image = #imageLiteral(resourceName: "iosStar")
                cell.textLabel!.text = "Active"
            } else {
                theSwitch.isOn = false
                self.active = ""
                self.activeImage.image = #imageLiteral(resourceName: "iosStarNA")
                cell.textLabel!.text = "Inactive"
            }
            
            cell.addSubview(theSwitch)
            cell.accessoryView = theSwitch
            cell.contentView.addSubview(activeImage)
            
        } else if (indexPath.row == 1) {
            
            self.salesman = textframe
            self.salesman!.adjustsFontSizeToFitWidth = true
            
            if self.frm13 == nil {
                
                self.salesman!.text = ""
                
            } else {
                
                self.salesman!.text = self.frm13
            }
            
            if (formController == "Salesman") {
                self.salesman.placeholder = "Salesman"
                cell.textLabel!.text = "Salesman"
            }
                
            else if (formController == "Product") {
                self.salesman.placeholder = "Product"
                cell.textLabel!.text = "Product"
            }
                
            else if (formController == "Advertiser") {
                self.salesman.placeholder = "Advertiser"
                cell.textLabel!.text = "Advertiser"
            }
                
            else if (formController == "Jobs") {
                self.salesman.placeholder = "Description"
                cell.textLabel!.text = "Description"
            }
                
            else if (formController == "Zip") {
                self.salesman.placeholder = "City"
                cell.textLabel!.text = "City"
            }
            
            cell.contentView.addSubview(self.salesman!)
            
        } else if (indexPath.row == 2) {
            
            self.salesNo = textframe
            
            if self.frm12 == nil {
                self.salesNo?.text = ""
            } else {
                self.salesNo?.text = self.frm12
            }
            
            if (formController == "Salesman") {
                self.salesNo.placeholder = "SalesNo"
                cell.textLabel!.text = "SalesNo"
            }
                
            else if (formController == "Product") {
                self.salesNo.placeholder = "ProductNo"
                cell.textLabel!.text = "ProductNo"
            }
                
            else if (formController == "Advertiser") {
                self.salesNo?.placeholder = "AdNo"
                cell.textLabel!.text = "AdNo"
            }
                
            else if (formController == "Jobs") {
                self.salesNo.placeholder = "JobNo"
                cell.textLabel!.text = "JobNo"
            }
                
            else if (formController == "Zip") {
                self.salesNo.placeholder = "State"
                cell.textLabel!.text = "State"
            }
            
            cell.contentView.addSubview(self.salesNo)
            
        } else if (indexPath.row == 3) {
            self.price = textframe
            self.price!.adjustsFontSizeToFitWidth = true
            
            if (formController == "Salesman") {
                cell.textLabel!.text = "Photo"
                self.customImageView.image = image
                cell.contentView.addSubview(customImageView)
            }
                
            else if (formController == "Jobs") {
                cell.textLabel!.text = "Photo"
                self.customImageView.image = image
                cell.contentView.addSubview(customImageView)
            }
                
            else if (formController == "Product") {
                self.price.placeholder = "Price"
                cell.textLabel!.text = "Price"
                
                if self.frm14 == nil {
                    self.price!.text = ""
                } else {
                    var Price:Int? = self.frm14! as Int
                    if Price == nil {
                        Price = 0
                    }
                    self.price!.text = "\(Price!)"
                }
                
                cell.contentView.addSubview(self.price)
            }
                
            else if (formController == "Zip") {
                self.price.placeholder = "Zip"
                cell.textLabel!.text = "Zip"
                
                if self.frm14 == nil {
                    self.price!.text = ""
                } else {
                    var Price:Int? = self.frm14! as Int
                    if Price == nil {
                        Price = 0
                    }
                    self.price!.text = "\(Price!)"
                }
                
                cell.contentView.addSubview(self.price)
                
            }
        } else if (indexPath.row == 4) {
            
            if (formController == "Product") {
                
                cell.textLabel!.text = "Photo"
                self.customImageView.image = image
                cell.contentView.addSubview(customImageView)
            }
                
            else if (formController == "Zip") {
                
                self.zip = textframe
                self.zip!.adjustsFontSizeToFitWidth = true
                
                self.zip.placeholder = "ZipNo"
                cell.textLabel!.text = "ZipNo"
                self.zip!.text = self.frm15
                
                cell.contentView.addSubview(self.zip)
            }
        }
        return cell
    }
}
extension NewEditData: UITableViewDelegate {
  
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
}
// MARK: - UISearchBar Delegate
extension NewEditData: UISearchBarDelegate {
    /*
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["name", "city", "phone", "date", "active"]
        //searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = .brown
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    } */
}

extension NewEditData: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
         self.foundUsers.removeAll(keepCapacity: false)
         let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
         let array = (self._feedItems as NSArray).filteredArrayUsingPredicate(searchPredicate)
         self.foundUsers = array as! [String]
         self.resultsController.tableView.reloadData() */
    }
}
