//
//  File.swift
//  TheLight2
//
//  Created by Peter Balsamo on 9/24/18.
//  Copyright © 2018 Peter Balsamo. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class PlaceMenuBar: UIView {
    
    lazy var menuView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        //view.layer.borderColor = UIColor.systemBackground.cgColor
        //view.layer.borderWidth = 1
        //view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let drivestextLabel: UILabel = {
        let label = UILabel()
        label.text = "Driven"
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let miletextLabel: UILabel = {
        let label = UILabel()
        label.text = "Miles Driven"
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loggedtextLabel: UILabel = {
        let label = UILabel()
        label.text = "Logged"
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let drivesLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .center
        label.textColor = Color.twitterBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let mileLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .center
        label.textColor = Color.twitterBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loggedLabel: UILabel = {
        let label = UILabel()
        label.text = "$0.0"
        label.textAlignment = .center
        label.textColor = Color.twitterBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var placeController: PlacesCollectionView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drivesLabel.text = String(LocationsStorage.shared.locations.count)
        setupHorizontalBar()
    }
    
    func setupHorizontalBar() {
        
        miletextLabel.font = Font.celltitle12m
        drivestextLabel.font = Font.celltitle12m
        loggedtextLabel.font = Font.celltitle12m
        mileLabel.font = Font.celltitle18m
        drivesLabel.font = Font.celltitle18m
        loggedLabel.font = Font.celltitle18m
        
        addSubview(menuView)
        menuView.addSubview(miletextLabel)
        menuView.addSubview(drivestextLabel)
        menuView.addSubview(loggedtextLabel)
        menuView.addSubview(mileLabel)
        menuView.addSubview(drivesLabel)
        menuView.addSubview(loggedLabel)
        
        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            menuView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            menuView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            menuView.heightAnchor.constraint(equalToConstant: 50),
            
            drivestextLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            drivestextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            drivestextLabel.widthAnchor.constraint(equalToConstant: 70),
            drivestextLabel.heightAnchor.constraint(equalToConstant: 20),
            
            miletextLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            miletextLabel.widthAnchor.constraint(equalToConstant: 75),
            miletextLabel.heightAnchor.constraint(equalToConstant: 20),
            miletextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            loggedtextLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            loggedtextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            loggedtextLabel.widthAnchor.constraint(equalToConstant: 70),
            loggedtextLabel.heightAnchor.constraint(equalToConstant: 20),
            
            drivesLabel.topAnchor.constraint(equalTo: miletextLabel.bottomAnchor, constant: 1),
            drivesLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            drivesLabel.widthAnchor.constraint(equalToConstant: 70),
            drivesLabel.heightAnchor.constraint(equalToConstant: 20),
            
            mileLabel.topAnchor.constraint(equalTo: drivestextLabel.bottomAnchor, constant: 1),
            mileLabel.widthAnchor.constraint(equalToConstant: 75),
            mileLabel.heightAnchor.constraint(equalToConstant: 20),
            mileLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            loggedLabel.topAnchor.constraint(equalTo: loggedtextLabel.bottomAnchor, constant: 1),
            loggedLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            loggedLabel.widthAnchor.constraint(equalToConstant: 70),
            loggedLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
