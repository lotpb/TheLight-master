//
//  User.swift
//  gameofchats
//
//  Created by Brian Voong on 6/29/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import Foundation

struct UserModel {
    let uid: String
    let username: String
    let profileImageUrl: String
    let phone: String
    let email: String
    let creationDate: Date
    var lastUpdate: Date
    //var facebookID: String
    //let emailVerified: String
    //let currentLocation: String
    
    
    init(dictionary: [String: Any]) {
        
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.lastUpdate = Date(timeIntervalSince1970: dictionary["lastUpdate"] as? Double ?? 0)
        
        //self.facebookID = facebookID
    }
}
