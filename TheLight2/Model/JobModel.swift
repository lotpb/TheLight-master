//
//  JobModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/28/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct JobModel {
    
    var jobId: String?
    let jobNo: String?
    let description: String
    let active: String
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        
        self.jobId = dictionary["jobId"] as? String ?? ""
        self.jobNo = dictionary["jobNo"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.active = dictionary["active"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
