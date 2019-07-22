//
//  SalesModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/28/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct SalesModel {
    
    var salesId: String?
    let salesNo: String?
    let salesman: String
    let active: String
    let imageUrl: String

    init(dictionary: [String: Any]) {
        
        self.salesId = dictionary["salesId"] as? String ?? ""
        self.salesNo = dictionary["salesNo"] as? String ?? ""
        self.salesman = dictionary["salesman"] as? String ?? ""
        self.active = dictionary["active"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
