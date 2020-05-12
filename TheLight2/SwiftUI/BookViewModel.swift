//
//  BookViewModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/8/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import Foundation
import FirebaseFirestore

class BookViewModel: ObservableObject {
    @Published var books = [Book]()

    private var db = Firestore.firestore()

    func fetchData() {
        db.collection("books").addSnapshotListener { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("Error getting documents:")
                return
            }

            self.books = documents.map { (QueryDocumentSnapshot) -> Book in
                let data = QueryDocumentSnapshot.data()
                let title = data["title"] as? String ?? ""
                let author = data["author"] as? String ?? ""
                let pages = data["numberOfPages"] as? Int ?? 0

                return Book(title: title, author: author, numberOfPages: pages)
            }
        }
    }
/*
    func fetchLeads() {
        db.collection("leads").addSnapshotListener { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("Error getting documents:")
                return
            }

            self.books = documents.map { (QueryDocumentSnapshot) -> Book in
                let data = QueryDocumentSnapshot.data()

                let uid = data["uid"] as? String ?? ""
                let leadId = data["leadId"] as? String ?? ""
                let lastname = data["lastname"] as? String ?? ""
                let address = data["address"] as? String ?? ""
                let city = data["city"] as? String ?? ""
                let state = data["state"] as? String ?? ""
                let callback = data["callback"] as? String ?? ""
                let phone = data["phone"] as? String ?? ""
                let first = data["first"] as? String ?? ""
                let spouse = data["spouse"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let photo = data["photo"] as? String ?? ""
                let comments = data["comments"] as? String ?? ""

                let amount = data["amount"] as? Int ?? 0
                let zip = data["zip"] as? Int ?? 0
                let leadNo = data["leadNo"] as? Int ?? 0
                let salesNo = data["salesNo"] as? Int ?? 0
                let jobNo = data["jobNo"] as? Int ?? 0
                let adNo = data["adNo"] as? Int ?? 0
                let active = data["active"] as? Int ?? 0

                let secondsFrom1970 = data["creationDate"] as? Double ?? 0
                let creationDate = Date(timeIntervalSince1970: secondsFrom1970)
                let lastUpdate = Date(timeIntervalSince1970: data["lastUpdate"] as? Double ?? 0)
                let aptdate = Date(timeIntervalSince1970: data["aptdate"] as? Double ?? 0)


                return Lead(uid: uid, leadId: leadId, lastname: lastname)
            }
        }
    } */




}
