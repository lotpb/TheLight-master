//
//  UserProfileController.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/21/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Parse
import MapKit
import CoreLocation
import MobileCoreServices //kUTTypeImage
import MessageUI
import AVKit


@available(iOS 13.0, *)
final class MeProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, MeProfileHeaderDelegate {
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    private let cellId = "cellId"
    private let mapId = "mapId"
    var isGridView = true
    
    var defaults = UserDefaults.standard
    
    var selectedImage : UIImage? //sharebutton
    var socialText: String = ""
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    //firebase
    var userlist = [UserModel]()
    var users: UserModel?
    var posts = [NewsModel]()
    
    var isFormMe: Bool = true
    var uidStr: String?

    //parse
    var _feedItems = NSMutableArray()
    var imageObject :PFObject!
    var imageFile :PFFileObject!
    var user : PFUser?
    
    var followingNumber: Int?
    var followNumber: Int?
    var status : String?
    var objectId : String?
    var username : String?
    var create : String?
    var email : String?
    var phone : String?

    
    let userDetailImageview: CustomImageView = { //firebase only
        let imageView = CustomImageView()
        imageView.backgroundColor = .systemRed
        imageView.contentMode = .scaleAspectFill //.scaleAspectFill //.scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        fetchPhotoImages() //dont move viewDidLoad
        setupNavigation()

        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.Lead.navColor
        refreshControl.tintColor = .label
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        fetchUserName() //dont move viewWillAppear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(MeProfileVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        setupNewsNavigationItems()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        users = nil
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    // MARK: - refresh
    @objc func refreshData() {
        userlist.removeAll()
        posts.removeAll()
        fetchPhotoImages()
        fetchUserName()
        DispatchQueue.main.async { //added
            self.collectionView?.reloadData()
        }
        collectionView?.refreshControl?.endRefreshing()
    }
    
    private func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
        }
        
