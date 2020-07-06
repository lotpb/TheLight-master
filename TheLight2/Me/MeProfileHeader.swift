//
//  UserProfileHeader.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/19/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Parse

protocol MeProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

@available(iOS 13.0, *)
final class MeProfileHeader: UICollectionViewCell {
    
    public var delegate: MeProfileHeaderDelegate?
    private var defaults = UserDefaults.standard
    
    var user: UserModel? {
        didSet {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                //fetchUserImage
                let query:PFQuery = PFUser.query()!
                query.whereKey("username",  equalTo: PFUser.current()?.username ?? "")
                query.limit = 1
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                            imageFile.getDataInBackground { imageData, error in
                                self.profileImageView.image = UIImage(data: imageData!)
                                self.usernameLabel.text = PFUser.current()!.username
                            }
                        }
                    }
                }
            } else {
                guard let profileImageUrl = user?.profileImageUrl else { return }
                profileImageView.loadImage(urlString: profileImageUrl)
                usernameLabel.text = self.user?.username
            }
        }
    }

    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let postLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle.grid.3x3.fill"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToGridView() {
        gridButton.tintColor = ColorX.twitterBlue
        listButton.tintColor = .systemGray //UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = .systemGray //UIColor(white:0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToListView() {
        listButton.tintColor = ColorX.twitterBlue
        gridButton.tintColor = .systemGray //UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .systemGray //UIColor(white:0, alpha: 0.2)
        //button.addTarget(self, action: #selector(settingButton), for: .touchUpInside)
        return button
    }()
    
    //lazy var because the title is being changed
    lazy var editProfileBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    let settingBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .label
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(MeProfileVC.settingButton), for: .touchUpInside)
        return button
    }()

    func updateValues(posts: Int, follower: Int, following: Int){
        
        self.postLabel.attributedText = updateAttributeText(value: posts, name: "posts")
        self.followersLabel.attributedText = updateAttributeText(value: follower, name: "followers")
        self.followingLabel.attributedText = updateAttributeText(value: following, name: "following")
    }
    
    func updateAttributeText(value: Int, name: String) -> NSAttributedString{
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
        attributedText.append(NSAttributedString(string: name, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        return attributedText
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
 
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = profileImageView.width/2
        profileImageView.clipsToBounds = true
        
        setupBottomToolbar() //dont move
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        setupUserStatsView() //dont move
        
        addSubview(settingBtn)
        
        NSLayoutConstraint.activate([
            settingBtn.topAnchor.constraint(equalTo: postLabel.bottomAnchor, constant: 4),
            settingBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            settingBtn.widthAnchor.constraint(equalToConstant: 32),
            settingBtn.heightAnchor.constraint(equalToConstant: 28)
            ])
        
        addSubview(editProfileBtn)
        editProfileBtn.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 40, width: 0, height: 28)
    }
    
    private func setupUserStatsView() {
        
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    private func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .systemGray
        
        let bottomDivivderView = UIView()
        bottomDivivderView.backgroundColor = .systemGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDivivderView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDivivderView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    // MARK: - Follow Button
    func setupEditFollowButton() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if currentLoggedInUserId == userId {
            self.editProfileBtn.isHidden = true
        } else {
            self.editProfileBtn.isHidden = false
            FirebaseRef.databaseRoot.child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.setupUnfollowStyle()
                } else {
                    self.setupFollowStyle()
                }
                
            }, withCancel: { (err) in
                print("Failed to check if following:", err)
            })
            
        }
        
        //editProfileBtn.setTitle("Follow", for: UIControlState.normal)
    }

    @objc func handleEditProfileFollow() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if (editProfileBtn.titleLabel?.text == "Follow"){

            let ref = FirebaseRef.databaseRoot.child("following").child(currentLoggedInUserId)
            
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follw user:", err)
                    return
                }
                self.setupUnfollowStyle()
                print("Succesfully followed user: ", self.user?.username ?? "")
            }
        } else if (editProfileBtn.titleLabel?.text == "Unfollow"){
            FirebaseRef.databaseRoot.child("following").child(currentLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                
                print("Succesfully unfollowed user: ",self.user?.username ?? "")
                self.setupFollowStyle()
            })
        }
    }
    
    private func setupFollowStyle() {
        self.editProfileBtn.setTitle("Follow", for: .normal)
        self.editProfileBtn.backgroundColor = UIColor.rgb(red: 27, green: 154, blue: 237)
        self.editProfileBtn.setTitleColor(.white, for: .normal)
        self.editProfileBtn.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    private func setupUnfollowStyle() {
        self.editProfileBtn.setTitle("Unfollow", for: .normal)
        self.editProfileBtn.backgroundColor = .white
        self.editProfileBtn.setTitleColor(.black, for: .normal)
        self.editProfileBtn.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
}
