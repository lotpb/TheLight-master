//
//  CustomMenuHeaderView.swift
//  SlideOutMenu
//
//  Created by ivica petrsoric on 15/10/2018.
//  Copyright © 2018 ivica petrsoric. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CustomMenuHeaderView: UIView {
    
    let nameLabel = UILabel()
    let userNameLabel = UILabel()
    let statsLabel = UILabel()
    //let profileImageView = ProfileImageView()

    //firebase
    var users: UserModel?

    private lazy var profileImageView: CustomImageView = {
        let profileImageView = CustomImageView()
        profileImageView.image = UIImage(named: "profile-rabbit-toy")
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        return profileImageView
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemGroupedBackground
        nameLabel.textColor = .label
        userNameLabel.textColor = .label

        setupComponentProps()
        setupStackView()

        //let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo:topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo:leadingAnchor, constant: 25),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponentProps() {

        guard let uid = Auth.auth().currentUser?.uid else {return}
        FirebaseRef.databaseRoot.child("users")
            .queryOrdered(byChild: "uid")
            .queryEqual(toValue: uid)
            .observeSingleEvent(of: .value, with:{ (snapshot) in
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    let userDict = userSnap.value as! [String: Any]
                    let userImageUrl = userDict["profileImageUrl"] as? String
                    self.profileImageView.loadImage(urlString: userImageUrl!)
                }
            })

        nameLabel.text = "Peter"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        userNameLabel.text = "Balsamo"
        statsLabel.text = "42 Following 7091 Followers"
        
        setupStatsAttributedText()
    }
    
    private func setupStatsAttributedText() {
        statsLabel.font = UIFont.systemFont(ofSize: 14)
        let attributedText = NSMutableAttributedString(string: "42 ", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .medium)])
        attributedText.append(NSAttributedString(string: "Following  ", attributes: [.foregroundColor: UIColor.label]))
        attributedText.append(NSAttributedString(string: "7091 ", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)]))
        attributedText.append(NSAttributedString(string: "Followers", attributes: [.foregroundColor: UIColor.label]))
        
        statsLabel.attributedText = attributedText
    }
    
    private func setupStackView() {
        let arrangedSubviews = [
            UIStackView(arrangedSubviews: [profileImageView, UIView()]),
            nameLabel,
            userNameLabel,
            SpacerView(space: 16),
            statsLabel
        ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.spacing = 4
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 24, left: 24, bottom: 24, right: 24)
    }
    
}

