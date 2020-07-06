//
//  Firebase.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/22/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation
import FirebaseDatabase
//import CoreLocation

struct FirebaseRef {
    
    static let databaseRoot: DatabaseReference = Database.database().reference()
    static let databaseVisits: DatabaseReference = databaseRoot.child("visits")
    static let databaseLeads: DatabaseReference = databaseRoot.child("Leads")
    static let databaseCust: DatabaseReference = databaseRoot.child("Customer")
    static let databaseBlog: DatabaseReference = databaseRoot.child("Blog")
    static let databaseUsers: DatabaseReference = databaseRoot.child("users")
    static let databaseEmply: DatabaseReference = databaseRoot.child("Employee")
    static let databaseVendor: DatabaseReference = databaseRoot.child("Vendor")
    static let databaseNews: DatabaseReference = databaseRoot.child("News")

    static let databaseAd: DatabaseReference = databaseRoot.child("Advertising")
    static let databaseJob: DatabaseReference = databaseRoot.child("Job")
    static let databaseProd: DatabaseReference = databaseRoot.child("Product")
    static let databaseSales: DatabaseReference = databaseRoot.child("Salesman")

    //static let databaseUpdatingLocations: DatabaseReference = databaseRoot.child("update_locations")
    //static let databaseSignificantChange: DatabaseReference = databaseRoot.child("significant_change")
    //static let databaseHeading: DatabaseReference = databaseRoot.child("headings")

    //let postStorageRef = Storage.storage().reference.child("Customer_images").child(userID)

    //static let databaseUsers: Storage.storage().reference().child("Customer_images").child(userID)
}

extension Database {
    static func fetchUserWithUID( uid: String, completion: @escaping (UserModel) -> ()) {

        FirebaseRef.databaseRoot.child("users").child(uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            let user = UserModel(dictionary: dict)
            print(user.username)
            print("Fetching user with uid", uid)
            completion(user)
            //self.fetchPostsWithUser(user: user)
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
}

