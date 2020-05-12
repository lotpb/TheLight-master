//
//  ContentView.swift
//  TheLight3
//
//  Created by Peter Balsamo on 7/5/19.
//  Copyright © 2019 Peter Balsamo. All rights reserved.
//

import SwiftUI
import FirebaseFirestore


@available(iOS 13.0, *)
struct ContentView : View {
    let users = ["Paul Hudson", "Taylor Swift"]
    //    @State var leadlist = [LeadModel]()

    var body: some View {

        NavigationView {
            
            List(users, id: \.self) { user in
                NavigationLink(destination: Text("Detail View")) {
                    Image("profile-rabbit-toy").resizable().frame(width: 50, height: 50)

                    VStack(alignment: .leading) {
                        Text("Johnny Appleseed").font(.headline)
                        Text("Occupation: Programmer")
                    }
                }
            }.navigationBarTitle("Users")
        }
        
    }

    private func newDocument() {

        let db = Firestore.firestore()

        let docData: [String: Any] = [
            "stringExample": "Hello world!",
            "booleanExample": true,
            "numberExample": 3.14159265,
            "dateExample": Timestamp(date: Date()),
            "arrayExample": [5, true, "hello"],
            "nullExample": NSNull(),
            "objectExample": [
                "a": 5,
                "b": [
                    "nested": "foo"
                ]
            ]
        ]
        db.collection("data").document("one").setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }


        var ref: DocumentReference? = nil
        ref = db.collection("cities").addDocument(data: [
            "name": "Tokyo",
            "country": "Japan"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}

func loadData() {

    let db = Firestore.firestore()
    db.collection("users").addSnapshotListener { (querySnapshot, err) in
        guard (querySnapshot?.documents) != nil else {
            print("Error getting documents:")
            return
        }
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
            }
        }
    }

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ContentView()
            }
            ContentView()
                .environment(\.colorScheme, .dark)
            ContentView()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }
}
#endif
