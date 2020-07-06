//
//  MenuBar.swift
//  youtube
//
//  Created by Brian Voong on 6/6/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cv.backgroundColor = .black
        } else {
            cv.backgroundColor = ColorX.youtubeRed
        }
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private let cellId = "cellId"
    private let imageNames = ["house.fill", "flame.fill", "car.fill", "person.fill"]
    
    var homeController: News?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        
        setupHorizontalBar()
    }
    
    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
    
    func setupHorizontalBar() {
        
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalBarView)
        
        horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftAnchorConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/4),
            horizontalBarView.heightAnchor.constraint(equalToConstant: 4)
            ])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        homeController?.scrollToMenuIndex(menuIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            cell.tintColor = .darkGray
        } else {
            cell.tintColor = UIColor.rgb(red: 91, green: 14, blue: 13)
        }
        cell.imageView1.image = UIImage(systemName: imageNames[indexPath.item])?.withRenderingMode(.alwaysTemplate)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return .init(width: frame.width / 4, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@available(iOS 13.0, *)
class MenuCell: CollectionViewCell {
    
    let imageView1: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "house.fill")
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            iv.tintColor = .darkGray
        } else {
            iv.tintColor = UIColor.rgb(red: 91, green: 14, blue: 13)
        }
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                imageView1.tintColor = isHighlighted ? UIColor.white : .darkGray
            } else {
                imageView1.tintColor = isHighlighted ? UIColor.white : UIColor.rgb(red: 91, green: 14, blue: 13)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if UIDevice.current.userInterfaceIdiom == .pad  {
                imageView1.tintColor = isSelected ? UIColor.white : .darkGray
            } else {
                imageView1.tintColor = isSelected ? UIColor.white : UIColor.rgb(red: 91, green: 14, blue: 13)
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView1)
        addConstraintsWithFormat(format: "H:[v0(28)]", views: imageView1)
        addConstraintsWithFormat(format: "V:[v0(28)]", views: imageView1)
        
        addConstraint(NSLayoutConstraint(item: imageView1, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView1, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    } 
}








