//
//  ViewController.swift
//  RecreatingAppStore
//
//  Created by Yu Sun on 26/10/17.
//  Copyright © 2017 Yu Sun. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Parse

class FeaturedAppController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    private let largeCellId = "largeCellId"
    private let headerId = "headerId"
    
    var appStore: AppStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadData()
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight Software - Snapshot"
        } else {
            navigationItem.title = "Snapshot"
        }
        self.navigationItem.largeTitleDisplayMode = .always
        
        
        AppCategory.fetchFeaturedApps { (appStore) in
            self.appStore = appStore
            self.collectionView?.reloadData()
        } 
        
        if #available(iOS 13.0, *) {
            collectionView?.backgroundColor = Color.Snap.collectbackColor
        } else {
            // Fallback on earlier versions
        } //UIColor.white
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(LargeCategoryCell.self, forCellWithReuseIdentifier: largeCellId)
        collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = appStore?.categories?.count { return count }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeCellId, for: indexPath) as! LargeCategoryCell
            cell.appCategory = appStore?.categories?[indexPath.item]
            
            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
        
        cell.appCategory = appStore?.categories?[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 2 {
            return .init(width: view.frame.width, height: 160)
        }
        return .init(width: view.frame.width, height: 230)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! Header
        
        header.appCategory = appStore?.bannerCategory
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 120)
    }
}


class Header: CategoryCell {
    
    private let bannerCellId = "bannerCellId"
    /*
    var userpost: UserModel? {
        didSet {
            
            guard let postImageUrl = userpost?.profileImageUrl else {return}
            imageView.loadImage(urlString: postImageUrl)
            nameLabel.text = userpost?.username
        }
    } */

    override func setupView() {
/*
        ref.child("users").observe(.childAdded , with:{ (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let post = UserModel(dictionary: dictionary)
            self.userlist.append(post)
            
            DispatchQueue.main.async(execute: {
                self.appsCollectionView.reloadData()
            })
        })
        
        var userlist = [UserModel]()
        
        
        
        let imageView: CustomImageView = {
            let imageView = CustomImageView()
            imageView.isUserInteractionEnabled = true
            imageView.backgroundColor = .black
            imageView.image = UIImage(named: "")
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }() */

    
        appsCollectionView.dataSource = self
        appsCollectionView.delegate = self

        appsCollectionView.register(BannerCell.self, forCellWithReuseIdentifier: bannerCellId)

        addSubview(appsCollectionView)
        NSLayoutConstraint.activate([
                appsCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
                appsCollectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
                appsCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
                appsCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)

            ])
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: frame.width / 2 + 50, height: frame.height)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerCellId, for: indexPath) as! BannerCell

        cell.app = appCategory?.apps?[indexPath.item]
        //cell.news = newslist[indexPath.item]

        return cell
    }

    private class BannerCell: AppCell {
        
        override func setupView() {

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 30
            imageView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
            imageView.layer.borderWidth = 0.5
            addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: self.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
                imageView.rightAnchor.constraint(equalTo: self.rightAnchor)
                ])
        }

    }
}
class LargeCategoryCell: CategoryCell {

    private let largeAppCellId = "LargeCellId"
    
    override func setupView() {
        super.setupView()
        appsCollectionView.register(LargeAppCell.self, forCellWithReuseIdentifier: largeAppCellId)
    }
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 200, height: frame.height - 32)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeAppCellId, for: indexPath) as! AppCell
        
        //cell.app = appCategory?.apps![indexPath.item]
        cell.news = newslist[indexPath.item]
        
        return cell
    }
    
    private class LargeAppCell: AppCell {
        override func setupView() {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
                    imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14),
                    imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
                    imageView.rightAnchor.constraint(equalTo: self.rightAnchor)
                ])
        }
        
    }
}


