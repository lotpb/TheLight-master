//
//  SceneDelegate.swift
//  TheLight2
//
//  Created by Peter Balsamo on 7/5/19.
//  Copyright © 2019 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseCore
import GoogleSignIn
//import FirebaseAuth
//import SwiftUI

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var defaults = UserDefaults.standard
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        /// MARK: - Register Settings
        defaults.register(defaults: [
            "AllowBackgroundFetch": false,
            "speechKey": false,
            "soundKey": false,
            "backendKey": "Firebase",
            "autolockKey": false,
            "pushnotifyKey": false,
            "geotifyKey": false,
            "weatherNotifyKey": false,
            "registerKey": false,
            "weatherKey": "2446726",
            "usernameKey": "Peter Balsamo",
            "passwordKey": "3911",
            "emailKey": "eunited@optonline.net",
            "websiteKey": "http://",
            "phoneKey": "(516)241-4786",
            "versionKey": "1",
            "emailtitleKey": "TheLight Support",
            "emailmessageKey": "<h3>Programming in Swift</h3>",
            "mileIQKey": "0.545",
        ])

        FirebaseApp.configure()
        customizeAppearance()

        /// MARK: - prevent Autolock
        if (defaults.bool(forKey: "autolockKey"))  {
            UIApplication.shared.isIdleTimerDisabled = true
        }

        /// MARK: - loadData()
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            /// MARK: - Parse
            let configuration = ParseClientConfiguration {
                $0.applicationId = "lMUWcnNfBE2HcaGb2zhgfcTgDLKifbyi6dgmEK3M"
                $0.clientKey = "UVyAQYRpcfZdkCa5Jzoza5fTIPdELFChJ7TVbSeX"
                $0.server = "https://parseapi.back4app.com"
                //$0.isLocalDatastoreEnabled = true
            }
            Parse.initialize(with: configuration)
        } else {
            /// MARK: - Firebase
            Database.database().isPersistenceEnabled = true
            FirebaseRef.databaseRoot.keepSynced(true)
        }

        /// MARK: - TabBarController
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TabBarController()
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()

        /*
         /// MARK: - splitViewController
         let splitViewController = UISplitViewController()
         let rootViewController = MasterViewController()
         let detailViewController = SnapshotVC()

         let homeNavigationController = UINavigationController(rootViewController: rootViewController)
         let secondNavigationController = UINavigationController(rootViewController: detailViewController)

         splitViewController.viewControllers = [homeNavigationController, secondNavigationController]
         //splitViewController.preferredDisplayMode = .allVisible */

        /*
         if let windowScene = scene as? UIWindowScene {
         let window = UIWindow(windowScene: windowScene)
         window.rootViewController = UIHostingController(rootView: ContentView())
         self.window = window
         window.makeKeyAndVisible()
         } */
    }

    /// MARK: - App Theme Customization
    func customizeAppearance() {

        UINavigationBar.appearance().tintColor = .systemGray

        let app = UINavigationBarAppearance()
        app .configureWithTransparentBackground()
        app.backgroundColor = .systemBackground

        app.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        app.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor:UIColor.label,
            NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 24)]

        UINavigationBar.appearance().standardAppearance = app
        UINavigationBar.appearance().scrollEdgeAppearance = app
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance().tintColor = .systemGray //text color
        UINavigationBar.appearance().prefersLargeTitles = true

        let attrsNormal = [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)
        ]
        let attrsSelected = [
            NSAttributedString.Key.foregroundColor: Color.twitterBlue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attrsSelected, for: .selected)
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBar.appearance().tintColor = Color.twitterBlue
        UITabBar.appearance().isTranslucent = false

        UIToolbar.appearance().barTintColor = Color.toolbarColor //Color.DGrayColor
        UIToolbar.appearance().tintColor = .secondarySystemGroupedBackground
        UIToolbar.appearance().isTranslucent = false
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {

    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {

    }
    
    func sceneWillResignActive(_ scene: UIScene) {

    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {

    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {

    }
    
    
}

