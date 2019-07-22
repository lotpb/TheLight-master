//
//  CustomTableCell.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 10/12/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseDatabase
//import Parse

class TableViewCell: UITableViewCell {
    var defaults = UserDefaults.standard
    var _feedItems = NSMutableArray()
    
    //firebase
    var blogpost: BlogModel? {
        didSet {
           
            blogtitleLabel.text = blogpost?.postBy
            blogsubtitleLabel.text = blogpost?.subject
            blogmsgDateLabel.text = blogpost?.creationDate.timeAgoDisplay()
            //customImageView.frame = .init(x: 10, y: 10, width: 50, height: 50)
            
            var Liked:Int? = blogpost?.liked as? Int
            if Liked == nil { Liked = 0 }
            numLabel?.text = "\(Liked!)"
            
            var CommentCount:Int? = blogpost?.commentCount as? Int
            if CommentCount == nil { CommentCount = 0 }
            commentLabel?.text = "\(CommentCount!)"
            
            if (defaults.bool(forKey: "parsedataKey")) {
                
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("users")
                    .queryOrdered(byChild: "uid")
                    .queryEqual(toValue: blogpost?.uid)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            let profileImageUrl = userDict["profileImageUrl"] as? String
                            self.customImageView.loadImage(urlString: profileImageUrl!)
                        }
                    })
            }
        }
    }
    
    var feedItems: Database! {
        didSet {
            
            leadtitleLabel!.text = _feedItems.value(forKey: "LastName") as? String ?? ""
            leadsubtitleLabel!.text = _feedItems.value(forKey: "City") as? String ?? ""
            myLabel10.text = _feedItems.value(forKey: "Date") as? String ?? ""
            myLabel20.text = _feedItems.value(forKey: "CallBack") as? String ?? ""
            
            if (_feedItems.value(forKey: "Coments") as? String == nil) || (_feedItems.value(forKey: "Coments") as? String == "") {
                
                leadreplyButton!.tintColor = .lightGray
            } else {
                leadreplyButton!.tintColor = Color.Lead.buttonColor
            }
            
            if (_feedItems.value(forKey: "Active") as? Int == 1 ) {
                leadlikeButton!.tintColor = Color.Lead.buttonColor
                leadlikeLabel.text! = "Active"
                leadlikeLabel.adjustsFontSizeToFitWidth = true
            } else {
                leadlikeButton!.tintColor = .lightGray
                leadlikeLabel.text! = ""
            }
            
        }
    }
    
    var leadpost: LeadModel? {
        didSet {
            
            if (defaults.bool(forKey: "parsedataKey")) {
               
            } else {
                
                leadtitleLabel.text = leadpost?.lastname
                
                leadsubtitleLabel.text = String(format: "%@ %@ %@", (leadpost?.city)!,
                                                (leadpost?.state)!,
                                                (leadpost?.zip)!).removeWhiteSpace()
                
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MMM dd yy"
                myLabel10.text = dateFormat.string(from: (leadpost?.creationDate)!) as String
                myLabel20.text = leadpost?.callback
                myLabel20.adjustsFontSizeToFitWidth = true
                
                var Liked:Int? = leadpost?.active as? Int
                if Liked == nil { Liked = 0 }
                leadlikeLabel?.text = "\(Liked!)"
                
                if leadpost?.comments == "" {
                    leadreplyButton!.tintColor = .lightGray
                } else {
                    leadreplyButton!.tintColor = Color.Lead.buttonColor
                }
                
                if leadpost?.active as? Int == 1 {
                    leadlikeButton!.tintColor = Color.Lead.buttonColor
                    leadlikeLabel.text! = "Active"
                    leadlikeLabel.sizeToFit()
                } else {
                    leadlikeButton!.tintColor = .lightGray
                    leadlikeLabel.text! = ""
                }
            }
        }
    }
    
    func configureLeadEntry(_ lead: LeadModel) {

        leadtitleLabel!.font = Font.celltitle20m
        leadsubtitleLabel!.font = Font.celltitle16r
        leadreplyLabel.font = Font.celltitle16r
        leadlikeLabel.font = Font.celltitle14r
        myLabel10.font = Font.celltitle16r
        myLabel20.font = Font.celltitle16m
    }
    
    var custpost: CustModel? {
        didSet {
            
            if #available(iOS 13.0, *) {
                custtitleLabel.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            custtitleLabel.text = custpost?.lastname
            
            custsubtitleLabel.text = String(format: "%@ %@ %@", (custpost?.city)!,
                                            (custpost?.state)!,
                                            (custpost?.zip)!).removeWhiteSpace()
            
            custlikeLabel.text = custpost?.rate
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            myLabel10.text = dateFormat.string(from: (custpost?.creationDate)!) as String
            
            var Amount = custpost?.amount as? Int
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if Amount == nil {
                Amount = 0
            }
            myLabel20.text = formatter.string(from: Amount! as NSNumber)
            
            if custpost?.comments == "" {
                custreplyButton!.tintColor = .lightGray
            } else {
                custreplyButton!.tintColor = Color.Cust.buttonColor
            }
            
            if custpost?.active as? Int == 1 {
                custreplyLabel.text! = "Active"
                custreplyLabel.adjustsFontSizeToFitWidth = true
            } else {
                custreplyLabel.text! = ""
            }
            
            if custpost?.rate == "A" {
                custlikeButton!.tintColor = Color.Cust.buttonColor
            } else {
                custlikeButton!.tintColor = .lightGray
            }
        }
    }
    
    var vendpost: VendModel? {
        didSet {
            if #available(iOS 13.0, *) {
                vendtitleLabel.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            vendtitleLabel.text = vendpost?.vendor
            
            if vendpost?.profession == "" {
                vendsubtitleLabel.text = "No profession available"
            } else {
                vendsubtitleLabel.text = vendpost?.profession
            }
            
            var Liked:Int? = leadpost?.active as? Int
            if Liked == nil { Liked = 0 }
            vendlikeLabel?.text = "\(Liked!)"
            
            if vendpost?.comments == "" {
                vendreplyButton!.tintColor = .lightGray
            } else {
                vendreplyButton!.tintColor = Color.Vend.buttonColor
            }
            
            if vendpost?.active as? Int == 1 {
                vendlikeButton!.tintColor = Color.Vend.buttonColor
                vendlikeLabel.text! = "Active"
                vendlikeLabel.sizeToFit()
            } else {
                vendlikeButton!.tintColor = .lightGray
                vendlikeLabel.text! = ""
            }
        }
    }
    
    var employpost: EmployModel? {
        didSet {
            
            if #available(iOS 13.0, *) {
                employtitleLabel.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            employtitleLabel.text = String(format: "%@ %@ %@", (employpost?.first)!,
                                           (employpost?.lastname)!,
                                           (employpost?.company)!).removeWhiteSpace()
            
            if employpost?.title == "" {
                employsubtitleLabel.text = "No title available"
            } else {
                employsubtitleLabel.text = employpost?.title
            }
            /*
             employsubtitleLabel.text = String(format: "%@ %@ %@", (employpost?.city)!,
             (employpost?.state)!,
             (employpost?.zip)!).removeWhiteSpace() */
            
            var Liked:Int? = leadpost?.active as? Int
            if Liked == nil { Liked = 0 }
            employlikeLabel?.text = "\(Liked!)"
            
            if employpost?.comments == "" {
                employreplyButton!.tintColor = .lightGray
            } else {
                employreplyButton!.tintColor = Color.Employ.buttonColor
            }
            
            if employpost?.active as? Int == 1 {
                employlikeButton!.tintColor = Color.Employ.buttonColor
                employlikeLabel.text! = "Active"
                employlikeLabel.sizeToFit()
            } else {
                employlikeButton!.tintColor = .lightGray
                employlikeLabel.text! = ""
            }
        }
    }
    
    var userpost: UserModel? {
        didSet {
            
            guard let postImageUrl = userpost?.profileImageUrl else {return}
            customImageView.loadImage(urlString: postImageUrl)
            
            usertitleLabel.text = userpost?.username
            usersubtitleLabel.text = userpost?.creationDate.timeAgoDisplay()
        }
    }
    
    var salespost: SalesModel? {
        didSet {
            
            //guard let postImageUrl = userpost?.profileImageUrl else {return}
            //customImageView.loadImage(urlString: postImageUrl)
            customImageView.frame = .init(x: 10, y: 10, width: 40, height: 40)
            customImageView.layer.cornerRadius = (customImageView.frame.size.width) / 2
            customImageView.image = #imageLiteral(resourceName: "profile-rabbit-toy")
            
            salestitleLabel.text = salespost?.salesman
        }
    }
    
    var prodpost: ProdModel? {
        didSet {
            customImageView.frame = .init(x: 10, y: 10, width: 40, height: 40)
            //customImageView.layer.cornerRadius = (customImageView.frame.size.width) / 2
            customImageView.image = #imageLiteral(resourceName: "profile-rabbit-toy")
            prodtitleLabel.text = prodpost?.products
        }
    }
    
    var jobpost: JobModel? {
        didSet {
            customImageView.frame = .init(x: 0, y: 0, width: 0, height: 0)
            jobtitleLabel.text = jobpost?.description
        }
    }
    
    var adpost: AdModel? {
        didSet {
            customImageView.frame = .init(x: 0, y: 0, width: 0, height: 0)
            adtitleLabel.text = adpost?.advertiser
        }
    }
    
    var zippost: ZipModel? {
        didSet {
            customImageView.frame = .init(x: 0, y: 0, width: 0, height: 0)
            ziptitleLabel.text = String(format: "%@, %@", (zippost?.city)!, (zippost?.state)!).removeWhiteSpace()
        }
    }
    
    let customImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.frame = .init(x: 10, y: 11, width: 50, height: 50)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = (imageView.frame.size.width) / 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let customImagelabel: UILabel = {
        let label = UILabel()
        label.frame = .init(x: 10, y: 10, width: 40, height: 40)
        label.backgroundColor = Color.Table.labelColor
        label.text = ""
        label.font = Font.celltitle14m
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 20.0
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let myLabel10: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.masksToBounds = true
        return label
    }()
    
    let myLabel20: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.adjustsFontSizeToFitWidth = true
        label.layer.masksToBounds = true
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        
    }
    
    func setupViews() {
        
        addSubview(customImageView)
        addSubview(customImagelabel)
        addSubview(myLabel10)
        addSubview(myLabel20)
        
        NSLayoutConstraint.activate([
            myLabel10.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            myLabel10.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            myLabel10.widthAnchor.constraint(equalToConstant: 100),
            myLabel10.heightAnchor.constraint(equalToConstant: 32),
            myLabel20.topAnchor.constraint(equalTo: myLabel10.bottomAnchor, constant: 0),
            myLabel20.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            myLabel20.widthAnchor.constraint(equalToConstant: 100),
            myLabel20.heightAnchor.constraint(equalToConstant: 33)
            ])
    }
    
    // Snapshot Controller
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var snaptitleLabel: UILabel!
    @IBOutlet weak var snapdetailLabel: UILabel!
    
    // Ad Controller
    @IBOutlet weak var adtitleLabel: UILabel!
    
    // Product Controller
    @IBOutlet weak var prodtitleLabel: UILabel!
    
    // Job Controller
    @IBOutlet weak var jobtitleLabel: UILabel!
    
    // salesman Controller
    @IBOutlet weak var salestitleLabel: UILabel!
    
    // zip Controller
    @IBOutlet weak var ziptitleLabel: UILabel!
    
    // BUser Controller
    @IBOutlet weak var usertitleLabel: UILabel!
    @IBOutlet weak var usersubtitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // Lead Controller
    @IBOutlet weak var leadtitleLabel: UILabel!
    @IBOutlet weak var leadsubtitleLabel: UILabel!
    @IBOutlet weak var leadImageView: UIImageView!
    @IBOutlet weak var leadreplyButton: UIButton!
    @IBOutlet weak var leadlikeButton: UIButton!
    @IBOutlet weak var leadreplyLabel: UILabel!
    @IBOutlet weak var leadlikeLabel: UILabel!
    
    // LeadDetailController
    @IBOutlet weak var leadtitleDetail: UILabel!
    @IBOutlet weak var leadsubtitleDetail: UILabel!
    @IBOutlet weak var leadreadDetail: UILabel!
    @IBOutlet weak var leadnewsDetail: UILabel!
    
    // Customer Controller
    @IBOutlet weak var custtitleLabel: UILabel!
    @IBOutlet weak var custsubtitleLabel: UILabel!
    @IBOutlet weak var custImageView: UIImageView!
    @IBOutlet weak var custreplyButton: UIButton!
    @IBOutlet weak var custlikeButton: UIButton!
    @IBOutlet weak var custreplyLabel: UILabel!
    @IBOutlet weak var custlikeLabel: UILabel!
    
    // Vendor Controller
    @IBOutlet weak var vendtitleLabel: UILabel!
    @IBOutlet weak var vendsubtitleLabel: UILabel!
    @IBOutlet weak var vendImageView: UIImageView!
    @IBOutlet weak var vendreplyButton: UIButton!
    @IBOutlet weak var vendlikeButton: UIButton!
    @IBOutlet weak var vendreplyLabel: UILabel!
    @IBOutlet weak var vendlikeLabel: UILabel!
    
    // Employee Controller
    @IBOutlet weak var employtitleLabel: UILabel!
    @IBOutlet weak var employsubtitleLabel: UILabel!
    @IBOutlet weak var employImageView: UIImageView!
    @IBOutlet weak var employreplyButton: UIButton!
    @IBOutlet weak var employlikeButton: UIButton!
    @IBOutlet weak var employreplyLabel: UILabel!
    @IBOutlet weak var employlikeLabel: UILabel!
    
    // BlogEditView
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var msgDateLabel: UILabel!
    //IBOutlet weak var blogImageView: UIImageView!
    
    // BlogController
    @IBOutlet weak var blogtitleLabel: UILabel!
    @IBOutlet weak var blogsubtitleLabel: UILabel!
    @IBOutlet weak var blogmsgDateLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    
}
