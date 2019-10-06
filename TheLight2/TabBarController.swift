//
//  MainTabBarController.swift
//  Firegram
//
//  Created by Peter Balsamo on 4/16/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit
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

        setupSplitViewController()
        setupTabBar()
    }

    func setupSplitViewController() {

        /*
        if UIDevice.current.userInterfaceIdiom == .pad {

            let splitViewController = UISplitViewController()
            let rootViewController = MasterViewController()
            let detailViewController = SnapshotVC()

            let homeNavigationController = UINavigationController(rootViewController: rootViewController)
            let secondNavigationController = UINavigationController(rootViewController: detailViewController)

            splitViewController.viewControllers = [homeNavigationController, secondNavigationController]
            //splitViewController.preferredDisplayMode = .allVisible
        } */
    }
    
    func setupTabBar() {

        let storyboard1 = UIStoryboard(name: "Home", bundle: nil)
        let myTab1 = storyboard1.instantiateViewController(withIdentifier: "homeId")

        let storyboard2 = UIStoryboard(name: "Blog", bundle: nil)
        let myTab2 = storyboard2.instantiateViewController(withIdentifier: "blogId")
        let layout3 = UICollectionViewFlowLayout()
        let myTab3 = News(collectionViewLayout: layout3)

        let storyboard4 = UIStoryboard(name: "Web", bundle: nil)
        let myTab4 = storyboard4.instantiateViewController(withIdentifier: "webId")

        let layout5 = UICollectionViewFlowLayout()
        let myTab5 = PlacesCollectionView(collectionViewLayout: layout5)

        let layout6 = UICollectionViewFlowLayout()
        let myTab6 = UserProfileVC(collectionViewLayout: layout6)

        
        let navController1 = UINavigationController(rootViewController: myTab1)
        navController1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 1)
        //navController1.tabBarItem.selectedImage = #imageLiteral(resourceName: "home30sel")
        
        let navController2 = UINavigationController(rootViewController: myTab2)
        navController2.tabBarItem = UITabBarItem(title: "Blog", image: UIImage(systemName: "square.and.pencil"), tag: 2)

        let navController3 = UINavigationController(rootViewController: myTab3)
        navController3.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "text.bubble.fill"), tag: 3)
        
        let navController4 = UINavigationController(rootViewController: myTab4)
        navController4.tabBarItem = UITabBarItem(title: "Web", image: UIImage(systemName: "cloud.fill"), tag: 4)

        let navController5 = UINavigationController(rootViewController: myTab5)
        navController5.tabBarItem = UITabBarItem(title: "Places", image: UIImage(systemName: "location.fill"), tag: 5)

        let navController6 = UINavigationController(rootViewController: myTab6)
        navController6.tabBarItem = UITabBarItem(title: "Me", image: UIImage(systemName: "person.fill"), tag: 6)
        
        viewControllers = [navController1, navController2, navController3, navController4, navController5, navController6]
        
        tabBarController?.viewControllers = viewControllers

        /*
         guard let items = tabBar.items else {return}
         for item in items{
         item.imageInsets = .init(top: 2, left: 0, bottom: 1, right: 0)
         } */
    }
}

