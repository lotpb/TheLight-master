//
//  ProdModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/28/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation

struct ProdModel {
    
    var prodId: String?
    let productNo: String?
    let products: String
    let active: String
    let price: Int
    let imageUrl: String
    let photo: String
    
    init(dictionary: [String: Any]) {
        
        self.prodId = dictionary["proddId"] as? String ?? ""
        self.productNo = dictionary["productNo"] as? String ?? ""
        self.products = dictionary["products"] as? String ?? ""
        self.price = dictionary["price"] as? Int ?? 0
        self.active = dictionary["active"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.photo = dictionary["photo"] as? String ?? ""
    }
}
