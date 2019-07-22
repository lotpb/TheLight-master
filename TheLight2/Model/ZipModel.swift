//
//  ZipModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/31/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct ZipModel {
    
    var zipId: String?
    let zipNo: String?
    let city: String
    let state: String
    let zip: String
    let active: String
    
    init(dictionary: [String: Any]) {
        
        self.zipId = dictionary["zipId"] as? String ?? ""
        self.zipNo = dictionary["zipNo"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.zip = dictionary["zip"] as? String ?? ""
        self.active = dictionary["active"] as? String ?? ""
    }
}
