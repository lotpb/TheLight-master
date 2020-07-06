//
//  UserDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/18/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import MapKit
import CoreLocation
import GeoFire
import MobileCoreServices //kUTTypeImage
import MessageUI

@available(iOS 13.0, *)
final class UserDetailController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    private let headerId = "headerId"
    private let cellId = "cellId"
    //firebase
    //var userlist = [UserModel]()
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userimageView: UIImageView?
    
    @IBOutlet weak var usernameField : UITextField?
    @IBOutlet weak var emailField : UITextField?
    @IBOutlet weak var phoneField : UITextField?
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var createtitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!

    public var status : String?
    public var objectId : String?
    public var username : String?
    public var create : String?
    public var update : String?
    public var email : String?
    public var phone : String?
    public var userimage : UIImage?
    
    private var user : PFUser?
    private var userquery : PFObject?
    private var pickImage : UIImage?
    private var pictureData : Data?
    
    private var picker: UIImagePickerController!
    private var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style .medium)
 
    private var emailTitle :NSString?
    private var messageBody:NSString?
    
    private let editProfileBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Photo", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(selectPhotosAlbum), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let updateBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update", for: .normal)
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = ColorX.BlueColor.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(ColorX.BlueColor, for: .normal)
        button.addTarget(self, action: #selector(Update), for: .touchUpInside)
        return button
    }()
    
    private let callBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call", for: .normal)
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(UIColor.label, for: .normal)
        button.addTarget(self, action: #selector(callPhone), for: .touchUpInside)
        return button
    }()
    
    private let emailBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Email", for: .normal)
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = ColorX.BlueColor.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(ColorX.BlueColor, for: .normal)
        button.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        return button
    }()

    private let createLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let updatetitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "last update:"
        label.textColor = .systemBlue
        label.textAlignment = .left
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let updateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "none"
        label.textColor = .label
        label.textAlignment = .left
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true
        setupNavigationButtons()
        
        emailTitle = defaults.string(forKey: "emailtitleKey")! as NSString
        messageBody = defaults.string(forKey: "emailmessageKey")! as NSString
        
        emailField?.keyboardType = .emailAddress
        phoneField?.keyboardType = .numbersAndPunctuation
        
        if status == "Edit" {
            setupMapData()
        }
        setupForm()
        setupBorder()
        setupFonts()

        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - User Profile"
        } else {
            navigationItem.title = "User Profile"
        }
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationButtons() {
        let cameraBtn = UIBarButtonItem(image: UIImage(systemName: "video.fill"), style: .plain, target: self, action: #selector(selectCamera))
        navigationItem.rightBarButtonItems = [cameraBtn]
    }
    
    func setupBorder() {
        
        let bottomBorder = CALayer()
        let width1 = CGFloat(2.0)
        bottomBorder.borderWidth = width1
        bottomBorder.borderColor = UIColor.darkGray.cgColor
        bottomBorder.frame = .init(x: 0, y: self.mainView!.frame.size.height-1, width: view.frame.size.width, height: 0.5)
        mainView?.layer.masksToBounds = true
        mainView?.layer.addSublayer(bottomBorder)
    }
    
    func setupForm() {
        
        view.backgroundColor = .systemBackground
        mainView?.backgroundColor = .systemBackground
        mapContainerView?.backgroundColor = .systemBackground
        infoLabel.textColor = .systemBlue
        createLabel.textColor = .label
        phoneLabel.textColor = .systemBlue
        emailLabel?.textColor = .systemBlue
        userLabel.textColor = .systemBlue
        mapLabel?.textColor = .label
        
        if status == "Edit" {
            usernameField?.text = username
            emailField?.text = email
            phoneField?.text = phone
            createLabel.text = create
            updateLabel.text = update
            userimageView?.image = userimage
        } else {
            userimageView?.image = #imageLiteral(resourceName: "profile-rabbit-toy")
        }
        
        userimageView?.contentMode = .scaleAspectFill
        userimageView?.backgroundColor = .white
        userimageView?.isUserInteractionEnabled = true
        userimageView?.layer.masksToBounds = true
        userimageView?.layer.cornerRadius = 60.0
        
        mapView?.delegate = self
        mapView?.layer.borderColor = UIColor.lightGray.cgColor
        mapView?.layer.borderWidth = 1.0
    }
    
    func setupMapData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query = PFUser.query()
            do {
                userquery = try query!.getObjectWithId(self.objectId!)
                let location = userquery!.value(forKey: "currentLocation") as! PFGeoPoint
                
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                mapView!.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.title = userquery!.object(forKey: "username") as? String
                annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                self.mapView!.addAnnotation(annotation)
                self.mapView!.showsUserLocation = true
            } catch {
                print("Error")
            }
        } else {
            //firebase
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let geofireRef = FirebaseRef.databaseRoot.child("users_locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire.getLocationForKey(uid, withCallback: { (location, error) in
                
                let center = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                
                let circleQuery = geoFire.query(at: center, withRadius: 50)
                circleQuery.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
                    //print("Key '\(key!)' entered the search are and is at location '\(location!)'")
                    
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
                    
                    let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
                    self.mapView!.setRegion(region, animated: true)
                    
                    //for object in objects! {
                    let annotation = MKPointAnnotation()
                    //annotation.title = object["username"] as? String
                    annotation.coordinate = location
                    self.mapView!.addAnnotation(annotation)
                    //}
                })
            })
        }
    }
    
    func setupFonts() {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.usernameField!.font = Font.celltitle20l
            self.emailField!.font = Font.celltitle20l
            self.phoneField!.font = Font.celltitle20l
            self.infoLabel.font = Font.celltitle22l
            self.createtitleLabel!.font = Font.celltitle16l
            self.createLabel.font = Font.celltitle16l
            self.updatetitle.font = Font.celltitle16l
            self.updateLabel.font = Font.celltitle16l
            self.mapLabel!.font = Font.celltitle20l
        } else {
            self.mapLabel!.font = Font.celltitle20l
            self.infoLabel.font = Font.celltitle18l
            self.createtitleLabel!.font = Font.celltitle14l
            self.createLabel.font = Font.celltitle14l
            self.updatetitle.font = Font.celltitle14l
            self.updateLabel.font = Font.celltitle14l
            self.usernameField!.font = Font.celltitle18l
            self.emailField!.font = Font.celltitle18l
            self.phoneField!.font = Font.celltitle18l
            self.phoneLabel.font = Font.celltitle14l
            self.emailLabel?.font = Font.celltitle14l
            self.userLabel.font = Font.celltitle14l
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mainView.addSubview(editProfileBtn)
        mainView.addSubview(createLabel)
        mainView.addSubview(updatetitle)
        mainView.addSubview(updateLabel)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([

            createLabel.topAnchor.constraint(equalTo: (createtitleLabel.bottomAnchor), constant: 2),
            createLabel.leadingAnchor.constraint(equalTo: (view.leadingAnchor), constant: 10),
            createLabel.widthAnchor.constraint(equalToConstant: 100),
            createLabel.heightAnchor.constraint(equalToConstant: 20),

            updatetitle.topAnchor.constraint(equalTo: (createLabel.bottomAnchor), constant: 10),
            updatetitle.leadingAnchor.constraint(equalTo: (view.leadingAnchor), constant: 10),
            updatetitle.widthAnchor.constraint(equalToConstant: 100),
            updatetitle.heightAnchor.constraint(equalToConstant: 20),

            updateLabel.topAnchor.constraint(equalTo: (updatetitle.bottomAnchor), constant: 2),
            updateLabel.leadingAnchor.constraint(equalTo: (view.leadingAnchor), constant: 10),
            updateLabel.widthAnchor.constraint(equalToConstant: 100),
            updateLabel.heightAnchor.constraint(equalToConstant: 20),

            editProfileBtn.topAnchor.constraint(equalTo: (userimageView?.bottomAnchor)!, constant: 10),
            editProfileBtn.centerXAnchor.constraint(equalTo: (userimageView?.centerXAnchor)!),
            editProfileBtn.widthAnchor.constraint(equalToConstant: 200),
            editProfileBtn.heightAnchor.constraint(equalToConstant: 20),
            
            mapView.topAnchor.constraint(equalTo: (mapLabel?.bottomAnchor)!, constant: +25),
            mapView.leadingAnchor.constraint( equalTo: guide.leadingAnchor),
            mapView.trailingAnchor.constraint( equalTo: guide.trailingAnchor),
            mapView.bottomAnchor.constraint( equalTo: guide.bottomAnchor, constant: -16)
            ])
        
        containView.addSubview(updateBtn)
        containView.addSubview(callBtn)
        containView.addSubview(emailBtn)
        
        let stackView = UIStackView(arrangedSubviews: [updateBtn, callBtn, emailBtn])
        if UIDevice.current.userInterfaceIdiom == .phone  {
            stackView.spacing = 15
            containView.translatesAutoresizingMaskIntoConstraints = false
            containView.heightAnchor.constraint(equalToConstant: 800).isActive = true
        } else {
            stackView.spacing = 75
        }
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        containView.addSubview(stackView)
        
        stackView.anchor(top: phoneField?.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: view.frame.width, height: 50)
    }
    
    // MARK: - Button
    @objc func selectCamera() {
        guard case self.objectId = Auth.auth().currentUser?.uid else {
        self.showAlert(title: "Alert!", message: "Updates not allowed for this member")
        return}

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            picker.videoQuality = .typeMedium
            picker.showsCameraControls = true
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            self.present(picker, animated: true)
        } else {
            self.showAlert(title: "Alert!", message: "Camera not available")
        }
    }
    
    @objc func selectPhotosAlbum() {
        guard case self.objectId = Auth.auth().currentUser?.uid else {
            self.showAlert(title: "Alert!", message: "Updates not allowed for this member")
            return}

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                picker.mediaTypes = [kUTTypeImage as String]
                self.present(picker, animated: false)
            } else {
                self.showAlert(title: "Alert!", message: "you are not authorize")
            }
        //}
}
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
            self.userimageView?.contentMode = .scaleAspectFill
            self.userimageView?.clipsToBounds = true
            self.userimageView?.image = image
            updateUsersProfile()
            dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }

    @IBAction func Update(_ sender: AnyObject) {

        self.activityIndicator.center = self.userimageView!.center
        self.activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        if ((defaults.string(forKey: "backendKey")) == "Parse") {

            self.user = PFUser.current()
            if self.usernameField!.text! == self.user?.username {

                pictureData = self.userimageView?.image?.jpegData(compressionQuality: 0.9)
                let file = PFFileObject(name: "img", data: pictureData!)

                file!.saveInBackground { (success: Bool, error: Error?) in
                    if success {
                        self.user!.setObject(self.usernameField!.text!, forKey:"username")
                        self.user!.setObject(self.emailField!.text!, forKey:"email")
                        self.user!.setObject(self.phoneField!.text!, forKey:"phone")
                        self.user!.setObject(file!, forKey:"imageFile")
                        self.user!.saveInBackground { (success: Bool, error: Error?) in
                        }
                        self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                    } else {
                        self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            } else {
                self.showAlert(title: "Alert", message: "User is not valid to edit data")
            }
        } else {
            updateUsersProfile()
        }
    }

    func updateUsersProfile() {
        //firebase
        guard case self.objectId = Auth.auth().currentUser?.uid else {
            self.showAlert(title: "Alert!", message: "Updates not allowed for this member")
            return
        }

        if let userID = Auth.auth().currentUser?.uid {
            let storageItem = Storage.storage().reference().child("profile_images").child(userID)
            guard let image = userimageView?.image else {return}
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            if let newImage = image.jpegData(compressionQuality: 0.9)  {
                storageItem.putData(newImage, metadata: metadata) { (metadata, error) in
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                    storageItem.downloadURL(completion: { (url, error) in
                        if error != nil{
                            print(error!.localizedDescription)
                            return
                        }

                        if let profilePhotoURL = url?.absoluteString {
                            let userRef = FirebaseRef.databaseUsers.child(userID)
                            let values = ["username": self.usernameField!.text!,
                                          "phone": self.phoneField!.text!,
                                          "email": self.emailField!.text!,
                                          "lastUpdate": Date().timeIntervalSince1970,
                                          "uid": userID,
                                          "profileImageUrl": profilePhotoURL] as [String: Any]
                            userRef.updateChildValues(values) { (error, ref) in
                                if error != nil {
                                    self.showAlert(title:"Update Failure", message: "Failure updating the data")
                                    return
                                } else {
                                    self.showAlert(title: "Update Complete", message: "Successfully updated the data")
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Call Phone
    @IBAction func callPhone(_ sender: AnyObject) {
        
        let phoneNo : String?
        if UIDevice.current.userInterfaceIdiom == .phone  {
            
            phoneNo = self.phoneField!.text
            if let phoneCallURL:URL = URL(string:"telprompt:\(phoneNo!)") {
                
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    
                    UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                }
            } else {
                
                self.showAlert(title: "Alert", message: "Call facility is not available!!!")
            }
        } else {
            
            self.showAlert(title: "Alert", message: "Your device doesn't support this feature.")
        }
    }
    
    // MARK: - Send Email
    @IBAction func sendEmail(_ sender: AnyObject) {
        
        if (self.emailField != NSNull()) {
            
            self.getEmail((emailField?.text)! as NSString)
            
        } else {
            
            self.showAlert(title: "Alert", message: "Your field doesn't have valid email.")
        }
    }
    
    func getEmail(_ emailfield: NSString) {
        
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setToRecipients([emailfield as String])
        email.setSubject((emailTitle as String?)!)
        email.setMessageBody((messageBody as String?)!, isHTML:true)
        email.modalTransitionStyle = .flipHorizontal
        self.present(email, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}

