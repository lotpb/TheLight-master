//
//  AppDelegate.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FBSDKLoginKit
import UserNotifications
import CoreLocation
import BackgroundTasks


@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    var defaults = UserDefaults.standard
    var backgroundSessionCompletionHandler: (() -> Void)? //music app
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    let locationManager = CLLocationManager() //geotify
    //mileIQ
    var destLocation: CLLocation? // for distance calculation
    var distance = 0.0
    let dateFormatter = DateFormatter()
    //journal
    static let geoCoder = CLGeocoder()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// MARK: - Register Settings
        defaults.register(defaults: [
            "AllowBackgroundFetch": false,
            "speechKey": false,
            "soundKey": false,
            "parsedataKey": false,
            "autolockKey": false,
            "pushnotifyKey": false,
            "geotifyKey": false,
            "weatherNotifyKey": false,
            "weatherKey": "2446726",
            "usernameKey": "Peter Balsamo",
            "passwordKey": "3911",
            "emailKey": "eunited@optonline.net",
            "websiteKey": "http://",
            "phoneKey": "(516)241-4786",
            "versionKey": "1",
            "emailtitleKey": "TheLight Support",
            "emailmessageKey": "<h3>Programming in Swift</h3>",
            "mileIQKey": "0.545"
            ])
        
        /// MARK: - Parse
        if (defaults.bool(forKey: "parsedataKey")) {
            
            let configuration = ParseClientConfiguration {
                $0.applicationId = "lMUWcnNfBE2HcaGb2zhgfcTgDLKifbyi6dgmEK3M"
                $0.clientKey = "UVyAQYRpcfZdkCa5Jzoza5fTIPdELFChJ7TVbSeX"
                $0.server = "https://parseapi.back4app.com"
                //$0.isLocalDatastoreEnabled = true
            }
            Parse.initialize(with: configuration)
        } else {
            /// MARK: - Firebase
            FirebaseApp.configure()
            Database.database().isPersistenceEnabled = true
            FirebaseRef.databaseRoot.keepSynced(true)
        }

        /// MARK: - prevent Autolock
        if (defaults.bool(forKey: "autolockKey"))  {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        /// MARK: - Background Fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    

        /// MARK: - Register login
        if (!(defaults.bool(forKey: "registerKey")) || defaults.bool(forKey: "loginKey")) {
            
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "loginIDController") as UIViewController
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
            
        } else {
            //window?.rootViewController = testTable()
        }

        /// MARK: - TabBarController
        if self.window!.rootViewController as? UITabBarController != nil {
            let tababarController = self.window!.rootViewController as! UITabBarController
            //var index: NSInteger = 0
            //index = 10; index += 1
            //tababarController.increaseBadge(indexOfTab: 3, num: "\(index)")
            
            let items = tababarController.tabBar.items
            for item in items!{
                item.imageInsets = .init(top: 2, left: 0, bottom: 1, right: 0)
            }
        }
        
        /// MARK: - Facebook Sign-in
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if !(defaults.bool(forKey: "parsedataKey")) {
            /// MARK: - Google Sign-in
            GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        }
        
        customizeAppearance()
        registerCategories()
        registerLocalNotification()
        set3DTouch()
        
        // MileIQ
        if (defaults.bool(forKey: "geotifyKey"))  {
            
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in }
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringVisits()
            locationManager.delegate = self
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()  // 2
        }
        
        return true
    }
    
    /// MARK: - SplitView
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {

        return false
    }
    
    /// MARK: - Google/Facebook

    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        
        GIDSignIn.sharedInstance().handle(url,
        sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: [:])
        
        return handled
    }
    
    // MARK: - Facebook

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        AppEvents.activateApp()
        application.applicationIconBadgeNumber = 0
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: UISceneSession Lifecycle
    /*
    @available(iOS 13.0, *)
     func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
         // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
     }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    } */
    
    
    // MARK: - Music Controller
    
    internal func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    /// MARK: - Schedule Notification set in NotificationController
    func scheduleNotification(at date: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = "Tutorial Reminder 🏈"
        content.body = "Just a reminder to read your tutorial over at appcoda.com!"
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Tornado.caf"))
        content.categoryIdentifier = "myCategory"
        
        let imageName = "profile-rabbit-toy"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.delegate = self
        center.add(request)
    }

    /// MARK: - Background Fetch
    //MARK: Regiater BackGround Tasks
    private func registerBackgroundTaks() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.SO.imagefetcher", using: nil) { task in
            //This task is cast with processing request (BGProcessingTask)
            //self.scheduleLocalNotification()
            //self.handleImageFetcherTask(task: task as! BGProcessingTask)
        }
        
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if UserDefaults.standard.bool(forKey: "AllowBackgroundFetch") {
            getBackgroundData()
            completionHandler(.newData)
            print("Background fetch called...")
            print("\(Date()): notification posted, running background if available")
        } else {
            print("Background fetch disabled")
        }
    }
    
    func getBackgroundData() {
        let content = UNMutableNotificationContent()
        content.title = "Background transfer! 🏈"
        content.body = "Background transfer service: Download complete!"
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "myCategory"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:60, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.delegate = self
        center.add(request)
        
        registerBackgroundTask()
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds") //dont work
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
}
extension AppDelegate {
    
