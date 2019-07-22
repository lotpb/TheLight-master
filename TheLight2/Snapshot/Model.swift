//
//  Model.swift
//  RecreatingAppStore
//
//  Created by Yu Sun on 27/10/17.
//  Copyright © 2017 Yu Sun. All rights reserved.
//

import UIKit

struct AppStore: Codable {
    var bannerCategory: AppCategory?
    var categories: [AppCategory]?
}

struct AppCategory: Codable {
    
    var name: String?
    var apps: [App]?
    var type: String?
    
    static func fetchFeaturedApps(completionHandler:@escaping (AppStore) -> ()) {
        
        let urlString = "https://api.letsbuildthatapp.com/appstore/featured"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            let decoder = JSONDecoder()
                
            do {
                let appStore = try decoder.decode(AppStore.self, from: data!)
                
                DispatchQueue.main.async(execute: {
                    completionHandler(appStore)
                    })
                
            } catch let error {
                
                print("Failed to decode: ", error)
            }
                

        }.resume()
    }
}

struct App: Codable {
    
    var id: Int?
    var name: String?
    var category: String?
    var imageName: String?
    var price: Double?
    
    // coding keys for tranfer name from server to local
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case category = "Category"
        case imageName = "ImageName"
        case price = "Price"
    }
    
}



