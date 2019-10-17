//
//  ContentView.swift
//  TheLight3
//
//  Created by Peter Balsamo on 7/5/19.
//  Copyright © 2019 Peter Balsamo. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct ContentView : View {
       let users = ["Paul Hudson", "Taylor Swift"]

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
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            ContentView()
                .environment(\.colorScheme, .dark)
            NavigationView {
                ContentView()
            }
        }
    }
}
#endif
