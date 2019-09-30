//
//  LeadDetail.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/10/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import ContactsUI
import EventKit
import MessageUI

final class LeadDetail: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    let defaults = UserDefaults.standard
    
    var tableData = NSMutableArray()
    var tableData2 = NSMutableArray()
    var tableData3 = NSMutableArray()
    var tableData4 = NSMutableArray()
    
    @IBOutlet weak var scrollWall: UIScrollView?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainView: UIView?
    @IBOutlet weak var tableView: UIView?

    @IBOutlet weak var listTableView: UITableView?
    @IBOutlet weak var listTableView2: UITableView?
    @IBOutlet weak var newsTableView: UITableView?
    
    var formController : String?
    var status : String?
    
    var objectId : String?
    var custNo : String?
    var leadNo : String?
    var date : String?
    var name : String?
    var address : String?
    var city : String?
    var state : String?
    var zip : String?
    var amount : String?
    var tbl11 : String?
    var tbl12 : String?
    var tbl13 : String?
    var tbl14 : String?
    var tbl15 : NSString?
    var tbl16 : String?
    var tbl21 : NSString?
    var tbl22 : String?
    var tbl23 : String!
    var tbl24 : String?
    var tbl25 : String?
    var tbl26 : NSString?
    var tbl27 : String? //employee company
    var photo : String?
    var comments : String?
    var active : String?
    
    var t11 : String?
    var t12 : String?
    var t13 : String?
    var t14 : String?
    var t15 : NSString?
    var t16 : String?
    var t21 : NSString?
    var t22 : String?
    var t23 : String!
    var t24 : String?
    var t25 : String?
    var t26 : NSString?
    
    var l1datetext : String?
    var lnewsTitle : String?
    
    var l11 : String?
    var l12 : String?
    var l13 : String?
    var l14 : String?
    var l15 : String?
    var l16 : String?
    
    var l21 : String?
    var l22 : String?
    var l23 : String?
    var l24 : String?
    var l25 : String?
    var l26 : String?
    
    var p1 : String?
    var p12 : String?
    var complete : String?
    var salesman : String?
    var jobdescription : String?
    var advertiser : String?
    
    var savedEventId : String?
    var getEmail : String?
    var emailTitle :String?
    var messageBody:String?

    let labelname: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .systemBlue
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let following: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .systemGray
        label.textAlignment = .right
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var activebutton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = true
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let labelamount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .label
        label.textAlignment = .left
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let labeladdress: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .label
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let labelcity: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

   let labeldatetext: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .systemBlue
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()

    let labeldate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .label
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()

    let photoImage: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = #imageLiteral(resourceName: "plus_photo")
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let labelNo: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .systemGray
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let mySwitch: UISwitch = {
        let button = UISwitch()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        button.tintColor = .lightGray
        button.onTintColor = .systemBlue
        return button
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitle("Map", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(mapClickButton), for: .touchUpInside)
        let btnLayer: CALayer = button.layer
        btnLayer.cornerRadius = 9.0
        btnLayer.masksToBounds = true
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Lead.navColor
        refreshControl.tintColor = .white
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    var detailItem: AnyObject? {
            didSet {
                configureView()
            }
        }
        
        func configureView() {
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        
        setupNavigationButtons()
        //Leave this setup below
        setupConstraints()
        setupTableView()
        setupForm()
        setupFonts()
        setupSwitch()
        loadData()
        followButton()
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = String(format: "%@ %@", "TheLight Software - \(self.formController!)", "Profile")
        } else {
            navigationItem.title = String(format: "%@ %@", "\(self.formController!)", "Profile")
        }
        self.navigationItem.largeTitleDisplayMode = .always
        self.mainView!.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
        fieldData()
        refreshData()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(LeadDetail.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
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
    
    private func setupNavigationButtons() {
        let editBtn = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButton))
        let actionBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButton))
        navigationItem.rightBarButtonItems = [editBtn,actionBtn]
    }
    
    func setupTableView() {
        self.listTableView!.rowHeight = 30
        self.listTableView2!.rowHeight = 30
        self.newsTableView!.estimatedRowHeight = 100
        self.newsTableView!.rowHeight = UITableView.automaticDimension
        self.newsTableView!.tableFooterView = UIView(frame: .zero)
    }
    
    func setupForm() {

        if #available(iOS 13.0, *) {
            mainView?.backgroundColor = .secondarySystemGroupedBackground
            contentView?.backgroundColor = .secondarySystemGroupedBackground
            tableView?.backgroundColor = .secondarySystemGroupedBackground
            listTableView?.backgroundColor = .secondarySystemGroupedBackground
            listTableView2?.backgroundColor = .secondarySystemGroupedBackground
            newsTableView?.backgroundColor = .secondarySystemGroupedBackground
        } else {
            view.backgroundColor = .white
        }
        
        emailTitle = defaults.string(forKey: "emailtitleKey")
        messageBody = defaults.string(forKey: "emailmessageKey")
        let topBorder = CALayer()
        let width = CGFloat(2.0)
        topBorder.borderColor = UIColor.lightGray.cgColor
        topBorder.frame = .init(x: 0, y: 0, width: view.frame.width, height: 0.5)
        topBorder.borderWidth = width
        tableView!.layer.addSublayer(topBorder)
        tableView!.layer.masksToBounds = true
    }
    
    func setupSwitch() {
        if (self.formController == "Leads") {
            if (self.tbl11 == "Sold") {
                self.mySwitch.setOn(true, animated:true)
            } else {
                self.mySwitch.setOn(false, animated:true)
            }
        }
    }
    
    func setupFonts() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            labelamount.font = Font.Detail.ipadAmount
            labelname.font = Font.Detail.ipadname
            labeldate.font = Font.Detail.ipaddate
            labeladdress.font = Font.Detail.ipadaddress
            labelcity.font = Font.Detail.ipadaddress
            following.font = Font.Detail.ipaddate
            mapButton.titleLabel?.font = Font.Detail.textbutton
            
        } else {
            
            labelname.font = Font.celltitle26r
            labeladdress.font = Font.Detail.textaddress
            labelcity.font = Font.Detail.textaddress
            mapButton.titleLabel?.font = Font.Detail.textbutton
            
            if (self.formController == "Vendor" || self.formController == "Employee") {
                labelamount.font = Font.Detail.VtextAmount
                labeldate.font = Font.Detail.Vtextdate
            } else {
                labelamount.font = Font.Detail.textAmount
                labeldate.font = Font.Detail.textdate
            }
        }
    }
    
    func setupConstraints() {

        mainView?.addSubview(labelname)
        mainView?.addSubview(following)
        mainView?.addSubview(activebutton)
        mainView?.addSubview(labelamount)
        mainView?.addSubview(labeladdress)
        mainView?.addSubview(labelcity)
        mainView?.addSubview(labeldate)
        mainView?.addSubview(labeldatetext)
        mainView?.addSubview(mySwitch)
        mainView?.addSubview(photoImage)
        mainView?.addSubview(labelNo)
        mainView?.addSubview(mapButton)

        //mainView?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([

            labelname.topAnchor.constraint(equalTo: mainView!.topAnchor, constant: 4),
            labelname.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 15),
            labelname.rightAnchor.constraint(equalTo: following.leftAnchor, constant: 1),
            labelname.heightAnchor.constraint(equalToConstant: 30),

            activebutton.topAnchor.constraint(equalTo: mainView!.topAnchor, constant: 9),
            activebutton.trailingAnchor.constraint(equalTo: mainView!.trailingAnchor, constant: -15),
            activebutton.widthAnchor.constraint(equalToConstant: 20),
            activebutton.heightAnchor.constraint(equalToConstant: 20),

            following.topAnchor.constraint(equalTo: mainView!.topAnchor, constant: 9),
            following.rightAnchor.constraint(equalTo: activebutton.leftAnchor, constant: -5),
            following.heightAnchor.constraint(equalToConstant: 20),

            labelamount.topAnchor.constraint(equalTo: mainView!.topAnchor, constant: 60),
            labelamount.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 15),
            labelamount.rightAnchor.constraint(equalTo: photoImage.leftAnchor, constant: 1),

            labeladdress.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 15),
            labeladdress.rightAnchor.constraint(equalTo: photoImage.leftAnchor, constant: 1),
            labeladdress.heightAnchor.constraint(equalToConstant: 30),

            labelcity.topAnchor.constraint(equalTo: labeladdress.bottomAnchor, constant: 1),
            labelcity.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 15),
            labelcity.rightAnchor.constraint(equalTo: photoImage.leftAnchor, constant: 1),
            labelcity.heightAnchor.constraint(equalToConstant: 30),

            labeldatetext.topAnchor.constraint(equalTo: labelcity.bottomAnchor, constant: 10),
            labeldatetext.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 15),
            labeldatetext.heightAnchor.constraint(equalToConstant: 20),

            labeldate.topAnchor.constraint(equalTo: labeldatetext.bottomAnchor, constant: 1),
            labeldate.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 15),
            labeldate.heightAnchor.constraint(equalToConstant: 20),

            mySwitch.topAnchor.constraint(equalTo: labeldate.bottomAnchor, constant: 15),
            mySwitch.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 15),

            photoImage.topAnchor.constraint(equalTo: (mainView?.topAnchor)!, constant: +65),
            photoImage.trailingAnchor.constraint( equalTo: (mainView?.trailingAnchor)!, constant: -15),

            labelNo.topAnchor.constraint(equalTo: photoImage.bottomAnchor, constant: 5),
            labelNo.rightAnchor.constraint( equalTo: photoImage.rightAnchor),
            labelNo.widthAnchor.constraint(equalToConstant: 125),
            labelNo.heightAnchor.constraint(equalToConstant: 20),
            
            mapButton.topAnchor.constraint(equalTo: (labelNo.bottomAnchor), constant: 15),
            mapButton.trailingAnchor.constraint( equalTo: (mainView?.trailingAnchor)!, constant: -13),
            mapButton.widthAnchor.constraint(equalToConstant: 75),
            mapButton.heightAnchor.constraint(equalToConstant: 30),
            ])
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            NSLayoutConstraint.activate([
                (mainView?.heightAnchor.constraint(equalToConstant: 325))!,
                photoImage.widthAnchor.constraint(equalToConstant: 150),
                photoImage.heightAnchor.constraint(equalToConstant: 150),
                labeladdress.topAnchor.constraint(equalTo: labelamount.bottomAnchor, constant: 25),
                labelamount.heightAnchor.constraint(equalToConstant: 40),
                ])
        } else {
            let width = 110 //view.frame.width/2-25
            NSLayoutConstraint.activate([
                (mainView?.heightAnchor.constraint(equalToConstant: 265))!,
                photoImage.widthAnchor.constraint(equalToConstant: CGFloat(width)),
                photoImage.heightAnchor.constraint(equalToConstant: 110),
                labeladdress.topAnchor.constraint(equalTo: labelamount.bottomAnchor, constant: 15),
                labelamount.heightAnchor.constraint(equalToConstant: 30),
                ])
        }
    }
    
    @objc func refreshData() {
        loadData()
        self.listTableView!.reloadData()
        self.listTableView2!.reloadData()
        self.newsTableView!.reloadData()
        self.refreshControl.endRefreshing()
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
    
    // MARK: - Button
    @objc func editButton() {
        self.status = "Edit"
        self.performSegue(withIdentifier: "editFormSegue", sender: self)
    }
    
    @objc func mapClickButton() {
        self.performSegue(withIdentifier: "showmapSegue", sender: self)
    }
    
    func followButton() {
        
        if(self.active == "1") {
            self.following.text = "Following"
            self.activebutton.tintColor = .systemYellow
        } else {
            self.following.text = "Follow"
            self.activebutton.tintColor = .systemGray
        }
    }
    
    func statButton() {
        self.performSegue(withIdentifier: "statisticSegue", sender: self)
    }
    
    // MARK: - Tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            if (section == 0) {
                return 15
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            if (section == 0) {
                let vw = UIView()
                vw.backgroundColor = Color.LGrayColor
                return vw
            }
        }
        return nil
    }
    
    // MARK: - LoadFieldData
    func fieldData() {
        
        if self.leadNo != nil {
            self.labelNo.text = leadNo
        } else {
           self.labelNo.text = "None"
        }
        if self.date != nil {
            self.labeldate.text = date
        }
        if self.l1datetext != nil {
            self.labeldatetext.text = l1datetext
        }
        if self.name != nil {
            self.labelname.text = name
        }
        if self.address != nil {
            self.labeladdress.text = address
        }
        if self.city == nil {
            city = "City"
        }
        if self.state == nil {
            state = "State"
        }
        if self.zip == nil {
            zip = "Zip"
        }
        if self.city != nil {
            self.labelcity.text = String(format: "%@ %@ %@", city!, state!, zip!)
        } else {
            city = "City"
        }
        if self.photo != nil {
            p1 = self.photo
        } else {
            p1 = "None"
        }
        if self.tbl11 != nil {
            t11 = tbl11
        } else {
            t11 = "None"
        }
        if self.tbl12 != nil {
            t12 = self.tbl12
        } else {
            t12 = "None"
        }
        if self.tbl13 != nil {
            t13 = self.tbl13
        } else {
            t13 = "None"
        }
        if self.tbl14 != nil {
            t14 = self.tbl14
        } else {
            t14 = "None"
        }
        if self.tbl15 != nil {
            t15 = self.tbl15
        } else {
            t15 = "None"
        }
        if self.tbl16 != nil {
            t16 = self.tbl16
        } else {
            t16 = "None"
        }
        if self.tbl21 != nil {
            t21 = self.tbl21
        } else {
            t21 = "None"
        }
        if self.tbl25 != nil {
            t25 = self.tbl25
        } else {
            t25 = "None"
        }
        if self.tbl26 != nil {
            t26 = self.tbl26
        } else {
            t26 = "None"
        }
    
        if (self.formController == "Leads" || self.formController == "Customer") {
            
            let formatter = NumberFormatter()
            var Amount:NSNumber? = formatter.number(from: amount! as String)
            formatter.numberStyle = .currency
            if Amount == nil {
                Amount = 0
            }
            labelamount.text =  formatter.string(from: Amount!)
            
            if self.salesman != nil {
                t22 = self.salesman
            } else {
                t22 = "None"
            }
            
            if self.jobdescription != nil {
                t23 = self.jobdescription
            } else {
                t23 = "None"
            }
            
            if self.advertiser != nil {
                t24 = self.advertiser
            } else {
                t24 = "None"
            }
            
        } else {
            
            if self.amount != nil {
                labelamount.text = self.amount
            } else {
                labelamount.text = "None"
            }
            
            if self.tbl22 != nil {
                t22 = self.tbl22
            } else {
                t22 = "None"
            }
            
            if self.tbl23 != nil {
                t23 = self.tbl23
            } else {
                t23 = "None"
            }
            
            if self.tbl24 != nil {
                t24 = self.tbl24
            } else {
                t24 = "None"
            }
        }
        
        tableData = [t11!, t12!, t13!, t14!, t15!, t16!]
        
        tableData2 = [t21!, t22!, t23!, t24!, t25!, t26!]
        
        tableData4 = [l11!, l12!, l13!, l14!, l15!, l16!]
        
        tableData3 = [l21!, l22!, l23!, l24!, l25!, l26!]
    }
    
    // MARK: - Parse
    func loadData() {

        if (formController == "Leads" || formController == "Customer") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query1 = PFQuery(className:"Salesman")
                query1.whereKey("SalesNo", equalTo:self.tbl22!)
                query1.cachePolicy = .cacheThenNetwork
                query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.salesman = object!.object(forKey: "Salesman") as? String
                    }
                }
                
                let query = PFQuery(className:"Job")
                query.whereKey("JobNo", equalTo:self.tbl23!)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.jobdescription = object!.object(forKey: "Description") as? String
                    }
                }
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Salesman")
                    .queryOrdered(byChild: "salesNo")
                    .queryEqual(toValue: self.tbl22!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.salesman = userDict["salesman"] as? String
                        }
                    })

                FirebaseRef.databaseRoot.child("Job")
                    .queryOrdered(byChild: "jobNo")
                    .queryEqual(toValue: self.tbl23!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.jobdescription = userDict["description"] as? String
                        }
                    })
            }
        }
        
        if (self.formController == "Customer") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Product")
                query.whereKey("ProductNo", equalTo:self.tbl24!)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.advertiser = object!.object(forKey: "Products") as? String
                    }
                }
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Product")
                    .queryOrdered(byChild: "productNo")
                    .queryEqual(toValue: self.tbl24!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.advertiser = userDict["products"] as? String
                        }
                    })
            }
        }
        
        if (self.formController == "Leads") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Advertising")
                query.whereKey("AdNo", equalTo:self.tbl24!)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.advertiser = object!.object(forKey: "Advertiser") as? String
                    }
                }
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Advertising")
                    .queryOrdered(byChild: "adNo")
                    .queryEqual(toValue: self.tbl24!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.advertiser = userDict["advertiser"] as? String
                        }
                    })
            }
        }
    }
    
    // MARK: - Actions
    @objc func actionButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        
        let addr = UIAlertAction(title: "Add Contact", style: .default, handler: { (action) in
            self.createContact()
        })
        let cal = UIAlertAction(title: "Add Calender Event", style: .default, handler: { (action) in
            self.addEvent()
        })
        let web = UIAlertAction(title: "Web Page", style: .default, handler: { (action) in
            self.openurl()
        })
        let new = UIAlertAction(title: "Add Customer", style: .default, handler: { (action) in
            self.status = "New"
            self.performSegue(withIdentifier: "editFormSegue", sender: self)
        })
        let phone = UIAlertAction(title: "Call Phone", style: .default, handler: { (action) in
            self.callPhone()
        })
        let email = UIAlertAction(title: "Send Email", style: .default, handler: { (action) in
            self.sendEmail()
        })
        let bday = UIAlertAction(title: "Birthday", style: .default, handler: { (action) in
            self.getBirthday()
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            //print("Cancel Button Pressed")
        }
        
        alertController.addAction(phone)
        alertController.addAction(email)
        alertController.addAction(addr)
        if (formController == "Leads") {
            alertController.addAction(new)
        }
        if (formController == "Vendor") {
            alertController.addAction(web)
        }
        if !(formController == "Employee") {
            alertController.addAction(cal)
        }
        alertController.addAction(bday)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true)
    }
    
    func callPhone() {
        
        let phoneNo : String?
        if UIDevice.current.userInterfaceIdiom == .phone  {
            
            if (formController == "Vendors") || (formController == "Employee") {
                phoneNo = t11!
            } else {
                phoneNo = t12!
            }
            
            if let phoneCallURL:URL = URL(string:"telprompt:\(phoneNo!)") {
                
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    
                    application.open(phoneCallURL, options: [:], completionHandler: nil)

                }
            } else {
                
                self.simpleAlert(title: "Alert", message: "Call facility is not available!!!")
            }
        } else {
            
            self.simpleAlert(title: "Alert", message: "Your device doesn't support this feature.")
        }
    }
    
    func openurl() {
        
        if (self.tbl26 != NSNull() && self.tbl26 != "0") {

            let Hooks = "http://\(self.tbl26!)"
            let Url = URL(string: Hooks)
            
            if UIApplication.shared.canOpenURL(Url!)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(Url!)
                } else {
                    // Fallback on earlier versions
                }
                
            } else {
                
                self.simpleAlert(title: "Invalid URL", message: "Your field doesn't have valid URL.")
            }
            
        } else {
            
            self.simpleAlert(title: "Invalid URL", message: "Your field doesn't have valid URL.")
            
        }
    }
    
    func sendEmail() {
        
        if (formController == "Leads") || (formController == "Customer") {
            if ((self.tbl15 != NSNull()) || (self.tbl15 != "0")) {
                
                self.getEmail((t15!) as NSString)
                
            } else {
                
                self.simpleAlert(title: "Alert", message: "Your field doesn't have valid email.")
            }
        }
        if (formController == "Vendor") || (formController == "Employee") {
            if ((self.tbl21 != NSNull()) && (self.tbl21 != "0" )) {
                
                self.getEmail(t21!)
                
            } else {
                
                self.simpleAlert(title: "Alert", message: "Your field doesn't have valid email.")
            }
        }
    }
    
    func getEmail(_ emailfield: NSString) {
      
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setToRecipients([emailfield as String])
        email.setSubject((emailTitle)!)
        email.setMessageBody((messageBody)!, isHTML:true)
        email.modalTransitionStyle = .flipHorizontal
        self.present(email, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
    
    func addEvent() {
        
        let eventStore = EKEventStore()
        let itemText = defaults.string(forKey: "eventtitleKey")!
        let startDate = Date().addingTimeInterval(60 * 60)
        let endDate = startDate.addingTimeInterval(60 * 60) // One hour
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                self.createEvent(eventStore, title: String(format: "%@, %@", itemText, self.name!), startDate: startDate, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: String(format: "%@ %@", itemText, self.name!), startDate: startDate, endDate: endDate)
        }
    }
    
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) {
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = String(format: "%@ %@ %@ %@", self.address!,self.city!,self.state!,self.zip!)
        event.notes = self.comments
        event.calendar = eventStore.defaultCalendarForNewEvents
        //event.addAlarm(EKAlarm.init(relativeOffset: 60.0))
        do {
            try eventStore.save(event, span: .thisEvent)
            savedEventId = event.eventIdentifier
            
            self.simpleAlert(title: "Event", message: "Event successfully saved.")
            
        } catch {
            print("An error occurred")
        }
    }
    
    func createContact() {
        
        let newContact = CNMutableContact()
        
        if (formController == "Leads") {
            
            newContact.givenName = self.tbl13! as String
            newContact.familyName = self.name!
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = "US"
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone = CNLabeledValue(label:CNLabelHome, value:CNPhoneNumber(stringValue: self.tbl12! as String))
            newContact.phoneNumbers = [homephone]
            
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl15!)
            newContact.emailAddresses = [homeEmail]
            
            newContact.note = self.comments!
        }
        
        if (formController == "Customer") {
            
            newContact.givenName = self.tbl13! as String
            newContact.familyName = self.name!
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = "US"
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone = CNLabeledValue(label:CNLabelHome, value:CNPhoneNumber(stringValue:self.tbl12! as String))
            newContact.phoneNumbers = [homephone]
            
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl15!)
            newContact.emailAddresses = [homeEmail]
            
            newContact.organizationName = self.tbl11!
            newContact.note = self.comments!
        }
        
        if (formController == "Vendor") {
            
            newContact.jobTitle = (self.tbl25)!
            newContact.organizationName = (self.name)!
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = "US"
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone1 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl11! as String))
            let homephone2 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl12! as String))
            let homephone3 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl13! as String))
            let homephone4 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl14! as String))
            newContact.phoneNumbers = [homephone1, homephone2, homephone3, homephone4]
            
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl21!)
            newContact.emailAddresses = [homeEmail]
            
            newContact.note = self.comments!
        }
        
        if (formController == "Employee") {
            
            newContact.givenName = self.tbl26! as String
            newContact.middleName = self.tbl15! as String
            newContact.familyName = self.custNo!
            
            newContact.jobTitle = (self.tbl23)
            newContact.organizationName = (self.tbl27!)
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = self.tbl25!
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone1 = CNLabeledValue(label:CNLabelHome, value:CNPhoneNumber(stringValue: self.tbl11! as String))
            let homephone2 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl12! as String))
            let homephone3 = CNLabeledValue(label:CNLabelPhoneNumberMobile, value:CNPhoneNumber(stringValue: self.tbl13! as String))
            newContact.phoneNumbers = [homephone1, homephone2, homephone3]

            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl21!)
          //let workEmail = CNLabeledValue(label: CNLabelWork,value: "liam@workemail.com")
            newContact.emailAddresses = [homeEmail]
            
            var birthday = DateComponents()
            birthday.year = 1988 // You can omit the year value for a yearless birthday
            birthday.month = 12
            birthday.day = 05
            newContact.birthday = birthday
            
            var anniversaryDate = DateComponents()
            anniversaryDate.month = 10
            anniversaryDate.day = 12
            //let anniversary = CNLabeledValue(label: "Anniversary", value: anniversaryDate)
            //newContact.dates = [anniversary]
            
            //newContact.departmentName = "Food and Beverages"
            
            /*
             let facebookProfile = CNLabeledValue(label: "FaceBook", value:
             CNSocialProfile(urlString: nil, username: "ios_blog",
             userIdentifier: nil, service: CNSocialProfileServiceFacebook))
             
             let twitterProfile = CNLabeledValue(label: "Twitter", value:
             CNSocialProfile(urlString: nil, username: "ios_blog",
             userIdentifier: nil, service: CNSocialProfileServiceTwitter))
             
             newContact.socialProfiles = [facebookProfile, twitterProfile]
             */
            
            if let img = UIImage(named: "profile-rabbit-toy"),
                let imgData = img.pngData() {
                newContact.imageData = imgData
            }
            
            newContact.note = self.comments!
        }
        
        do {
//-------------dupicate Contact-----------
            
            let nameStr: String
            if (formController == "Leads") || (formController == "Customer") {
                nameStr = "\(self.tbl13!) \(self.name!)"
            } else {
                nameStr = "\(self.name!)"
            }
            
            let predicateForMatchingName = CNContact
                .predicateForContacts(matchingName: nameStr)
            
            let matchingContacts = try! CNContactStore()
                .unifiedContacts(matching: predicateForMatchingName, keysToFetch: [])
            
            guard matchingContacts.isEmpty else {
                DispatchQueue.main.async {
                    self.simpleAlert(title: "Name already exists", message: "There can only be one\n \(nameStr)")
                }
                return
            }
            
//---------------------------------
            
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
            let contactStore = CNContactStore()
            
            try contactStore.execute(saveRequest)
            
            self.simpleAlert(title: "Contact", message: "Contact successfully saved.")
        } catch {
            self.simpleAlert(title: "Contact", message: "Failed to add the contact.")
        }
    }
    
     // FIXME:
    func getBirthday() {
        
        let nameStr: String
        if (formController == "Leads") || (formController == "Customer") {
            nameStr = "\(self.tbl13!) \(self.name!)"
        } else {
            nameStr = "\(self.name!)"
        }

        let store = CNContactStore()

        let contacts:[CNContact] = try! store.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: nameStr), keysToFetch:[CNContactBirthdayKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor])
        
        let contact = contacts[0]
 
        if ((contact.birthday as NSDateComponents?)?.date as Date?) != nil {
           
            let formatter = DateFormatter()
            formatter.timeZone = .current
            formatter.dateFormat = "MMM-dd-yyyy"
            let stringDate = formatter.string(from: contact.birthday!.date!)

            self.simpleAlert(title: "\(nameStr) Birthday", message: stringDate)
        } else {
            self.simpleAlert(title: "Info", message: "No Birthdays for \(nameStr) ")
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        if segue.identifier == "showmapSegue" {
            guard let controller = segue.destination as? MapView else { return }
            controller.formController = "CustMap"
            controller.mapaddress = self.address! as NSString
            controller.mapcity = self.city! as NSString
            controller.mapstate = self.state! as NSString
            controller.mapzip = self.zip! as NSString
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
        if segue.identifier == "editFormSegue" {
            guard let controller = segue.destination as? EditData else { return }

            if (formController == "Leads") {
                
                if (self.status == "Edit") {
                    
                    controller.formController = self.formController
                    controller.status = "Edit"
                    controller.objectId = self.objectId //Parse Only
                    controller.leadNo = self.leadNo
                    controller.frm11 = self.tbl13 //first
                    controller.frm12 = self.name
                    controller.frm13 = nil
                    controller.frm14 = self.address
                    controller.frm15 = self.city
                    controller.frm16 = self.state
                    controller.frm17 = self.zip
                    controller.frm18 = self.date
                    controller.frm19 = self.tbl21 as String? //aptdate
                    controller.frm20 = self.tbl12 //phone
                    controller.frm21 = self.tbl22 //salesNo
                    controller.frm22 = self.tbl23 //jobNo
                    controller.frm23 = self.tbl24 //adNo
                    controller.frm24 = self.amount
                    controller.frm25 = self.tbl15 as String?//email
                    controller.frm26 = self.tbl14 //spouse
                    controller.frm27 = self.tbl11 //callback
                    controller.frm28 = self.comments
                    controller.frm29 = self.photo
                    controller.frm30 = self.active as NSString?
                    controller.saleNo = self.tbl22
                    controller.jobNo = self.tbl23
                    controller.adNo = self.tbl24
                    
                } else if (self.status == "New") { //new Customer from Lead
                    
                    controller.formController = "Customer"
                    controller.status = "New"
                    controller.custNo = self.custNo
                    controller.frm11 = self.tbl13 //first
                    controller.frm12 = self.name
                    controller.frm13 = nil
                    controller.frm14 = self.address
                    controller.frm15 = self.city
                    controller.frm16 = self.state
                    controller.frm17 = self.zip
                    controller.frm18 = nil //date
                    controller.frm19 = nil //aptdate
                    controller.frm20 = self.tbl12 //phone
                    controller.frm21 = self.salesman
                    controller.frm22 = self.jobdescription
                    controller.frm23 = nil //adNo
                    controller.frm24 = self.amount
                    controller.frm25 = self.tbl15 as String? //email
                    controller.frm26 = self.tbl14 //spouse
                    controller.frm27 = nil //callback
                    controller.frm28 = self.comments
                    controller.frm29 = self.photo
                    controller.frm30 = self.active as NSString?
                    controller.frm31 = nil //start
                    controller.frm32 = nil //completion
                }
                
            } else if (formController == "Customer") {
                
                controller.formController = self.formController
                controller.status = "Edit"
                controller.objectId = self.objectId //Parse Only
                controller.custNo = self.custNo
                controller.leadNo = self.leadNo
                controller.frm11 = self.tbl11 //first
                controller.frm12 = self.name
                controller.frm13 = self.tbl13
                controller.frm14 = self.address
                controller.frm15 = self.city
                controller.frm16 = self.state
                controller.frm17 = self.zip
                controller.frm18 = self.date
                controller.frm19 = self.tbl26 as String? //rate
                controller.frm20 = self.tbl12 //phone
                controller.frm21 = self.tbl22 //salesNo
                controller.frm22 = self.tbl23 //jobNo
                controller.frm23 = self.tbl24 //prodNo
                controller.frm24 = self.amount
                controller.frm25 = self.tbl15 as String? //email
                controller.frm26 = self.tbl14 //spouse
                controller.frm27 = self.tbl25 //quan
                controller.frm28 = self.comments
                controller.frm29 = self.photo
                controller.frm30 = self.active as NSString?
                controller.frm31 = self.tbl21 as String? //start
                controller.frm32 = self.complete
                controller.saleNo = self.tbl22
                controller.jobNo = self.tbl23
                controller.adNo = self.tbl24
                controller.time = self.tbl16
              //controller.frm33 = self.photo1
              //controller.frm34 = self.photo2
                
            } else if (formController == "Vendor") {
                controller.formController = self.formController
                controller.status = "Edit"
                controller.objectId = self.objectId //Parse Only
                controller.leadNo = self.leadNo //vendorNo
                controller.frm11 = self.name //vendorname
                controller.frm12 = self.date //webpage
                controller.frm13 = self.tbl24 //manager
                controller.frm14 = self.address
                controller.frm15 = self.city
                controller.frm16 = self.state
                controller.frm17 = self.zip
                controller.frm18 = self.tbl25 //profession
                controller.frm19 = self.tbl15 as String? //assistant
                controller.frm20 = self.tbl11 //phone
                controller.frm21 = self.tbl12 //phone1
                controller.frm22 = self.tbl13 //phone2
                controller.frm23 = self.tbl14 //phone3
                controller.frm24 = self.tbl22 //department
                controller.frm25 = self.tbl21 as String? //email
                controller.frm26 = self.tbl23 //office
                controller.frm27 = nil
                controller.frm28 = self.comments
                controller.frm29 = nil
                controller.frm30 = self.active as NSString?

            } else if (formController == "Employee") {
                controller.formController = self.formController
                controller.status = "Edit"
                controller.objectId = self.objectId //Parse Only
                controller.leadNo = self.leadNo //employeeNo
                controller.frm11 = self.tbl26 as String? //first
                controller.frm12 = self.custNo //lastname
                controller.frm13 = self.tbl27 //company
                controller.frm14 = self.address
                controller.frm15 = self.city
                controller.frm16 = self.state
                controller.frm17 = self.zip
                controller.frm18 = self.tbl23 //title
                controller.frm19 = self.tbl15 as String? //middle
                controller.frm20 = self.tbl11 //homephone
                controller.frm21 = self.tbl12 //workphone
                controller.frm22 = self.tbl13 //cellphone
                controller.frm23 = self.tbl14 //social
                controller.frm24 = self.tbl22 //department
                controller.frm25 = self.tbl21 as String?//email
                controller.frm26 = self.tbl25 //manager
                controller.frm27 = self.tbl24
                controller.frm28 = self.comments
                controller.frm29 = nil
                controller.frm30 = self.active! as NSString
            }
        }
    }
}
extension LeadDetail: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.listTableView) {
            return tableData.count
        } else if (tableView == self.listTableView2) {
            return tableData2.count
        } else if (tableView == self.newsTableView) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.textLabel?.font = Font.Detail.celltitlePad
            cell.detailTextLabel?.font = Font.Detail.cellsubtitlePad
        } else {
            cell.textLabel?.font = Font.Detail.celltitle
            cell.detailTextLabel?.font = Font.Detail.cellsubtitle
        }
        
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .systemBlue
            cell.detailTextLabel?.textColor = .label
        } else {
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }
        
        
        if (tableView == self.listTableView) {
            
            cell.textLabel?.text = tableData4.object(at: indexPath.row) as? String
            cell.detailTextLabel?.text = tableData.object(at: indexPath.row) as? String
            
            return cell
            
        } else if (tableView == self.listTableView2) {
            
            cell.textLabel?.text = tableData3.object(at: indexPath.row) as? String
            cell.detailTextLabel?.text = tableData2.object(at: indexPath.row) as? String
            
            return cell
            
        } else if (tableView == self.newsTableView) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
            cell.customImageView.isHidden = true //fix
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                cell.leadtitleDetail!.font = Font.Detail.ipadnewstitle
                cell.leadsubtitleDetail!.font = Font.Detail.ipadnewssubtitle
                cell.leadreadDetail!.font = Font.Detail.ipadnewsdetail
                cell.leadnewsDetail!.font = Font.Detail.ipadnewsdetail
            } else {
                cell.leadtitleDetail!.font = Font.Detail.newstitle
                cell.leadsubtitleDetail!.font = Font.Detail.newssubtitle
                cell.leadreadDetail!.font = Font.Detail.newsdetail
                cell.leadnewsDetail!.font = Font.Detail.newsdetail
            }
            
            let width = CGFloat(2.0)
            let topBorder = CALayer()
            topBorder.borderColor = UIColor.lightGray.cgColor
            topBorder.frame = .init(x: 0, y: 0, width: view.frame.width, height: 0.5)
            topBorder.borderWidth = width
            cell.layer.addSublayer(topBorder)
            cell.layer.masksToBounds = true
            
            cell.customImagelabel.backgroundColor = .clear
            cell.leadtitleDetail!.text = "\(self.formController!) News: \(self.lnewsTitle!)"
            cell.leadtitleDetail!.numberOfLines = 0
                        cell.leadsubtitleDetail!.text = "Comments"
            
            //--------------------------------------------------------------
            
            if (self.formController == "Vendor" || self.formController == "Employee") {
                
                cell.leadsubtitleDetail.text = "Comments"
                
            } else {
                
                let dateStr = self.date
                let dateFormatter = DateFormatter()
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                } else {
                    //firebase
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                }
                
                let date1 = dateFormatter.date(from: dateStr!)
                let date2 = Date()
                let calendar = Calendar.current
                if date1 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                    let daysCount = diffDateComponents.day
                    cell.leadsubtitleDetail.text = "Comments, \(daysCount!) days ago"
                }
            }
            
            //--------------------------------------------------------------
            
            cell.leadreadDetail.text = "Read more"
            cell.leadnewsDetail.text = self.comments
            cell.leadnewsDetail.numberOfLines = 0
            
            if #available(iOS 13.0, *) {
                cell.leadtitleDetail!.textColor = .label
                cell.leadsubtitleDetail.textColor = .systemBlue
                cell.leadreadDetail.textColor = .systemGray
                cell.leadnewsDetail.textColor = .label
            } else {
   
            }
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
}



