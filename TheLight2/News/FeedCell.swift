//
//  FeedCell.swift
//  youtube
//
//  Created by Brian Voong on 7/3/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//


import UIKit
import Parse
import FirebaseDatabase
import AVFoundation

@available(iOS 13.0, *)
class FeedCell: CollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //firebase
    var newslist = [NewsModel]()
    //parse
    var _feedItems = NSMutableArray()
    var imageObject :PFObject!
    var imageFile :PFFileObject!
    
    private var selectedImage : UIImage?
    var defaults = UserDefaults.standard
    private var socialText: String = ""
    private let cellId = "cellId"
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .secondarySystemGroupedBackground
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let newsImageview: CustomImageView = { //firebase only
        let imageView = CustomImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill //.scaleAspectFill //.scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .systemGroupedBackground
        refreshControl.tintColor = .lightGray
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        self.fetchVideos()
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        self.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView.addSubview(self.refreshControl)

    }
    
    // MARK: - Parse
    func fetchVideos() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let query = PFQuery(className:"Newsios")
            query.limit = 1000
            query.cachePolicy = .cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                } else {
                    print("Errortube")
                }
            }
        } else {
            //firebase
            let ref = FirebaseRef.databaseRoot.child("News")
            ref.observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let newsTxt = NewsModel(dictionary: dictionary)
                self.newslist.append(newsTxt)
                
                self.newslist.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                })
            })
        }
    }
    
    // MARK: - refresh
    @objc func refreshData() {
        newslist.removeAll()
        fetchVideos()
        DispatchQueue.main.async { //added
            self.collectionView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - NavigationController Hidden
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
    @objc func likeSetButton(sender: UIButton) {
        
        sender.isSelected = true
        sender.tintColor = ColorX.BlueColor
        let hitPoint = sender.convert(CGPoint.zero, to: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: hitPoint)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query = PFQuery(className:"Newsios")
            query.whereKey("objectId", equalTo:((_feedItems.object(at: ((indexPath! as NSIndexPath).row)) as AnyObject).value(forKey: "objectId") as! String))
            query.getFirstObjectInBackground { object, error in
                if error == nil {
                    object!.incrementKey("Liked")
                    object!.saveInBackground()
                }
            }
        } else {
            //firebase
            let likeStr = newslist[(indexPath?.item)!].newsId
            print(likeStr!)
            let refReservations = FirebaseRef.databaseRoot.child("News").child(likeStr!).child("liked")
            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                var value = self.newslist[(indexPath?.item)!].liked as? Int
                if value == nil {
                    value = 0
                }
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }
        }
    }
    
    // MARK: imgLoadSegue
    @objc func imgLoadSegue(_ sender: UITapGestureRecognizer) {
        
        let storyboard = UIStoryboard(name:"Me", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MeProfileID") as! MeProfileVC
        vc.isFormMe = false
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            //vc.uidProfileStr = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "objectId") as? String)!
        } else {
            //firebase
            //vc.uidProfileStr = newslist[(sender.view!.tag)].uid
        }
        let navigationController = UINavigationController(rootViewController: vc)
        let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        windows?.rootViewController?.present(navigationController, animated: true)
    }
    
    @objc func shareButton(sender: UIButton) {
        
        let point : CGPoint = sender.convert(.zero, to: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            socialText = ((_feedItems.object(at: (indexPath! as NSIndexPath).row) as AnyObject).value(forKey: "newsTitle") as? String)!
            
            imageObject = _feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as? PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile.getDataInBackground { imageData, error in
                
                self.selectedImage = UIImage(data: imageData!)
            }
        } else {
            //firebase
            socialText = newslist[(indexPath?.row)!].newsTitle
            
            let newsImageUrl = self.newslist[(indexPath?.row)!].imageUrl
            self.newsImageview.loadImage(urlString: newsImageUrl)
            self.selectedImage = self.newsImageview.image
        }
        
        let image: UIImage = self.selectedImage!
        let activityVC = UIActivityViewController (activityItems: [(image), socialText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = (sender)
        activityVC.popoverPresentationController?.permittedArrowDirections = .any
        activityVC.popoverPresentationController?.sourceRect = .init(x: 150, y: 150, width: 0, height: 0)
        let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        windows?.rootViewController?.present(activityVC, animated: true)
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            return self._feedItems.count
        } else {
            return self.newslist.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? VideoCell else { fatalError("Unexpected Index Path") }
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.titleLabelnew.font = Font.News.newstitlePad
            cell.subtitleLabel.font = Font.News.newssourcePad
            cell.uploadbylabel.font = Font.News.newslabel2Pad
            cell.storyLabel.font = Font.News.newslabel2Pad
            
        } else {
            cell.titleLabelnew.font = Font.News.newstitle
            cell.subtitleLabel.font = Font.News.newssource
            cell.uploadbylabel.font = Font.News.newslabel2
        }
        cell.titleLabelnew.textColor = .label
        cell.subtitleLabel.textColor = .secondaryLabel
        cell.uploadbylabel.textColor = .secondaryLabel 
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            imageObject = _feedItems.object(at: (indexPath).row) as? PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile.getDataInBackground { data, error in
                if error == nil {
                    UIView.transition(with: cell.customImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.selectedImage = UIImage(data: data!)
                        cell.customImageView.image = UIImage(data: data!) //self.selectedImage
                    }, completion: nil)
                }
            }
            
            //profile Image
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo:(self._feedItems[(indexPath).row] as AnyObject).value(forKey: "username") as! String)
            query.cachePolicy = .cacheThenNetwork
            query.getFirstObjectInBackground { object, error in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                        imageFile.getDataInBackground { imageData, error in
                            
                            UIView.transition(with: cell.profileImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                cell.profileImageView.image = UIImage(data: imageData!)
                            }, completion: nil)
                        }
                    }
                }
            }
            
            cell.titleLabelnew.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsTitle") as? String
            
            var newsView:Int? = (_feedItems[(indexPath).row] as AnyObject).value(forKey: "newsView")as? Int
            if newsView == nil { newsView = 0 }
            let date1 = ((self._feedItems[(indexPath).row] as AnyObject).value(forKey: "createdAt") as? Date)!
            let date2 = Date()
            let calendar = Calendar.current
            let diffDateComponents = calendar.dateComponents([.day], from: date1, to: date2)
            cell.subtitleLabel.text = String(format: "%@, %@, %d%@", ((self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsDetail") as? String)!, "\(newsView!) views", diffDateComponents.day!," days ago" )
            
            let updated:Date = date1
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let elapsedTimeInSeconds = NSDate().timeIntervalSince(date1 as Date)
            let secondInDays: TimeInterval = 60 * 60 * 24
            if elapsedTimeInSeconds > 7 * secondInDays {
                dateFormatter.dateFormat = "MMM dd, yyyy"
            } else if elapsedTimeInSeconds > secondInDays {
                dateFormatter.dateFormat = "EEEE"
            }
            let createString = dateFormatter.string(from: updated)
            
            
            
            var Liked:Int? = (_feedItems[(indexPath).row] as AnyObject).value(forKey: "Liked")as? Int
            if Liked == nil {
                Liked = 0
                cell.uploadbylabel.text = String(format: "%@ %@", " Uploaded", createString)
            } else {
                let numString : String
                numString = String(format: "%@ %@ %@", "\(Liked!)", " Uploaded", createString)
                let attributedString = NSMutableAttributedString(string: numString)
                let firstAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 18)]
                attributedString.addAttributes(firstAttributes, range: NSRange(location: 0, length: 3))
                cell.uploadbylabel.attributedText = attributedString
            }

            let imageDetailurl = self.imageFile.url ?? ""
            let result1 = imageDetailurl.contains("movie.mp4")
            cell.playButton.isHidden = result1 == false
            cell.playButton.setTitle(imageDetailurl, for: .normal)
            cell.videoLengthLabel.isHidden = result1 == false
            
        } else {
            //firebase
            cell.news = newslist[indexPath.item]
            
            var Liked:Int? = cell.news?.liked as? Int
            if Liked == 0 {
                Liked = 0
                cell.uploadbylabel.text = String(format: "%@ %@", " Uploaded", (cell.news?.creationDate.timeAgoDisplay())!)
            } else {
                let numString : String
                numString = String(format: "%@ %@ %@", "\(Liked!)", " Uploaded", (cell.news?.creationDate.timeAgoDisplay())!)
                let attributedString = NSMutableAttributedString(string: numString)
                let firstAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 18)]
                attributedString.addAttributes(firstAttributes, range: NSRange(location: 0, length: 3))
                cell.uploadbylabel.attributedText = attributedString
            }
        }
        
        cell.actionButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
        cell.likeBtn.addTarget(self, action: #selector(likeSetButton), for: .touchUpInside)
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                cell.storyLabel.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "storyText") as? String
            } else {
                //firebase
                cell.storyLabel.text = self.newslist[(indexPath).row].storyLabel
            }
        } else {
            cell.storyLabel.text = ""
        }
        
        cell.profileImageView.tag = indexPath.row
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgLoadSegue))
        cell.profileImageView.addGestureRecognizer(tap)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            let size = CGSize.init(width: UIScreen.main.bounds.width, height: 275)
            return size
        } else {
            // FIXME:
            let height = (frame.width - 20 - 20) * 9 / 16
            return .init(width: frame.width, height: height + 20 + 20 + 86)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    // MARK: - Segues
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
                
                let imageDetailurl = self.imageFile.url
                let result1 = imageDetailurl!.contains("movie.mp4")
                if (result1 == true) {
                    /*
                     let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PlayVC") as! PlayVC
                    vc.videoURL = imageDetailurl
                    let navigationController = UINavigationController(rootViewController: vc)
                    UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true) */
                    
                    /*
                     let videoLauncher = NavVC()
                     videoLauncher.videoURL = imageDetailurl
                     //self.navigationController?.pushViewController(videoLauncher, animated: true)
                    present(videoLauncher, animated: true, completion: nil)
                    */
                    
                    NotificationCenter.default.post(name: NSNotification.Name("open"), object: nil)
                    
                } else {
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
            }
        } else {
            //firebase
            let likeStr = newslist[(indexPath.row)].newsId
            let refReservations = FirebaseRef.databaseRoot.child("News").child(likeStr!).child("viewCount")
            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                var value = currentData.value as? Int
                if value == nil {
                    value = 0
                }
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }
            
            let imageDetailurl = self.newslist[indexPath.row].videoUrl
            if !(imageDetailurl == "") {

                NotificationCenter.default.post(name: NSNotification.Name("open"), object: nil)
                let storyboard = UIStoryboard(name: "News", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "PlayVC") as! PlayVC
                vc.videoURL = self.newslist[indexPath.row].videoUrl
                vc.idLookup = self.newslist[indexPath.row].newsId
                vc.titleLookup = self.newslist[indexPath.row].newsTitle
                vc.likesLookup = String(describing: self.newslist[indexPath.row].liked)
                vc.dislikesLookup = String(describing: self.newslist[indexPath.row].dislikes)
                vc.viewLookup = String(describing: self.newslist[indexPath.row].viewCount)

                let navigationController = UINavigationController(rootViewController: vc)
                let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                windows?.rootViewController?.present(navigationController, animated: true)

            } else {
                vc.objectId = self.newslist[indexPath.row].newsId
                vc.newsTitle = self.newslist[indexPath.row].newsTitle
                vc.newsDetail = self.newslist[indexPath.row].newsDetail
                vc.newsDate = self.newslist[indexPath.row].creationDate
                vc.newsStory = self.newslist[indexPath.row].storyLabel
                vc.imageUrl = self.newslist[indexPath.row].imageUrl
                vc.videoURL = self.newslist[indexPath.row].videoUrl
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                windows?.rootViewController?.present(navigationController, animated: true)
            }
        }
    }
}



















