//
//  LoginController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/13/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase
//import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import LocalAuthentication
import FBSDKLoginKit
import GoogleSignIn
//import TwitterKit
import MapKit
import GeoFire


final class LoginController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let ipadtitle = UIFont.systemFont(ofSize: 20)
    let celltitle = UIFont.systemFont(ofSize: 18)

    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var forgotPassword: UIButton?
    @IBOutlet weak var authentButton: UIButton!

    var defaults = UserDefaults.standard
    var pictureData : Data?
    var user : PFUser?
    //firebase
    var users: UserModel?
    var userimage : UIImage?
    var userimageView : UIImageView?
    //Facebook
    var profileUrl: String?
    //Google
    private var googleButton : GIDSignInButton = GIDSignInButton()
    private var loginObserver: NSObjectProtocol?

    private let FBloginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()

    lazy var usernameField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.keyboardType = .emailAddress
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.placeholder = "username..."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.placeholder = "password..."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.keyboardAppearance = .dark
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var reEnterPasswordField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.placeholder = "re-enterpassword..."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.keyboardAppearance = .dark
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var emailField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.placeholder = "email..."
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var phoneField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.placeholder = "phone..."
        textField.keyboardType = .numbersAndPunctuation
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 3
        button.layer.masksToBounds = true
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()

    let loginBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign-In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(LoginUser), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let registerBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create an Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let backloginBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Sign in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(returnLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Gradient
        bottomView.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)

        mainView.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: mainView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Google
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Google Log out
        GIDSignIn.sharedInstance().signOut()
        // Log Out facebook
        FBSDKLoginKit.LoginManager().logOut()

        AccessToken.current = nil

        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            PFUser.logOut()
        }

        setupDefaults()
        setupView()
        setupFont()
        setupConstraints()
        self.mapView?.showsUserLocation = true
    }

    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Move Keyboard
        observeKeyboardNotifications()
        // Animate Buttons
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.googleButton.frame = .init(x: self.view.frame.width - 125, y: 320, width: 110, height: 40)
            self.FBloginButton.frame = .init(x: 10, y: 325, width: 110, height: 40)
        }, completion: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupFont() {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.usernameField.font = ipadtitle
            self.passwordField.font = ipadtitle
            self.reEnterPasswordField.font = ipadtitle
            self.emailField.font = ipadtitle
            self.phoneField.font = ipadtitle
        } else {
            self.usernameField.font = celltitle
            self.passwordField.font = celltitle
            self.reEnterPasswordField.font = celltitle
            self.emailField.font = celltitle
            self.phoneField.font = celltitle
        }
    }

    private func setupView() {

        if ((defaults.string(forKey: "registerKey") == nil)) {
            self.registerBtn.setTitle("Register", for: .normal)
            self.loginBtn.isHidden = true //hide login button no user is regsitered
            self.forgotPassword?.isHidden = true
            self.authentButton?.isHidden = true
            self.FBloginButton.isHidden = true
            self.googleButton.isHidden = true
            self.emailField.isHidden = false
            self.phoneField.isHidden = false
            self.plusPhotoButton.isHidden = false
        } else {
            self.reEnterPasswordField .isHidden = true
            self.registerBtn.isHidden = false
            self.forgotPassword!.isHidden = false
            self.FBloginButton.isHidden = false
            self.googleButton.isHidden = false
            self.emailField.isHidden = true
            self.phoneField.isHidden = true
            self.backloginBtn.isHidden = true
            self.plusPhotoButton.isHidden = true
            // Keychain
            //self.usernameField!.text = KeychainWrapper.standard.string(forKey: "usernameKey")
            //self.passwordField!.text = KeychainWrapper.standard.string(forKey: "passwordKey")
        }

        self.passwordField.text = ""
    }

    func setupConstraints() {

        self.mainView?.addSubview(FBloginButton)
        self.mainView?.addSubview(googleButton)
        self.mainView?.addSubview(usernameField)
        self.mainView?.addSubview(passwordField)
        self.mainView?.addSubview(reEnterPasswordField)
        self.mainView?.addSubview(emailField)
        self.mainView?.addSubview(phoneField)
        self.mainView?.addSubview(loginBtn)
        self.mainView?.addSubview(registerBtn)
        self.mainView?.addSubview(backloginBtn)

        mapView?.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad  {
            mapView?.heightAnchor.constraint(equalToConstant: 380).isActive = true
        } else {
            mapView?.heightAnchor.constraint(equalToConstant: 175).isActive = true
        }

        NSLayoutConstraint.activate([
            usernameField.topAnchor.constraint(equalTo: mapView!.bottomAnchor, constant: 15),
            usernameField.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            usernameField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            usernameField.heightAnchor.constraint(equalToConstant: 40),

            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            passwordField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            passwordField.heightAnchor.constraint(equalToConstant: 40),

            reEnterPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            reEnterPasswordField.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            reEnterPasswordField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            reEnterPasswordField.heightAnchor.constraint(equalToConstant: 40),

            emailField.topAnchor.constraint(equalTo: reEnterPasswordField.bottomAnchor, constant: 10),
            emailField.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            emailField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            emailField.heightAnchor.constraint(equalToConstant: 40),

            phoneField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            phoneField.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            phoneField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            phoneField.heightAnchor.constraint(equalToConstant: 40),

            loginBtn.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 15),
            loginBtn.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            loginBtn.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            loginBtn.heightAnchor.constraint(equalToConstant: 40),

            registerBtn.topAnchor.constraint(equalTo: loginBtn.bottomAnchor, constant: 15),
            registerBtn.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            registerBtn.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            registerBtn.heightAnchor.constraint(equalToConstant: 40),

            backloginBtn.topAnchor.constraint(equalTo: registerBtn.bottomAnchor, constant: 15),
            backloginBtn.leadingAnchor.constraint( equalTo: mainView!.leadingAnchor, constant: 10),
            backloginBtn.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            backloginBtn.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    func setupDefaults() {

        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            self.usernameField.text = "Peter Balsamo"
        } else {
            //firebase
            self.usernameField.text = "eunited@optonline.net"
        }
    }

    // MARK: - Login User
    @IBAction func LoginUser(_ sender:AnyObject) {

        guard let email = usernameField.text?.removeWhiteSpace(), let password = passwordField.text,
            !email.isEmpty, !password.isEmpty, password.count >= 4 else {
                self.showAlert(title: "Oooops", message: "Failed to log in user with email")
                return
        }

        if ((defaults.string(forKey: "backendKey")) == "Parse") {

            PFUser.logInWithUsername(inBackground: email, password: password) { user, error in
                if user != nil {
                    self.saveDefaults()
                    self.refreshLocation()

                } else {

                    self.showAlert(title: "Oooops", message: "Your username and password does not match")

                    PFUser.current()?.fetchInBackground(block: { (object, error)  in

                        let isEmailVerified = (PFUser.current()?.object(forKey: "emailVerified") as AnyObject).boolValue

                        if isEmailVerified == true {
                            self.emailField.text = "Email has been verified."
                        } else {
                            self.emailField.text = "Email is not verified."
                        }
                    })
                }
            }
        } else {

            Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] user, error in
                guard let strongSelf = self else { return }
                guard let result = user, error == nil else {
                    self!.showAlert(title: "Oooops", message: "Failed to log in user with email: \(email)")
                    return
                }
                let user = result.user
                print("Succesfully logged back in with user: \(user)")

                self!.saveDefaults()
                self!.refreshLocation()
                strongSelf.navigationController?.dismiss(animated: true)
            })
        }
    }

    @IBAction func returnLogin(_ sender:AnyObject) {

        self.view.endEditing(true)
        keyboardHide()
        self.registerBtn.setTitle("Create an Account", for: .normal)
        self.usernameField.text = defaults.string(forKey: "usernameKey")
        self.passwordField.isHidden = false
        self.loginBtn.isHidden = false
        self.registerBtn.isHidden = false
        self.forgotPassword?.isHidden = false
        self.authentButton?.isHidden = false
        self.backloginBtn.isHidden = true
        self.reEnterPasswordField.isHidden = true
        self.emailField.isHidden = true
        self.phoneField.isHidden = true
        self.FBloginButton.isHidden = false
        self.googleButton.isHidden = false
        self.plusPhotoButton.isHidden = true
        self.mapView?.isHidden = false
        setupDefaults()
    }

    // MARK: - Register User
    @IBAction func registerUser(_ sender:AnyObject) {

        if (self.registerBtn.titleLabel!.text == "Create an Account") {

            self.registerBtn.setTitle("Register", for: .normal)
            self.usernameField.text = ""
            self.loginBtn.isHidden = true
            self.forgotPassword?.isHidden = true
            self.authentButton?.isHidden = true
            self.backloginBtn.isHidden = false
            self.reEnterPasswordField.isHidden = false
            self.emailField.isHidden = false
            self.phoneField.isHidden = false
            self.FBloginButton.isHidden = true
            self.googleButton.isHidden = true
            self.plusPhotoButton.isHidden = false
            self.mapView?.isHidden = true

        } else {
            if (self.usernameField.text == "" || self.emailField.text == "" || self.passwordField.text == "" || self.reEnterPasswordField.text == "") {

                self.showAlert(title: "Oooops", message: "You must complete all fields")
            } else {
                checkPasswordsMatch()
            }
        }
    }

    func checkPasswordsMatch() {

        if self.passwordField.text == self.reEnterPasswordField.text {
            registerNewUser()
        } else {
            self.showAlert(title: "Oooops", message: "Your entered passwords do not match")
        }
    }

    func registerNewUser() {

        guard let email = emailField.text?.removeWhiteSpace(), let password = passwordField.text, let username = usernameField.text, let phone = phoneField.text,
            !phone.isEmpty, !username.isEmpty, !email.isEmpty, !password.isEmpty, username.count >= 0, password.count >= 4 else {
                self.showAlert(title:"Oooops", message: "Please enter all information to create a new account.")
                return
        }

        if ((defaults.string(forKey: "backendKey")) == "Parse") {

            if (self.plusPhotoButton.imageView?.image == nil) {
                self.plusPhotoButton.imageView?.image = UIImage(named:"profile-rabbit-toy.png")
            }
            pictureData = self.plusPhotoButton.imageView?.image?.jpegData(compressionQuality: 0.9)
            let file = PFFileObject(name: "Image.jpg", data: pictureData!)

            let user = PFUser()
            user.username = username
            user.password = password
            user.email = email

            user.setObject(file!, forKey:"imageFile")
            user.signUpInBackground { succeeded, error in
                if (succeeded) {
                    self.saveDefaults()
                    self.refreshLocation()
                    self.usernameField.text = nil
                    self.passwordField.text = nil
                    self.emailField.text = nil
                    self.phoneField.text = nil

                    self.showAlert(title: "Success", message: "You have registered a new user")
                } else {
                    self.showAlert(title: "Alert", message: "Error: \(String(describing: error))")
                }
            }

        } else {
            // firebase
            //let phone = phoneField.text ?? ""
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                guard error == nil else {
                    print("Failed to create user: ", error!)
                    return
                }

                guard let image = self.plusPhotoButton.imageView?.image else {return}
                guard let uploadData = image.jpegData(compressionQuality: 0.9) else {return}

                let fileName = NSUUID().uuidString

                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                let storageItem = Storage.storage().reference().child("profile_images").child(fileName)
                storageItem.putData(uploadData, metadata: metadata) { (metadata, error) in

                    if let err = error {
                        print("Failed to upload profile image:" , err)
                        return
                    } else {
                        storageItem.downloadURL(completion: { (url, error) in

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
                                        self.showAlert(title:"new member Failure", message: "Failure updating the data")
                                        print("Failed to save user info to database: ", err)
                                        return
                                    } else {
                                        self.showAlert(title: "Congratulations", message: "Successfully became a member")
                                        print("Succefully saved user info to db")
                                        self.defaults.set(self.usernameField.text, forKey: "usernameKey")
                                        self.saveDefaults()
                                        self.refreshLocation()

                                        self.usernameField.text = nil
                                        self.passwordField.text = nil
                                        self.emailField.text = nil
                                        self.phoneField.text = nil
                                        self.showAlert(title: "Success", message: "You have registered a new user")
                                        self.redirectToHome()
                                    }
                                })
                            }
                        })
                    }
                }
            })
        }
    }

    // MARK: - Google
    // FIXME:
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print(error.localizedDescription)
            }
            return
        }

        guard let user = user else {
            return
        }

        guard let email = user.profile.email,
            let name = user.profile.name else {
                //let firstName = user.profile.givenName,
                //let lastName = user.profile.familyName else {
                return
        }

        if user.profile.hasImage {
            guard let url = user.profile.imageURL(withDimension: 200) else {
                return
            }
            print(url)

            self.usernameField.text = name
            self.emailField.text = email
            self.passwordField.text = "united"
            //self.profileUrl = url

//            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
//                guard let data = data else {
//                    return
//                }
//            })
//
//            DatabaseManager.shared.userExist(with: email, completion: { exist in
//                if !exist {
//                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
//                                                                        lastName: LastName,
//                                                                        emailAddress: email))
//                }
//            })

        }
        guard let authentication = user.authentication else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential, completion:  { (result, error) in
            guard result != nil, error == nil else {
                //if let error = error {
                print("Failed to create a Firebase User with Google account: ", error!)
                return
            }

            print("Successfully logged into Firebase with Google")
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
            self.registerNewUser()
            self.saveDefaults()
            self.refreshLocation()
            self.redirectToHome()

        })
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error!)
    }

    // MARK: - Password Reset
    @IBAction func passwordReset(_ sender:AnyObject) {
        
        self.usernameField.isHidden = true
        self.loginBtn.isHidden = true
        self.passwordField.isHidden = true
        self.authentButton!.isHidden = true
        self.backloginBtn.isHidden = false
        self.registerBtn.isHidden = true
        self.emailField.isHidden = false
        
        let email = self.emailField.text
        let finalEmail = email!.removeWhiteSpace()
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            PFUser.requestPasswordResetForEmail(inBackground: finalEmail) { (success, error)  in
                if success {
                    self.showAlert(title: "Alert", message: "Link to reset the password has been send to specified email")
                } else {
                    self.showAlert(title: "Alert", message: "Enter email in field: %@")
                }
            }
        } else {
            //firebase
            Auth.auth().sendPasswordReset(withEmail: finalEmail) { error in
                if error != nil {
                    self.showAlert(title: "Alert", message: "Link to reset the password has been send to specified email")
                } else {
                    self.showAlert(title: "Alert", message: "Enter email in field: %@")
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
                            self.showAlert(title: "Your fingerprint could not be verified; please try again.", message: evaluateError?.localizedDescription)
                        }
                    }
                }
            } else {
                print("Face ID")
                self.showAlert(title: "Error", message: error?.localizedDescription)
            }
        }
    }
    
    func didAuthenticateWithTouchId() {
        
        self.emailField.text = "eunited@optonline.net"
        self.phoneField.text = "(516)241-4786"
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            self.usernameField.text = "Peter Balsamo"
            self.passwordField.text = "3911"
            
            PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!) { user, error in
                if user != nil {
                    self.saveDefaults()
                    self.refreshLocation()
                }
            }
        } else {
            self.emailField.text = "eunited@optonline.net"
            self.passwordField.text = "united"
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, err) in
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
            self.defaults.set(self.usernameField.text, forKey: "usernameKey")
            self.defaults.set(self.emailField.text, forKey: "emailKey")
            self.defaults.set(self.passwordField.text, forKey: "passwordKey")
            self.defaults.set(self.phoneField.text, forKey: "phoneKey")
        } else {
            //firebase
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.users = user
                self.defaults.set(self.users?.email, forKey: "emailKey")
                self.defaults.set(self.users?.username, forKey: "usernameKey") // FIXME:
                self.defaults.set(self.users?.phone, forKey: "phoneKey")
                self.defaults.set(self.passwordField.text, forKey: "passwordKey")
            }
        }
        self.defaults.set(true, forKey: "registerKey")
        self.redirectToHome()
    }
    
    // MARK: - RedirectToHome

    func redirectToHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.dismiss(animated: true)
                self.tabBarController?.selectedIndex = 0
            } else {
                self.dismiss(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    // MARK: - Keyboard

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
            self.view.frame = .init(x: 0, y: -10, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: nil)
    }
    
    // MARK: - AvatarImage

    @objc func handlePlusPhoto () {

        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated:true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        plusPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2

        dismiss(animated: true, completion: nil)
    }

    func updateUsersProfile() {
        //firebase
        if let userID = Auth.auth().currentUser?.uid {
            //let storageRef = Storage.storage().reference().child("profile_images/\(uid)")
            let storageRef = Storage.storage().reference().child("profile_images").child(userID)
            guard let image = userimageView?.image else {return}

            if let newImage = image.jpegData(compressionQuality: 0.9)  {
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                storageRef.putData(newImage, metadata: metadata) { metadata, error in
                    if error == nil, metadata != nil {
                        storageRef.downloadURL(completion: { url, error in
                            if error != nil{
                                print(error!)
                                return
                            }

                            if let profilePhotoURL = url?.absoluteString {
                                let userRef = FirebaseRef.databaseUsers.child(userID)
                                let values = ["username": self.usernameField.text!,
                                              "phone": self.phoneField.text!,
                                              "email": self.emailField.text!,
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
    }
}
extension LoginController: LoginButtonDelegate {
        // MARK: - Facebook
        // FIXME:
        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            guard let token = result?.token?.tokenString else {
                print(error!)
                return
            }

            let request = FBSDKLoginKit.GraphRequest(graphPath: "/me",
                                                     parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"],
                                                     tokenString: token,
                                                     version: nil,
                                                     httpMethod: .get)

            request.start(completionHandler: {connection, result, error in
                guard let result = result as? [String: Any], error == nil else {
                    print("Failed to make facebook graph request")
                    return
                }

                guard let firstName = result["first_name"]as? String,
                    let lastName = result["last_name"] as? String,
                    let email = result["email"] as? String,
                    let picture = result["picture"] as? [String:Any],
                    let imgData = picture["data"] as? [String:Any],
                    let profileUrl = imgData["url"] as? String else {
                        print("Failed to get email and name from fb result")
                        return
                }

    //            DatabaseManager.shared.userExist(with: email, completion: { exist in
    //                if !exist {
    //                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
    //                                                                        lastName: LastName,
    //                                                                        emailAddress: email))
    //                }
    //            })
    //
    //            guard let userName = result["name"] as? String,
    //                let email = result["email"] as? String else {
    //                    print("Failed to get email and name from fb result")
    //                    return
    //            }
    //            let nameComponents = userName.components(separatedBy: "")
    //            guard nameComponents.count == 2 else {
    //                return
    //            }
    //            let firstName = nameComponents[0]
    //            let lastName = nameComponents[1]

                let credential = FacebookAuthProvider.credential(withAccessToken: token)
                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                    guard let strongSelf = self else {
                        return
                    }

                    guard authResult != nil, error == nil else {
                        if let error = error {
                            print("Facebook login failed, MFA may be needed - \(error)")
                        }
                        return
                    }

                    print("Successfully logged user in")
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                })


                self.usernameField.text = "\(firstName) \(lastName)"
                self.emailField.text = "\(email)"
                self.passwordField.text = "united" //"\(useId)"
                self.profileUrl = profileUrl

                self.registerNewUser()
                self.saveDefaults()
                self.refreshLocation()
                self.redirectToHome()
            })
        }

        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            print("Did log out of facebook")
        }
}
