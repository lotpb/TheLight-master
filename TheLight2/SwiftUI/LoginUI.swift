//
//  LoginUI.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/7/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import SwiftUI

struct LoginUI: View {
    var body: some View {

        Login()
    }
}

struct LoginUI_Previews: PreviewProvider {
    static var previews: some View {
        LoginUI()
    }
}

struct Login : View {

    @State var user = ""
    @State var pass = ""

    var body : some View{

        VStack{
            Image("plus_photo")
            //.resizable().frame(width: 100, height: 100)

            Text("Sign In").fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)

            VStack(alignment: .leading){

                VStack(alignment: .leading){

                    Text("Username").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))

                    HStack{

                        TextField("Enter Your Username", text: $user)

                        if user != ""{

                            Image("checkmark").foregroundColor(Color.init(.label))
                        }

                    }

                    Divider()

                }.padding(.bottom, 15)

                VStack(alignment: .leading){

                    Text("Password").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))

                    SecureField("Enter Your Password", text: $pass)

                    Divider()
                }

                HStack{

                    Spacer()

                    Button(action: {

                    }) {

                        Text("Forget Password ?").foregroundColor(Color.gray.opacity(0.5))
                    }
                }

            }.padding(.horizontal, 6)


            bottomView()

        }.padding()
    }
}

struct bottomView : View{

    var body : some View{

        VStack{

            Button(action: {

            }) {

                Text("Sign In").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()


            }.background(Color(.systemOrange))
            .clipShape(Capsule())
            .padding(.top, 45)

            Text("(or)").foregroundColor(Color.gray.opacity(0.5)).padding(.top,30)

            HStack{

                Button(action: {

                }) {

                    Image("title_icon").renderingMode(.original).padding()


                }.background(Color(.systemGray6))
                .clipShape(Circle())

                Spacer()

                Button(action: {

                }) {

                   Image("title_icon").renderingMode(.original).padding()


                }.background(Color(.systemGray6))
                .clipShape(Circle())

                Spacer()

                Button(action: {

                }) {

                   Image("title_icon").renderingMode(.original).padding()


                }.background(Color(.systemGray6))
                .clipShape(Circle())

                Spacer()

                Button(action: {

                }) {

                   Image("title_icon").renderingMode(.original).padding()


                }.background(Color(.systemGray6))
                .clipShape(Circle())

            }.padding(.top, 25)

            HStack(spacing: 8){

                Text("Don't Have An Account ?").foregroundColor(Color.gray.opacity(0.5))

                Button(action: {

                }) {

                   Text("Sign Up")

                }.foregroundColor(.blue)

            }.padding(.top, 25)
        }
    }
}
