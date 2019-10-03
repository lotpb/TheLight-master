//
//  LoginController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/13/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import Firebase
import FirebaseDatabase
//import FirebaseAuth
//import FirebaseStorage
import LocalAuthentication
import FBSDKLoginKit
import GoogleSignIn
//import TwitterKit
import MapKit
import GeoFire


final class LoginController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LoginButtonDelegate, GIDSignInUIDelegate {
    
    let ipadtitle = UIFont.systemFont(ofSize: 20)
    let celltitle = UIFont.systemFont(ofSize: 18)
    
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var registerBtn: UIButton?
    @IBOutlet weak var loginBtn: UIButton?
    @IBOutlet weak var backloginBtn: UIButton?
    @IBOutlet weak var forgotPassword: UIButton?
    @IBOutlet weak var authentButton: UIButton!
    
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    @IBOutlet weak var reEnterPasswordField: UITextField?
    @IBOutlet weak var emailField: UITextField?
    @IBOutlet weak var phoneField: UITextField?
    
    var defaults = UserDefaults.standard
    var pictureData : Data?
    var user : PFUser?
    //firebase
    var users: UserModel?
    
    //Facebook
    var fbButton : FBLoginButton = FBLoginButton()
    //Google
    var googleButton : GIDSignInButton = GIDSignInButton()
    //Twitter
    //var twitterButton : TWTRLogInButton = TWTRLogInButton()
    
