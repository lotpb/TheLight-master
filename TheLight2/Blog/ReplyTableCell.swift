//
//  ReplyTableCell.swift
//  
//
//  Created by Peter Balsamo on 5/23/17.
//
//

import UIKit
import FirebaseDatabase

@available(iOS 13.0, *)
final class ReplyTableCell: UITableViewCell {
    
    var postReply: BlogModel? {
        didSet {
            FirebaseRef.databaseRoot.child("users")
                .queryOrdered(byChild: "uid")
                .queryEqual(toValue: postReply?.uid)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let userDict = userSnap.value as! [String: Any]
                        let newsImageUrl = userDict["profileImageUrl"] as? String
                        self.replyImageView.loadImage(urlString: newsImageUrl!)
                    }
                })

            replytitleLabel.text = postReply?.postBy
            replysubtitleLabel.text = postReply?.subject
            replydateLabel.text = postReply?.creationDate.timeAgoDisplay()
            
            var Liked:Int? = postReply?.liked as? Int
            if Liked == nil { Liked = 0 }
            replylikeLabel.text = "\(Liked!)"
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let replyImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "")
        imageView.layer.cornerRadius = imageView.width/2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    public let replytitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    public let replysubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .lightGray
        label.numberOfLines = 4
        return label
    }()
    
    public let replydateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Uploaded by:"
        return label
    }()
    
    public let replylikeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        return button
    }()
    
    public let replyactionBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
    public let replylikeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10"
        label.textColor = .systemBlue
        return label
    }()
    
    private func setupViews() {
        
        addSubview(replyImageView)
        addSubview(replytitleLabel)
        addSubview(replyactionBtn)
        addSubview(replysubtitleLabel)
        addSubview(replydateLabel)
        addSubview(replylikeBtn)
        addSubview(replylikeLabel)
        
        NSLayoutConstraint.activate([
            replyImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            replyImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            replyImageView.widthAnchor.constraint(equalToConstant: 44),
            replyImageView.heightAnchor.constraint(equalToConstant: 44),
            
            replytitleLabel.topAnchor.constraint(equalTo: replyImageView.topAnchor, constant: 0),
            replytitleLabel.leftAnchor.constraint(equalTo: replyImageView.rightAnchor, constant: 10),
            replytitleLabel.heightAnchor.constraint(equalToConstant: 21),
            
            replyactionBtn.topAnchor.constraint(equalTo: replyImageView.topAnchor, constant: 2),
            replyactionBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            replyactionBtn.widthAnchor.constraint(equalToConstant: 20),
            replyactionBtn.heightAnchor.constraint(equalToConstant: 20),
            
            replysubtitleLabel.topAnchor.constraint(equalTo: replytitleLabel.bottomAnchor, constant: 0),
            replysubtitleLabel.leftAnchor.constraint(equalTo: replyImageView.rightAnchor, constant: 10),
            replysubtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            replydateLabel.topAnchor.constraint(equalTo: replysubtitleLabel.bottomAnchor, constant: 0),
            replydateLabel.leftAnchor.constraint(equalTo: replyImageView.rightAnchor, constant: 10),
            replydateLabel.heightAnchor.constraint(equalToConstant: 20),
            
            replylikeBtn.topAnchor.constraint(equalTo: replysubtitleLabel.bottomAnchor, constant: 0),
            replylikeBtn.leftAnchor.constraint(equalTo: replydateLabel.rightAnchor, constant: 6),
            replylikeBtn.widthAnchor.constraint(equalToConstant: 20),
            replylikeBtn.heightAnchor.constraint(equalToConstant: 20),
            
            replylikeLabel.topAnchor.constraint(equalTo: replysubtitleLabel.bottomAnchor, constant: 0),
            replylikeLabel.leftAnchor.constraint(equalTo: replylikeBtn.rightAnchor, constant: 2),
            replylikeLabel.widthAnchor.constraint(equalToConstant: 20),
            replylikeLabel.heightAnchor.constraint(equalToConstant: 20),
            replylikeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            ])
    }
}
