//
//  Firebase.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/22/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation

struct FirebaseRef {
    
    static let databaseRoot: DatabaseReference = Database.database().reference()
    static let databaseVisits: DatabaseReference = databaseRoot.child("visits")
    static let databaseLeads: DatabaseReference = databaseRoot.child("Leads")
    static let databaseCust: DatabaseReference = databaseRoot.child("Customer")
    static let databaseBlog: DatabaseReference = databaseRoot.child("Blog")
    //static let databaseUpdatingLocations: DatabaseReference = databaseRoot.child("update_locations")
    //static let databaseSignificantChange: DatabaseReference = databaseRoot.child("significant_change")
    //static let databaseHeading: DatabaseReference = databaseRoot.child("headings")
    
    
    /*
     static func saveHeadingInfoWith(
     newHeading: CLHeading,
     databaseRef reference: DatabaseReference,
     dateFormatter: DateFormatter
     ) {
     let dateString = dateFormatter.string(from: newHeading.timestamp)
     let key = dateString
     let timestamp = newHeading.timestamp.timeIntervalSince1970
     
     let recordReference = reference.child(key)
     let object: [String: Any] = [
     "headings": [
     "magneticHeading": newHeading.magneticHeading,
     "trueHeading": newHeading.trueHeading,
     "accuracy": newHeading.headingAccuracy
     ],
     "timestamp": Int(timestamp),
     "x": newHeading.x,
     "y": newHeading.y,
     "z": newHeading.z
     ]
     recordReference.setValue(object)
     
     } */
     /*
     static func saveLocationInfoWith(
     location: CLLocation,
     databaseRef reference: DatabaseReference,
     dateFormatter: DateFormatter
     ) {
     let dateString = dateFormatter.string(from: location.timestamp)
     let key = dateString
     let timestamp = location.timestamp.timeIntervalSince1970
     var level = "N/A"
     if let floor = location.floor {
     level = "\(floor.level)"
     }
     
     let recordReference = reference.child(key)
     let object: [String: Any] = [
     "coordinate": [
     "latitude": location.coordinate.latitude,
     "longitude": location.coordinate.longitude
     ],
     "altitude": location.altitude,
     "floor": level,
     "timestamp": Int(timestamp),
     "speed": location.speed,
     "course": location.course
     ]
     recordReference.setValue(object)
     }  */
}

extension Database {
    static func fetchUserWithUID( uid: String, completion: @escaping (UserModel) -> ()) {
        print("Fetching user with uid", uid)
        FirebaseRef.databaseRoot.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = UserModel(dictionary: userDictionary)
            //let user = UserModel(uid: uid, dictionary: userDictionary)
            print(user.username)
            completion(user)
            //self.fetchPostsWithUser(user: user)
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
}
