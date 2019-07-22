//
//  EmployModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/28/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct EmployModel {
    
    let uid: String
    var employeeId: String?
    let lastname: String
    let address: String
    let city: String
    let state: String
    let company: String
    let homephone: String
    let workphone: String
    let cellphone: String
    let ss: String
    let first: String
    let title: String
    let email: String
    let middle: String
    let comments: String
    let manager: String
    let department: String
    let country: String
    let imageUrl: String
    
    let zip: NSNumber
    let employeeNo: NSNumber
    let active: NSNumber
    
    let creationDate: Date
    var lastUpdate: Date
    
    
    init(dictionary: [String: Any]) {
        
        //self.users = users
        self.uid = dictionary["uid"] as? String ?? ""
        self.employeeId = dictionary["employeeId"] as? String ?? ""
        self.lastname = dictionary["lastname"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.company = dictionary["company"] as? String ?? ""
        self.homephone = dictionary["homephone"] as? String ?? ""
        self.workphone = dictionary["workphone"] as? String ?? ""
        self.cellphone = dictionary["cellphone"] as? String ?? ""
        self.ss = dictionary["ss"] as? String ?? ""
        self.first = dictionary["first"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.middle = dictionary["middle"] as? String ?? ""
        self.comments = dictionary["comments"] as? String ?? ""
        self.manager = dictionary["manager"] as? String ?? ""
        self.department = dictionary["department"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        
        self.employeeNo = dictionary["employeeNo"] as? NSNumber ?? 0
        self.zip = dictionary["zip"] as? NSNumber ?? 0
        self.active = dictionary["active"] as? NSNumber ?? 0
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.lastUpdate = Date(timeIntervalSince1970: dictionary["lastUpdate"] as? Double ?? 0)
    }
}
