//
//  MessageUI.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/10/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import SwiftUI

struct MessageUI: View {
    var body: some View {

        HomeMessage()
    }
}

struct MessageUI_Previews: PreviewProvider {
    static var previews: some View {
        MessageUI()
    }
}

struct HomeMessage : View {

    @State var index = 0
    @State var expand = false

    var body : some View{

        ZStack{

            VStack{

                Color.white
                Color(.red)
            }

            VStack{

                ZStack{

                    Chats(expand: self.$expand).opacity(self.index == 0 ? 1 : 0)

                    Groups().opacity(self.index == 1 ? 1 : 0)

                    Settings().opacity(self.index == 2 ? 1 : 0)
                }

                BottomView(index: self.$index)

            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct Chats : View {

    @Binding var expand : Bool

    var body : some View{

        VStack(spacing: 0){

            TopView(expand: self.$expand).zIndex(25)

            Centerview(expand: self.$expand).offset(y: -25)
        }
    }
}

struct Groups : View {

    var body : some View{

        GeometryReader{_ in

            VStack{

                Text("Group")
            }

        }
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
        .background(Color(.label))
        .clipShape(shape())
        .padding(.bottom, 25)
    }
}

struct Settings : View {

    var body : some View{

        GeometryReader{_ in

            VStack{

                Text("Settings")

            }
        }
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
        .background(Color.red)
        .clipShape(shape())
        .padding(.bottom, 25)
    }
}

struct TopView : View {

    @State var search = ""
    @Binding var expand : Bool

    var body : some View{

        VStack(spacing: 22){

            if self.expand{

                HStack{

                    Text("Messages")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color.black.opacity(0.7))

                    Spacer()

                    Button(action: {

                    }) {

                        Image(systemName: "lightbulb")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.black.opacity(0.4))
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {

                    HStack(spacing: 18){

                        Button(action: {

                        }) {

                            Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                                .foregroundColor(Color(.red))
                            .padding(18)

                        }.background(Color(.systemGroupedBackground).opacity(0.5))
                        .clipShape(Circle())

                        ForEach(1...7,id: \.self){i in

                            Button(action: {

                            }) {

                                Image("Icon-167")
                                //Image("p\(i)")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 60, height: 60)

                            }.background(Color(.systemGroupedBackground).opacity(0.5))
                            .clipShape(Circle())
                        }
                    }
                }

            }

            HStack(spacing: 15){

                Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(Color.black.opacity(0.3))

                TextField("Search", text: self.$search)

            }.padding()
                .background(Color(.systemGray5))
            .cornerRadius(8)
            .padding(.bottom, 10)

        }.padding()
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .background(Color(.secondarySystemGroupedBackground))
        .clipShape(shape())
        .animation(.default)

    }
}

struct Centerview : View {

    @Binding var expand : Bool

    var body : some View{

        List(data){i in

            if i.id == 0{

                cellView(data : i)
                .onAppear {

                    self.expand = true
                }
                .onDisappear {

                    self.expand = false
                }
            }
            else{

                cellView(data : i)
            }

        }
        .padding(.top, 20)
        .background(Color.white)
        .clipShape(shape())
    }
}

struct BottomView : View {

    @Binding var index : Int

    var body : some View{

        HStack{

            Button(action: {

                self.index = 0

            }) {

                Image(systemName: "message.fill")
                .resizable()
                .frame(width: 25, height: 25)
                    .foregroundColor(self.index == 0 ? Color.white : Color.white.opacity(0.5))
                .padding(.horizontal)
            }

            Spacer(minLength: 10)

            Button(action: {

                self.index = 1

            }) {

                Image(systemName: "message.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(self.index == 1 ? Color.white : Color.white.opacity(0.5))
                .padding(.horizontal)
            }

            Spacer(minLength: 10)

            Button(action: {

                self.index = 2

            }) {

                Image(systemName: "message.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(self.index == 2 ? Color.white : Color.white.opacity(0.5))
                .padding(.horizontal)
            }

        }.padding(.horizontal, 30)
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
    }
}

struct cellView : View {

    var data : Msg

    var body : some View{

        HStack(spacing: 12){

            Image(data.img)
            .resizable()
            .frame(width: 55, height: 55)

            VStack(alignment: .leading, spacing: 12) {

                Text(data.name)

                Text(data.msg).font(.caption)
            }

            Spacer(minLength: 0)

            VStack{

                Text(data.date)

                Spacer()
            }
        }.padding(.vertical)
    }
}

struct shape : Shape {

    func path(in rect: CGRect) -> Path {

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 30, height: 30))

        return Path(path.cgPath)
    }
}


struct Msg : Identifiable, Codable {

    var id : Int
    var name : String
    var msg : String
    var date : String
    var img : String
}

var data = [

    Msg(id: 0, name: "Emily", msg: "Hello!!!", date: "25/03/20",img: "Icon-167"),
    Msg(id: 1, name: "Jonh", msg: "How Are You ???", date: "22/03/20",img: "Icon-167"),
    Msg(id: 2, name: "Catherine", msg: "New Tutorial From Kavsoft", date: "20/03/20",img: "Icon-167"),
    Msg(id: 3, name: "Emma", msg: "Hey Everyone", date: "25/03/20",img: "Icon-167"),
    Msg(id: 4, name: "Lina", msg: "SwiftUI Tutorials", date: "25/03/20",img: "Icon-167"),
    Msg(id: 5, name: "Steve Jobs", msg: "New Apple iPhone", date: "15/03/20",img: "Icon-167"),
    Msg(id: 6, name: "Roy", msg: "Hey Guys!!!", date: "25/03/20",img: "Icon-167"),
    Msg(id: 7, name: "Julia", msg: "Hello!!!", date: "25/03/20",img: "Icon-167"),
    Msg(id: 8, name: "Watson", msg: "How Are You ???", date: "22/03/20",img: "Icon-167"),
    Msg(id: 9, name: "Kavuya", msg: "New Tutorial From Kavsoft", date: "20/03/20",img: "Icon-167"),
    Msg(id: 10, name: "Julie", msg: "Hey Everyone", date: "25/03/20",img: "Icon-167"),
    Msg(id: 11, name: "Lisa", msg: "SwiftUI Tutorials", date: "25/03/20",img: "Icon-167"),

]

