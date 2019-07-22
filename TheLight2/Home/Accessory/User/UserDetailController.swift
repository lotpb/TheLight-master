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

class UserDetailController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    private let headerId = "headerId"
    private let cellId = "cellId"
    //firebase
    //var userlist = [UserModel]()
    
    var userId: String?
    var followingNumber: Int?
    
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
    @IBOutlet weak var createLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!

    var status : String?
    var objectId : String?
    var username : String?
    var create : String?
    //var creationDate : Date?
    var email : String?
    var phone : String?
    
    var user : PFUser?
    var userquery : PFObject?
    var userimage : UIImage?
    var pickImage : UIImage?
    var pictureData : Data?
    
    var imagePicker: UIImagePickerController!
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style .medium)
 
    var emailTitle :NSString?
    var messageBody:NSString?
    
    lazy var editProfileBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        //button.addTarget(self, action: #selector(UserProfileController.EditProfileButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var updateBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update", for: .normal)
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = Color.BlueColor.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(Color.BlueColor, for: .normal)
        button.addTarget(self, action: #selector(Update), for: .touchUpInside)
        return button
    }()
    
    lazy var callBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Call", for: .normal)
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = Color.BlueColor.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(Color.BlueColor, for: .normal)
        button.addTarget(self, action: #selector(callPhone), for: .touchUpInside)
        return button
    }()
    
    lazy var emailBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Email", for: .normal)
        button.layer.cornerRadius = 24.0
        button.layer.borderColor = Color.BlueColor.cgColor
        button.layer.borderWidth = 3.0
        button.setTitleColor(Color.BlueColor, for: .normal)
        button.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true
        setupNavigationButtons()
        
        emailTitle = defaults.string(forKey: "emailtitleKey")! as NSString
        messageBody = defaults.string(forKey: "emailmessageKey")! as NSString
        
        self.emailField?.keyboardType = .emailAddress
        self.phoneField?.keyboardType = .numbersAndPunctuation
        
        if status == "Edit" {
            setupMapData()
        }
        setupForm()
        setupBorder()
        setupFonts()
        setupConstraints()
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - User Profile"
        } else {
            navigationItem.title = "User Profile"
        }
        self.navigationItem.largeTitleDisplayMode = .always
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
        let albumBtn = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectPhotosAlbum))
        let cameraBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Camcorder").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(selectCamera))
        navigationItem.rightBarButtonItems = [albumBtn, cameraBtn]
    }
    
    func setupBorder() {
        
        let bottomBorder = CALayer()
        let width1 = CGFloat(2.0)
        bottomBorder.borderWidth = width1
        bottomBorder.borderColor = UIColor.darkGray.cgColor
        bottomBorder.frame = .init(x: 0, y: self.mainView!.frame.size.height-1, width: view.frame.size.width, height: 0.5)
        self.mainView?.layer.masksToBounds = true
        self.mainView?.layer.addSublayer(bottomBorder)
    }
    
    func setupForm() {
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
            mainView?.backgroundColor = .systemBackground
            mapContainerView?.backgroundColor = .systemBackground
            infoLabel.textColor = .systemBlue
            createLabel?.textColor = .label
            phoneLabel.textColor = .systemBlue
            emailLabel?.textColor = .systemBlue
            userLabel.textColor = .systemBlue
            mapLabel?.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        
        if status == "Edit" {
            self.usernameField?.text = self.username
            self.emailField?.text = self.email
            self.phoneField?.text = self.phone
            self.createLabel?.text = self.create
            self.userimageView?.image = self.userimage
        } else {
            self.userimageView?.image = #imageLiteral(resourceName: "profile-rabbit-toy")
        }
        
        self.userimageView?.contentMode = .scaleAspectFill
        self.userimageView?.backgroundColor = .white
        self.userimageView?.isUserInteractionEnabled = true
        self.userimageView?.layer.masksToBounds = true
        self.userimageView?.layer.cornerRadius = 60.0
        
        mapView?.delegate = self
        mapView?.layer.borderColor = UIColor.lightGray.cgColor
        mapView?.layer.borderWidth = 1.0
    }
    
    func setupMapData() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            let query = PFUser.query()
            do {
                userquery = try query!.getObjectWithId(self.objectId!)
                let location = userquery!.value(forKey: "currentLocation") as! PFGeoPoint
                
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView!.setRegion(region, animated: true)
                
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
            self.createLabel!.font = Font.celltitle16l
            self.mapLabel!.font = Font.celltitle20l
        } else {
            self.usernameField!.font = Font.celltitle18l
            self.emailField!.font = Font.celltitle18l
            self.phoneField!.font = Font.celltitle18l
            self.createLabel!.font = Font.celltitle14l
            self.mapLabel!.font = Font.celltitle20l
            self.infoLabel.font = Font.celltitle14l
            self.phoneLabel.font = Font.celltitle14l
            self.emailLabel?.font = Font.celltitle14l
            self.userLabel.font = Font.celltitle14l
        }
    }
    
    func setupConstraints() {
        mainView.addSubview(editProfileBtn)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            editProfileBtn.topAnchor.constraint(equalTo: (userimageView?.bottomAnchor)!, constant: 10),
            editProfileBtn.centerXAnchor.constraint(equalTo: (userimageView?.centerXAnchor)!),
            editProfileBtn.widthAnchor.constraint(equalToConstant: 200),
            editProfileBtn.heightAnchor.constraint(equalToConstant: 20),
            
            mapView.topAnchor.constraint(equalTo: (mapLabel?.bottomAnchor)!, constant: +25),
            mapView.leadingAnchor.constraint( equalTo: view.layoutMarginsGuide.leadingAnchor),
            mapView.trailingAnchor.constraint( equalTo: view.layoutMarginsGuide.trailingAnchor),
            mapView.bottomAnchor.constraint( equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16)
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
        
        stackView.anchor(top: phoneField?.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: self.view.frame.width, height: 50)
    }
    
    // MARK: - Button
    @objc func selectCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            imagePicker.delegate = self
            imagePicker.showsCameraControls = true
            self.present(imagePicker, animated: true)
        } else {
            self.simpleAlert(title: "Alert!", message: "Camera not available")
        }
    }
    
    @objc func selectPhotosAlbum() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker = UIImagePickerController()
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: false)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
            self.userimageView?.contentMode = .scaleAspectFill
            self.userimageView?.clipsToBounds = true
            self.userimageView?.image = image
            dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true)
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
                
                self.simpleAlert(title: "Alert", message: "Call facility is not available!!!")
            }
        } else {
            
            self.simpleAlert(title: "Alert", message: "Your device doesn't support this feature.")
        }
    }
    
    // MARK: - Send Email
    @IBAction func sendEmail(_ sender: AnyObject) {
        
        if (self.emailField != NSNull()) {
            
            self.getEmail((emailField?.text)! as NSString)
            
        } else {
            
            self.simpleAlert(title: "Alert", message: "Your field doesn't have valid email.")
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
    
    @IBAction func Update(_ sender: AnyObject) {
        
        self.activityIndicator.center = self.userimageView!.center
        self.activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
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
                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                    } else {
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            } else {
                self.simpleAlert(title: "Alert", message: "User is not valid to edit data")
            }
        } else {
            //firebase
            //fix
            guard let image = self.userimageView?.image else { return }
            let fileName = UUID().uuidString
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let storageRef = Storage.storage().reference().child("profile_images").child(fileName)
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
            storageRef.putData(uploadData, metadata: metadata, completion: {(metadata, error) in
                
                if let err = error {
                    print("Failed to upload profile image:" , err)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if url != nil {
                        //guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else {return}
                        guard let uid = Auth.auth().currentUser?.uid else { return } //maybe needs fix
                        
                        //let newValue = ["profileImageURL": newImageURL]
                        let dictionaryValues = ["username": self.usernameField!.text!,
                                                "phone": self.phoneField!.text!,
                                                "email": self.emailField!.text!,
                                                "creationDate": Date().timeIntervalSince1970,
                                                "lastUpdate": Date().timeIntervalSince1970,
                                                "uid": uid,
                                                "profileImageUrl": url!.absoluteString] as [String: Any]
                        let values =  [uid: dictionaryValues]
                        
                        FirebaseRef.databaseRoot.child("users").updateChildValues(values, withCompletionBlock: {(err, ref) in
                            //FirebaseRef.databaseRoot.child("Users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if let err = err {
                                self.simpleAlert(title: err as? String, message: "Failure updating the data")
                                return
                            } else {
                                self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            }
                        })
                    }
                })
            })
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
}
