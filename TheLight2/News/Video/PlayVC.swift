//
//  PlayVC.swift
//  YouTube
//
//  Created by Haik Aslanyan on 7/25/16.
//  Copyright © 2016 Haik Aslanyan. All rights reserved.
//
protocol PlayerVCDelegate {
    func didMinimize()
    func didmaximize()
    func swipeToMinimize(translation: CGFloat, toState: stateOfVC)
    func didEndedSwipe(toState: stateOfVC)
}

import UIKit
import AVFoundation
import Parse
import FirebaseDatabase
import FirebaseAuth

class PlayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var containView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var player = AVPlayer.init()
    private var playerLayer: AVPlayerLayer?
    var videoURL: String?
    var isPlaying = true
    var gradientLayer = CAGradientLayer()
    
    var delegate: PlayerVCDelegate?
    var state = stateOfVC.hidden
    var direction = Direction.none
    
    //firebase
    var newslist = [NewsModel]()
    var user: UserModel?
    //parse
    var _feedItems = NSMutableArray()
    var imageObject: PFObject!
    var imageFile: PFFileObject!
    
    var idLookup: String?
    var uidLookup: String?
    var titleLookup: String?
    var viewLookup: String?
    var likesLookup: String?
    var dislikesLookup: String?
    var imageLookup: String?
    var selectedImage : UIImage?
    var selectedChannelPic : UIImage?
    var defaults = UserDefaults.standard
    var subscribeNumber: Int?
    
    let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .systemRed
        slider.maximumTrackTintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        slider.setThumbImage(UIImage(systemName: "circle"), for: .normal)
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    lazy var minimizeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        button.setImage(UIImage(systemName: "chevron.down", withConfiguration: config), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = false
        button.addTarget(self, action: #selector(minimize), for: .touchUpInside)
        return button
    }()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        button.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = false
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containView.backgroundColor = .clear
        self.customization()
        self.setupConstraints()
        fetchPlayVCVideos()
        self.subscribeNumber = 0
        
        if videoURL == nil {
            videoURL = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        }
        self.playVideo(videoURL: videoURL!)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func prepareToDeinit() {
        
        self.resetPlayer()
    }
    
    open func resetPlayer() {
        
        self.player.pause()
        self.playerLayer?.removeFromSuperlayer()
        player.replaceCurrentItem(with: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Video Player
    
    private func playVideo(videoURL: String) {
        
        self.player.pause()
        
        if let url = NSURL(string: videoURL) {
            DispatchQueue.main.async(execute: {
                self.player = AVPlayer(url: url as URL)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.playerView.layer.addSublayer(self.playerLayer!)
                if self.state != .hidden {
                    self.player.play()
                    
                }
                //self.loopVideo(videoPlayer: self.videoPlayer)
                self.playDidEnd(videoPlayer: self.player)
                
                self.setupTimeRanges()//must keep below videoPlayer.play()
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = containView.bounds
        self.gradientLayer.frame = containView.bounds
    }
    
    
    // MARK: - Setup View
    
    func customization() {
        
        self.view.backgroundColor = .clear
        self.playerView.layer.anchorPoint.applying(CGAffineTransform.init(translationX: -0.5, y: -0.5))
        self.tableView.tableFooterView = UIView.init(frame: .init(x: 0, y: 0, width: 0, height: 0))
        self.containView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(PlayVC.tapPlayView)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayVC.tapPlayView), name: NSNotification.Name("open"), object: nil)
    }
    
    func setupConstraints() {

        setupGradientLayer()
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        
        containView.addSubview(activityIndicator)
        containView.addSubview(minimizeButton)
        containView.addSubview(pausePlayButton)
        containView.addSubview(videoLengthLabel)
        containView.addSubview(currentTimeLabel)
        containView.addSubview(videoSlider)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            
            minimizeButton.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 20),
            minimizeButton.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 20),
            minimizeButton.widthAnchor.constraint(equalToConstant: 30),
            minimizeButton.heightAnchor.constraint(equalToConstant: 30),
            
            pausePlayButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            pausePlayButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            pausePlayButton.heightAnchor.constraint(equalToConstant: 50),
            
            videoLengthLabel.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -8),
            videoLengthLabel.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -2),
            videoLengthLabel.heightAnchor.constraint(equalToConstant: 24),
            
            currentTimeLabel.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 8),
            currentTimeLabel.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -2),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 24)
            ])
        
        for label in [pausePlayButton, videoLengthLabel, currentTimeLabel] as [Any] {
            (label as AnyObject).widthAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        NSLayoutConstraint.activate([
            videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor),
            videoSlider.bottomAnchor.constraint(equalTo: playerView.bottomAnchor),
            videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor),
            videoSlider.heightAnchor.constraint(equalToConstant: 30)
            ])
    }
    
    func animate()  {
        switch self.state {
        case .fullScreen:
            UIView.animate(withDuration: 0.3, animations: {
                self.minimizeButton.alpha = 1
                self.containView.alpha = 1
                self.tableView.alpha = 1
                self.playerView.transform = CGAffineTransform.identity
                //UIApplication.shared.isStatusBarHidden = true
            })
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                //UIApplication.shared.isStatusBarHidden = false
                self.minimizeButton.alpha = 0
                self.containView.alpha = 0
                self.tableView.alpha = 0
                let scale = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                let trasform = scale.concatenating(CGAffineTransform.init(translationX: -self.playerView.bounds.width/4, y: -self.playerView.bounds.height/4))
                self.playerView.transform = trasform
            })
        default: break
        }
    }
    
    func changeValues(scaleFactor: CGFloat) {
        self.minimizeButton.alpha = 1 - scaleFactor
        self.containView.alpha = 1 - scaleFactor
        self.tableView.alpha = 1 - scaleFactor
        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * scaleFactor), y: (1 - 0.5 * scaleFactor))
        let transform = scale.concatenating(CGAffineTransform.init(translationX: -(self.playerView.bounds.width / 4 * scaleFactor), y: -(self.playerView.bounds.height / 4 * scaleFactor)))
        self.playerView.transform = transform
    }
    
    @objc func tapPlayView()  {
        showControlObjects()
        self.player.play()
        self.state = .fullScreen
        self.delegate?.didmaximize()
        self.animate()
    }
    
    
    @IBAction func minimize(_ sender: UIButton) {
        self.state = .minimized
        self.delegate?.didMinimize()
        self.animate()
    }
    
    @IBAction func minimizeGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let velocity = sender.velocity(in: nil)
            if abs(velocity.x) < abs(velocity.y) {
                self.direction = .up
            } else {
                self.direction = .left
            }
        }
        var finalState = stateOfVC.fullScreen
        switch self.state {
        case .fullScreen:
            let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
            self.changeValues(scaleFactor: factor)
            self.delegate?.swipeToMinimize(translation: factor, toState: .minimized)
            finalState = .minimized
        case .minimized:
            if self.direction == .left {
                finalState = .hidden
                let factor: CGFloat = sender.translation(in: nil).x
                self.delegate?.swipeToMinimize(translation: factor, toState: .hidden)
            } else {
                finalState = .fullScreen
                let factor = 1 - (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
                self.changeValues(scaleFactor: factor)
                self.delegate?.swipeToMinimize(translation: factor, toState: .fullScreen)
            }
        default: break
        }
        if sender.state == .ended {
            self.state = finalState
            self.animate()
            self.delegate?.didEndedSwipe(toState: self.state)
            if self.state == .hidden {
                self.player.pause()
            }
        }
    }
    
    // MARK: - Setup Video
    
    private func setupGradientLayer() {
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        containView.layer.addSublayer(gradientLayer)
    }
    
    @objc func handlePause() {
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        if isPlaying {
            player.pause()
            pausePlayButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        } else {
            player.play()
            pausePlayButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    @objc func handleSliderChange() {
        
        print(videoSlider.value)
        if let duration = player.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
        }
    }
    
    private func setupTimeRanges() {
        
        self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        //track player progress
        let interval = CMTime(value: 1, timescale: 2)
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            //lets move the slider thumb
            if let duration = self.player.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoSlider.value = Float(seconds / durationSeconds)
            }
        })
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicator.stopAnimating()
            containView.backgroundColor = .clear
            self.hideControlObjects()
            isPlaying = true
            
            if let duration = player.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    
    func showControlObjects() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.pausePlayButton.alpha = 1
            self.minimizeButton.alpha = 1
            self.currentTimeLabel.alpha = 1
            self.videoSlider.alpha = 1
            self.videoLengthLabel.alpha = 1
            self.gradientLayer.isHidden = false
        }, completion: {
            Bool in
            //self.panelVisible = true
        })
    }
    
    
    func hideControlObjects() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.pausePlayButton.alpha = 0
            self.minimizeButton.alpha = 0
            self.currentTimeLabel.alpha = 0
            self.videoSlider.alpha = 0
            self.videoLengthLabel.alpha = 0
            self.gradientLayer.isHidden = true
            
        }, completion: {
            Bool in
            //self.panelVisible = false
        })
    }
    
    // return to start Video
    func playDidEnd(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            
            self.player.seek(to: CMTime.zero, completionHandler: {
                Bool in
                self.videoSlider.setValue(0.0, animated: true)
                self.showControlObjects()
                self.handlePause()
            })
        }
    }    
    
    
    // MARK: - Button
    
    @objc func setthumbUp(_ sender: UIButton) {
        
        sender.isSelected = true
        sender.tintColor = Color.BlueColor
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
        let query = PFQuery(className:"Newsios")
        query.whereKey("objectId", equalTo:(self.idLookup!))
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object!.incrementKey("Liked")
                object!.saveInBackground()
            }
        }
        } else {
            //firebase
            let likeStr = self.idLookup
            let refReservations = FirebaseRef.databaseRoot.child("News").child(likeStr!).child("liked")
            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                var value = Int(self.likesLookup!)
                if value == nil { value = 0 }
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }
        }
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
    }
    
    @objc func setthumbDown(_ sender: UIButton) {
        
        sender.isSelected = true
        sender.tintColor = Color.BlueColor
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
        let query = PFQuery(className:"Newsios")
        query.whereKey("objectId", equalTo:(self.idLookup!))
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object!.incrementKey("Dislikes")
                object!.saveInBackground()
            }
        }
        } else {
            //firebase
            let likeStr = self.idLookup
            let refReservations = FirebaseRef.databaseRoot.child("News").child(likeStr!).child("dislikes")
            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                var value = Int(self.dislikesLookup!)
                if value == nil {value = 0}
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }
        }
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
    }
    
    @objc func shareButton(_ sender: UIButton) {
        
        let image: UIImage = (self.selectedImage ?? nil)!
        
        let activityViewController = UIActivityViewController (activityItems: [(image), self.titleLookup!], applicationActivities: nil)
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = sender
            activityViewController.popoverPresentationController?.permittedArrowDirections = .any
        }
        self.present(activityViewController, animated: true)
    }
    
    

    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            return self._feedItems.count + 1
        } else {
            return self.newslist.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell = UITableViewCell()
        switch indexPath.row {
        case 0:

            let cell = tableView.dequeueReusableCell(withIdentifier: "Header") as! headerCell

            cell.selectionStyle = .none
            cell.title.text = self.titleLookup ?? "Big Buck Bunny"
            cell.viewCount.text = self.viewLookup ?? "0 views"
            cell.likes.text = self.likesLookup ?? "0"
            cell.disLikes.text = self.dislikesLookup ?? "0"
            cell.channelSubscribers.text = String(format: "%@ %@", "\(String(describing: subscribeNumber!))", " subscribers")
            
            cell.commentBtn.tag = indexPath.row
            cell.commentBtn .addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
            cell.shareView.tag = indexPath.row
            cell.shareView .addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
            cell.thumbUp.tag = indexPath.row
            cell.thumbUp .addTarget(self, action: #selector(setthumbUp), for: .touchUpInside)
            
            cell.thumbDown.tag = indexPath.row
            cell.thumbDown .addTarget(self, action: #selector(setthumbDown), for: .touchUpInside)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query:PFQuery = PFUser.query()!
                query.whereKey("username",  equalTo: self.imageLookup ?? PFUser.current()?.username as Any)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                            imageFile.getDataInBackground { imageData, error in
                                
                                UIView.transition(with: (cell.channelPic), duration: 0.5, options: .transitionCrossDissolve, animations: {
                                    self.selectedChannelPic = UIImage(data: imageData! as Data)
                                }, completion: nil)
                            }
                        }
                    }
                }
                cell.channelTitle.text = self.imageLookup ?? PFUser.current()?.username
            } else {
                //firebase
                let uid = Auth.auth().currentUser?.uid
                FirebaseRef.databaseRoot.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let value = snapshot.value as? [String: Any] else { return }
                    cell.channelTitle.text = value["username"] as? String ?? ""
                    let profileImageUrl = value["profileImageUrl"] as? String ?? ""
                    cell.channelPic.loadImage(urlString: profileImageUrl)
                    self.selectedChannelPic = cell.channelPic.image
                    
                }) { (err) in
                    print("Failed to fetch user:", err)
                }
            }
            cell.channelPic.image = self.selectedChannelPic

            returnCell = cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! videoCell
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                // fix added - 1 to (indexPath).row - 1
                cell.title.text = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsTitle") as? String
                
                var newsView:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsView")as? Int
                if newsView == nil { newsView = 0 }
                
                let NewText = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsDetail") as? String
                cell.name.text =  String(format: "%@%@", "\(NewText!)", " \(newsView!) views")
                
                imageObject = _feedItems.object(at: ((indexPath as NSIndexPath).row) - 1) as? PFObject
                imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
                imageFile.getDataInBackground { imageData, error in
                    UIView.transition(with: cell.tumbnail, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        cell.tumbnail.image = UIImage(data: imageData!)
                    }, completion: nil)
                }
            } else {
                //firebase
                cell.title.text = newslist[(indexPath.row - 1)].newsTitle
                
                var newsView:Int? = newslist[(indexPath.row - 1)].viewCount as? Int
                if newsView == nil { newsView = 0 }
                let NewText = newslist[(indexPath.row - 1)].newsDetail
                cell.name.text =  String(format: "%@%@", "\(NewText)", " \(newsView!) views")
                
                let newsImageUrl = self.newslist[(indexPath.row - 1)].imageUrl
                cell.tumbnail.loadImage(urlString: newsImageUrl)
            }
            self.selectedImage = cell.tumbnail.image //fix firebase actionView wrong image
            
            returnCell = cell
        }
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        switch indexPath.row {
        case 0:
            height = 180
        default:
            height = 90
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            // fix added - 1 to (indexPath).row - 1
            self.idLookup = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "objectId") as? String
            
            self.titleLookup = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsTitle") as? String
            
            var newsView:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsView")as? Int
            if newsView == nil { newsView = 0 }
            self.viewLookup = "\(newsView!) views"
            
            var Liked:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "Liked")as? Int
            if Liked == nil { Liked = 0 }
            self.likesLookup = "\(Liked!)"
            
            var Disliked:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "Dislikes")as? Int
            if Disliked == nil { Disliked = 0 }
            self.dislikesLookup = "\(Disliked!)"
            
            self.imageLookup = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "username") as? String
            
            imageObject = _feedItems.object(at: indexPath.row - 1) as? PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFileObject
            imageFile.getDataInBackground { imageData, error in
                let imageDetailurl = self.imageFile.url
                let result1 = imageDetailurl!.contains("movie.mp4")
                if (result1 == true) {
                    self.playVideo(videoURL: self.imageFile.url!)
                }
            }
        } else {
            //firebase
            self.idLookup = self.newslist[(indexPath.row - 1)].newsId
            self.uidLookup = self.newslist[(indexPath.row - 1)].uid
            self.titleLookup = self.newslist[(indexPath.row - 1)].newsTitle 
            
            var newsView:Int? = self.newslist[(indexPath.row - 1)].viewCount as? Int
            if newsView == nil { newsView = 0 }
            self.viewLookup = "\(newsView!) views"
            
            var Liked:Int? = self.newslist[(indexPath.row - 1)].liked as? Int
            if Liked == nil { Liked = 0 }
            self.likesLookup = "\(Liked!)"
            
            var Disliked:Int? = self.newslist[(indexPath.row - 1)].dislikes as? Int
            if Disliked == nil { Disliked = 0 }
            self.dislikesLookup = "\(Disliked!)"
            
            let imageDetailurl = self.newslist[(indexPath.row - 1)].videoUrl
            if !(imageDetailurl == "") {
                self.playVideo(videoURL: imageDetailurl!)
            }
        }
        setupViewCounter(tableView)
        scrollToFirstRow()
        getNumberSubscribed()
    }
    
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    //MARK: - Fetch Data
    
    private func fetchPlayVCVideos() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query = PFQuery(className:"Newsios")
            //query.whereKey("imageFile", equalTo:"movie.mp4")
            query.cachePolicy = .cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("ErrorVideo")
                }
            }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("News")
                .queryOrdered(byChild: "videoUrl")
                .queryStarting(atValue: "!")
                .queryEnding(atValue: "~")
                .observe(.childAdded , with:{ (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let newsTxt = NewsModel(dictionary: dictionary)
                    self.newslist.append(newsTxt)
                    
                    self.newslist.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
        }
    }
    
    func setupViewCounter(_ sender: UITableView) {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            //update View Count
            let query = PFQuery(className:"Newsios")
            query.whereKey("objectId", equalTo:(self.idLookup!))
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    object!.incrementKey("newsView")
                    object!.saveInBackground()
                }
            }
        } else {
            //firebase
            let likeStr = self.idLookup
            let refReservations = FirebaseRef.databaseRoot.child("News").child(likeStr!).child("viewCount")
            refReservations.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                var value = currentData.value as? Int
                if value == nil {
                    value = 0
                }
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }
        }
    }
    
    func getNumberSubscribed() {
        
        if (defaults.bool(forKey: "parsedataKey"))  {
            
            
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Subscribed")
                .child(self.uidLookup!).observeSingleEvent(of: .value, with: { (snapshot) in
                self.subscribeNumber = Int(snapshot.childrenCount)
                    DispatchQueue.main.async(execute: {
                        self.tableView?.reloadData()
                    })
            }) { (err) in
                print("Failed to fetch following user ids ", err)
            }
        }
    }
    
    // MARK:  Subscribed
    /*
    @objc func subscribedButton(_ sender: UIButton) {
        
        if (sender.titleLabel!.text == " UNSUBSCRIBE")   {
            sender.setTitle(" SUBSCRIBE", for: .normal)
            sender.setTitleColor(Color.youtubeRed, for: .normal)
            sender.tintColor = Color.youtubeRed
            sender.setImage(#imageLiteral(resourceName: "iosStar").withRenderingMode(.alwaysTemplate), for: .normal)
            sender.addTarget(self, action: #selector(subscribedBtn), for: .touchUpInside)
        } else {
            sender.setTitle(" UNSUBSCRIBE", for: .normal)
            sender.setTitleColor(Color.DGrayColor, for: .normal)
            sender.tintColor = Color.DGrayColor
            sender.setImage(#imageLiteral(resourceName: "iosStarNA").withRenderingMode(.alwaysTemplate), for: .normal)
            sender.addTarget(self, action: #selector(subscribedBtn), for: .touchUpInside)
        }
    } */
    
    
    
    @objc func subscribedBtn(_ sender: UIButton) {
        
        if (defaults.bool(forKey: "parsedataKey"))  {
            
            let query = PFObject(className:"User")
            query.add([(PFUser.current()?.objectId)!], forKey:"Subscribed")
            query.saveInBackground {(success: Bool, error: Error?) in
                if success == true {
                    print("Subscribed Yes")
                } else {
                    print("Subscribed No")
                }
            }
        } else {
            //firebase
            
            guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
            guard let userId = uidLookup else {return}
            
            if (sender.titleLabel!.text == " SUBSCRIBE"){
                    FirebaseRef.databaseRoot.child("Subscribed").child(currentLoggedInUserId)
                
                guard let userId = uidLookup else {return}
                
                let values = [userId: 1]
                FirebaseRef.databaseRoot.updateChildValues(values) { (err, ref) in
                    if let err = err {
                        print("Failed to follw user:", err)
                        return
                    }
                    print("Succesfully followed user: ", self.user?.username ?? "")
                }
            } else if (sender.titleLabel!.text == " UNSUBSCRIBE"){
                
                FirebaseRef.databaseRoot
                    .child("Subscribed").child(currentLoggedInUserId)
                    .child(userId).removeValue(completionBlock: { (err, ref) in
                        if let err = err {
                            print("Failed to unfollow user:", err)
                            return
                        }
                        print("Succesfully unfollowed user: ",self.user?.username ?? "")
                    })
            }
        }
        let FeedbackGenerator = UINotificationFeedbackGenerator()
        FeedbackGenerator.notificationOccurred(.success)
    }
}

