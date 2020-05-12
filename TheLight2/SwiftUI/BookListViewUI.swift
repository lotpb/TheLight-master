//
//  BookListViewUI.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/8/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import SwiftUI
/*
 let testData = [
 Book(title: "introduction to Alorithms", author: "Peter Balsamo", numberOfPages: 815),
 Book(title: "Changer", author: "Peter Balsamo", numberOfPages: 474),
 Book(title: "Personal", author: "Peter Balsamo", numberOfPages: 194)
 ] */

struct BookListViewUI: View {

    @ObservedObject private var viewModel = BookViewModel()
    //var books = testData

    var body: some View {
        NavigationView {
            List(viewModel.books) { book in
                Button(action: {
                }) {
                    Image("profile-rabbit-toy")
                        .renderingMode(.original)
                        .resizable().frame(width: 50, height: 50)
                }
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.headline)
                    Text(book.author)
                        .font(.subheadline)
                    Text("\(book.numberOfPages) pages")
                        .font(.subheadline)
                }
            }
            .navigationBarTitle("Books")
            .onAppear() {
                self.viewModel.fetchData()
            }
        }
    }
}

struct BookListViewUI_Previews : PreviewProvider {
    static var previews: some View {
        BookListViewUI()
    }
}