        //collectionView?.contentInset = .init(top: 50,left: 50,bottom: 0,right: 50)
        collectionView?.backgroundColor = .secondarySystemGroupedBackground
        collectionView?.register(MeProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(MeProfileGridCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(MeProfileListCell.self, forCellWithReuseIdentifier: mapId)
    }
    
    private func setupNavigation() {

        navigationItem.largeTitleDisplayMode = .never
        /*
        if isFormMe == false {
            let userMapItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(userDetailBtn))
            navigationItem.setRightBarButton(userMapItem, animated: true)
            
            let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(setbackButton))
            navigationItem.setLeftBarButton(doneBarButtonItem, animated: true)
        } */
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
    }
    
    // MARK: - NavigationController Hidden
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    // MARK: - LoadData
    private func fetchUserName() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {

            self.navigationItem.title =  PFUser.current()?.username ?? "Error"
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
            })
        } else {
            
            if isFormMe == true {
                uidStr = Auth.auth().currentUser?.uid
            } else {
                uidStr = self.objectId
            }
            Database.fetchUserWithUID(uid: uidStr!) { (user) in
                self.users = user
                self.navigationItem.title = self.users?.username
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func fetchPhotoImages() { 
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            //fetchPhotoImages
            let query1 = PFQuery(className:"Newsios")
            query1.limit = 1000
            query1.cachePolicy = .cacheThenNetwork
            query1.order(byDescending: "createdAt")
            query1.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                } else {
                    print("Failed to fetch photo's for users")
                }
            }
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
            })
            
        } else {
            //firebase
            guard let uid = Auth.auth().currentUser?.uid else { return }
            if isFormMe == true {
                uidStr = Auth.auth().currentUser?.uid
            } else {
                //uidStr = uidProfileStr
                uidStr = self.objectId
            }
            //News
            FirebaseRef.databaseRoot.child("News")
                .queryOrdered(byChild: "uid")
                .queryEqual(toValue: uidStr)
                .observe(.childAdded , with:{ (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let post = NewsModel(dictionary: dictionary)
                    self.posts.append(post)

                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }) { (err) in
                    print("Failed to fetch photo's for users:", err)
            }
            //following
            FirebaseRef.databaseRoot.child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                self.followingNumber = Int(snapshot.childrenCount)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            }) { (err) in
                print("Failed to get current user's following people", err)
                return
            }
            //followers
            /*
             ref.child("followers")
             ref.queryOrdered(byChild: "uid")
             .queryEqual(toValue: uidStr)
             .observe(.value, with: { snapshot in
             /*
             if let foo = snapshot.value as? [String: AnyObject] {
             //let name = foo["name"] as? String
             //let email = foo["email"] as? String
             } */
             }) */
        }
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if isGridView {
            let width = (view.frame.width - 2) / 3
            return .init(width: width, height: width)
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad  {
                return .init(width: 700, height: 525)
            } else {
                let width = (view.frame.width - 2)
                return .init(width: width, height: 344)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            return self._feedItems.count
        } else {
            return posts.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if isGridView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MeProfileGridCell
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedItems.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    guard let imageData = imageData else {return}
                    DispatchQueue.main.async {
                        cell.photoImageView.image = UIImage(data: imageData)
                    }
                }
                let imageDetailurl = self.imageFile.url ?? ""
                let result1 = imageDetailurl.contains("movie.mp4")
                cell.playButton.isHidden = result1 == false
                
            } else {
                //firebase
                cell.post = posts[indexPath.item]
                //cell.photoImageView.tag = indexPath.row
            }
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mapId, for: indexPath) as! MeProfileListCell
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                imageObject = _feedItems.object(at: indexPath.row) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile!.getDataInBackground { imageData, error in
                    
                    guard let imageData = imageData else {return}
                    DispatchQueue.main.async {
                        cell.photoImageView.image = UIImage(data: imageData)
                    }
                }
                let imageDetailurl = self.imageFile.url ?? ""
                let result1 = imageDetailurl.contains("movie.mp4")
                cell.playButton.isHidden = result1 == false
                
            } else {
                //firebase
                cell.post = posts[indexPath.item]
            }
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! MeProfileHeader
        
        header.user = self.users
        header.delegate = self
        
        if isFormMe == true {
            header.editProfileBtn.setTitle("Edit Profile", for: .normal)
            header.editProfileBtn.addTarget(self, action: #selector(userDetailBtn), for: .touchUpInside)
        } else {
            header.editProfileBtn.setTitle("follow", for: .normal)
            //header.editProfileBtn.addTarget(self, action: #selector(header.handleEditProfileFollow), for: .touchUpInside)
            header.setupEditFollowButton()
        }
        
        let followNum = followNumber ?? 0
        let followingNum = followingNumber ?? 0
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            header.updateValues(posts: _feedItems.count , follower: followNum, following: followingNum)
        } else {
            //firebase
            header.updateValues(posts: posts.count , follower: followNum, following: followingNum)
        } 
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 180)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout()
        })
    }

    // MARK: - Button
    @objc func setbackButton() {
        dismiss(animated: true)
    }
    
    // FIXME: This needs to replaced next sprint
    @objc func userDetailBtn() { //fix
        self.performSegue(withIdentifier: "userprofileDetailSegue", sender: self)
    }
    
    @objc func settingButton() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
    }
    
    @objc func shareButton(sender: UIButton) {
        
        let point : CGPoint = sender.convert(.zero, to: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: point)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            socialText = ((_feedItems.object(at: (indexPath! as NSIndexPath).row) as AnyObject).value(forKey: "newsTitle") as? String)!
            
            imageObject = _feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as? PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile.getDataInBackground { imageData, error in
                
                self.selectedImage = UIImage(data: imageData!)
            }
        } else {
            //firebase
            socialText = posts[(indexPath?.row)!].newsTitle
            
            let newsImageUrl = self.posts[(indexPath?.row)!].imageUrl
            self.userDetailImageview.loadImage(urlString: newsImageUrl)
            self.selectedImage = self.userDetailImageview.image
        }
        
        let image: UIImage = self.selectedImage!
        let activityVC = UIActivityViewController (activityItems: [(image), socialText], applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = (sender)
        activityVC.popoverPresentationController?.permittedArrowDirections = .any
        activityVC.popoverPresentationController?.sourceRect = .init(x: 150, y: 150, width: 0, height: 0)
        let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        windows?.rootViewController?.present(activityVC, animated: true)
    }
    //----------------------------------------------------------------
    
    // MARK: - Segue
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name:"News", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailVC
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query = PFQuery(className:"Newsios")
            query.whereKey("objectId", equalTo:((_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).value(forKey: "objectId") as? String?)!!)
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    object!.incrementKey("newsView")
                    object!.saveInBackground()
                }
            }
            
            imageObject = _feedItems.object(at: indexPath.row) as? PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                self.selectedImage = UIImage(data: imageData! as Data)
                vc.objectId = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                vc.newsTitle = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String
                vc.newsDetail = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsDetail") as? String
                vc.newsDate = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
                vc.newsStory = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "storyText") as? String
                vc.image = self.selectedImage
                vc.imageUrl = self.imageFile.url
                //vc.videoURL = self.imageFile.url
                let navigationController = UINavigationController(rootViewController: vc)
                let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                windows?.rootViewController?.present(navigationController, animated: true)

            }
        } else {
            //firebase
            vc.objectId = self.posts[indexPath.row].newsId
            vc.newsTitle = self.posts[indexPath.row].newsTitle
            vc.newsDetail = self.posts[indexPath.row].newsDetail
            vc.newsDate = self.posts[indexPath.row].creationDate
            vc.newsStory = self.posts[indexPath.row].storyLabel
            vc.imageUrl = self.posts[indexPath.row].imageUrl
            vc.videoURL = self.posts[indexPath.row].videoUrl
            let navigationController = UINavigationController(rootViewController: vc)
            let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            windows?.rootViewController?.present(navigationController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let updated: Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        if segue.identifier == "userprofileDetailSegue" {

            guard let VC = segue.destination as? UserDetailController else { return }
  
                VC.status = "Edit"
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    updated = PFUser.current()!.createdAt
                    VC.objectId = PFUser.current()!.objectId
                    VC.username = PFUser.current()!.username
                    VC.email = PFUser.current()!.email
                    VC.phone = defaults.string(forKey: "phoneKey")
                    VC.userimage = #imageLiteral(resourceName: "profile-rabbit-toy")
                } else {
                    //firebase
                    updated = users?.creationDate
                    //VC.creationDate = users?.creationDate
                    VC.username = users?.username
                    VC.email = users?.email
                    VC.phone = users?.phone

                    let profileImageUrl = users?.profileImageUrl
                    self.userDetailImageview.loadImage(urlString: profileImageUrl!)
                    VC.userimage = self.userDetailImageview.image
                    
                    let createString = dateFormatter.string(from: (updated)!)
                    VC.create = createString
                }
            }
        }
}
extension MeProfileVC{

