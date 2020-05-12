//
//  TweetUI.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/8/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct TweetUI: View {

    @State var show = false

    var body: some View {


        ZStack{

            TabView{

                HomeTweet().tabItem {

                    Image("Home")

                }.tag(0)

                SearchUI().tabItem {

                    Image("Search")

                }.tag(1)

                Text("Notifications").tabItem {

                    Image("Notifications")

                }.tag(2)

                Text("Messages").tabItem {

                    Image("Messages")

                }.tag(3)

            }.accentColor(.blue)
                .edgesIgnoringSafeArea(.top)

            VStack{

                Spacer()

                HStack{

                    Spacer()

                    Button(action: {

                        self.show.toggle()

                    }) {

                        Image("Tweet").resizable().frame(width: 20, height: 20).padding()
                    }.background(Color("bg"))
                        .foregroundColor(.white)
                        .clipShape(Circle())

                }.padding()

            }.padding(.bottom,65)

        }.sheet(isPresented: $show) {

            CreateTweet(show: self.$show)
        }

    }
}

struct TweetUI_Previews: PreviewProvider {
    static var previews: some View {
        TweetUI()
    }
}

//Home.swift

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct HomeTweet : View {

    @EnvironmentObject var observedData : getData

    var body : some View{

        NavigationView{

            ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading){

                    ForEach(observedData.datas){i in

                        tweetCellTop(name: i.name, id: i.tagId, pic: i.pic, image: i.url, msg: i.msg)

                        if i.pic != ""{

                            tweetCellMiddle(pic: i.pic).padding(.leading, 60)

                        }


                        tweetCellBottom().offset(x: UIScreen.main.bounds.width / 4)
                    }
                }

            }.padding(.bottom, 15)

                .navigationBarTitle("Home",displayMode: .inline)
                .navigationBarItems(leading:

                    Image("User Image").resizable().frame(width: 35, height: 35).clipShape(Circle()).onTapGesture {

                        print("slide out menu ....")
                    }

            )
        }
    }
}

//TweetcellBottom.swift

import SwiftUI

struct tweetCellBottom : View {

    var body : some View{

        HStack(spacing : 40){

            Button(action: {

            }) {

                Image("Comments").resizable().frame(width: 20, height: 20)

            }.foregroundColor(.gray)

            Button(action: {

            }) {

                Image("Retweet").resizable().frame(width: 20, height: 20)

            }.foregroundColor(.gray)

            Button(action: {

            }) {

                Image("love").resizable().frame(width: 20, height: 17)

            }.foregroundColor(.gray)

            Button(action: {

            }) {

                Image("upload").resizable().frame(width: 20, height: 20)

            }.foregroundColor(.gray)
        }
    }
}

//TweetCellTop.swift

import SwiftUI
import SDWebImageSwiftUI

struct tweetCellTop : View {

    var name = ""
    var id = ""
    var pic = ""
    var image = ""
    var msg = ""

    var body : some View{

        HStack(alignment: .top){

            VStack{

                AnimatedImage(url: URL(string: image)!).resizable().frame(width: 50, height: 50).clipShape(Circle())

            }


            VStack(alignment: .leading){

                Text(name).fontWeight(.heavy)
                Text(id)
                Text(msg).padding(.top, 8)

            }

        }.padding()
    }
}

//TweetCellMiddle.swift

import SwiftUI
import SDWebImageSwiftUI


struct tweetCellMiddle : View {

    var pic = ""

    var body : some View{

        AnimatedImage(url: URL(string: pic)!).resizable().frame(height: 300).cornerRadius(20).padding()
    }
}

//CreateTweet.swift


import SwiftUI
import Firebase

struct CreateTweet : View {
    @Binding var show : Bool
    @State var txt = ""

    var body : some View{

        VStack{

            HStack{

                Button(action: {

                    self.show.toggle()

                }) {

                    Text("Cancel")
                }

                Spacer()

                Button(action: {


                    postTweet(msg: self.txt)
                    self.show.toggle()

                }) {

                    Text("Tweet").padding()

                }.background(Color("bg"))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            multilineTextField(txt: $txt)

        }.padding()
    }
}

//multilineTextField.swift


import SwiftUI

// now we going to create multiline Textfield.....

struct multilineTextField : UIViewRepresentable {


    @Binding var txt : String

