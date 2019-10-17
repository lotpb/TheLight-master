//
//  CategoryCell.swift
//  RecreatingAppStore
//
//  Created by Yu Sun on 26/10/17.
//  Copyright © 2017 Yu Sun. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Parse
import AVFoundation


@available(iOS 13.0, *)
class CategoryCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var defaults = UserDefaults.standard
    
    var newslist = [NewsModel]()
    var joblist = [JobModel]()
    var userlist = [UserModel]()
    var saleslist = [SalesModel]()
    var employlist = [EmployModel]()
    
    func loadData() {
        
        FirebaseRef.databaseRoot.child("News").observe(.childAdded , with:{ (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let newsTxt = NewsModel(dictionary: dictionary)
            self.newslist.append(newsTxt)
            
            DispatchQueue.main.async(execute: {
                self.appsCollectionView.reloadData()
            })
        })
        
        FirebaseRef.databaseRoot.child("users").observe(.childAdded , with:{ (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let post = UserModel(dictionary: dictionary)
            self.userlist.append(post)

            DispatchQueue.main.async(execute: {
                self.appsCollectionView.reloadData()
            })
        })
        
        FirebaseRef.databaseRoot.child("Job").observe(.childAdded , with:{ (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let employTxt = JobModel(dictionary: dictionary)
            self.joblist.append(employTxt)
            
            DispatchQueue.main.async(execute: {
                self.appsCollectionView.reloadData()
            })
        })
    }
    
    
    var appCategory: AppCategory? {
        didSet {
            
            if let name = appCategory?.name {
                nameLabel.text = name
                
            }
            
            appsCollectionView.reloadData()
        }
    }
    
    private let cellId = "cellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //----------------------------------------------------------
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Best New Apps"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white //added
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let appsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemOrange //UIColor.clear
        
        return collectionView
    }()
    
    func setupView() {
        loadData()
        
        backgroundColor = .systemRed //UIColor.clear
        
        addSubview(appsCollectionView)
        addSubview(dividerLineView)
        addSubview(nameLabel)
        
        appsCollectionView.delegate = self
        appsCollectionView.dataSource = self
        appsCollectionView.register(AppCell.self, forCellWithReuseIdentifier: cellId)
        
        NSLayoutConstraint.activate([
            appsCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            appsCollectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
            appsCollectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            appsCollectionView.bottomAnchor.constraint(equalTo: dividerLineView.topAnchor),
            dividerLineView.heightAnchor.constraint(equalToConstant: 1),
            dividerLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            dividerLineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 14),
            dividerLineView.rightAnchor.constraint(equalTo: self.rightAnchor),
            nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 14),
            nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 30)
            ])


    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return userlist.count
        case 1:
            return joblist.count
        case 2:
            return newslist.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppCell
        
        switch indexPath.section {
        case 0:
            cell.userpost = userlist[indexPath.item]
            break
        case 1:
            cell.jobpost = joblist[indexPath.item]
            break
        case 2:
            cell.news = newslist[indexPath.item]
            break
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 100, height: frame.height - 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 14, bottom: 0, right: 14)
    }
}
@available(iOS 13.0, *)
class AppCell: UICollectionViewCell {
    
    var news: NewsModel? {
        didSet {
            
            guard let newsImageUrl = news?.imageUrl else {return}
            imageView.loadImage(urlString: newsImageUrl)
            //nameLabel.text = "crap" //news?.newsTitle
        }
    }
    
    var userpost: UserModel? {
        didSet {
            
            guard let postImageUrl = userpost?.profileImageUrl else {return}
            imageView.loadImage(urlString: postImageUrl)
            //nameLabel.text = userpost?.username
        }
    }
    
    var jobpost: JobModel? {
        didSet {
            guard let jobImageUrl = jobpost?.imageUrl else {return}
            imageView.loadImage(urlString: jobImageUrl)
            //nameLabel.text = "crap1" //jobpost?.description
        }
    }
    
    var salespost: SalesModel? {
        didSet {
            guard let jobImageUrl = salespost?.imageUrl else {return}
            imageView.loadImage(urlString: jobImageUrl)
            //nameLabel.text = "crap1" //jobpost?.description
        }
    }
    
    var employpost: EmployModel? {
        didSet {
            guard let jobImageUrl = employpost?.imageUrl else {return}
            imageView.loadImage(urlString: jobImageUrl)
            //nameLabel.text = "crap1" //jobpost?.description
        }
    }
    
    
    var app: App? {
        didSet {
            if let name = app?.name {
                nameLabel.text = name
                
                let rect = NSString(string: name).boundingRect(with: CGSize(width: frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
                
                if rect.height > 20 {
                    categoryLabel.frame = .init(x: 0, y: frame.width + 38, width: frame.width, height: 20)
                    priceLabel.frame = .init(x: 0, y: frame.width + 56, width: frame.width, height: 20)
                } else {
                    categoryLabel.frame = .init(x: 0, y: frame.width + 22, width: frame.width, height: 20)
                    priceLabel.frame = .init(x: 0, y: frame.width + 40, width: frame.width, height: 20)
                }
                
                nameLabel.frame = .init(x: 0, y: frame.width + 5, width: frame.width, height: 40)
                nameLabel.sizeToFit()
            }
            
            if let category = app?.category {
                categoryLabel.text = category
            }
            
            if let price = app?.price {
                priceLabel.text = "$\(price)"
            } else {
                priceLabel.text = "free"
            }
            
            if let imageName = app?.imageName {
                imageView.image = UIImage(named: imageName)

            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .black
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
            self.imageView.image = nil
            let URL = NSURL(string: videoURL)
            player = AVPlayer(url: URL! as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.frame = (imageView.bounds)
            imageView.layer.addSublayer(playerLayer!)
            player?.play()
            //activityIndicator.startAnimating()
            playButton.isHidden = true
        }
    }
    
//-------------------------------------------------------------------------
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white //UIColor.darkGray
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white //UIColor.darkGray
        return label
    }()
    
    func setupView() {
        
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(categoryLabel)
        addSubview(priceLabel)
        
        imageView.frame = .init(x: 0, y: 0, width: frame.width, height: frame.width)
        nameLabel.frame = .init(x: 0, y: frame.width + 2, width: frame.width, height: 40)
        categoryLabel.frame = .init(x: 0, y: frame.width + 38, width: frame.width, height: 20)
        priceLabel.frame = .init(x: 0, y: frame.width + 56, width: frame.width, height: 20)
    }
}
