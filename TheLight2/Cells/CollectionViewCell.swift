//
//  CCollectionViewCell.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/17/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import MapKit


class CollectionViewCell: UICollectionViewCell {
    
    // News
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var profileView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var sourceLabel: UILabel?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var actionBtn: UIButton?
    @IBOutlet weak var numLabel: UILabel?
    @IBOutlet weak var uploadbyLabel: UILabel?
    
    // UserView Controller
    @IBOutlet weak var user2ImageView: CustomImageView?
    
    
    //-----------youtube/SnapshotController---------
    
    let snapImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill //.scaleAspectFill //.scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
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
    
    lazy var playBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CollectionViewCell.playVideo))
        button.addGestureRecognizer(tap)
        return button
    }()
    
    var playerLayer2: AVPlayerLayer?
    var player2: AVPlayer?
    
    @objc func playVideo(sender: UITapGestureRecognizer) {
        
        let button = sender.view as? UIButton
        if let videoURL = button!.titleLabel!.text {
            let URL = NSURL(string: videoURL)
            player2 = AVPlayer(url: URL! as URL)
            playerLayer2 = AVPlayerLayer(player: player2)
            playerLayer2?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer2?.frame = (snapImageView.bounds)
            snapImageView.layer.addSublayer(playerLayer2!)
            player2?.play()
            activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            playBtn.isHidden = true
            //videoCell.playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer2?.removeFromSuperlayer()
        player2?.pause()
        activityIndicator.stopAnimating()
        ///playBtn.isHidden = false //added
        //playButton.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        
        addSubview(snapImageView)
        snapImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
        snapImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),        snapImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),        snapImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),        snapImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -13),
        
        activityIndicator.centerXAnchor.constraint(equalTo: snapImageView.centerXAnchor),        activityIndicator.centerYAnchor.constraint(equalTo: snapImageView.centerYAnchor),        activityIndicator.widthAnchor.constraint(equalToConstant: 50),        activityIndicator.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}

class VideoCell: CollectionViewCell {
    
