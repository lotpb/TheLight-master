//
//  MainTabBarController.swift
//  Firegram
//
//  Created by Peter Balsamo on 4/16/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Register login
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true)
            }
        }
        
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
        //tabBar.shadowImage = UIImage() //remove border
        //tabBar.backgroundImage = UIImage() //remove border

        setupViewControllers()
    }
    
    func setupViewControllers() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        /*
        let splitViewController = UISplitViewController()
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "homeId") as! MasterViewController
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "snapshotId") as! SnapshotController
        splitViewController.viewControllers = [rootViewController,detailViewController]
        splitViewController.preferredDisplayMode = .primaryHidden
  
        let splitViewController1 = UISplitViewController()
        let rootViewController1 = storyboard.instantiateViewController(withIdentifier: "favoriteId") as UIViewController
        let detailViewController1 = storyboard.instantiateViewController(withIdentifier: "webId") as UIViewController
        splitViewController1.viewControllers = [rootViewController1, detailViewController1]
        //splitViewController1.preferredDisplayMode = .allVisible */
 
        let layout3 = UICollectionViewFlowLayout()
        let layout4 = UICollectionViewFlowLayout()

        let myTab1 = storyboard.instantiateViewController(withIdentifier: "homeId") as! MasterViewController
        let myTab2 = storyboard.instantiateViewController(withIdentifier: "blogId") as UIViewController
        let myTab3 = UserProfileVC(collectionViewLayout: layout3)
        let myTab4 = News(collectionViewLayout: layout4)
        let myTab5 = storyboard.instantiateViewController(withIdentifier: "webId") as! Web
        
        let navController1 = UINavigationController(rootViewController: myTab1)
        navController1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        //navController1.tabBarItem.selectedImage = #imageLiteral(resourceName: "home30sel")
        
        let navController2 = UINavigationController(rootViewController: myTab2)
        navController2.tabBarItem = UITabBarItem(title: "Blog", image: UIImage(systemName: "square and.pencil"), tag: 1)
        //navController2.tabBarItem.selectedImage = #imageLiteral(resourceName: "note30copy")
        
        let navController3 = UINavigationController(rootViewController: myTab3)
        navController3.tabBarItem = UITabBarItem(title: "Me", image: UIImage(systemName: "bookmark"), tag: 2)
        //navController3.tabBarItem.selectedImage = #imageLiteral(resourceName: "ribbon")

        let navController4 = UINavigationController(rootViewController: myTab4)
        navController4.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "text.bubble.fill"), tag: 3)
        //navController4.tabBarItem.selectedImage = #imageLiteral(resourceName: "display30copy")
        
        let navController5 = UINavigationController(rootViewController: myTab5)
        navController5.tabBarItem = UITabBarItem(title: "Web", image: UIImage(systemName: "cloud.fill"), tag: 4)
        //navController5.tabBarItem.selectedImage = #imageLiteral(resourceName: "cloud30copy")
        
        viewControllers = [navController1, navController2, navController3, navController4, navController5]
        
        tabBarController?.viewControllers = viewControllers

        guard let items = tabBar.items else {return}
        for item in items{
            item.imageInsets = .init(top: 2, left: 0, bottom: 1, right: 0)
        }
    }
    
}

