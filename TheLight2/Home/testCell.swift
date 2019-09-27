//
//  testCell.swift
//  TheLight2
//
//  Created by Peter Balsamo on 9/17/19.
//  Copyright © 2019 Peter Balsamo. All rights reserved.
//

import UIKit

class testCell: UITableViewCell {
    var videoImageView = UIImageView()
    var customImagelabel = UILabel()
    var prodtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(videoImageView)
        addSubview(customImagelabel)

        configureImageView()
        configureTitleLabel()
        setImageContraints()
        setTitleLabelContraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureImageView() {
        videoImageView.clipsToBounds = true
        videoImageView.layer.cornerRadius = 30
    }

    func configureTitleLabel() {
        customImagelabel.adjustsFontSizeToFitWidth = true
        customImagelabel.numberOfLines = 0
    }

    func setImageContraints() {
        videoImageView.translatesAutoresizingMaskIntoConstraints                                                = false
        videoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive                                = true
        videoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive                  = true
        videoImageView.heightAnchor.constraint(equalToConstant: 80).isActive                                    = true
        videoImageView.widthAnchor.constraint(equalTo: videoImageView.heightAnchor, multiplier: 16/9).isActive  = true
    }

    func setTitleLabelContraints() {
        customImagelabel.translatesAutoresizingMaskIntoConstraints                                                = false
        customImagelabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive                                = true
        customImagelabel.leadingAnchor.constraint(equalTo: videoImageView.trailingAnchor, constant: 12).isActive  = true
        customImagelabel.heightAnchor.constraint(equalToConstant: 80).isActive                                    = true
        customImagelabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive               = true
    }
}
