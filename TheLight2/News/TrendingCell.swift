//
//  TrendingCell.swift
//  youtube
//
//  Created by Brian Voong on 7/9/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase


@available(iOS 13.0, *)
class TrendingCell: FeedCell {
    
    override func fetchVideos() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query = PFQuery(className:"Newsios")
            query.limit = 1000
            query.cachePolicy = .cacheThenNetwork
            query.order(byDescending: "Liked")
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                } else {
                    print("ErrorTrend")
                }
            }
        } else {
            //firebase
            let ref = FirebaseRef.databaseRoot.child("News")
            ref.observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let newsTxt = NewsModel(dictionary: dictionary)
                self.newslist.append(newsTxt)
                
                self.newslist.sort(by: { (p1, p2) -> Bool in
                    return p1.viewCount.compare(p2.viewCount) == .orderedDescending
                })
                /*
                self.newslist.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                }) */
                
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                })
            })
        }
    }
    
}
