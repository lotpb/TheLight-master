//
//  HomeDatasourceController+navbar.swift
//  TwitterLBTA
//
//  Created by Brian Voong on 1/14/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

extension Blog {
    
    func setupNavigationBarItems() {
        setupLeftNavItem()
        setupRightNavItems()
    }
    
    private func setupLeftNavItem() {
        let followButton = UIButton(type: .system)
        followButton.setImage(#imageLiteral(resourceName: "follow").withRenderingMode(.alwaysOriginal), for: .normal)
        followButton.frame = .init(x: 0, y: 0, width: 34, height: 34)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: followButton)
    }
    
    private func setupRightNavItems() {
        //let searchBtn = UIButton(type: .system)
        //searchBtn.setImage(#imageLiteral(resourceName: "search").withRenderingMode(.alwaysOriginal), for: .normal)
        //searchBtn.frame = .init(x: 0, y: 0, width: 34, height: 34)
        //searchBtn.addTarget(self, action: #selector(Blog.searchButton), for: .touchUpInside)
        
        let composeBtn = UIButton(type: .system)
        composeBtn.setImage(#imageLiteral(resourceName: "compose").withRenderingMode(.alwaysOriginal), for: .normal)
        composeBtn.frame = .init(x: 0, y: 0, width: 34, height: 34)
        composeBtn.addTarget(self, action: #selector(Blog.newButton), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: composeBtn)]
    }
}

public extension UIViewController {
    
    func setupTwitterNavigationBarItems() {
        setupTwitterNavItems()
    }
    
    func setupNewsNavigationItems() {
        setupNewsNavigationBarItems()
    }
    
    func setMainNavItems() {
        
        /*
        var preferredStatusBarStyle : UIStatusBarStyle {
            return .lightContent
        } */
 
        if #available(iOS 13.0, *) {
            if let statusBar = UIStatusBarManager.self as? UIView {
                if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
                    statusBar.backgroundColor = #colorLiteral(red: 0, green: 0.7156304717, blue: 0.9302947521, alpha: 1)
                }
            }
        } else {
            // Fallback on earlier versions
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
                    statusBar.backgroundColor = .black
                }
            }
        }
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .systemGray
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 26)]
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)

    }
    
    private func setupNewsNavigationBarItems() {
        /*
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            if UI_USER_INTERFACE_IDIOM() == .pad {
                statusBar.backgroundColor = .black
                if #available(iOS 13.0, *) {
                    navigationController?.navigationBar.barTintColor = .systemBackground
                } else {
                    navigationController?.navigationBar.barTintColor = .black
                }
            } else {
                if #available(iOS 13.0, *) {
                    statusBar.backgroundColor = .systemBackground
                    navigationController?.navigationBar.barTintColor = .systemBackground
                } else {
                    statusBar.backgroundColor = Color.News.navColor
                    navigationController?.navigationBar.barTintColor = Color.News.navColor
                }
                navigationController?.navigationBar.isTranslucent = false
            }
        } */

        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.backgroundColor = .systemBackground
            navigationController?.navigationBar.tintColor = .systemGray
        } else {
            navigationController?.navigationBar.backgroundColor = .white
            navigationController?.navigationBar.tintColor = .white
        }
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

    }
    
    private func setupTwitterNavItems() {
        /*
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            if #available(iOS 13.0, *) {
                statusBar.backgroundColor = .systemBackground
            } else {
                statusBar.backgroundColor = .white
            }
            if #available(iOS 13.0, *) {
                navigationController?.navigationBar.barTintColor = .systemBackground
            } else {
                navigationController?.navigationBar.barTintColor = .white
            }
            navigationController?.navigationBar.isTranslucent = false //removed a light bar
        } */
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "title_icon"))
        titleImageView.frame = .init(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        navigationController?.navigationBar.tintColor = Color.twitterBlue
        //navigationController?.navigationBar.backgroundColor = .white
        //navigationController?.navigationBar.barTintColor = .black
        UINavigationBar.appearance().tintColor = .systemGray
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:Color.twitterline, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 26)]
        
        let separatorLineView1 = UIView(frame: .init(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
        separatorLineView1.backgroundColor = Color.twitterline
        view.addSubview(separatorLineView1)
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = nil //UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)

    }
}
