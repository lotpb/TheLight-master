//
//  Registration.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/6/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//
//

import SwiftUI

struct ShapeUI: View {
    var body: some View {

        HomeUI()
    }
}

struct ShapeUI_Previews: PreviewProvider {
    static var previews: some View {
        ShapeUI()
    }
}


struct HomeUI : View {

    @State var color = 0
    @State var height = UIScreen.main.bounds.height
    @State var width = UIScreen.main.bounds.width

    var body: some View{

        VStack{

            ZStack(alignment: .top){

                VStack{
                    Image(self.color == 0 ? "taylor_swift_profile" : "profile-rabbit-toy")
                    .resizable()
                    .frame(height: 225)
                    .frame(width: 225)


                    HStack(spacing: 20){

                        Button(action: {

                            self.color = 0

                        }) {

                            VStack(spacing: 8){

                                ZStack{

                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 20, height: 20)

                                    Circle()
                                        .stroke(self.color == 0 ? Color.white : Color.clear, lineWidth: 2)
                                        .frame(width: 30, height: 30)
                                }

                                Text("Yellow")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }

                        Button(action: {

                            self.color = 1

                        }) {

                            VStack(spacing: 8){

                                ZStack{

                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 20, height: 20)

                                    Circle()
                                        .stroke(self.color == 1 ? Color.white : Color.clear, lineWidth: 2)
                                        .frame(width: 30, height: 30)
                                }

                                Text("Orange")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                }

                HStack{

                    Button(action: {

                    }) {

                        Image(systemName: "house")
                            .renderingMode(.original)
                            .padding()
                    }
                    .padding(.leading, 10)
                    .padding(.top, 20)

                    Spacer()

                    Button(action: {

                    }) {

                        Image(systemName: "house")
                            .renderingMode(.original)
                            .padding()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, self.height > 800 ? 15 : 10)
                    .background(Color.white)
                    .clipShape(CustomShape(corner: .bottomLeft, radii: self.height > 800 ? 35 : 30))
                }

            }
            .background(self.color == 0 ? Color.yellow : Color.orange)
            .clipShape(CustomShape(corner: .bottomLeft, radii: 55))

            ScrollView(self.height > 800 ? .init() : .vertical, showsIndicators: false) {

                VStack{

                    HStack{

                        Text("Melodi Lamp")
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: {

                        }) {

                            Image("heart")
                                .renderingMode(.original)
                                .padding()
                        }
                        .background(self.color == 0 ? Color.yellow : Color.orange)
                        .clipShape(Circle())

                    }
                    .padding(.horizontal, 35)
                    .padding(.top,25)


                    Text("The lampshape provides directional lighting above the dining table and pleasant diffused light throught the room")
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 30)
                        .padding(.top,20)

                    Spacer(minLength: 0)

                    HStack(spacing: 10){

                        Button(action: {

                        }) {

                            VStack{

                                Image(systemName: "house")
                                    //.renderingMode(.original)
                                .foregroundColor(self.color == 0 ? Color.yellow : Color.orange)

                                Text("22 W")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.white))
                            }
                            .padding()
                        }
                        .background(Color(.systemGray4))
                        .cornerRadius(12)

                        Button(action: {

                        }) {

                            VStack{

                                Image(systemName: "house")
                                    //.renderingMode(.original)
                                .foregroundColor(self.color == 0 ? Color.yellow : Color.orange)

                                Text("24 CM")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.white))
                            }
                            .padding()
                        }
                        .background(Color(.systemGray4))
                        .cornerRadius(12)

                        Button(action: {

                        }) {

                            VStack{

                                Image(systemName: "house")
                                    //.renderingMode(.original)
                                .foregroundColor(self.color == 0 ? Color.yellow : Color.orange)

                                Text("26 CM")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.white))
                            }
                            .padding()
                        }
                        .background(Color(.systemGray4))
                        .cornerRadius(12)

                        Button(action: {

                        }) {

                            VStack{

                                Image(systemName: "house")
                                //.renderingMode(.original)
                                .foregroundColor(self.color == 0 ? Color.yellow : Color.orange)

                                Text("1.6 M")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.white))
                            }
                            .padding()
                        }
                        .background(Color(.systemGray4))
                        .cornerRadius(12)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 25)

                    Spacer(minLength: 0)
                }
            }

            HStack{

                Text("$12.99")
                    .foregroundColor(Color(.label))
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 35)
                    .padding(.bottom,25)

                Spacer()

                Button(action: {

                }) {

                    Text("Add to Cart")
                        .foregroundColor(.black)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 35)
                }
                .background(self.color == 0 ? Color.yellow : Color.orange)
                .clipShape(CustomShape(corner: .topLeft, radii: 55))

            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
        .animation(.default)
    }
}


struct CustomShape : Shape {

    var corner : UIRectCorner
    var radii : CGFloat

    func path(in rect: CGRect) -> Path {

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: radii, height: radii))

        return Path(path.cgPath)
    }
}

class Host : UIHostingController<ShapeUI> {

    override var prefersHomeIndicatorAutoHidden: Bool{

        return true
    }
}
