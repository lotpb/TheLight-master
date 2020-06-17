//
//  VendorModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/28/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct VendModel {

    let uid: String
    var vendId: String?
    let vendor: String
    let address: String
    let city: String
    let state: String
    let assistant: String
    let phone: String
    let phone1: String
    let phone2: String
    let phone3: String
    let first: String
    let department: String
    let email: String
    let office: String
    let comments: String
    let manager: String
    let profession: String
    let webpage: String
    let photo: String
    
    let zip: NSNumber
    let vendorNo: NSNumber
    let active: NSNumber
    
    let creationDate: Date
    var lastUpdate: Date
    
    
    init(dictionary: [String: Any]) {
        
        //self.users = users
        self.uid = dictionary["uid"] as? String ?? ""
        self.vendId = dictionary["vendId"] as? String ?? ""
        self.vendor = dictionary["vendor"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.assistant = dictionary["assistant"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.phone1 = dictionary["phone1"] as? String ?? ""
        self.phone2 = dictionary["phone2"] as? String ?? ""
        self.phone3 = dictionary["phone3"] as? String ?? ""
        self.first = dictionary["first"] as? String ?? ""
        self.department = dictionary["department"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.office = dictionary["office"] as? String ?? ""
        self.comments = dictionary["comments"] as? String ?? ""
        self.manager = dictionary["manager"] as? String ?? ""
        self.profession = dictionary["profession"] as? String ?? ""
        self.webpage = dictionary["webpage"] as? String ?? ""
        self.photo = dictionary["photo"] as? String ?? ""
        
        self.vendorNo = dictionary["vendorNo"] as? NSNumber ?? 0
        self.zip = dictionary["zip"] as? NSNumber ?? 0
        self.active = dictionary["active"] as? NSNumber ?? 0
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.lastUpdate = Date(timeIntervalSince1970: dictionary["lastUpdate"] as? Double ?? 0)
    }
}
