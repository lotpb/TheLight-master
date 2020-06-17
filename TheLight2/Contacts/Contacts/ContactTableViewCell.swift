//
//  ContactTableViewCell.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 20/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//


import UIKit
import Contacts

final class ContactTableViewCell: UITableViewCell {
    // outlets
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactEmailLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCircularAvatar() {
        contactImageView.layer.cornerRadius = contactImageView.bounds.size.width / 2.0
        contactImageView.layer.masksToBounds = true
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setCircularAvatar()
    }
    
    func configureWithContactEntry(_ contact: ContactEntry) {
        
        if #available(iOS 13.0, *) {
            contactNameLabel.textColor = .systemBlue
        } else {
            // Fallback on earlier versions
        }
        if UIDevice.current.userInterfaceIdiom == .pad  {
            contactNameLabel.font = Font.celltitle22m
            contactEmailLabel.font = Font.celltitle20l
            contactPhoneLabel.font = Font.celltitle20l
        } else {
            contactNameLabel.font = Font.celltitle20l
            contactEmailLabel.font = Font.celltitle16r
            contactPhoneLabel.font = Font.celltitle16r
        }

        contactNameLabel.text = contact.name
        contactEmailLabel.text = contact.email ?? ""
        contactPhoneLabel.text = contact.phone ?? ""
        contactPhoneLabel.adjustsFontSizeToFitWidth = true
        contactImageView.image = contact.image ?? #imageLiteral(resourceName: "profile-rabbit-toy")
        setCircularAvatar()
    }
}
