//
//  UserProfilePhotoCell.swift
//  Firegram
//
//  Created by Nithin Reddy Gaddam on 4/29/17.
//  Copyright © 2017 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class UserProfileGridCell: UICollectionViewCell {
    
    var post: NewsModel? {
        didSet {
            guard let imageUrl = post?.imageUrl else {return}
            photoImageView.loadImage(urlString: imageUrl)
            self.playButton.isHidden = post?.videoUrl == ""
        }
    }
    
    var userProfileController: UserProfileVC?
    
    lazy var photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        //iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return iv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        button.tintColor = .white //lightGray
        button.setImage(#imageLiteral(resourceName: "Camcorder"), for: .normal)
        //let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
        //button.addGestureRecognizer(tap)
        return button
    }()
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.addSubview(playButton)
        
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: photoImageView.topAnchor, constant: 0),
            playButton.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -5),
            playButton.widthAnchor.constraint(equalToConstant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 30)
            ])
    }
    /*
    @objc private func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        print("Grid crap")
        guard let imageView = tapGesture.view as? UIImageView else { return }
        // PRO tip: don't perform a lot of custom logic inside of a view class
        self.userProfileController?.performZoomInForStartingImageView(startingImageView: imageView)
    } */
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
