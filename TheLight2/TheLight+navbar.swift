//
//  HomeDatasourceController+navbar.swift
//  TwitterLBTA
//
//  Created by Brian Voong on 1/14/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
extension Blog {
    
    func setupBlogNavigationBar() {
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
        
        let composeBtn = UIButton(type: .system)
        composeBtn.setImage(#imageLiteral(resourceName: "compose").withRenderingMode(.alwaysOriginal), for: .normal)
        composeBtn.frame = .init(x: 0, y: 0, width: 34, height: 34)
        composeBtn.addTarget(self, action: #selector(Blog.newButton), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: composeBtn)]
    }
}
@available(iOS 13.0, *)
public extension UIViewController {
    
    func setupTwitterNavigationBarItems() {
        setupTwitterNavItems()
    }
    
    func setupNewsNavigationItems() {
        setupNewsNavigationBarItems()
    }
    
    func setMainNavItems() {
        
        let app = UINavigationBarAppearance()
        app .configureWithTransparentBackground()
        app.backgroundColor = .systemBackground
        
        app.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        app.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor:UIColor.label,
            NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 24)]
        
        navigationController?.navigationBar.standardAppearance = app
        navigationController?.navigationBar.scrollEdgeAppearance = app
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    private func setupNewsNavigationBarItems() {
        
        let app = UINavigationBarAppearance()
        app .configureWithTransparentBackground()
        app.backgroundColor = .systemBackground
        
        app.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemRed]
        app.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor:UIColor.systemRed,
            NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 24)]
        
        navigationController?.navigationBar.standardAppearance = app
        navigationController?.navigationBar.scrollEdgeAppearance = app
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.tintColor = .systemGray //text color
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupTwitterNavItems() {
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "title_icon"))
        titleImageView.frame = .init(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        let app = UINavigationBarAppearance()
               app .configureWithTransparentBackground()
               app.backgroundColor = .systemBackground
               
               app.titleTextAttributes = [NSAttributedString.Key.foregroundColor:ColorX.twitterline]
               app.largeTitleTextAttributes = [
                   NSAttributedString.Key.foregroundColor:UIColor.white,
                   NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 24)]
               
               navigationController?.navigationBar.standardAppearance = app
               navigationController?.navigationBar.scrollEdgeAppearance = app
               navigationController?.navigationBar.isTranslucent = true
               navigationController?.navigationBar.backgroundColor = UIColor.clear
        
        let separator = UIView(frame: .init(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = ColorX.twitterline
        view.addSubview(separator)
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = nil //UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
}