    var news: NewsModel? {
        didSet {

            FirebaseRef.databaseRoot.child("users")
                .queryOrdered(byChild: "uid")
                .queryEqual(toValue: news?.uid)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let userDict = userSnap.value as! [String: Any]
                        let profileImageUrl = userDict["profileImageUrl"] as? String
                        self.profileImageView.loadImage(urlString: profileImageUrl!)
                    }
                })
            
            guard let newsImageUrl = news?.imageUrl else {return}
            customImageView.loadImage(urlString: newsImageUrl)
            
            titleLabelnew.text = news?.newsTitle
            subtitleLabel.text = String(format: "%@, %@", (news?.newsDetail)!, "\(news?.viewCount ?? 0) views")
            uploadbylabel.text = String(format: "%@ %@", "Uploaded", (news?.creationDate.timeAgoDisplay())!)
            storyLabel.text = news?.storyLabel
            
            var Liked:Int? = news?.liked as? Int
            if Liked == nil { Liked = 0 }
            numberLabel.text = "\(Liked!)"
            
            let imageDetailurl = news?.videoUrl
            playButton.isHidden = news?.videoUrl == ""
            playButton.setTitle(imageDetailurl, for: .normal)
            videoLengthLabel.isHidden = news?.videoUrl == ""
        }
    }
    
    let customImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        if #available(iOS 13.0, *) {
            imageView.backgroundColor = .systemGray6
        } else {
            imageView.backgroundColor = .black
        }
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let titleLabelnew: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let storyLabel: UILabel = { //maybe for ipad
        let label = UILabel()
        label.text = "Comment by:"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10"
        label.textColor = .systemBlue
        return label
    }()
    
    let uploadbylabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Uploaded by:"
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "nav_more_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    let likeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    lazy var buttonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
        button.addGestureRecognizer(tap)
        return button
    }()
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc override func playVideo(sender: UITapGestureRecognizer) {
        let button = sender.view as? UIButton
        if let videoURL = button!.titleLabel!.text {
            self.customImageView.image = nil
            let URL = NSURL(string: videoURL)
            player = AVPlayer(url: URL! as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.frame = (customImageView.bounds)
            customImageView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicator.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicator.stopAnimating()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem.loadedTimeRanges" {
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupViews() {
        
        self.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        addSubview(customImageView)
        addSubview(profileImageView)
        addSubview(titleLabelnew)
        addSubview(subtitleLabel)
        addSubview(storyLabel)
        addSubview(buttonView)
        buttonView.addSubview(actionButton)
        buttonView.addSubview(likeBtn)
        buttonView.addSubview(numberLabel)
        buttonView.addSubview(uploadbylabel)
        addSubview(separatorView)
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            let width = 400
            let height = ((width) * 9 / 16) + 16
            
            NSLayoutConstraint.activate([
                customImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
                customImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
                customImageView.widthAnchor.constraint(equalToConstant: CGFloat(width)),
                customImageView.heightAnchor.constraint(equalToConstant: CGFloat(height)),
                
                titleLabelnew.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
                titleLabelnew.leftAnchor.constraint(equalTo: customImageView.rightAnchor, constant: 15),
                titleLabelnew.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                
                profileImageView.topAnchor.constraint(equalTo: titleLabelnew.bottomAnchor, constant: 5),
                profileImageView.leftAnchor.constraint(equalTo: customImageView.rightAnchor, constant: 15),
                profileImageView.widthAnchor.constraint(equalToConstant: 40),
                profileImageView.heightAnchor.constraint(equalToConstant: 40),
                
                subtitleLabel.topAnchor.constraint(equalTo: titleLabelnew.bottomAnchor, constant: 7),
                subtitleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10),
                subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                subtitleLabel.heightAnchor.constraint(equalToConstant: 20),
                
                storyLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 7),
                storyLabel.leftAnchor.constraint(equalTo: customImageView.rightAnchor, constant: 15),
                storyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                
                buttonView.topAnchor.constraint(equalTo: storyLabel.bottomAnchor, constant: 5),
                buttonView.leftAnchor.constraint(equalTo: customImageView.rightAnchor, constant: 15),
                buttonView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                buttonView.heightAnchor.constraint(equalToConstant: 30),
                
                likeBtn.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 3),
                likeBtn.leftAnchor.constraint(equalTo: subtitleLabel.leftAnchor, constant: 0),
                likeBtn.widthAnchor.constraint(equalToConstant: 20),
                likeBtn.heightAnchor.constraint(equalToConstant: 20),
                
                numberLabel.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 3),
                numberLabel.leftAnchor.constraint(equalTo: likeBtn.rightAnchor, constant: 2),
                numberLabel.widthAnchor.constraint(equalToConstant: 20),
                numberLabel.heightAnchor.constraint(equalToConstant: 20),
                
                uploadbylabel.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 3),
                uploadbylabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 0),
                uploadbylabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                uploadbylabel.heightAnchor.constraint(equalToConstant: 20),
                
                actionButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 3),
                actionButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 15),
                actionButton.widthAnchor.constraint(equalToConstant: 20),
                actionButton.heightAnchor.constraint(equalToConstant: 20),
                
                separatorView.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 3),
                separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                separatorView.heightAnchor.constraint(equalToConstant: 1)
                ])
            
        } else {
            
            let height = ((self.frame.width) * 9 / 16) //+ 16
            NSLayoutConstraint.activate([
                customImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                customImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                customImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                customImageView.heightAnchor.constraint(equalToConstant: height),
                
                profileImageView.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 8),
                profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                profileImageView.widthAnchor.constraint(equalToConstant: 40),
                profileImageView.heightAnchor.constraint(equalToConstant: 40),
                
                titleLabelnew.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 7),
                titleLabelnew.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10),
                titleLabelnew.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                
                subtitleLabel.topAnchor.constraint(equalTo: titleLabelnew.bottomAnchor, constant: 1),
                subtitleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10),
                subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                subtitleLabel.heightAnchor.constraint(equalToConstant: 20),
                
                //fix view to make buttons work
                buttonView.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 0),
                buttonView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                buttonView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                buttonView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                
                actionButton.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 7),
                actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7),
                actionButton.widthAnchor.constraint(equalToConstant: 20),
                actionButton.heightAnchor.constraint(equalToConstant: 20),
                
                likeBtn.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 3),
                likeBtn.leftAnchor.constraint(equalTo: subtitleLabel.leftAnchor, constant: 0),
                likeBtn.widthAnchor.constraint(equalToConstant: 20),
                likeBtn.heightAnchor.constraint(equalToConstant: 20),
                
                numberLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 3),
                numberLabel.leftAnchor.constraint(equalTo: likeBtn.rightAnchor, constant: 2),
                numberLabel.widthAnchor.constraint(equalToConstant: 20),
                numberLabel.heightAnchor.constraint(equalToConstant: 20),
                
                uploadbylabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 3),
                uploadbylabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 0),
                uploadbylabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                uploadbylabel.heightAnchor.constraint(equalToConstant: 20),
                
                //separatorView.topAnchor.constraint(equalTo: likeBtn.bottomAnchor, constant: 3),
                separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                separatorView.heightAnchor.constraint(equalToConstant: 1)
                ])
        }
        
        customImageView.addSubview(playButton)
        customImageView.addSubview(videoLengthLabel)
        customImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            videoLengthLabel.rightAnchor.constraint(equalTo: customImageView.rightAnchor, constant: -8),
            videoLengthLabel.bottomAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: -2),
            videoLengthLabel.heightAnchor.constraint(equalToConstant: 30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50)
            ])
        
        snapImageView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: snapImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: snapImageView.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 30),
            activityIndicator.heightAnchor.constraint(equalToConstant: 30)
            ])
    }
}

