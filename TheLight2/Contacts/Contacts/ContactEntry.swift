//
//  ContactEntry.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 20/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import Contacts

class ContactEntry: NSObject {
    
    var name: String!
    var email: String?
    var phone: String?
    var image: UIImage?
    
    init(name: String, email: String?, phone: String?, image: UIImage?) {
        self.name = name
        self.email = email
        self.phone = phone
        self.image = image
    }
    
    
    @available(iOS 9.0, *)
    init?(cnContact: CNContact) {
        // name
        if !cnContact.isKeyAvailable(CNContactGivenNameKey), !cnContact.isKeyAvailable(CNContactFamilyNameKey) { return nil }
        self.name = (cnContact.givenName + " " + cnContact.familyName + " " + cnContact.organizationName).removeWhiteSpace()
        // image
        self.image = (cnContact.isKeyAvailable(CNContactImageDataKey) && cnContact.imageDataAvailable) ? UIImage(data: cnContact.imageData!) : nil
        // email
        if cnContact.isKeyAvailable(CNContactEmailAddressesKey) {
            for possibleEmail in cnContact.emailAddresses {
                let properEmail = possibleEmail.value as String
                if properEmail.isValidEmailAddress { self.email = properEmail; break }
            }
        }
        // phone 
        if cnContact.isKeyAvailable(CNContactPhoneNumbersKey) {
            if cnContact.phoneNumbers.count > 0 {
                let phone = cnContact.phoneNumbers.first?.value
                self.phone = phone?.stringValue
            }
        }
    } 
}
//added
extension ContactEntry {
    var contactValue : CNContact {
        //1
        let contact = CNMutableContact()
        //2
        contact.givenName = name
        //3
        //contact.emailAddresses = email
        //4
        if let profilePicture = image {
            let imageData = profilePicture.jpegData(compressionQuality: 1)
            contact.imageData = imageData
        }
        //5
        return contact.copy() as! CNContact
    }
    

}
