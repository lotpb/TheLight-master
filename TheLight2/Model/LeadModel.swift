//
//  LeadModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/28/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct LeadModel {
    
    //let users: UserModel
    let uid: String
    var leadId: String?
    let lastname: String
    let address: String
    let city: String
    let state: String
    let callback: String
    let phone: String
    let first: String
    let spouse: String
    let email: String
    let photo: String
    let comments: String
    
    let amount: NSNumber
    let zip: NSNumber
    let leadNo: NSNumber
    let salesNo: NSNumber
    let jobNo: NSNumber
    let adNo: NSNumber
    let active: NSNumber

    let aptdate: Date
    let creationDate: Date
    var lastUpdate: Date
    
    
    init(dictionary: [String: Any]) {
        
        //self.users = users
        self.uid = dictionary["uid"] as? String ?? ""
        self.leadId = dictionary["leadId"] as? String ?? ""
        self.lastname = dictionary["lastname"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.callback = dictionary["callback"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.first = dictionary["first"] as? String ?? ""
        self.spouse = dictionary["spouse"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.photo = dictionary["photo"] as? String ?? ""
        self.comments = dictionary["comments"] as? String ?? ""
        
        self.amount = dictionary["amount"] as? NSNumber ?? 0
        self.zip = dictionary["zip"] as? NSNumber ?? 0
        self.leadNo = dictionary["leadNo"] as? NSNumber ?? 0
        self.salesNo = dictionary["salesNo"] as? NSNumber ?? 0
        self.jobNo = dictionary["jobNo"] as? NSNumber ?? 0
        self.adNo = dictionary["adNo"] as? NSNumber ?? 0
        self.active = dictionary["active"] as? NSNumber ?? 0
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.lastUpdate = Date(timeIntervalSince1970: dictionary["lastUpdate"] as? Double ?? 0)
        self.aptdate = Date(timeIntervalSince1970: dictionary["aptdate"] as? Double ?? 0)
        
    }
}
