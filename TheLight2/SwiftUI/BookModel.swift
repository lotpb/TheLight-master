//
//  BookModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/8/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct Book: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var author: String
    var numberOfPages: Int

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case numberOfPages = "pages"
    }
}
/*
struct Lead: Identifiable, Codable {
    var uid: String = UUID().uuidString
    var leadId: String
    var lastname: String
    var address: String
    var city: String
    var state: String
    var callback: String
    var phone: String
    var first: String
    var spouse: String
    var email: String
    var photo: String
    var comments: String

    var amount: Int
    var zip: Int
    var leadNo: Int
    var salesNo: Int
    var jobNo: Int
    var adNo: Int
    var active: Int

    var creationDate: Date
    var lastUpdate: Date
    var aptdate: Date

    enum CodingKeys: String, CodingKey {
        case uid
        case leadId
        case lastname
        case address
        case city
        case state
        case callback
        case phone
        case first
        case spouse
        case email
        case comments

        case amount
        case zip
        case leadNo
        case salesNo
        case jobNo
        case adNo
        case active

        case creationDate
        case lastUpdate
        case aptdate
    }
} */
