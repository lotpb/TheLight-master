//
//  UserProfilePhotoCell.swift
//  Firegram
//
//  Created by Nithin Reddy Gaddam on 4/29/17.
//  Copyright © 2017 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
final class UserViewCell: UICollectionViewCell {
    
    var user: UserModel? {
        didSet {

            guard let profileImageUrl = user?.profileImageUrl else {return}
            customImageView.loadImage(urlString: profileImageUrl)
            usertitleLabel.text = user?.username
        }
    }
    
    let customImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usertitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemBackground
        label.textColor = .label
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let loadingSpinner: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    func setupViews() {
        addSubview(customImageView)
        addSubview(usertitleLabel)
        addSubview(loadingSpinner)
        
        NSLayoutConstraint.activate([
            customImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            customImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            customImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            customImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -13),
            
            usertitleLabel.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 0),
            usertitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            usertitleLabel.widthAnchor.constraint(equalTo: customImageView.widthAnchor),
            usertitleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            loadingSpinner.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            loadingSpinner.widthAnchor.constraint(equalToConstant: 20),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 20)
            ])
    }

    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
}
