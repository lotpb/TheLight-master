//
//  UserProfileMapCell.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/23/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit
import FirebaseDatabase

@available(iOS 13.0, *)
final class UserProfileListCell: UICollectionViewCell {
    
    var post: NewsModel? {
        didSet{

            FirebaseRef.databaseRoot.child("users")
                .queryOrdered(byChild: "uid")
                .queryEqual(toValue: post?.uid)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let userDict = userSnap.value as! [String: Any]
                        self.titleLabelnew.text = userDict["username"] as? String
                        let profileImageUrl = userDict["profileImageUrl"] as? String
                        self.profileImageView.loadImage(urlString: profileImageUrl!)
                    }
                })

            guard let imageUrl = post?.imageUrl else {return}
            photoImageView.loadImage(urlString: imageUrl)
            
            self.playButton.isHidden = post?.videoUrl == ""

            uploadbylabel.text = String(format: "%@ %@", "Uploaded", (post?.creationDate.timeAgoDisplay())!)
            viewsLabel.text = String(format: "%@", "\(post?.viewCount ?? 0) views")
            viewsLabel.font = UIFont.boldSystemFont(ofSize: 16)
            
            var Liked:Int? = post?.liked as? Int
            if Liked == nil { Liked = 0 }
            numberLabel.text = "\(Liked!)"
        }
    }
    
    var userProfileController: UserProfileVC?
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .secondarySystemGroupedBackground
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        //iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        button.tintColor = .white //lightGray
        button.setImage(UIImage(systemName: "video.fill"), for: .normal)
        //let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
        //button.addGestureRecognizer(tap)
        return button
    }()
    
    let titleLabelnew: UILabel = {
        let label = UILabel()
        label.text = ""
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
    
    let likeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        return button
    }()
    
    let actionBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .black
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.addTarget(self, action: #selector(UserProfileVC.shareButton), for: .touchUpInside)
        return button
    }()
    
    let viewsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground //UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = .secondarySystemGroupedBackground
        addSubview(titleLabelnew)
        addSubview(profileImageView)
        addSubview(photoImageView)
        addSubview(buttonView)
        addSubview(viewsLabel)
        addSubview(actionBtn)
        buttonView.addSubview(likeBtn)
        buttonView.addSubview(numberLabel)
        buttonView.addSubview(uploadbylabel)
        
        let height = ((self.frame.width) * 9 / 16) //+ 16
        NSLayoutConstraint.activate([
            titleLabelnew.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            titleLabelnew.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 7),
            titleLabelnew.heightAnchor.constraint(equalToConstant: 30),
            
            actionBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            actionBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            actionBtn.widthAnchor.constraint(equalToConstant: 28),
            actionBtn.heightAnchor.constraint(equalToConstant: 28),
            
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            
            photoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 44),
            photoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            photoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            photoImageView.heightAnchor.constraint(equalToConstant: height),
            
            buttonView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 1),
            buttonView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            buttonView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            buttonView.heightAnchor.constraint(equalToConstant: 44),
            
            likeBtn.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 3),
            likeBtn.leftAnchor.constraint(equalTo: buttonView.leftAnchor, constant: 10),
            likeBtn.widthAnchor.constraint(equalToConstant: 32),
            likeBtn.heightAnchor.constraint(equalToConstant: 32),
            
            numberLabel.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 3),
            numberLabel.leftAnchor.constraint(equalTo: likeBtn.rightAnchor, constant: 2),
            numberLabel.widthAnchor.constraint(equalToConstant: 20),
            numberLabel.heightAnchor.constraint(equalToConstant: 30),
            
            uploadbylabel.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 3),
            uploadbylabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 0),
            uploadbylabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            uploadbylabel.heightAnchor.constraint(equalToConstant: 30),
            
            viewsLabel.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 3),
            viewsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            viewsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            viewsLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
    }
    /*
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        print("List crap")
        if let imageView = tapGesture.view as? UIImageView {
            // PRO tip: don't perform a lot of custom logic inside of a view class
            self.userProfileController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    } */
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 
