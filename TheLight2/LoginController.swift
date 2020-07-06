//
//  LoginController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/13/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseAuth
import FirebaseStorage
import LocalAuthentication
import FBSDKLoginKit
import GoogleSignIn
import MapKit
import GeoFire


final class LoginController: UIViewController, UITextFieldDelegate {

    let ipadtitle = UIFont.systemFont(ofSize: 20)
    let celltitle = UIFont.systemFont(ofSize: 18)

    private var defaults = UserDefaults.standard
    private var pictureData: Data?
    private var user: PFUser?
    //firebase
    private var users: UserModel?
    private var userimage: UIImage?
    //Facebook
    private var profileUrl: String?
    //Google
    private let googleButton: GIDSignInButton = GIDSignInButton()
    private var loginObserver: NSObjectProtocol?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    private let userimageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private let FBloginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()

    private let usernameField: UITextField = {
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

    private let passwordField: UITextField = {
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

    private let reEnterPasswordField: UITextField = {
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

    private let emailField: UITextField = {
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

    private let phoneField: UITextField = {
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

    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 3
        button.layer.masksToBounds = true
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()

    private let loginBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign-In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(LoginUser), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let registerBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create an Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let backloginBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Sign in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(returnLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let forgotPassword: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(passwordReset), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let authentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Authenticate", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(authenticateUser), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isUserInteractionEnabled = true //does nothing
        // Google
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
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
        mapView.showsUserLocation = true
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
            self.googleButton.frame = .init(x: self.view.frame.width - 125, y: 395, width: 110, height: 40)
            self.FBloginButton.frame = .init(x: 10, y: 400, width: 110, height: 40)
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
            usernameField.font = ipadtitle
            passwordField.font = ipadtitle
            reEnterPasswordField.font = ipadtitle
            emailField.font = ipadtitle
            phoneField.font = ipadtitle
        } else {
            usernameField.font = celltitle
            passwordField.font = celltitle
            reEnterPasswordField.font = celltitle
            emailField.font = celltitle
            phoneField.font = celltitle
        }
    }

    private func setupView() {

        if ((defaults.string(forKey: "registerKey") == nil)) {
            registerBtn.setTitle("Register", for: .normal)
            loginBtn.isHidden = true //hide login button no user is regsitered
            forgotPassword.isHidden = true
            authentButton.isHidden = true
            FBloginButton.isHidden = true
            googleButton.isHidden = true
            emailField.isHidden = false
            phoneField.isHidden = false
            plusPhotoButton.isHidden = false
        } else {
            reEnterPasswordField .isHidden = true
            registerBtn.isHidden = false
            forgotPassword.isHidden = false
            FBloginButton.isHidden = false
            googleButton.isHidden = false
            emailField.isHidden = true
            phoneField.isHidden = true
            backloginBtn.isHidden = true
            plusPhotoButton.isHidden = true
            // Keychain
            //self.usernameField!.text = KeychainWrapper.standard.string(forKey: "usernameKey")
            //self.passwordField!.text = KeychainWrapper.standard.string(forKey: "passwordKey")
        }
        self.passwordField.text = ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        // Gradient
        scrollView.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)

        view.addSubview(scrollView)
        scrollView.addSubview(mainView)
        scrollView.addSubview(mapView)
        scrollView.addSubview(FBloginButton)
        scrollView.addSubview(googleButton)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(reEnterPasswordField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(phoneField)
        scrollView.addSubview(loginBtn)
        scrollView.addSubview(registerBtn)
        scrollView.addSubview(backloginBtn)
        scrollView.addSubview(forgotPassword)
        scrollView.addSubview(authentButton)
        mainView.addSubview(plusPhotoButton)

        plusPhotoButton.anchor(top: mainView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 55, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true

        //mapView.translatesAutoresizingMaskIntoConstraints = false
        //mapView.heightAnchor.constraint(equalToConstant: 380).isActive = true

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            mapView.topAnchor.constraint(equalTo: mainView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 9.0/16.0),

            usernameField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 15),
            usernameField.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            usernameField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            usernameField.heightAnchor.constraint(equalToConstant: 40),

            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            passwordField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            passwordField.heightAnchor.constraint(equalToConstant: 40),

            reEnterPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            reEnterPasswordField.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            reEnterPasswordField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            reEnterPasswordField.heightAnchor.constraint(equalToConstant: 40),

            emailField.topAnchor.constraint(equalTo: reEnterPasswordField.bottomAnchor, constant: 10),
            emailField.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            emailField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            emailField.heightAnchor.constraint(equalToConstant: 40),

            phoneField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            phoneField.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            phoneField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            phoneField.heightAnchor.constraint(equalToConstant: 40),

            loginBtn.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 15),
            loginBtn.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            loginBtn.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            loginBtn.heightAnchor.constraint(equalToConstant: 40),

            registerBtn.topAnchor.constraint(equalTo: loginBtn.bottomAnchor, constant: 15),
            registerBtn.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            registerBtn.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            registerBtn.heightAnchor.constraint(equalToConstant: 40),

            backloginBtn.topAnchor.constraint(equalTo: registerBtn.bottomAnchor, constant: 15),
            backloginBtn.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            backloginBtn.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            backloginBtn.heightAnchor.constraint(equalToConstant: 40),

            forgotPassword.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 5),
            forgotPassword.leadingAnchor.constraint( equalTo: mainView.leadingAnchor, constant: 10),
            forgotPassword.widthAnchor.constraint(equalToConstant: 125),
            forgotPassword.heightAnchor.constraint(equalToConstant: 30),

            authentButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 5),
            authentButton.trailingAnchor.constraint( equalTo: mainView.trailingAnchor, constant: -10),
            authentButton.widthAnchor.constraint(equalToConstant: 125),
            authentButton.heightAnchor.constraint(equalToConstant: 30),
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

        view.endEditing(true)
        keyboardHide()
        registerBtn.setTitle("Create an Account", for: .normal)
        usernameField.text = defaults.string(forKey: "usernameKey")
        passwordField.isHidden = false
        loginBtn.isHidden = false
        registerBtn.isHidden = false
        forgotPassword.isHidden = false
        authentButton.isHidden = false
        backloginBtn.isHidden = true
        reEnterPasswordField.isHidden = true
        emailField.isHidden = true
        phoneField.isHidden = true
        FBloginButton.isHidden = false
        googleButton.isHidden = false
        plusPhotoButton.isHidden = true
        mapView.isHidden = false
        setupDefaults()
    }

    // MARK: - Register User
    @IBAction func registerUser(_ sender:AnyObject) {

        if (self.registerBtn.titleLabel!.text == "Create an Account") {

            registerBtn.setTitle("Register", for: .normal)
            usernameField.text = ""
            loginBtn.isHidden = true
            forgotPassword.isHidden = true
            authentButton.isHidden = true
            backloginBtn.isHidden = false
            reEnterPasswordField.isHidden = false
            emailField.isHidden = false
            phoneField.isHidden = false
            FBloginButton.isHidden = true
            googleButton.isHidden = true
            plusPhotoButton.isHidden = false
            mapView.isHidden = true

        } else {
            if (usernameField.text == "" || emailField.text == "" || passwordField.text == "" || reEnterPasswordField.text == "") {

                self.showAlert(title: "Oooops", message: "You must complete all fields")
            } else {
                checkPasswordsMatch()
            }
        }
    }

    func checkPasswordsMatch() {

        if passwordField.text == reEnterPasswordField.text {
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

            if (plusPhotoButton.imageView?.image == nil) {
                plusPhotoButton.imageView?.image = UIImage(named:"profile-rabbit-toy.png")
            }
            pictureData = plusPhotoButton.imageView?.image?.jpegData(compressionQuality: 0.9)
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

            usernameField.text = name
            emailField.text = email
            passwordField.text = "united"
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
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
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
    @objc func passwordReset(_ sender:AnyObject) {
        
        self.usernameField.isHidden = true
        self.loginBtn.isHidden = true
        self.passwordField.isHidden = true
        self.authentButton.isHidden = true
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

    @objc func authenticateUser(_ sender: AnyObject) {
        
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
            geoFire.setLocation(CLLocation(latitude: (mapView.userLocation.coordinate.latitude), longitude: (mapView.userLocation.coordinate.longitude)), forKey: uid)
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

}
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - AvatarImage

    @objc func handlePlusPhoto () {

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
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
            guard let image = userimageView.image else {return}

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
