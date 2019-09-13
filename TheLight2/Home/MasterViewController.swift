//
//  MasterViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import Parse
import AVFoundation
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAnalytics
//import SwiftKeychainWrapper


final class MasterViewController: UITableViewController, UISplitViewControllerDelegate {

    let defaults = UserDefaults.standard
    
    //firebase
    var currentUser: UserModel?

    private var menuItems = ["Snapshot","Statistics","Leads","Customers","Vendors","Employee","Advertising","Product","Job","Salesman", "Zip","Geotify","Search Places","Music","YouTube","Spot Beacon","Transmit Beacon","Contacts", "Show Detail"]
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredMenu = [String]()
    
    var currentItem = "Snapshot"
    var player : AVAudioPlayer! = nil
    var objects = [AnyObject]()

    weak var symYQL: NSArray!
    weak var tradeYQL: NSArray!
    weak var changeYQL: NSArray!

    var tempYQL: String!
    var textYQL: String!
    
    let myLabel1: UILabel = {
        let label = UILabel(frame: .init(x: 10, y: 10, width: 74, height: 74))
        label.numberOfLines = 2
        label.backgroundColor = .white
        label.textColor = UIColor.systemBlue//Color.goldColor
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 37.0
        label.layer.borderColor = UIColor.lightText.cgColor //Color.Header.headtextColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let myLabel2: UILabel = {
        let label = UILabel(frame: .init(x: 110, y: 10, width: 74, height: 74))
        label.numberOfLines = 2
        label.backgroundColor = .white
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 37.0
        label.layer.borderColor = UIColor.lightText.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let myLabel3: UILabel = {
        let label = UILabel(frame: .init(x: 210, y: 10, width: 74, height: 74))
        label.numberOfLines = 2
        label.backgroundColor = .white
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 37.0
        label.layer.borderColor = UIColor.lightText.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let myLabel4: UILabel = {
        let label = UILabel(frame: .init(x: 10, y: 115, width: 280, height: 20))
        label.font = Font.celltitle16l
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let myLabel15: UILabel = {
        let label = UILabel(frame: .init(x: 10, y: 85, width: 74, height: 20))
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.font = Font.celltitle14m
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let myLabel25: UILabel = {
        let label = UILabel(frame: .init(x: 110, y: 85, width: 74, height: 20))
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let myLabel35: UILabel = {
        let label = UILabel(frame: .init(x: 210, y: 85, width: 74, height: 20))
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var separatorLine1: UIView = {
        let view = UIView(frame: .init(x: 10, y: 105, width: 74, height: 3.5))
        view.backgroundColor = .systemGreen
        return view
    }()
    
    lazy var separatorLine2: UIView = {
        let view = UIView(frame: .init(x: 110, y: 105, width: 74, height: 3.5))
        return view
    }()
    
    lazy var separatorLine3: UIView = {
        let view = UIView(frame: .init(x: 210, y: 105, width: 74, height: 3.5))
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = false
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
        self.splitViewController?.maximumPrimaryColumnWidth = 350

        setupNavigation()
        setupTableView()
        versionCheck()
        speech()
        updateYahoo()
        fetchUserIds()
        edgesForExtendedLayout = []  // FIXME: header space

        // Sound
        if (defaults.bool(forKey: "soundKey"))  {
            playSound()
        }
        
        // yahoo bad weather warning
        if (defaults.bool(forKey: "weatherNotifyKey"))  {
            guard let severeYQL = textYQL else { return }
            if (severeYQL.contains("Rain") || severeYQL.contains("Snow") || severeYQL.contains("Thunderstorms") || severeYQL.contains("Showers")) {
                
                DispatchQueue.main.async {
                    self.simpleAlert(title: severeYQL, message: "Bad weather today!")
                }
            }
        }
        
        self.refreshControl?.backgroundColor = .clear //Color.Lead.navColor
        self.refreshControl?.tintColor = .white
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl?.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
        self.tabBarController?.tabBar.isHidden = false
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
    
    private func fetchUserIds() {
        
        // MARK: - Login
        let userId: String = (defaults.object(forKey: "usernameKey") as! String?)!
        let userpassword: String = (defaults.object(forKey: "passwordKey") as! String?)!
        let useremail: String = (defaults.object(forKey: "emailKey") as! String?)!
        /*
        let userSuccessful: Bool = KeychainWrapper.standard.set(userId, forKey: "usernameKey")
        let passSuccessful: Bool = KeychainWrapper.standard.set(userpassword, forKey: "passwordKey")
        
        // MARK: - Keychain
        if (userSuccessful == true), (passSuccessful == true) {
            print("Keychain successful")
        } else {
            print("Keychain failed")
        } */
        
        // MARK: - Parse
        if (defaults.bool(forKey: "parsedataKey")) {
            
            PFUser.logInWithUsername(inBackground: userId, password:userpassword) { (user, error) in
                if error != nil {
                    print("Error: \(String(describing: error)) \(String(describing: error!._userInfo))")
                    return
                }
            }
            
        } else {
            //firebase
            Auth.auth().signIn(withEmail: useremail, password: userpassword, completion: { (user, err) in
                if let err = err{
                    self.simpleAlert(title: "Oooops", message: "Your username and password does not match")
                    print("Failed to login:", err)
                    return
                }
                print("Succesfully logged back in with user:", user?.user.uid ?? "")
            })
        }
    }
    
    // MARK: - Splitview
    //added makes MainController opens on startup instead of DetailViewController
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    func setupNavigation() {

        navigationController?.navigationBar.prefersLargeTitles = true
        let addBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.actionButton))
        navigationItem.rightBarButtonItems = [addBtn]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.handleLogout))
        navigationItem.title = "Main Menu"
        
        searchController = UISearchController(searchResultsController: resultsController)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        
        self.definesPresentationContext = true
    }
    
    func setupTableView() {
        if #available(iOS 13.0, *) {
            let bgView = UIView()
            bgView.backgroundColor = .secondarySystemGroupedBackground
            tableView!.backgroundView = bgView
            self.tableView!.backgroundColor = .systemGroupedBackground
            resultsController.tableView.backgroundColor = .systemGroupedBackground
        } else {
            self.tableView!.backgroundColor = Color.LGrayColor //.black
            resultsController.tableView.backgroundColor = Color.LGrayColor
        }
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.sizeToFit()
        self.tableView!.clipsToBounds = true
        self.tableView!.tableFooterView = UIView(frame: .zero)

        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc func refreshData() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.updateYahoo()
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    // MARK: - Button
    @objc func actionButton(_ sender: AnyObject) {
 
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        
        let setting = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            let settingsUrl = URL(string:UIApplication.openSettingsURLString)
            UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
        })
        let buttonTwo = UIAlertAction(title: "Users", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "userSegue", sender: self)
        })
        let buttonThree = UIAlertAction(title: "Notification", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "notificationSegue", sender: self)
        })
        let buttonFour = UIAlertAction(title: "Membership Card", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "codegenSegue", sender: self)
        })
        let buttonSocial = UIAlertAction(title: "Social", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "socialSegue", sender: self)
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alertController.addAction(setting)
        alertController.addAction(buttonTwo)
        alertController.addAction(buttonThree)
        alertController.addAction(buttonFour)
        alertController.addAction(buttonSocial)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true)
    }
    
     // MARK: - playSound
    func playSound() {
        
        let audioPath = Bundle.main.path(forResource: "MobyDick", ofType: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }
        catch {
            self.simpleAlert(title: "Alert", message: "Something bad happened. Try catching specific errors to narrow things down")
        }
        player.play()
    }
    
    // MARK: - speech
    func speech() {
        if (defaults.bool(forKey: "speechKey")) {
            let utterance = AVSpeechUtterance(string: "Greetings from TheLight Software")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-gb")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    // MARK: - VersionCheck
    //fix
    func versionCheck() {
        if (defaults.bool(forKey: "parsedataKey")) {
            /*
            let query = PFQuery(className:"Version")
            query.cachePolicy = .cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                
                let versionId = object?.value(forKey: "VersionId") as! String?
                if (versionId != self.defaults.string(forKey: "versionKey")) {
                    DispatchQueue.main.async {
                        self.simpleAlert(title: "New Version!", message: "A new version of app is available to download")
                    }
                } else {
                    print("You have current software version!")
                }
            } */
        } else {

            let numVer = self.defaults.string(forKey: "versionKey")
            
            FirebaseRef.databaseRoot.child("Version")
                .queryOrdered(byChild: "version")
                .queryEqual(toValue: numVer)
                .observe(.value, with:{ (snapshot) in
                    
                    if snapshot.exists() {
                        DispatchQueue.main.async {
                            self.simpleAlert(title: "New Version!", message: "A new version of app is available to download")
                        }
                        
                    } else {
                        print("You have current software version!")
                    }
                })
        }
    }
    
    // MARK: - updateYahoo
    func updateYahoo() {

        //weather
        let results = YQL.query(statement: String(format: "%@%@", "select * from weather.forecast where woeid=", self.defaults.string(forKey: "weatherKey")!))
        
        let queryResults = results?.value(forKeyPath: "query.results.channel.item") as? NSDictionary
        if queryResults != nil {
            
            let weatherInfo = queryResults!["condition"] as? NSDictionary
            tempYQL = weatherInfo?.object(forKey: "temp") as? String ?? ""
            textYQL = weatherInfo?.object(forKey: "text") as? String ?? ""
        }
        //stocks
        let stockresults = YQL.query(statement: "select * from yahoo.finance.quote where symbol in (\"^IXIC\",\"SPY\")")
        let querystockResults = stockresults?.value(forKeyPath: "query.results") as? NSDictionary?
        if querystockResults != nil {
            
            symYQL = querystockResults!?.value(forKeyPath: "quote.symbol") as? NSArray
            tradeYQL = querystockResults!?.value(forKeyPath: "quote.LastTradePriceOnly") as? NSArray
            changeYQL = querystockResults!?.value(forKeyPath: "quote.Change") as? NSArray
        } 
    }
    
    // MARK: - Logout
    @objc func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            PFUser.logOut()
            LoginManager().logOut()
            GIDSignIn.sharedInstance().signOut()
            AccessToken.current = nil
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginIDController")
        self.present(vc, animated: true)
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 4
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if (section == 0) {
                return 2
            } else if (section == 1) {
                return 4
            } else if (section == 2) {
                return 5
            } else if (section == 3) {
                return 8
            }
        } else {
            return filteredMenu.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if (tableView == self.tableView) {
            
            cellIdentifier = "Cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            cell.selectionStyle = .none
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .secondarySystemGroupedBackground //.systemGroupedBackground
                cell.textLabel?.textColor = .label
            } else {
                cell.backgroundColor = .white
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                cell.textLabel!.font = Font.celltitle22m
            } else {
                cell.textLabel!.font = Font.celltitle20l
            }
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    cell.textLabel!.text = menuItems[0]
                } else if (indexPath.row == 1) {
                    cell.textLabel!.text = menuItems[1]
                }
                
            } else if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    cell.textLabel!.text = menuItems[2]
                } else if (indexPath.row == 1) {
                    cell.textLabel!.text = menuItems[3]
                } else if (indexPath.row == 2) {
                    cell.textLabel!.text = menuItems[4]
                } else if (indexPath.row == 3) {
                    cell.textLabel!.text = menuItems[5]
                }
                
            } else if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    cell.textLabel!.text = menuItems[6]
                } else if (indexPath.row == 1) {
                    cell.textLabel!.text = menuItems[7]
                } else if (indexPath.row == 2) {
                    cell.textLabel!.text = menuItems[8]
                } else if (indexPath.row == 3) {
                    cell.textLabel!.text = menuItems[9]
                } else if (indexPath.row == 4) {
                    cell.textLabel!.text = menuItems[10]
                }
            } else if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    cell.textLabel!.text = menuItems[11]
                } else if (indexPath.row == 1) {
                    cell.textLabel!.text = menuItems[12]
                } else if (indexPath.row == 2) {
                    cell.textLabel!.text = menuItems[13]
                } else if (indexPath.row == 3) {
                    cell.textLabel!.text = menuItems[14]
                } else if (indexPath.row == 4) {
                    cell.textLabel!.text = menuItems[15]
                } else if (indexPath.row == 5) {
                    cell.textLabel!.text = menuItems[16]
                } else if (indexPath.row == 6) {
                    cell.textLabel!.text = menuItems[17]
                } else if (indexPath.row == 7) {
                    cell.textLabel!.text = menuItems[18]
                }
            }
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.textLabel!.text = self.filteredMenu[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.tableView) {
            if (section == 0) {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 145.0
                } else {
                    return CGFloat.leastNormalMagnitude
                }
            } else if (section == 1) {
                return 10
            } else if (section == 2) {
                return 10
            } else if (section == 3) {
                return 10
            }
            return 0
        }
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (tableView == self.tableView) {
            if (section == 0) {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    let vw = UIView()
                    vw.backgroundColor = .systemGroupedBackground
                    //tableView.tableHeaderView = vw

                    myLabel1.text = String(format: "%@%d", "COUNT\n", menuItems.count )
                    vw.addSubview(myLabel1)
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        myLabel15.text = "Parse"
                    } else {
                        myLabel15.text = "Firebase"
                    }
                    vw.addSubview(myLabel15)

                    myLabel2.text = "NASDAQ \n \(tradeYQL?[0] ?? "0")"
                    vw.addSubview(myLabel2)
                    
                    myLabel25.text = "\(changeYQL?[0] ?? "0")"
                    vw.addSubview(myLabel25)
                    
                    myLabel3.text = "S&P 500 \n \(tradeYQL?[1] ?? "0")"
                    vw.addSubview(myLabel3)
                    
                    myLabel35.text = "\(changeYQL?[1] ?? "0")"
                    vw.addSubview(myLabel35)
                    
                    if (myLabel25.text?.contains("-"))! {
                        separatorLine2.backgroundColor = .systemRed
                        myLabel25.textColor = .systemRed
                    } else {
                        separatorLine2.backgroundColor = .systemGreen
                        myLabel25.textColor = .systemGreen
                    }
                    
                    if (myLabel35.text?.contains("-"))! {
                        separatorLine3.backgroundColor = .systemRed
                        myLabel35.textColor = .systemRed
                    } else {
                        separatorLine3.backgroundColor = .systemGreen
                        myLabel35.textColor = .systemGreen
                    }
                    vw.addSubview(separatorLine1)
                    vw.addSubview(separatorLine2)
                    vw.addSubview(separatorLine3)
                    
                    if (tempYQL != nil) && (textYQL != nil) {
                        myLabel4.text = String(format: "%@ %@ %@", "Weather:", "\(tempYQL!)°", "\(textYQL!)")
                        if (textYQL!.contains("Rain") ||
                            textYQL!.contains("Snow") ||
                            textYQL!.contains("Thunderstorms") ||
                            textYQL!.contains("Showers")) {
                            myLabel4.textColor = .systemRed
                        } else {
                            myLabel4.textColor = .systemGreen
                        }
                    } else {
                        myLabel4.text = "Weather not available"
                        myLabel4.textColor = .systemRed
                    }
                    vw.addSubview(myLabel4)
                    
                    /*
                     photoImage.frame = .init(x: 0, y: 0, width: tableView..frame.size.width, height: 145)
                     vw.addSubview(photoImage)
                     
                     let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                     visualEffectView.frame = photoImage.bounds
                     photoImage.addSubview(visualEffectView) */
                    
                    return vw
                }
                //return nil
            }
            //return nil
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Segues
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        let currentItem = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        if (currentItem.textLabel!.text! == "Snapshot") {
            self.performSegue(withIdentifier: "snapshotSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Statistics") {
            self.performSegue(withIdentifier: "statisticSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Leads") {
            self.performSegue(withIdentifier: "showleadSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Customers") {
            self.performSegue(withIdentifier: "showcustSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Vendors") {
            self.performSegue(withIdentifier: "showvendSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Employee") {
            self.performSegue(withIdentifier: "showemployeeSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Advertising") {
            self.performSegue(withIdentifier: "showadSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Product") {
            self.performSegue(withIdentifier: "showproductSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Job") {
            self.performSegue(withIdentifier: "showjobSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Salesman") {
            self.performSegue(withIdentifier: "showsalesmanSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Zip") {
            self.performSegue(withIdentifier: "showzipSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Geotify") {
            self.performSegue(withIdentifier: "geotifySegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Show Detail") {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        } else if (currentItem.textLabel!.text! == "Music") {
            self.performSegue(withIdentifier: "musicSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "YouTube") {
            self.performSegue(withIdentifier: "youtubeSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Spot Beacon") {
            self.performSegue(withIdentifier: "spotbeaconSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Transmit Beacon") {
            self.performSegue(withIdentifier: "transmitbeaconSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Contacts") {
            self.performSegue(withIdentifier: "contactSegue", sender: self)
        } else if (currentItem.textLabel!.text! == "Search Places") {
            self.performSegue(withIdentifier: "searchMapSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        if segue.identifier == "geotifySegue" {
            guard let controller = segue.destination as? GeotificationVC else { return }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "searchMapSegue" {
            guard let controller = segue.destination as? MapsearchVC else { return }
            //navigationItem.backBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: nil, action: nil)
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "snapshotSegue" {
            guard let controller = segue.destination as? SnapshotVC else { return }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "statisticSegue" {
            guard let controller = segue.destination as? StatisticVC else { return }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "showDetail" {
            guard let controller = segue.destination as? DetailViewVC else { return }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "musicSegue" {
            guard let controller = segue.destination as? MusicController else { return }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "youtubeSegue" {
            guard let controller = segue.destination as? YouTubeController else { return }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "spotbeaconSegue" {
            /*
 
            if #available(iOS 13.0, *) {
                let detailsView = DetailView()
                let host = UIHostingController(rootView: detailsView)
                navigationController?.pushViewController(host, animated: true)
            } else { */
            guard let controller = segue.destination as? SpotBeaconVC else { return }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
           // }
        }
        if segue.identifier == "transmitbeaconSegue" {
            /*
 
            if #available(iOS 13.0, *) {
                let detailsView = LabelView()
                let host = UIHostingController(rootView: detailsView)
                navigationController?.pushViewController(host, animated: true)
            } else { */
                guard let controller = segue.destination as? TransmitBeaconVC else { return }
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
           // }
        }
        if segue.identifier == "contactSegue" {
            guard let controller = segue.destination as? ContactVC else { return }
            //let controller = (segue.destination as! UINavigationController).topViewController as! ContactVC
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }

    }
}
//-----------------------end------------------------------
extension MasterViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
        guard let searchText = searchController.searchBar.text, searchText.count > 0 else { return }
        filteredMenu = menuItems.filter { $0.range(of: searchText) != nil }
        print("update search results for \(searchText) - items are now: \(filteredMenu)")
        self.resultsController.tableView.reloadData() */

        self.filteredMenu.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.menuItems as NSArray).filtered(using: searchPredicate)
        self.filteredMenu = array as! [String]
        self.resultsController.tableView.reloadData()
    }
}




