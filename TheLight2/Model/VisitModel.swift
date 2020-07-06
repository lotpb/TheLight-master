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
    let arrivaldate: String
    let departuredate: String
    let desciption: String
    let latitude: Double
    let longitude: Double
    let horizontalaccuracy: Double

    
    //init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String) {
    init(dictionary: [String: Any]) {
        
        self.uid = dictionary["uid"] as? String ?? ""
        let coordinate = dictionary["coordinate"] as? [String: Any]
        self.latitude = coordinate!["latitude"] as? Double ?? 0
        self.longitude = coordinate!["longitude"] as? Double ?? 0
        self.desciption = dictionary["desciption"] as? String ?? ""
        self.horizontalaccuracy = dictionary["horizontal_accuracy"] as? Double ?? 0

        //self.arrivaldate = Date(timeIntervalSince1970: dictionary["arrival_date"] as? Double ?? 0)
        self.arrivaldate = dictionary["arrival_date"] as! String
        self.departuredate = dictionary["departure_date"] as! String
    }
}

