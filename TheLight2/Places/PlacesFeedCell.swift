//
//  PlacesCell.swift
//  TheLight2
//
//  Created by Peter Balsamo on 9/22/18.
//  Copyright © 2018 Peter Balsamo. All rights reserved.
//

import UIKit
import Firebase

@available(iOS 13.0, *)
class PlaceFeedCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    //firebase
    var visitlist = [VisitModel]()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching:CGFloat = 3.0

    var defaults = UserDefaults.standard
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemFill
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear //Color.News.navColor
        refreshControl.tintColor = .lightGray
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        beginBatchFetch()

        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.register(PlaceCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView.addSubview(self.refreshControl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - refresh
    @objc func refreshData() {
        DispatchQueue.main.async { //added
            self.collectionView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - NavigationController Hidden
    func fetchPosts(completion:@escaping (_ posts:[VisitModel])->()) {
        if ((defaults.string(forKey: "backendKey")) == "Firebase") {
            //firebase
            FirebaseRef.databaseRoot.child("visits").child("test").queryLimited(toLast: 20)
                .observe(.childAdded , with:{ (snapshot) in

                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let post = VisitModel(dictionary: dictionary)
                    self.visitlist.append(post)

                    self.visitlist.sort(by: { (p1, p2) -> Bool in
                        return p1.arrivaldate.compare(p2.arrivaldate) == .orderedDescending
                    })
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                }) { (err) in
                    print("Failed to fetch posts:", err)
            }
        }
    }

    func beginBatchFetch() {
        fetchingMore = true
        self.collectionView.reloadSections(IndexSet(integer: 0))

        fetchPosts { newPosts in
            self.visitlist.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //fetch
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            if !fetchingMore && !endReached {
                beginBatchFetch()
            }
        }

        //hidden tabBar
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
}
@available(iOS 13.0, *)
extension PlaceFeedCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            //return LocationsStorage.shared.locations.count
            return visitlist.count
        case 1:
            return fetchingMore ? 1 : 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PlaceCell

        cell.backgroundColor = .systemBackground
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = ColorX.Mile.cellborderColor.cgColor

        cell.miletextLabel.textColor = .systemGray
        cell.costTextLabel.textColor = .systemGray
        cell.titleTimeLabel.textColor = .systemGray
        cell.subtitleTimeLabel.textColor = .systemGray
        
        cell.mileLabel.font = Font.celltitle22b
        cell.miletextLabel.font = Font.celltitle12r
        cell.dayLabel.font = Font.celltitle12b
        cell.dayTextLabel.font = Font.celltitle16r
        cell.costLabel.font = Font.celltitle22b
        cell.costTextLabel.font = Font.celltitle12r
        cell.titleLabelnew.font = Font.celltitle14r
        cell.subtitleLabel.font = Font.celltitle14r
        cell.titleTimeLabel.font = Font.celltitle12m
        cell.subtitleTimeLabel.font = Font.celltitle12m
        
        //Cell-----------------------------------------------------------------
        //cell.mapStart = LocationsStorage.shared.locations[indexPath.row]
        cell.mapStart = visitlist[indexPath.row]
        //Cell2-----------------------------------------------------------------
        let thisIndexPath = indexPath.row
        if thisIndexPath - 1 > -1 {
            //cell.mapDest = LocationsStorage.shared.locations[thisIndexPath - 1]
            cell.mapDest = visitlist[indexPath.row - 1]
        }
        //-----------------------------------------------------------------
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            let size = CGSize.init(width: 420, height: 475)
            return size
        } else {
            let height = (frame.width - 20 - 20) * 9 / 16
            return .init(width: frame.width - 20, height: height + 20 + 225)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if UIDevice.current.userInterfaceIdiom == .pad  {
            return .init(top: 20, left: 20, bottom: 20, right: 20)
        } else {
            return .init(top: 20, left: 0, bottom: 20, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at:indexPath) as! PlaceCell
        
        let storyboard = UIStoryboard(name:"EditData", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mapviewStory") as! MapViewVC
        vc.formController = "MileIQ"
        vc.startCoordinates = cell.startCoordinates
        vc.endCoordinates = cell.endCoordinates
        let controller = UINavigationController(rootViewController: vc)
        let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        windows?.rootViewController?.present(controller, animated: true)
    }

}
