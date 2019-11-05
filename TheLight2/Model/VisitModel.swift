//
//  File.swift
//  TheLight2
//
//  Created by Peter Balsamo on 10/6/18.
//  Copyright © 2018 Peter Balsamo. All rights reserved.
//

import Foundation
import CoreLocation

struct VisitModel {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    let uid: String
    let arrival_date: Date
    let departure_date: Date
    let desciption: String
    let latitude: Double
    let longitude: Double
    let horizontal_accuracy: Double
    
    //init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String) {
    init(dictionary: [String: Any]) {
        
        self.uid = dictionary["uid"] as? String ?? ""
        let secondsFrom1970 = dictionary["arrival_date"] as? Double ?? 0
        self.arrival_date = Date(timeIntervalSince1970: secondsFrom1970)
        self.departure_date = Date(timeIntervalSince1970: dictionary["departure_date"] as? Double ?? 0)
        self.latitude =  dictionary["latitude"] as? Double ?? 0
        self.longitude =  dictionary["longitude"] as? Double ?? 0
        self.desciption = dictionary["desciption"] as? String ?? ""
        self.horizontal_accuracy = dictionary["horizontal_accuracy"] as? Double ?? 0
    }
}