    func makeCoordinator() -> multilineTextField.Coordinator {

        return multilineTextField.Coordinator(parent1 : self)
    }
    func makeUIView(context: UIViewRepresentableContext<multilineTextField>) -> UITextView {

        let text = UITextView()
        text.isEditable = true
        text.isUserInteractionEnabled = true
        text.text = "Type Something"
        text.textColor = .gray
        text.font = .systemFont(ofSize: 20)
        text.delegate = context.coordinator
        return text
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<multilineTextField>) {


    }

    class Coordinator : NSObject,UITextViewDelegate{


        var parent : multilineTextField

        init(parent1 : multilineTextField) {

            parent = parent1
        }

        func textViewDidBeginEditing(_ textView: UITextView) {

            textView.text = ""
            textView.textColor = .black
        }

        func textViewDidChange(_ textView: UITextView) {

            self.parent.txt = textView.text
        }
    }
}


//Datatypes.swift

import Foundation

struct datatype : Identifiable {

    var id : String
    var name : String
    var msg : String
    var retwetts : String
    var likes : String
    var pic : String
    var url : String
    var tagId : String
}

struct Topdatatype : Identifiable {

    var id : String
    var tag : String
    var tweets : String
}

//Search.swift

import SwiftUI
import Firebase

struct SearchUI : View {

    @EnvironmentObject var datas : getData

    var body : some View{

        NavigationView{

            List(datas.top){i in

                SearchCell(tag: i.tag, tweets: i.tweets)

            }.navigationBarTitle("",displayMode: .inline)
                .navigationBarItems(leading:

                    HStack{

                        Image("User Image").resizable().frame(width: 35, height: 35).clipShape(Circle()).onTapGesture {

                            print("slide out menu ....")
                        }

                        SearchBar().frame(width: UIScreen.main.bounds.width - 120)
                    }

                    , trailing:

                    Button(action: {

                    }, label: {

                        Image("Add").resizable().frame(width: 35, height: 25)

                    }).foregroundColor(Color("bg"))

            )

        }
    }
}

struct SearchCell : View {

    var tag = ""
    var tweets = ""

    var body : some View{

        VStack(alignment : .leading,spacing : 5){

            Text(tag).fontWeight(.heavy)
            Text(tweets + " Tweets").fontWeight(.light)
        }
    }
}

struct SearchBar : UIViewRepresentable {

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {

        let search = UISearchBar()
        return search
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {


    }
}

//Observables.swift


import SwiftUI
import Firebase

class getData : ObservableObject{

    @Published var datas = [datatype]()
    @Published var top = [Topdatatype]()

    init() {

        let db = Firestore.firestore()

        db.collection("tweets").addSnapshotListener { (snap, err) in

            if err != nil{

                print((err?.localizedDescription)!)
                return
            }

            for i in snap!.documentChanges{

                if i.type == .added{

                    print("hello world")

                    let id = i.document.documentID
                    let name = i.document.get("name") as! String
                    let msg = i.document.get("msg") as! String
                    let pic = i.document.get("pic") as! String
                    let url = i.document.get("url") as! String
                    let retweets = i.document.get("retweet") as! String
                    let likes = i.document.get("likes") as! String
                    let tagID = i.document.get("id") as! String

                    DispatchQueue.main.async {

                        self.datas.append(datatype(id: id, name: name, msg: msg, retwetts: retweets, likes: likes, pic: pic, url: url, tagId: tagID))
                    }

                }
            }
        }

        db.collection("Top").order(by: "tweets", descending: true).getDocuments { (snap, err) in

            if err != nil{

                print((err?.localizedDescription)!)
                return
            }

            for i in snap!.documents{

                let id = i.documentID
                let tag = i.get("tag") as! String
                let tweets = i.get("tweets") as! NSNumber

                self.top.append(Topdatatype(id: id, tag: tag, tweets: "\(tweets)"))
            }
        }
    }
}

func postTweet(msg : String){

    let db = Firestore.firestore()

    // I'm going to use default name and image url.....

    db.collection("tweets").document().setData(["name" : "Kavsoft","id":"@kavsoft","msg":msg,"retweet":"0","likes":"0","pic":"","url":" Image URL "]) { (err) in

        if err != nil{

            print((err?.localizedDescription)!)

            return
        }
        print("success")
    }
}