    func cancelAllPandingBGTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
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
        if #available(iOS 13.0, *) {
            UITabBar.appearance().barTintColor = .systemBackground
        } else {
            UITabBar.appearance().barTintColor = .white
        }
        UITabBar.appearance().tintColor = Color.twitterBlue
        UITabBar.appearance().isTranslucent = false
        
        UIToolbar.appearance().barTintColor = Color.toolbarColor //Color.DGrayColor
        if #available(iOS 13.0, *) {
            UIToolbar.appearance().tintColor = .secondarySystemGroupedBackground
        } else {
            UIToolbar.appearance().tintColor = .white
        }
        UIToolbar.appearance().isTranslucent = false
    }
    
    /// MARK: - Register Notifications
    
    func registerLocalNotification() {
        
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        center.requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    /// MARK: - Register Categories
    
    func registerCategories() {
        
        center.delegate = self
        let action = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        let delete = UNNotificationAction(identifier: "delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: "myCategory", actions: [action, delete], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    /// MARK: - 3D Touch
    /*
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            // Create an action for sharing
            let Blog = UIAction(title: "Blog", image: UIImage(systemName: "square.and.arrow.up")) { action in
                // Show system share sheet
            }

            // Create an action for renaming
            let News = UIAction(title: "News", image: UIImage(systemName: "square.and.pencil")) { action in
                // Perform renaming
            }

            // Here we specify the "destructive" attribute to show that it’s destructive in nature
            let Web = UIAction(title: "Web", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // Perform delete
            }
            
            // Here we specify the "destructive" attribute to show that it’s destructive in nature
            let Settings = UIAction(title: "Settings", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // Perform delete
            }

            // Create and return a UIMenu with all of the actions as children
            return UIMenu(title: "", children: [Blog, News, Web, Settings])
        }
    } */
    
    func set3DTouch() { //only 4 shortcuts allowed

        let firstItemIcon1:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .cloud)
        let firstItem1 = UIMutableApplicationShortcutItem(type: "1", localizedTitle: "Blog", localizedSubtitle: "Post Message.", icon: firstItemIcon1, userInfo: nil)
        
        let firstItemIcon2:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .compose)
        let firstItem2 = UIMutableApplicationShortcutItem(type: "2", localizedTitle: "News", localizedSubtitle: "View TheLight News.", icon: firstItemIcon2, userInfo: nil)
        
        let firstItemIcon3:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .love)
        let firstItem3 = UIMutableApplicationShortcutItem(type: "3", localizedTitle: "Web", localizedSubtitle: "View Web.", icon: firstItemIcon3, userInfo: nil)
        
        let firstItemIcon4:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .time)
        let firstItem4 = UIMutableApplicationShortcutItem(type: "4", localizedTitle: "Settings", localizedSubtitle: "View Settings.", icon: firstItemIcon4, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [firstItem4, firstItem3, firstItem2, firstItem1]
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let handledShortCutItem = handleShortCutItem(shortcutItem: shortcutItem)
        completionHandler(handledShortCutItem)
        
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var handled = false
        
        if shortcutItem.type == "1" {
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
            handled = true
        }
        
        if shortcutItem.type == "3" {
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 3
            handled = true
        }
        
        if shortcutItem.type == "4" {
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 5
            handled = true
        }
        
        if shortcutItem.type == "5" {
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
            handled = true
        }
        return handled
    }
    
    /// Geotify
    
    func handleEvent(forRegion region: CLRegion!, didEnter: Bool) {
        
        let message = didEnter ? "Alert! You have entered the region" : "Alert! You have exited the region ⚾️"
        let geoTitle = note(from: region.identifier)
        
        if UIApplication.shared.applicationState == .active {

            guard let message = note(from: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: geoTitle, message: message)
            
        } else {
            
            let content = UNMutableNotificationContent()
            content.title = message
            //content.subtitle = geoTitle
            content.body = geoTitle!
            content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Tornado.caf")) //UNNotificationSound.default()
            content.categoryIdentifier = "myCategory"
            
            //let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            /// Remove pending notifications to avoid duplicates.
            center.add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    /// Method retrieves the geotification note from the persistent store, based on its identifier, and returns the note for that geotification.
    
    func note(from identifier: String) -> String? {
        let geotifications = Geotification.allGeotifications()
        guard let matched = geotifications.filter({
            $0.identifier == identifier
        }).first else { return nil }
        return matched.note
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        //print("Notification being triggered - willPresent")
    }
    
    /// Schedule Notification Action
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.actionIdentifier == "remindLater" {
            let newDate = Date(timeInterval: 60, since: Date())
            scheduleNotification(at: newDate)
        }
        
        if response.actionIdentifier == "delete" {
            print("Delete")
        }

        //print("Notification being triggered - didReceive")
        completionHandler()
    }
}
/// Geotify
extension AppDelegate: CLLocationManagerDelegate {
    
