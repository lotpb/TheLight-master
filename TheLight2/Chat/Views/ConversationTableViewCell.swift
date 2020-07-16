//
//  ConversationTableViewCell.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/18/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.addSubview(userImageView)
        self.addSubview(userNameLabel)
        self.addSubview(userMessageLabel)

        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint( equalTo: self.leadingAnchor, constant: 10),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50),

            userNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            userNameLabel.leftAnchor.constraint( equalTo: userImageView.rightAnchor, constant: 10),
            userNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            userNameLabel.heightAnchor.constraint(equalToConstant: 22),

            userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 3),
            userMessageLabel.leftAnchor.constraint( equalTo: userNameLabel.leftAnchor, constant: 0),
            userMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            userNameLabel.heightAnchor.constraint(equalToConstant: 45),
            //userNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
        ])
    }

    public func configure(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
        userMessageLabel.textColor = .lightGray

        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):

                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }

            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }

}
