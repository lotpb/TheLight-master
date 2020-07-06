//
//  UserProfilePhotoCell.swift
//  Firegram
//
//  Created by Nithin Reddy Gaddam on 4/29/17.
//  Copyright © 2017 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import SDWebImage


@available(iOS 13.0, *)
final class MeProfileGridCell: UICollectionViewCell {
    
    var post: NewsModel? {
        didSet {

            let imageUrlString = post?.imageUrl
            guard let imageUrl:URL = URL(string: imageUrlString!) else { return }
            DispatchQueue.main.async {
                self.photoImageView.sd_setImage(with: imageUrl, completed: nil)
            }
            self.playButton.isHidden = post?.videoUrl == ""
        }
    }
    
    private var MeProfileController: MeProfileVC?
    
    public let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        //iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return iv
    }()
    
    public let playButton: UIButton = {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