class headerCell: UITableViewCell {
    
    var defaults = UserDefaults.standard
    
    var news: NewsModel? {
        didSet {
            
            setupEditFollowButton()
        }
    }
    
    private func setupEditFollowButton() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        let userId = "Y4kfBJnneOMOYJLyDqGOfyrlYyQ2" //fix
        //guard let userId = uidLookup else {return}
        
        if currentLoggedInUserId == userId {
            //self.editProfileFollowButton.isHidden = true
        } else {
            //self.editProfileFollowButton.isHidden = false
            FirebaseRef.databaseRoot.child("Subscribed").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.setupUnsubscribedStyle()
                } else {
                    self.setupsubscribedStyle()
                }
                
            }, withCancel: { (err) in
                print("Failed to check if following:", err)
            })
        }
    }
    
    //firebase
    
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    let viewCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = ""
        //label.textColor = .lightGray
        return label
    }()
    
    let commentBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let thumbUp: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let likes: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = ""
        return label
    }()
    
    let thumbDown: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let disLikes: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = ""
        return label
    }()
    
    let shareView: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let shareTxt: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Share"
        return label
    }()
    
    let channelPic: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "")
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let channelTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    lazy var sv: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let channelSubscribers: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = Font.celltitle14r
        return label
    }()
    
    lazy var subscribed: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Color.youtubeRed
        button.isUserInteractionEnabled = true
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        //button.setImage(#imageLiteral(resourceName: "iosStar").withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle(" SUBSCRIBE", for: .normal)
        button.setTitleColor(Color.youtubeRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.addTarget(self, action: #selector(subscribedBtn), for: .touchUpInside)
        return button
    }()
    
    func setupsubscribedStyle() {
        subscribed.setTitle(" SUBSCRIBE", for: .normal)
        subscribed.setTitleColor(Color.youtubeRed, for: .normal)
        subscribed.tintColor = Color.youtubeRed
        subscribed.setImage(UIImage(systemName: "star.fill"), for: .normal)
        //subscribed.setImage(#imageLiteral(resourceName: "iosStar").withRenderingMode(.alwaysTemplate), for: .normal)
        //sender.addTarget(self, action: #selector(subscribedBtn), for: .touchUpInside)
    }
    
    func setupUnsubscribedStyle() {
        subscribed.setTitle(" UNSUBSCRIBE", for: .normal)
        subscribed.setTitleColor(Color.DGrayColor, for: .normal)
        subscribed.tintColor = .systemGray
        subscribed.setImage(UIImage(systemName: "star.fill"), for: .normal)
        //subscribed.setImage(#imageLiteral(resourceName: "iosStarNA").withRenderingMode(.alwaysTemplate), for: .normal)
        //sender.addTarget(self, action: #selector(subscribedBtn), for: .touchUpInside)
    }
    
    func setupViews() {
        
        addSubview(title)
        addSubview(commentBtn)
        addSubview(viewCount)
        addSubview(thumbUp)
        addSubview(thumbDown)
        addSubview(shareView)
        addSubview(likes)
        addSubview(disLikes)
        addSubview(shareTxt)
        addSubview(sv)
        addSubview(channelPic)
        addSubview(channelTitle)
        addSubview(channelSubscribers)
        addSubview(subscribed)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            commentBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            commentBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            commentBtn.widthAnchor.constraint(equalToConstant: 12),
            commentBtn.heightAnchor.constraint(equalToConstant: 6),
            
            viewCount.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            viewCount.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            viewCount.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            thumbUp.topAnchor.constraint(equalTo: viewCount.bottomAnchor, constant: 10),
            thumbUp.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            thumbUp.widthAnchor.constraint(equalToConstant: 25),
            thumbUp.heightAnchor.constraint(equalToConstant: 25),
            
            thumbDown.topAnchor.constraint(equalTo: viewCount.bottomAnchor, constant: 10),
            thumbDown.leftAnchor.constraint(equalTo: thumbUp.rightAnchor, constant: 50),
            thumbDown.widthAnchor.constraint(equalToConstant: 25),
            thumbDown.heightAnchor.constraint(equalToConstant: 25),
            
            shareView.topAnchor.constraint(equalTo: viewCount.bottomAnchor, constant: 10),
            shareView.leftAnchor.constraint(equalTo: thumbDown.rightAnchor, constant: 50),
            shareView.widthAnchor.constraint(equalToConstant: 25),
            shareView.heightAnchor.constraint(equalToConstant: 25),
            
            likes.topAnchor.constraint(equalTo: thumbUp.bottomAnchor, constant: 0),
            likes.centerXAnchor.constraint(equalTo: thumbUp.centerXAnchor),
            likes.heightAnchor.constraint(equalToConstant: 21),
            
            disLikes.topAnchor.constraint(equalTo: thumbUp.bottomAnchor, constant: 0),
            disLikes.centerXAnchor.constraint(equalTo: thumbDown.centerXAnchor),
            disLikes.heightAnchor.constraint(equalToConstant: 21),
            
            shareTxt.topAnchor.constraint(equalTo: thumbUp.bottomAnchor, constant: 0),
            shareTxt.centerXAnchor.constraint(equalTo: shareView.centerXAnchor),
            shareTxt.heightAnchor.constraint(equalToConstant: 21),
            
            sv.topAnchor.constraint(equalTo: shareTxt.bottomAnchor, constant: 1),
            sv.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            sv.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            sv.heightAnchor.constraint(equalToConstant: 1),
            
            channelPic.topAnchor.constraint(equalTo: likes.topAnchor, constant: 30),
            channelPic.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            channelPic.widthAnchor.constraint(equalToConstant: 36),
            channelPic.heightAnchor.constraint(equalToConstant: 36),
            
            channelTitle.topAnchor.constraint(equalTo: channelPic.topAnchor, constant: 0),
            channelTitle.leftAnchor.constraint(equalTo: channelPic.rightAnchor, constant: 10),
            channelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            channelTitle.heightAnchor.constraint(equalToConstant: 21),
            
            channelSubscribers.topAnchor.constraint(equalTo: channelTitle.bottomAnchor, constant: 2),
            channelSubscribers.leftAnchor.constraint(equalTo: channelTitle.leftAnchor, constant: 0),
            channelSubscribers.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            channelSubscribers.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
            subscribed.topAnchor.constraint(equalTo: channelPic.topAnchor, constant: 10),
            subscribed.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            subscribed.heightAnchor.constraint(equalToConstant: 20)
            ])
    }
    
    //MARK: Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
}

class videoCell: UITableViewCell {
    
    let tumbnail: CustomImageView = {
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.numberOfLines = 3
        return label
    }()
    
    let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = ""
        label.textColor = .systemGray
        return label
    }()
    
    func setupViews() {
        
        addSubview(tumbnail)
        addSubview(title)
        addSubview(name)
        
        NSLayoutConstraint.activate([
            tumbnail.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            tumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            tumbnail.heightAnchor.constraint(equalTo: tumbnail.widthAnchor, multiplier: 9.0/16.0),
            tumbnail.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            title.leftAnchor.constraint(equalTo: tumbnail.rightAnchor, constant: 22),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            
            name.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            name.leftAnchor.constraint(equalTo: tumbnail.rightAnchor, constant: 22),
            name.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
            ])
    }
    
    //MARK: Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
}


