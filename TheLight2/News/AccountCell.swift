//
//  AccountCell.swift
//  TheLight
//
//  Created by Peter Balsamo on 9/22/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices //kUTTypeImage

@available(iOS 13.0, *)
final class AccountCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var image = ["clock", "arrowtriangle.right.fill", "bell", "clock.fill"]
    private var items = ["clock", "My Videos", "Notifications", "Watch Later"]
    
    private var image1 = ["profile-rabbit-toy", "taylor_swift_profile", "profile-rabbit-toy", "taylor_swift_profile"]
    private var items1 = ["All Videos", "Favorites", "Liked videos", "My Top Videos"]
    private var itemsDetail1 = ["80 videos", "106 videos", "76 videos", "42 videos"]
    
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var userimageView: UIImageView?
    

    let headerImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Acctimages"))
        imageView.contentMode = .scaleAspectFill

        let overlay = UIView(frame: imageView.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.1)
        imageView.addSubview(overlay)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        let defaults = UserDefaults.standard
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query:PFQuery = PFUser.query()!
            query.whereKey("username", equalTo: defaults.object(forKey: "usernameKey") as! String)
            query.limit = 1
            query.cachePolicy = .cacheThenNetwork
            query.getFirstObjectInBackground { object, error in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                        imageFile.getDataInBackground { imageData, error in
                            imageView.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
        } else {
            //firebase
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let usertitleLabel: UILabel = {
        let defaults = UserDefaults.standard
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = defaults.object(forKey: "usernameKey") as! String?
        label.sizeToFit()
        label.textColor = .red
        return label
    }()
    
    lazy var nameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .red
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        return button
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondarySystemGroupedBackground
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemGroupedBackground
        //self.userimageView?.tintColor = .black
        
        let floatingButton = UIButton(frame: .init(x: frame.size.width - 70, y: 65, width: 50, height: 50))
        floatingButton.layer.cornerRadius = floatingButton.frame.size.width / 2
        floatingButton.backgroundColor = ColorX.News.navColor
        floatingButton.tintColor = .white
        floatingButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        floatingButton.addTarget(self, action: #selector(selectCamera), for: .touchUpInside)
        
        registerCells()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        //tableView.addSubview(refreshControl)

        addSubview(headerImageView)
        addSubview(userProfileImageView)
        addSubview(usertitleLabel)
        addSubview(nameButton)
        addSubview(tableView)
        addSubview(floatingButton)

        NSLayoutConstraint.activate([
        headerImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
        headerImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
        headerImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
        headerImageView.heightAnchor.constraint(equalToConstant: 90),
        ])

        //horizontal constraints
        //addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: headerImageView)
        addConstraintsWithFormat(format: "H:|-16-[v0(44)]", views: userProfileImageView)
        addConstraintsWithFormat(format: "H:|-16-[v0]-10-[v1(15)]", views: usertitleLabel, nameButton)
        addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: tableView)
        
        //vertical constraints
        //addConstraintsWithFormat(format: "V:|-0-[v0(90)]", views: headerImageView)
        addConstraintsWithFormat(format: "V:|-15-[v0(44)]", views: userProfileImageView)
        addConstraintsWithFormat(format: "V:|-60-[v0(30)]-60-[v1(6)]", views: usertitleLabel, nameButton)
        addConstraintsWithFormat(format: "V:|-91-[v0]-0-|", views: tableView)
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: nameButton, attribute: .top, relatedBy: .equal, toItem: userProfileImageView, attribute: .bottom, multiplier: 1, constant: 13))
        //left constraint
        addConstraint(NSLayoutConstraint(item: nameButton, attribute: .left, relatedBy: .equal, toItem: usertitleLabel, attribute: .right, multiplier: 1, constant: 10))

    }
    
    
    private func registerCells() {
        tableView.register(AccountViewCell.self, forCellReuseIdentifier: "accountcell")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return self.items.count
        } else if (section == 1) {
            return self.items1.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if ((indexPath).section == 0) {
            let result:CGFloat = 44
            
            return result
        }
        else if ((indexPath).section == 1) {
            let result:CGFloat = 54
            
            return result
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "accountcell", for: indexPath) as! AccountViewCell
        
        cell.selectionStyle = .none
        cell.detailLabel.textColor = .systemGray //UIColor(white: 0.5, alpha: 1)
        self.tableView.separatorStyle = .none
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            
            cell.titleLabel.font =  Font.celltitle16r
            cell.detailLabel.font =  Font.News.newslabel2
            
        } else {
            
            cell.titleLabel.font =  Font.celltitle16r
            cell.detailLabel.font =  Font.News.newslabel2

        }
        
        if (indexPath.section == 0) {
            
            cell.titleImage.frame = .init(x: 28, y: 12, width: 20, height: 20)
            cell.titleLabel.frame = .init(x: 75, y: 10, width: tableView.frame.width, height: 20.0)
            
            cell.titleImage.image = UIImage.init(systemName: self.image[indexPath.row])
            cell.titleLabel.text = self.items[indexPath.row]
            
            return cell
        }
        
        if (indexPath.section == 1) {
            
            cell.titleImage.frame = .init(x: 15, y: 10, width: 45, height: 45)
            cell.titleLabel.frame = .init(x: 75, y: 10, width: tableView.frame.width, height: 20.0)
            cell.detailLabel.frame = .init(x: 75, y: 30, width: tableView.frame.width, height: 20.0)
            
            cell.titleImage.image = UIImage.init(named: self.image1[indexPath.row])
            cell.titleLabel.text = self.items1[indexPath.row]
            cell.detailLabel.text = self.itemsDetail1[indexPath.row]
            
            return cell
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        } else if (section == 1) {
            return 44
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = .secondarySystemGroupedBackground
        
        if (section == 1) {
            
            let topBorder = CALayer()
            let width = CGFloat(2.0)
            topBorder.borderColor = UIColor.lightGray.cgColor
            topBorder.frame = .init(x: 0, y: 0, width: tableView.frame.width, height: 0.5)
            topBorder.borderWidth = width
            vw.layer.addSublayer(topBorder)
            vw.layer.masksToBounds = true
            
            let myLabel1:UILabel = UILabel(frame: .init(x: 16, y: 12, width: 10, height: 20))
            myLabel1.textColor = .label
            myLabel1.text = "Library (A-Z)"
            myLabel1.sizeToFit()
            //myLabel1.font = Font.headtitle
            vw.addSubview(myLabel1)
            
            let sortButton = UIButton(frame: .init(x: 120, y: 18, width: 10, height: 7))
            sortButton.tintColor = .black
            sortButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            vw.addSubview(sortButton)
            
            return vw
        }
        return vw
    }
    
    // MARK: - Button
    // MARK: Video
    
    @objc func selectCamera(_ sender: AnyObject) {
        
    }
    
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
            guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
            self.headerImageView.image = image
            picker.dismiss(animated: true) */
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class AccountViewCell: UITableViewCell {
    
    let titleImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "taylor_swift_profile"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Taylor Swift - Blank Space"
        label.numberOfLines = 2
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Taylor Swift - Blank Space"
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
  
        addSubview(titleImage)
        addSubview(titleLabel)
        addSubview(detailLabel)
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
