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

    private var defaults = UserDefaults.standard
    public var SnapshotBool = false //hide leftBarButtonItems
    
    public var image: UIImage?
    public var objectId: String?
    public var storageID: String?
    public var newsTitle: String?
    public var newsDetail: String?
    //var viewCount: String?
    public var newsStory: String?
    public var newsDate: Date?
    public var imageUrl: String?
    //firebase
    public var videoURL: String?

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.sizeToFit()
        return label
    }()

//    lazy var viewCount: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = .secondaryLabel
//        label.sizeToFit()
//        return label
//    }()

    private let newsTextview: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .label
        textView.textContainerInset = .init(top: 0, left: -4, bottom: 0, right: 0)
        textView.backgroundColor = .clear
        textView.autocorrectionType = .yes
        textView.dataDetectorTypes = .all
        return textView
    }()

    private let faceLabel: UILabel = {
        let label = UILabel()
        label.text = "---"
        label.font = Font.celltitle14r
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("News Detail", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let playButton: UIButton = {
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
            newsImageview.image = nil //removes image
            faceLabel.isHidden = true
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
        view.backgroundColor = .systemBackground

        setupNavigation()
        setupForm()
        setupImageView()
        setupFonts()
        setupTextView()
        findFace()  // FIXME:
        setupScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        // FIXME: TextView Scroll first line
        newsTextview.isScrollEnabled = false
        setupNewsNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // FIXME: TextView Scroll first line
        newsTextview.isScrollEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        
        navigationItem.largeTitleDisplayMode = .never
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editData))
        let backItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(setbackButton))
        navigationItem.rightBarButtonItems = [editItem]
        
        if SnapshotBool == false {
            navigationItem.leftBarButtonItems = [backItem]
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        navigationItem.titleView = self.titleButton
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return newsImageview
    }

    func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.zoomScale = 1.0
    }
    
    func setupImageView() {
        
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

        titleLabel.text = newsTitle
        let date1 = newsDate ?? Date()
        MasterViewController.dateFormatter.dateFormat = "h:mm a"
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date1 as Date)
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            MasterViewController.dateFormatter.dateFormat = "MMM dd, yyyy"
        } else if elapsedTimeInSeconds > secondInDays {
            MasterViewController.dateFormatter.dateFormat = "EEEE"
        }
        
        let dateString = MasterViewController.dateFormatter.string(from: date1)
        detailLabel.text = String(format: "%@ %@ %@", "\(String(describing: self.newsDetail!))", "Uploaded", "\(dateString)")
    }
    
    func setupFonts() {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            titleLabel.font = Font.celltitle26r
            detailLabel.font = Font.celltitle18r
            newsTextview.isEditable = true // FIXME: shouldn't crash
            newsTextview.font = Font.celltitle18l
        } else {
            titleLabel.font = Font.celltitle20r
            detailLabel.font = Font.celltitle16r
            newsTextview.isEditable = true // FIXME: shouldn't crash
            newsTextview.font = Font.News.newssource
        }
    }
    
    func setupTextView() {
        
        newsTextview.text = self.newsStory
        newsTextview.delegate = self
        // Make web links clickable
        newsTextview.isSelectable = true
        newsTextview.isEditable = false
        newsTextview.dataDetectorTypes = .link
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.addSubview(scrollView)
        scrollView.addSubview(newsImageview)
        view.addSubview(contentView)
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(newsTextview)
        newsImageview.addSubview(faceLabel)
        newsImageview.addSubview(playButton)
        newsImageview.addSubview(activityIndicator)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([

            //newsImageview.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            //newsImageview.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            newsImageview.topAnchor.constraint(equalTo: guide.topAnchor),
            newsImageview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsImageview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //newsImageview.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newsImageview.heightAnchor.constraint(equalTo: newsImageview.widthAnchor, multiplier: 9/16),

            contentView.topAnchor.constraint(equalTo: newsImageview.bottomAnchor, constant: 0),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 25),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            detailLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            detailLabel.heightAnchor.constraint(equalToConstant: 25),

            newsTextview.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 10),
            newsTextview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newsTextview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newsTextview.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20),

            playButton.centerXAnchor.constraint(equalTo: newsImageview.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: newsImageview.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            faceLabel.topAnchor.constraint(equalTo: newsImageview.topAnchor, constant: 7),
            faceLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
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
        
//        guard let faceImage = CIImage(image: self.newsImageview.image!) else { return }
//        
//        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
//        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
//        let faces = faceDetector?.features(in: faceImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink: true])
//        
//        for face in faces as! [CIFaceFeature] {
//            
//            if face.hasSmile {
//                print("😁")
//            }
//            
//            if face.leftEyeClosed {
//                print("Left: 😉")
//            }
//            
//            if face.rightEyeClosed {
//                print("Right: 😉")
//            }
//        }
//        
//        if faces!.count != 0 {
//            self.faceLabel.text = "Faces: \(faces!.count)"
//        } else {
//            self.faceLabel.text = "No Faces 😢"
//        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "uploadSegue"
        {
            guard let VC = segue.destination as? UploadController else { return }
            
            VC.formState = "Update"
            VC.objectId = self.objectId
            VC.storageID = self.storageID
            VC.newsImage = self.newsImageview.image
            VC.newstitle = self.titleLabel.text
            VC.newsdetail = self.newsDetail
            VC.newsStory = self.newsStory
            VC.imageDetailurl = self.imageUrl
            VC.videoDetailurl = self.videoURL
        }
    }
}