    var profile_pic: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            PFUser.logOut()
        }
        LoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        AccessToken.current = nil
        
        //Facebook
        fbButton.delegate = self
        if (AccessToken.current != nil) {
            self.simpleAlert(title: "Alert", message: "User is already logged in")
        } else {
            //fbButton.rea = ["public_profile", "email", "user_friends","user_birthday"]
        }
        
        //Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()!.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently() //.signIn()
        
        //Twitter
        setupTwitterButton()
        
        setupDefaults()
        setupView()
        setupFont()
        setupConstraints()
        self.mapView?.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .black
    }
    
    //Animate Buttons
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeKeyboardNotifications() //Move Keyboard
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.googleButton.frame = .init(x: self.view.frame.width - 125, y: 320, width: 110, height: 40)
            self.fbButton.frame = .init(x: 10, y: 325, width: 110, height: 40)
            if UIDevice.current.userInterfaceIdiom == .pad  {
                //self.twitterButton.frame = .init(x: self.view.frame.width/2 - 90, y: 325, width: 180, height: 40)
            } else {
                //self.twitterButton.frame = .init(x: self.view.frame.width/2 - 55, y: 325, width: 110, height: 40)
            }
        }, completion: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - LoginUser
    func setupFont() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.usernameField?.font = ipadtitle
            self.passwordField?.font = ipadtitle
            self.reEnterPasswordField?.font = ipadtitle
            self.emailField?.font = ipadtitle
            self.phoneField?.font = ipadtitle
        } else {
            self.usernameField?.font = celltitle
            self.passwordField?.font = celltitle
            self.reEnterPasswordField?.font = celltitle
            self.emailField?.font = celltitle
            self.phoneField?.font = celltitle
        }
    }
    
    private func setupView() {
        //Password AutoFill in iOS 11 - not setup
        if #available(iOS 11.0, *) {
            //self.usernameField!.textContentType = .username
            //self.emailField!.textContentType = .emailAddress
            //self.phoneField!.textContentType = .password
        } else {
            // Fallback on earlier versions
        }
        
        if ((defaults.string(forKey: "registerKey") == nil)) {
            self.registerBtn?.setTitle("Register", for: .normal)
            self.loginBtn?.isHidden = true //hide login button no user is regsitered
            self.forgotPassword?.isHidden = true
            self.authentButton?.isHidden = true
            self.fbButton.isHidden = true
            self.googleButton.isHidden = true
            //self.twitterButton.isHidden = true
            self.emailField?.isHidden = false
            self.phoneField?.isHidden = false
            self.plusPhotoButton.isHidden = false
        } else {
            //Keychain
            //self.usernameField!.text = KeychainWrapper.standard.string(forKey: "usernameKey")
            //self.passwordField!.text = KeychainWrapper.standard.string(forKey: "passwordKey")
            self.reEnterPasswordField?.isHidden = true
            self.registerBtn?.isHidden = false
            self.forgotPassword?.isHidden = false
            self.fbButton.isHidden = false
            self.googleButton.isHidden = false
            //self.twitterButton.isHidden = false
            self.emailField?.isHidden = true
            self.phoneField?.isHidden = true
            self.backloginBtn?.isHidden = true
            self.plusPhotoButton.isHidden = true
        }

        self.registerBtn?.setTitleColor(.white, for: .normal)
        self.loginBtn?.setTitleColor(.white, for: .normal)
        self.backloginBtn?.setTitleColor(.white, for: .normal)
        self.usernameField?.keyboardType = .emailAddress
        self.emailField?.keyboardType = .emailAddress
        self.phoneField?.keyboardType = .numbersAndPunctuation
        
        self.passwordField?.text = ""
        //self.userimage = nil
    }
    
    func setupConstraints() {
        
        self.mainView?.addSubview(fbButton)
        self.mainView?.addSubview(googleButton)
        
        mapView?.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad  {            mapView?.heightAnchor.constraint(equalToConstant: 380).isActive = true
        } else {
            mapView?.heightAnchor.constraint(equalToConstant: 175).isActive = true
        }
    }
    
    func setupDefaults() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            self.usernameField?.text = "Peter Balsamo"
            
        } else {
            //firebase
            self.usernameField?.text = "eunited@optonline.net"
        }
    }
    
    @IBAction func LoginUser(_ sender:AnyObject) {
 
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            PFUser.logInWithUsername(inBackground: usernameField!.text!, password: passwordField!.text!) { user, error in
                if user != nil {
                    self.saveDefaults()
                    self.refreshLocation()
                    
                } else {
                    
                    self.simpleAlert(title: "Oooops", message: "Your username and password does not match")
                
                    PFUser.current()?.fetchInBackground(block: { (object, error)  in
                        
                        let isEmailVerified = (PFUser.current()?.object(forKey: "emailVerified") as AnyObject).boolValue
                        
                        if isEmailVerified == true {
                            self.emailField!.text = "Email has been verified."
                        } else {
                            self.emailField!.text = "Email is not verified."
                        }
                    })
                }
            }
        } else {
            
            guard let email = usernameField?.text!.removeWhiteSpace() else {return}
            guard let password = passwordField?.text else {return}
            
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
                if let err = err{
                    self.simpleAlert(title: "Oooops", message: "Your username and password does not match")
                    print("Failed to login:", err)
                    return
                }
                
                print("Succesfully logged back in with user:", self.user ?? "")
                self.saveDefaults()
                self.refreshLocation()
            })
        }
    }
    
    @IBAction func returnLogin(_ sender:AnyObject) {

        self.view.endEditing(true)
        keyboardHide()
        self.registerBtn?.setTitle("Create an Account", for: .normal)
        self.usernameField?.text = defaults.string(forKey: "usernameKey")
        self.passwordField?.isHidden = false
        self.loginBtn?.isHidden = false
        self.registerBtn?.isHidden = false
        self.forgotPassword?.isHidden = false
        self.authentButton?.isHidden = false
        self.backloginBtn?.isHidden = true
        self.reEnterPasswordField?.isHidden = true
        self.emailField?.isHidden = true
        self.phoneField?.isHidden = true
        self.fbButton.isHidden = false
        self.googleButton.isHidden = false
        //self.twitterButton.isHidden = false
        self.plusPhotoButton.isHidden = true
        setupDefaults()
    }
    
    // MARK: - RegisterUser
    @IBAction func registerUser(_ sender:AnyObject) {
        
        if (self.registerBtn!.titleLabel!.text == "Create an Account") {
            
            self.registerBtn?.setTitle("Register", for: .normal)
            self.usernameField?.text = ""
            self.loginBtn?.isHidden = true
            self.forgotPassword?.isHidden = true
            self.authentButton?.isHidden = true
            self.backloginBtn?.isHidden = false
            self.reEnterPasswordField?.isHidden = false
            self.emailField?.isHidden = false
            self.phoneField?.isHidden = false
            self.fbButton.isHidden = true
            self.googleButton.isHidden = true
            //self.twitterButton.isHidden = true
            self.plusPhotoButton.isHidden = false
            
        } else {
            //check if all text fields are completed
            if (self.usernameField!.text == "" || self.emailField!.text == "" || self.passwordField!.text == "" || self.reEnterPasswordField!.text == "") {
                
                self.simpleAlert(title: "Oooops", message: "You must complete all fields")
            } else {
                checkPasswordsMatch()
            }
        }
    }
    
    func checkPasswordsMatch() {
        
        if self.passwordField!.text == self.reEnterPasswordField!.text {
            
            registerNewUser()
            
        } else {
            
            self.simpleAlert(title: "Oooops", message: "Your entered passwords do not match")
        }
    }
    
    func registerNewUser() {
        // MARK: - Parse
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            if (self.self.plusPhotoButton.imageView?.image == nil) {
                self.self.plusPhotoButton.imageView?.image = UIImage(named:"profile-rabbit-toy.png")
            }
            //pictureData = UIImageJPEGRepresentation((self.plusPhotoButton.imageView?.image)!, 0.9)
            pictureData = self.plusPhotoButton.imageView?.image?.jpegData(compressionQuality: 0.9)
            let file = PFFileObject(name: "Image.jpg", data: pictureData!)
            
            let user = PFUser()
            user.username = usernameField!.text
            user.password = passwordField!.text
            user.email = emailField!.text
            
            user.setObject(file!, forKey:"imageFile")
            user.signUpInBackground { succeeded, error in
                if (succeeded) {
                    self.saveDefaults()
                    self.refreshLocation()
                    self.usernameField!.text = nil
                    self.passwordField!.text = nil
                    self.emailField!.text = nil
                    self.phoneField!.text = nil
                    
                    self.simpleAlert(title: "Success", message: "You have registered a new user")
                } else {
                    self.simpleAlert(title: "Alert", message: "Error: \(String(describing: error))")
                }
            }
            
        } else {
            // firebase
            guard let email = emailField?.text, email.count > 0 else { return }
            guard let username = usernameField?.text, username.count > 0 else { return }
            guard let password = passwordField?.text, password.count > 0 else { return }
            let phone = phoneField?.text ?? ""
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if let err = error {
                    print("Failed to create user: ", err)
                    return
                    
                } else {
                    
                    //print("Successfully created user: ", user?.uid ?? "")
                    guard let image = self.plusPhotoButton.imageView?.image else {return}
                    guard let uploadData = image.jpegData(compressionQuality: 0.9) else {return}
                    
                    let fileName = NSUUID().uuidString
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    let storageItem = Storage.storage().reference().child("profile_images").child(fileName)
                    storageItem.putData(uploadData, metadata: metadata) { (metadata, error) in
                        //Storage.storage().reference().child("profile_images").child(fileName).putData(uploadData, metadata: metadata, completion: {(metadata, err) in
                        
                        if let err = error {
                            print("Failed to upload profile image:" , err)
                            return
                        } else {
                            storageItem.downloadURL(completion: { (url, error) in
                                //guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else {return}
                                if error != nil {
                                    print(error!)
                                    return
                                } else {
                                    
                                    print("Successfully Uploaded profile image")
                                    guard let uid = user?.user.uid else { return }
                                    
                                    let dictionaryValues = ["username": username,
                                                            "phone": phone,
                                                            "email": email,
                                                            "creationDate": Date().timeIntervalSince1970,
                                                            "profileImageUrl": url?.absoluteString as Any,
                                                            "uid": uid] as [String: Any]
                                    let values =  [uid: dictionaryValues]
                                    
                                    FirebaseRef.databaseRoot.child("users").updateChildValues(values, withCompletionBlock: {(error, ref) in
                                        
                                        if let err = error {
                                            print("Failed to save user info to database: ", err)
                                            return
                                        } else {
                                            print("Succefully saved user info to db")
                                            self.defaults.set(self.usernameField!.text, forKey: "usernameKey")
                                            self.saveDefaults()
                                            self.refreshLocation()
                                            
                                            self.usernameField!.text = nil
                                            self.passwordField!.text = nil
                                            self.emailField!.text = nil
                                            self.phoneField!.text = nil
                                            self.simpleAlert(title: "Success", message: "You have registered a new user")
                                        }
                                    })
                                }
                            })
                        }
                    }
               }
            })
        }
    }
    
    // MARK: - TwitterButton
    private func setupTwitterButton() {
        /*
 
        twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                print("Failed to login via Twitter: ", err)
                return
            }
            print("Successfully logged in under Twitter...")
            //lets login with Firebase
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = TwitterAuthProvider.credential(withToken: token, secret: secret)
            
            Auth.auth().signInAndRetrieveData(with: credentials) { (authResult, error) in
                if let err = error {
                    print("Failed to login to Firebase with Twitter: ", err)
                    return
                }
                print("Successfully created a Firebase-Twitter user: ", self.user ?? "")
            }
            self.redirectToHome()
            self.refreshLocation()
        }
        self.mainView.addSubview(twitterButton) */
    } 
    
    // MARK: - Google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            print(error!)
            return
        }
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            guard let uid = self.user else { return }
            print("Successfully logged into Firebase with Google", uid)
        }
        
        self.usernameField!.text = user.profile.name
        self.emailField!.text = user.profile.email
        self.passwordField!.text = "united" //user.userID
        
        if user.profile.hasImage{
            let profilePicURL = user.profile.imageURL(withDimension: 200).absoluteString
            print(profilePicURL)
            self.profile_pic = profilePicURL
        }
 
        //let dimension = round(imageSize.width * UIScreen.main.scale)
        //let pic = user.profile.imageURL(withDimension: dimension)
        
        /*
        //if success display the email on label
        let currUser = UserData(name: user.profile.name,
                                email: user.profile.email,
                                photoUrl: user.profile.imageURL(withDimension: 150),
                                givenName: user.profile.givenName,
                                familyName: user.profile.familyName);
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.currUser = currUser
        self.performSegue(withIdentifier: "showTabBarViewController", sender: nil) */

        
        self.registerNewUser()
        self.saveDefaults()
        self.refreshLocation()
        self.redirectToHome()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            print(error!)
            return
        }
    }
    
    // MARK: - Facebook
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if ((error) != nil) {
            print(error!)
            return
        }
        fetchProfileFB()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Did log out of facebook")
    }
    
    func fetchProfileFB() {
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true)
                
                return
            }
            print("Successfully logged in facebook with our user: ", self.user ?? "")
        }
        
        GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
            .start { (connection, result, error) in
                if (error == nil) {
                    
                    guard let result = result as? NSDictionary,
                        let firstName = result["first_name"] as? String,
                        let lastName = result["last_name"] as? String,
                        //let useId = result["id"]  as? String,
                        let email = result["email"] as? String
                        else {
                            return
                    }
                    
                    guard let userInfo = result as? [String: Any] else { return }
                    if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        print(imageURL)
                        self.profile_pic = imageURL
                    }
                    /*
                     self.plusPhotoButton.imageView?.image = UIImage(data: try! Data(contentsOf: URL(string: pictureUrl)!))
                     DispatchQueue.main.async(execute: { ()  in
                     //self.userImageView.image = self.plusPhotoButton.imageView?.image
                     }) */
                    
                    self.usernameField!.text = "\(firstName) \(lastName)"
                    self.emailField!.text = "\(email)"
                    self.passwordField!.text = "united" //"\(useId)"
                    
                    self.registerNewUser()
                    self.saveDefaults()
                    self.refreshLocation()
                    self.redirectToHome()
                    
                } else {
                    print("Failed to start graph request:", error ?? "")
                    return
                }
        }
    }

    // MARK: - Password Reset
    @IBAction func passwordReset(_ sender:AnyObject) {
        
        self.usernameField!.isHidden = true
        self.loginBtn!.isHidden = true
        self.passwordField!.isHidden = true
        self.authentButton!.isHidden = true
        self.backloginBtn!.isHidden = false
        self.registerBtn!.isHidden = true
        self.emailField!.isHidden = false
        
        let email = self.emailField!.text
        let finalEmail = email!.removeWhiteSpace()
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            PFUser.requestPasswordResetForEmail(inBackground: finalEmail) { (success, error)  in
                if success {
                    self.simpleAlert(title: "Alert", message: "Link to reset the password has been send to specified email")
                } else {
                    self.simpleAlert(title: "Alert", message: "Enter email in field: %@")
                }
            }
        } else {
            //firebase
            Auth.auth().sendPasswordReset(withEmail: finalEmail) { error in
                if error != nil {
                    self.simpleAlert(title: "Alert", message: "Link to reset the password has been send to specified email")
                } else {
                    self.simpleAlert(title: "Alert", message: "Enter email in field: %@")
                }
            }
        }
    }
    
    // MARK: - Authenticate
    @IBAction func authenticateUser(_ sender: AnyObject) {
        
        let ctx = LAContext()
        let myLocalizedReasonString = "Biometric Authntication testing !!"
        
        var error: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            self.didAuthenticateWithTouchId()
                        } else {
                            let ac = UIAlertController(title: "Your fingerprint could not be verified; please try again.",
                                                       message: evaluateError?.localizedDescription,
                                                       preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(ac, animated: true)
                        }
                    }
                }
            } else {
                print("Face ID")
                let ac = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    func didAuthenticateWithTouchId() {
        
        self.emailField?.text = "eunited@optonline.net"
        self.phoneField?.text = "(516)241-4786"
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            self.usernameField!.text = "Peter Balsamo"
            self.passwordField!.text = "3911"
            
            PFUser.logInWithUsername(inBackground: usernameField!.text!, password: passwordField!.text!) { user, error in
                if user != nil {
                    self.saveDefaults()
                    self.refreshLocation()
                }
            }
        } else {
            self.emailField!.text = "eunited@optonline.net"
            self.passwordField!.text = "united"
            Auth.auth().signIn(withEmail: emailField!.text!, password: passwordField!.text!, completion: { (user, err) in
                if user != nil {
                    self.saveDefaults()
                    self.refreshLocation()
                }
            })
        }
    }
    
    // MARK: - Map
    func refreshLocation() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            PFGeoPoint.geoPointForCurrentLocation {(geoPoint: PFGeoPoint?, error: Error?) in
                if error == nil {
                    PFUser.current()!.setValue(geoPoint, forKey: "currentLocation")
                    PFUser.current()!.saveInBackground()
                }
            }
        } else {
            //firebase
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let geofireRef = FirebaseRef.databaseRoot.child("users_locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire.setLocation(CLLocation(latitude: (mapView?.userLocation.coordinate.latitude)!, longitude: (mapView?.userLocation.coordinate.longitude)!), forKey: uid)
        }
    }
    
    // MARK: - saveDefaults
    func saveDefaults() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            self.defaults.set(self.usernameField!.text, forKey: "usernameKey")
            self.defaults.set(self.emailField!.text, forKey: "emailKey")
            self.defaults.set(self.passwordField!.text, forKey: "passwordKey")
            self.defaults.set(self.phoneField!.text, forKey: "phoneKey")
        } else {
            //firebase
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.users = user
                self.defaults.set(self.users?.email, forKey: "emailKey")
                self.defaults.set(self.users?.username, forKey: "usernameKey") // FIXME:
                self.defaults.set(self.users?.phone, forKey: "phoneKey")
                self.defaults.set(self.passwordField!.text, forKey: "passwordKey")
            }
        }
        /*
        if (self.emailField!.text != nil) {
            self.defaults.set(self.emailField!.text, forKey: "emailKey")
        }*/
        self.defaults.set(true, forKey: "registerKey")
        self.redirectToHome()
    }
    
    // MARK: - RedirectToHome
    func redirectToHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {

            if UIDevice.current.userInterfaceIdiom == .pad {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }

        }
    }
    
//------------------------------------------------
    
    // MARK: - Move Keyboard
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = .init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
            }, completion: nil)
    }
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = .init(x: 0, y: -140, width: self.view.frame.width, height: self.view.frame.height)
            
            }, completion: nil)
    }
    
    // MARK: - AvatarImage
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePhotoButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePhotoButton () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated:true)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
            
        else if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true)
    }
}

