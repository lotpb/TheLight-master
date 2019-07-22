//
//  Post.swift
//  Firegram
//
//  Created by Nithin Reddy Gaddam on 4/29/17.
//  Copyright © 2017 Nithin Reddy Gaddam. All rights reserved.
//

import Foundation

struct BlogModel {
    
    //let users: UserModel
    let uid: String
    var blogId: String?
    let imageUrl: String
    let replyId: String
    let rating: String
    let subject: String
    let postBy: String
    let liked: NSNumber
    let commentCount: NSNumber
    let creationDate: Date
    var lastUpdate: Date

    
    init(dictionary: [String: Any]) {
        
        //self.users = users
        self.uid = dictionary["uid"] as? String ?? ""
        self.blogId = dictionary["blogId"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.replyId = dictionary["replyId"] as? String ?? ""
        self.rating = dictionary["rating"] as? String ?? ""
        self.subject = dictionary["subject"] as? String ?? ""
        self.postBy = dictionary["postBy"] as? String ?? ""
        self.liked = dictionary["liked"] as? NSNumber ?? 0
        self.commentCount = dictionary["commentCount"] as? NSNumber ?? 0
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.lastUpdate = Date(timeIntervalSince1970: dictionary["lastUpdate"] as? Double ?? 0)
      
    }
} 
