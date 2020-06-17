//
//  AdModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/28/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct AdModel {
    
    var adId: String?
    let adNo: String?
    let advertiser: String
    let active: String
    let imageUrl: String
    let photo: String
    
    init(dictionary: [String: Any]) {
        
        self.adId = dictionary["adId"] as? String ?? ""
        self.adNo = dictionary["adNo"] as? String ?? ""
        self.advertiser = dictionary["advertiser"] as? String ?? ""
        self.active = dictionary["active"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.photo = dictionary["photo"] as? String ?? ""
    }
}
