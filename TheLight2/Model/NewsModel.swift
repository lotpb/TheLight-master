//
//  Comment.swift
//  Firegram
//
//  Created by Nithin Reddy Gaddam on 5/3/17.
//  Copyright © 2017 Nithin Reddy Gaddam. All rights reserved.
//

import Foundation

struct NewsModel {
    
    let uid: String
    var newsId: String?
    let imageUrl: String
    let newsTitle: String
    let newsDetail: String
    let storyLabel: String
    let liked: NSNumber
    let dislikes: NSNumber
    let viewCount: NSNumber
    let creationDate: Date
    var videoUrl: String?
    var storageID: String?
    
    
    init(dictionary: [String: Any]) {
        
        self.uid = dictionary["uid"] as? String ?? ""
        self.newsId = dictionary["newsId"] as? String ?? ""
        self.storageID = dictionary["storageID"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.videoUrl = dictionary["videoUrl"] as? String ?? ""
        self.newsTitle = dictionary["newsTitle"] as? String ?? ""
        self.newsDetail = dictionary["newsDetail"] as? String ?? ""
        self.storyLabel = dictionary["storyText"] as? String ?? ""
        self.liked = dictionary["liked"] as? NSNumber ?? 0
        self.dislikes = dictionary["dislikes"] as? NSNumber ?? 0
        viewCount = dictionary["viewCount"] as? NSNumber ?? 0
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
