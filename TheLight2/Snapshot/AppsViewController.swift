//
//  ViewController.swift
//  TapStore
//
//  Created by Paul Hudson on 01/10/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class AppsViewController: UIViewController {
    //let sections = Bundle.main.decode([Section].self, from: "appstore.json")
    var collectionView: UICollectionView!

    //var dataSource: UICollectionViewDiffableDataSource<Section, App>?

    override func viewDidLoad() {
        super.viewDidLoad()

        //collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)

        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseIdentifier)
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
        //collectionView.register(MediumTableCell.self, forCellWithReuseIdentifier: MediumTableCell.reuseIdentifier)
        //collectionView.register(SmallTableCell.self, forCellWithReuseIdentifier: SmallTableCell.reuseIdentifier)

        //createDataSource()
        //reloadData()
    }


}

