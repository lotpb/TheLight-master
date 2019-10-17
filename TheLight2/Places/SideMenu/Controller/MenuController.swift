//
//  MenuController.swift
//  SlideOutMenu
//
//  Created by ivica petrsoric on 14/10/2018.
//  Copyright © 2018 ivica petrsoric. All rights reserved.
//

import UIKit

struct MenuItem {
    let icon: UIImage
    let title: String
}

@available(iOS 13.0, *)
extension MenuController {

}


@available(iOS 13.0, *)
class MenuController: UITableViewController {
    
    let menuItems = [
        MenuItem(icon: UIImage(systemName: "hand.thumbsup.fill")!, title: "Unclassified"),
        MenuItem(icon: UIImage(systemName: "car.fill")!, title: "All Drives"),
        MenuItem(icon: UIImage(systemName: "text.bubble.fill")!, title: "Monthly  Summaries"),
        MenuItem(icon: UIImage(systemName: "gear")!, title: "Account Settings"),
        MenuItem(icon: UIImage(systemName: "phone.fill")!, title: "Drive  Detection"),
        MenuItem(icon: UIImage(systemName: "questionmark.circle.fill")!, title: "Help"),
        ]
    
    private let cellID = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let slidingController = window?.rootViewController as? BaseSlidingController
        slidingController?.didSelectMenuItem(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customHeaderView = CustomMenuHeaderView()
        return customHeaderView
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 200
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuItemCell(style: .default, reuseIdentifier: cellID)
        let menuItem = menuItems[indexPath.row]
        cell.iconImageView.image = menuItem.icon
        cell.titleLabel.text = menuItem.title
//        cell.textLabel?.text = menuItem.title
//        cell.imageView?.image = menuItem.icon
        return cell
    }
    
}
