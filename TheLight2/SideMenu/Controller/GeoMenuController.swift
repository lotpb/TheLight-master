//
//  File.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/3/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import UIKit

struct GeoMenuItem {
    let icon: UIImage
    let title: String
}


@available(iOS 13.0, *)
class GeoMenuController: UITableViewController {

    let menuItems = [
        GeoMenuItem(icon: UIImage(systemName: "hand.thumbsup.fill")!, title: "COVID-19"),
        GeoMenuItem(icon: UIImage(systemName: "car.fill")!, title: "Inbox"),
        GeoMenuItem(icon: UIImage(systemName: "text.bubble.fill")!, title: "Promotions"),
        GeoMenuItem(icon: UIImage(systemName: "gear")!, title: "Earnings"),
        GeoMenuItem(icon: UIImage(systemName: "phone.fill")!, title: "Uber Pro"),
        GeoMenuItem(icon: UIImage(systemName: "questionmark.circle.fill")!, title: "Wallet"),
    ]

    private let cellID = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customHeaderView = CustomMenuHeaderView()
        return customHeaderView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuItemCell(style: .default, reuseIdentifier: cellID)
        let menuItem = menuItems[indexPath.row]
        cell.iconImageView.image = menuItem.icon
        cell.titleLabel.text = menuItem.title

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let slidingController = window?.rootViewController as? BaseSlidingController
        slidingController?.didSelectMenuItem(indexPath: indexPath)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        }, completion: nil)
    }

}
