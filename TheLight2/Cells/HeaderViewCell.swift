//
//  HeaderViewCell.swift
//  TheLight
//
//  Created by Peter Balsamo on 5/3/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit
//import SwiftUI

final class HeaderViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    let myLabel1: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = .init(x: 10, y: 10, width: 54, height: 54)
        label.text = ""
        label.numberOfLines = 2
        label.backgroundColor = .white
        label.textColor = .systemGray //Color.goldColor
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 27.0
        label.layer.borderColor = UIColor.systemGray.cgColor //Color.Blog.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let myLabel2: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = .init(x: 84, y: 10, width: 54, height: 54)
        label.text = ""
        label.numberOfLines = 2
        label.backgroundColor = .white
        label.textColor = .systemGray //Color.goldColor
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 27.0
        label.layer.borderColor = UIColor.systemGray.cgColor//Color.Blog.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let myLabel3: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = .init(x: 158, y: 10, width: 54, height: 54)
        label.text = ""
        label.numberOfLines = 2
        label.backgroundColor = .white
        label.textColor = .systemGray //Color.goldColor
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 27.0
        label.layer.borderColor = UIColor.systemGray.cgColor //Color.Blog.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var separatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = .init(x: 10, y: 70, width: 54, height: 2.5)
        return view
    }()
    
    lazy var separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = .init(x: 84, y: 70, width: 54, height: 2.5)
        return view
    }()
    
    lazy var separatorView3: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = .init(x: 158, y: 70, width: 54, height: 2.5)
        return view
    }()
    
    func setupViews() {
        
        if UIDevice.current.userInterfaceIdiom == .phone  {

            self.contentView.addSubview(myLabel1)
            self.contentView.addSubview(myLabel2)
            self.contentView.addSubview(myLabel3)
            self.contentView.addSubview(separatorView1)
            self.contentView.addSubview(separatorView2)
            self.contentView.addSubview(separatorView3)
        }
    }
    
}