    func performZoomLogic(imageView: UIImageView){
        print("performing zoom in logic")
        let fullScreenImageViewController = FullScreenImageViewController()
        fullScreenImageViewController.imageView.image = imageView.image
        fullScreenImageViewController.modalPresentationStyle = .fullScreen
        fullScreenImageViewController.modalTransitionStyle = .crossDissolve
        present(fullScreenImageViewController, animated: true, completion: nil)
    }

    //MARK: Another logic for zoom functionality (better than the first one in terms of functionality)
    class FullScreenImageViewController: UIViewController {

        lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        override func viewDidLoad() {
            super .viewDidLoad()
            view.backgroundColor = .black
            view.addSubview(imageView)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
            let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
            swipeUpGesture.direction = .up
            let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
            swipeDownGesture.direction = .down

            view.gestureRecognizers = [tapGesture ,swipeUpGesture, swipeDownGesture]

            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }

        @objc func handleDismiss(){
            dismiss(animated: true, completion: nil)
        }
    }

}
extension MeProfileVC{
    func playVideo(with videoUrl: URL){
        let videoPlayer = AVPlayer(url: videoUrl)
        let videoPlayerVC = AVPlayerViewController()
        videoPlayerVC.player = videoPlayer

        present(videoPlayerVC, animated: true) {
            videoPlayer.play()
        }
    }
}