    /// Method is called when the device enters a CLRegion.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            handleEvent(forRegion: region, didEnter: true)
            UserWarningSpeakManager.warning.startSpeaking("Alert! You have entered the region")
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.warning)
            //geoSubtitle = "enter \(region.notifyOnEntry), \(region.notifyOnExit)"
        }
    }
    
    /// Method is called when the device exits a CLRegion.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            handleEvent(forRegion: region, didEnter: false)
            UserWarningSpeakManager.warning.startSpeaking("Alert! You have exited the region")
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.warning)
            //geoSubtitle = "exit \(region.notifyOnEntry), \(region.notifyOnExit)"
            //UserWarningSpeakManager.warning.stopSpeaking()
        }
    }
    //journal
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {

  //mileIQ------------------------------------------------------------------------------
        /*
        let visitInfo = """
        ----Visit----
        latitude: \(visit.coordinate.latitude)
        longitude: \(visit.coordinate.longitude)
        arrival date: \(visit.arrivalDate)
        departure date: \(visit.departureDate)
        horizontal accuracy: \(visit.horizontalAccuracy)
        """
        //showTextLabel.text = visitInfo
        print("Crap", visitInfo) */

        let recordVisitReference = FirebaseRef.databaseVisits.child("test")

        let object: [String: Any] = [
            "coordinate": [
                "latitude": visit.coordinate.latitude,
                "longitude": visit.coordinate.longitude
            ],
            "arrival_date": "\(visit.arrivalDate)",
            "departure_date": "\(visit.departureDate)",
            "horizontal_accuracy": visit.horizontalAccuracy,
            "description": visit.description
           // "distance": "\(distance)",
            //"previousLocation": self.previousLocation! //[self dictionaryFromVisit:_visits[[_visits count]-1]];

        ]
        recordVisitReference
            //.child("\(visit.arrivalDate)_" + DemoItems.visit.rawValue)
            .child("\(visit.arrivalDate)")
            .setValue(object)
   //----------------------------------------------------------------------------------

        // create CLLocation from the coordinates of CLVisit
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        
        // Get location description
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "\(place)"
                self.newVisitReceived(visit, description: description)
            }
        }
    }
    
    func newVisitReceived(_ visit: CLVisit, description: String) {
        let location = Location(visit: visit, descriptionString: description)
        LocationsStorage.shared.saveLocationOnDisk(location)
        
        let content = UNMutableNotificationContent()
        content.title = "Location Update 📌"
        content.body = location.description
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
        //mileIQ
        guard let location = locations.last else { return }
        var level = "N/A"
        if let floor = location.floor {
            level = "\(floor.level)"
        }
        
        if let previousLocation = self.previousLocation {
            distance = location.distance(from: previousLocation)
        }
        
        self.previousLocation = location
        print("distance", distance)
        print("previousLocation", self.previousLocation!)
        
        let locationInfo = """
        ----User's Location----
        latitude: \(location.coordinate.latitude)
        longitude: \(location.coordinate.longitude)
        distance with previous location: \(distance) meters
        altitude: \(location.altitude) meters
        floor: \(level)
        timestamp: \(location.timestamp)
        speed: \(location.speed)
        course: \(location.course)
        """
        print(locationInfo)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        FirebaseRef.saveLocationInfoWith(
            location: location,
            databaseRef: FirebaseRef.databaseUpdatingLocations,
            dateFormatter: dateFormatter
        )  */
    }
}

 




