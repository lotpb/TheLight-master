//
//  UploadController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/20/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import MobileCoreServices //kUTTypeImage
import AVKit
import AVFoundation
import UserNotifications
import MessageUI


@available(iOS 13.0, *)
final class UploadController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
   fileprivate let addText = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var commentTitle: UITextField!
    @IBOutlet weak var commentSorce: UITextField!
    
    var playerViewController = AVPlayerViewController()
    var imagePicker = UIImagePickerController()
    var isPickImage = false
    var isEditImage = false
    
    var formState : String?
    var objectId : String?
    var newstitle : String?
    var newsdetail : String?
    var newsStory : String?
    var imageDetailurl : String?
    var videoDetailurl : String?
    var newsImage : UIImage!
    
    //firebase
    var picImage : UIImage!
    var newsvideourl : String?
    
    // Parse
    var file : PFFileObject!
    var uploadData : Data!
    
    var videoURL : URL?
    let defaults = UserDefaults.standard
    let progress = Progress(totalUnitCount: 1)
    
    let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let newsImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let commentDetail: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .systemBackground
        textView.autocorrectionType = .yes
        textView.dataDetectorTypes = .all
        return textView
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("Upload", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white //Color.DGrayColor
        button.layer.cornerRadius = 12.0
        button.layer.borderColor = UIColor.systemBlue.cgColor //Color.DGrayColor.cgColor
        button.layer.borderWidth = 2.0
        button.addTarget(self, action: #selector(clearBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var selectPic: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Select Picture", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white //Color.DGrayColor
        button.layer.cornerRadius = 12.0
        button.layer.borderColor = UIColor.systemBlue.cgColor //Color.DGrayColor.cgColor
        button.layer.borderWidth = 2.0
        button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationButtons()
        setupConstraints()
        setupForm()
        setupFonts()
        self.navigationItem.titleView = self.titleButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.commentDetail.isScrollEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.commentDetail.isScrollEnabled = false
        setupNewsNavigationItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerViewController)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func setupNavigationButtons() {
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(shootPhoto))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(uploadImage))
        navigationItem.rightBarButtonItems = [saveButton, cameraButton]
    }
    
    func setupForm() {

        self.mainView.backgroundColor = .secondarySystemGroupedBackground
        //self.activityIndicator.isHidden = true
        self.commentDetail.delegate = self
        progressView.isHidden = true
        progressView.setProgress(0, animated: true)
        progressView.transform = self.progressView.transform.scaledBy(x: 1, y: 1.5)
        
        if self.formState == "Update" {
            // FIXME:
            if (newsImage != nil) {
                isPickImage = true
            } else {
                isPickImage = false
            }
            
            self.commentTitle.text = self.newstitle
            self.commentDetail.text = self.newsStory
            self.commentSorce.text = self.newsdetail
            self.newsImageView.image = self.newsImage
        } else {
            self.commentDetail.text = addText
        }
    }
    
    func setupFonts() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.commentTitle!.font = Font.celltitle18r
            self.commentDetail.font = Font.celltitle18r
            self.commentSorce.font = Font.celltitle18r
        } else {
            self.commentTitle!.font = Font.celltitle16r
            self.commentDetail.font = Font.celltitle16r
            self.commentSorce.font = Font.celltitle16r
        }
    }
    
    func setupConstraints() {
        mainView.addSubview(newsImageView)
        mainView.addSubview(commentDetail)
        mainView.addSubview(selectPic)
        mainView.addSubview(clearButton)
        mainView.addSubview(activityIndicator)
        
        let height = ((commentTitle.frame.width) * 9 / 16) + 16
        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: (commentSorce?.bottomAnchor)!, constant: 10),
            newsImageView.leadingAnchor.constraint( equalTo: (commentSorce?.leadingAnchor)!, constant: 0),
            newsImageView.trailingAnchor.constraint( equalTo: (commentSorce?.trailingAnchor)!, constant: 0),
            newsImageView.heightAnchor.constraint(equalToConstant: height),
            
            commentDetail.topAnchor.constraint(equalTo: (selectPic.bottomAnchor), constant: 15),
            commentDetail.leadingAnchor.constraint( equalTo: (commentSorce?.leadingAnchor)!, constant: 0),
            commentDetail.trailingAnchor.constraint( equalTo: (commentSorce?.trailingAnchor)!, constant: 0),
            commentDetail.heightAnchor.constraint(equalToConstant: 200),
            
            selectPic.topAnchor.constraint(equalTo: (newsImageView.bottomAnchor), constant: 10),
            selectPic.leadingAnchor.constraint( equalTo: (newsImageView.leadingAnchor), constant: 0),
            selectPic.widthAnchor.constraint(equalToConstant: 120),
            selectPic.heightAnchor.constraint(equalToConstant: 30),
            
            clearButton.topAnchor.constraint(equalTo: (commentDetail.bottomAnchor), constant: 10),
            clearButton.leadingAnchor.constraint( equalTo: (commentSorce.leadingAnchor), constant: 0),
            clearButton.widthAnchor.constraint(equalToConstant: 75),
            clearButton.heightAnchor.constraint(equalToConstant: 30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: newsImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: newsImageView.centerYAnchor)
            ])
        
        commentTitle.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            commentTitle.widthAnchor.constraint(equalToConstant: 450).isActive = true
        } else {
            commentTitle.widthAnchor.constraint(equalToConstant: 338).isActive = true
        }
    }
    
    // MARK: - Button
    @objc func clearBtn() {
        
        if (self.clearButton.titleLabel!.text == "Clear")   {
            self.commentDetail.text = ""
            self.clearButton.setTitle("add text", for: .normal)
        } else {
            self.commentDetail.text = addText
            self.clearButton.setTitle("Clear", for: .normal)
        }
    }
    
    private func sendMessageWithProperties(properties: [String:AnyObject]) {
        // fix
    }
    
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGeneretor = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGeneretor.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        return nil
    }
    
    //-----------------------------------------------------------------------------
    
    // MARK: - video playback
    @objc func finishedPlaying(_ myNotification:Notification) {
        let stoppedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
        stoppedPlayerItem.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    // MARK: - Update Data
    @objc func uploadImage(_ sender: AnyObject) {
        
        guard let commentText = self.commentTitle.text else { return }
        
        if commentText == "" {
            self.simpleAlert(title: "Oops!", message: "No text entered.")
        } else {
            
            self.navigationItem.rightBarButtonItem!.isEnabled = false
            self.progressView.isHidden = false
            
            self.activityIndicator.startAnimating()
            
            if (isPickImage == true) { //image
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    uploadData = self.newsImageView.image?.jpegData(compressionQuality: 0.9)
                    file = PFFileObject(name: "img", data: uploadData!)
                } else {
                    //Firebase
                    uploadToFirebaseStorageUsingImage(image: self.newsImageView.image!, completion: { (imageUrl) in
                        //self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
                    })
                }
                
            } else { //video
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    file = PFFileObject(name: "movie.mp4", data: FileManager.default.contents(atPath: videoURL!.path)!)
                } else {
                    //Firebase
                    handleVideoSelectedForUrl(videoURL!)
                }
            }
            
            if (self.formState == "Update") {
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    
                    let query = PFQuery(className:"Newsios")
                    query.whereKey("objectId", equalTo:self.objectId!)
                    query.getFirstObjectInBackground {(updateNews: PFObject?, error: Error?) in
                        if error == nil {
                            updateNews!.setObject(self.commentTitle.text ?? NSNull(), forKey:"newsTitle")
                            updateNews!.setObject(self.commentSorce.text ?? NSNull(), forKey:"newsDetail")
                            updateNews!.setObject(self.commentDetail.text ?? NSNull(), forKey:"storyText")
                            updateNews!.setObject(PFUser.current()!.username ?? NSNull(), forKey:"username")
                            updateNews!.saveEventually()
                            
                            if self.isEditImage == true {
                                self.file!.saveInBackground { (success: Bool, error: Error?) in
                                    if success {
                                        updateNews!.setObject(self.file!, forKey:"imageFile")
                                        updateNews!.saveInBackground { (success: Bool, error: Error?) in
                                            
                                            self.simpleAlert(title: "Image Upload Complete", message: "Successfully updated the image")
                                            self.gotoHome()
                                        }
                                    }
                                }
                            } else {
                                self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            }
                            self.navigationItem.rightBarButtonItem!.isEnabled = true
                        } else {
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                } else {
                    //firebase
                }
                
            } else { //save
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    file!.saveInBackground { (success: Bool, error: Error?) in
                        if success {
                            let saveNews:PFObject = PFObject(className:"Newsios")
                            saveNews.setObject(self.file ?? NSNull(), forKey:"imageFile")
                            saveNews.setObject(self.commentTitle.text ?? NSNull(), forKey:"newsTitle")
                            saveNews.setObject(self.commentSorce.text ?? NSNull(), forKey:"newsDetail")
                            saveNews.setObject(self.commentDetail.text ?? NSNull(), forKey:"storyText")
                            saveNews.setObject(PFUser.current()!.username ?? NSNull(), forKey:"username")
                            saveNews.saveInBackground { (success: Bool, error: Error?) in
                                if success {
                                    self.simpleAlert(title: "Upload Complete", message: "Successfully saved the data")
                                    self.newsNotification()
                                    self.gotoHome()
                                    
                                } else {
                                    print("Error: \(String(describing: error)) \(String(describing: error!._userInfo))")
                                }
                            }
                        } else {
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                } else {
                    //firebase
                }
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    func gotoHome() {
        
        let FeedbackGenerator = UINotificationFeedbackGenerator()
        FeedbackGenerator.notificationOccurred(.success)

        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "homeId")
            self.show(vc, sender: self)
       }
        self.newsNotification()
        self.newsEmail()
    }
    
    // MARK: - News Notification
    func newsNotification() {
        
        guard self.defaults.bool(forKey: "pushnotifyKey") == true else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Breaking News 🏀"
        content.body = "News Posted by \(defaults.object(forKey: "usernameKey") ?? "Pete") at TheLight"
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "status"
        
        let imageName = "applelogo"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        content.userInfo = ["link":""]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func newsEmail() {
        
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        guard self.defaults.bool(forKey: "emailnotifyKey") == true else { return }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["eunited@optonline.net"])
        mail.setSubject("Breaking News")
        mail.setMessageBody("News Posted by \(defaults.object(forKey: "usernameKey") ?? "Pete") at TheLight", isHTML: true)
        
        guard let theImage = newsImageView.image else {return}
        guard let imageData = theImage.pngData() else {return}
        mail.addAttachmentData(imageData, mimeType: "image/png", fileName: "heart")
        self.present(mail, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
@available(iOS 13.0, *)
extension UploadController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Camera
    @objc func shootPhoto(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            imagePicker.delegate = self
            imagePicker.showsCameraControls = true
            self.present(imagePicker, animated: true)
        } else{
            self.simpleAlert(title: "Alert!", message: "Camera not available")
        }
    }
    //-----------------------------------------------------------------------------
    @IBAction func selectImage(_ sender: AnyObject) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.isEditImage = true
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let videoStrURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL {
            videoURL = videoStrURL
            isPickImage = false
            let player = AVPlayer(url: videoStrURL)
            playerViewController.player = player
            playerViewController.view.frame = self.newsImageView.bounds
            playerViewController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspect.rawValue)
            playerViewController.showsPlaybackControls = true
            newsImageView.addSubview(playerViewController.view)
            player.play()
            
        } else {
            
            isPickImage = true
            handleImageSelectedForInfo(_info: info as [String : AnyObject])
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    private func handleImageSelectedForInfo(_info: [String: Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = _info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = _info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        newsImageView.image = selectedImageFromPicker
        
        picImage = selectedImageFromPicker
    }
    
    fileprivate func handleVideoSelectedForUrl(_ url: URL) {
        
        let filename = UUID().uuidString + ".mov"
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        let ref = Storage.storage().reference().child("News_movies").child(filename)
        
        let uploadTask = ref.putFile(from: url, metadata: metadata, completion: { (_, error) in
            
            if error != nil {
                print("CRAP Failed upload of video:", error!)
                return
            }
            
            ref.downloadURL( completion: { (downloadUrl, error) in
                if let err = error {
                    print("CRAP Failed to get download url:", err)
                    return
                }
                
                guard let downloadURL = downloadUrl?.absoluteString else { return}
                
                 self.newsvideourl = downloadURL
                
                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": downloadURL as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                    })
                    
                }
            })
        })
        
        uploadTask.observe(.resume) { snapshot in
          // Upload resumed, also fires when the upload starts
        }

        uploadTask.observe(.pause) { snapshot in
          // Upload paused
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            self.progressView.setProgress(Float(percentComplete), animated: true)
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.progressView.isHidden = true
            self.progressView.progress = 0.0
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    print("User doesn't have permission to access file")
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        let filename: String
        if !(self.formState == "Update") { //New
            filename = NSUUID().uuidString
        } else {
            filename = (Auth.auth().currentUser?.uid)!
        }
        
        if let uploadData = image.jpegData(compressionQuality: 0.9) {
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let storageItem = Storage.storage().reference().child("News").child(filename)
            storageItem.putData(uploadData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Failed to upload image:", error!)
                    return
                    
                } else {
                    
                    storageItem.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if !(self.formState == "Update") { //New
                            self.saveToDatabaseWithImageUrl(imageUrl: (url?.absoluteString)!)
                            
                        } else { //Update
                            
                            let userRef = FirebaseRef.databaseRoot.child("News").child(self.objectId!)
                            let values = ["newsTitle": self.commentTitle.text ?? "",
                                          "newsDetail": self.commentSorce.text ?? "",
                                          //"imageUrl": self.imageDetailurl ?? "",
                                          //"videoUrl": self.videoDetailurl ?? "",
                                          "storyText": self.commentDetail.text ?? ""
                                          ] as [String: Any]
                            
                            userRef.updateChildValues(values) { (err, ref) in
                                if let err = err {
                                    self.simpleAlert(title: "Upload Failure", message: err as? String)
                                    return
                                }
                                self.simpleAlert(title: "update Complete", message: "Successfully updated the data")
                                self.navigationItem.rightBarButtonItem?.isEnabled = true
                                self.gotoHome()
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func saveToDatabaseWithImageUrl(imageUrl:String) {
        
        guard let titleText = self.commentTitle.text else {return}
        guard let detailText = self.commentDetail.text else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let key = FirebaseRef.databaseRoot.child("News").child(uid).childByAutoId().key
        
        let values = ["imageUrl": imageUrl,
                      "videoUrl": self.newsvideourl ?? "",
                      "newsTitle": titleText,
                      "newsDetail": self.commentSorce.text ?? "",
                      "storyText": detailText,
                      "liked": 0,
                      "newsId": key!,
                      "creationDate" : Date().timeIntervalSince1970,
                      //"imageWidth": postImage.size.width,
                      //"imageHeight": postImage.size.height,
                      "uid": uid] as [String : Any]
        let childUpdates = ["/News/\(String(key!))": values]
        
        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.simpleAlert(title: "Upload Failure", message: err as? String)
                return
            }
            
            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
            self.gotoHome()
        }
    }
}
