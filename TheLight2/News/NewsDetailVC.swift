//
//  NewsDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import AVFoundation

@available(iOS 13.0, *)
final class NewsDetailVC: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UISplitViewControllerDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var newsTextview: UITextView!
    
    var defaults = UserDefaults.standard
    var SnapshotBool = false //hide leftBarButtonItems
    
    var image: UIImage?
    var objectId: String?
    var newsTitle: String?
    var newsDetail: String?
    var newsStory: String?
    var newsDate: Date?
    var imageUrl: String?
    //firebase
    var videoURL: String?
    
    let faceLabel: UILabel = {
        let label = UILabel()
        label.text = "---"
        label.font = Font.celltitle14r
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let newsImageview: CustomImageView = {
        let imageView = CustomImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill // .scaleAspectFill //.scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("News Detail", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        button.tintColor = .white
        button.setImage(UIImage(systemName: "play.circle"), for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
        button.addGestureRecognizer(tap)
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func playVideo(sender: UITapGestureRecognizer) {
        let button = sender.view as? UIButton
        if let videoURL = button!.titleLabel!.text {
            self.newsImageview.image = nil //removes image
            self.faceLabel.isHidden = true
            let URL = NSURL(string: videoURL)
            player = AVPlayer(url: URL! as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = (newsImageview.bounds)
            newsImageview.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicator.startAnimating()
            playButton.isHidden = true
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTextview.backgroundColor = .clear
        setupNavigation()
        setupConstraints()
        setupForm()
        setupImageView()
        setupFonts()
        setupTextView()
        findFace()  //fix
        //setupViewCounter() set up in FeedCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        //fix TextView Scroll first line
        self.newsTextview.isScrollEnabled = false
        setupNewsNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //fix TextView Scroll first line
        self.newsTextview.isScrollEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        
        self.navigationItem.largeTitleDisplayMode = .never
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editData))
        let backItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(setbackButton))
        navigationItem.rightBarButtonItems = [editItem]
        
        if SnapshotBool == false {
            navigationItem.leftBarButtonItems = [backItem]
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        self.navigationItem.titleView = self.titleButton
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.newsImageview
    }
    
    func setupImageView() {
        
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        
        //self.scrollView.contentOffset = CGPoint(x: 500, y: 200)
        //self.scrollView.zoomScale = 1.0
        //self.scrollView.contentOffset = CGPoint(x: 1000, y: 450)
        //self.scrollView.contentSize = newsImageview.bounds.size
        //self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        UIView.transition(with: self.newsImageview, duration: 0.5, options: .transitionCrossDissolve, animations: {
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                self.newsImageview.image = self.image
                
                let imageDetailurl = self.imageUrl ?? ""
                let result1 = imageDetailurl.contains("movie.mp4")
                self.playButton.isHidden = result1 == false
                self.playButton.setTitle(imageDetailurl, for: .normal)

            } else {
                //firebase
                let newsImageUrl = self.imageUrl
                self.newsImageview.loadImage(urlString: newsImageUrl!)
                
                let imageDetailurl = self.videoURL
                self.playButton.isHidden = self.videoURL == ""
                self.playButton.setTitle(imageDetailurl, for: .normal)
                
            }
        }, completion: nil)
    }
    
    func setupForm() {

        contentView.backgroundColor = .systemBackground
        self.titleLabel.textColor = .label
        self.titleLabel.text = self.newsTitle
        self.titleLabel.numberOfLines = 2
        
        let date1 = self.newsDate ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date1 as Date)
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MMM dd, yyyy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEEE"
        }
        
        let dateString = dateFormatter.string(from: date1)
        self.detailLabel.text = String(format: "%@ %@ %@", "\(String(describing: self.newsDetail!))", "Uploaded", "\(dateString)")
        self.detailLabel.textColor = .secondaryLabel
        self.detailLabel.sizeToFit() 
    }
    
    func setupFonts() {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            self.titleLabel.font = Font.celltitle36r
            self.detailLabel.font = Font.celltitle20r
            self.newsTextview.isEditable = true //bug fix
            self.newsTextview.font = Font.celltitle26l
        } else {
            self.titleLabel.font = Font.celltitle20r
            self.detailLabel.font = Font.celltitle16r
            self.newsTextview.isEditable = true//bug fix
            self.newsTextview.font = Font.News.newssource
        }
    }
    
    func setupTextView() {
        
        self.newsTextview.text = self.newsStory
        self.newsTextview.textColor = .secondaryLabel
        self.newsTextview.delegate = self
        self.newsTextview.textContainerInset = .init(top: 0, left: -4, bottom: 0, right: 0)
        // Make web links clickable
        self.newsTextview.isSelectable = true
        self.newsTextview.isEditable = false
        self.newsTextview.dataDetectorTypes = .link
    }
    
    func setupConstraints() {
      //view.addSubview(newsImageview)
        scrollView.addSubview(newsImageview)
        newsImageview.addSubview(faceLabel)
        newsImageview.addSubview(playButton)
        newsImageview.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            newsImageview.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),
            newsImageview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            newsImageview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            newsImageview.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            newsImageview.heightAnchor.constraint(equalTo: newsImageview.widthAnchor, multiplier: 9/16),

            playButton.centerXAnchor.constraint(equalTo: newsImageview.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: newsImageview.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            faceLabel.topAnchor.constraint(equalTo: newsImageview.topAnchor, constant: 7),
            faceLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            faceLabel.heightAnchor.constraint(equalToConstant: 25),
            
            activityIndicator.centerXAnchor.constraint(equalTo: newsImageview.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: newsImageview.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    // MARK: - Button
    @objc func setbackButton() {
        dismiss(animated: true)
    }
    
    @objc func editData(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "uploadSegue", sender: self)
    }
    
    // MARK: - FaceDetector
    func findFace() {
        
        guard let faceImage = CIImage(image: self.newsImageview.image!) else { return }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: faceImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink: true])
        
        for face in faces as! [CIFaceFeature] {
            
            if face.hasSmile {
                print("😁")
            }
            
            if face.leftEyeClosed {
                print("Left: 😉")
            }
            
            if face.rightEyeClosed {
                print("Right: 😉")
            }
        }
        
        if faces!.count != 0 {
            self.faceLabel.text = "Faces: \(faces!.count)"
        } else {
            self.faceLabel.text = "No Faces 😢"
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "uploadSegue"
        {
            guard let photo = segue.destination as? UploadController else { return }
            
            photo.formState = "Update"
            photo.objectId = self.objectId
            photo.newsImage = self.newsImageview.image
            photo.newstitle = self.titleLabel.text
            photo.newsdetail = self.newsDetail
            photo.newsStory = self.newsStory
            photo.imageDetailurl = self.imageUrl
            photo.videoDetailurl = self.videoURL
        }
    }
}

