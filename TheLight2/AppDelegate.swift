//
//  AppDelegate.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import FirebaseCore
import FBSDKCoreKit
import GoogleSignIn
import UserNotifications
import CoreLocation
import BackgroundTasks

fileprivate let backgroundTaskIdentifier = "com.PeterBalsamo.apprefresh"

@available(iOS 13.0, *)
@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    let center = UNUserNotificationCenter.current()
    var defaults = UserDefaults.standard
    
    let locationManager = CLLocationManager() //geotify
    //mileIQ
    var destLocation: CLLocation? // for distance calculation
    var distance = 0.0
    let dateFormatter = DateFormatter()
    //journal
    static let geoCoder = CLGeocoder()

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        
        /// MARK: -  BackGround Tasks
        if UserDefaults.standard.bool(forKey: "AllowBackgroundFetch") {
            registerBackgroundTaks()
            print("Background task called...")
            print("\(Date()): notification posted, running background if available")
        } else {
            print("Background task disabled")
        }

        /// MARK: - Google Sign-in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

        registerCategories()
        registerLocalNotification()
        set3DTouch()
        
        // MileIQ
        if (defaults.bool(forKey: "geotifyKey"))  {
            
            center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in }
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringVisits()
            locationManager.delegate = self
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()  // 2
        }
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// MARK: - Google/Facebook
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        
        //GIDSignIn.sharedInstance().handle(url,
        //sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        //annotation: [:])
        
        return handled
    }
    
    // MARK: - Facebook
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
        application.applicationIconBadgeNumber = 0
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        cancelAllPandingBGTask()
        fireBackgrounfNotification()
        scheduleAppRefresh()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {

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
//----------------------------------------------------------------------------------------------------------
    /// MARK: - Register BackGround Tasks
    private func registerBackgroundTaks() {

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.PeterBalsamo.apprefresh", using: DispatchQueue.global()) { (task) in
            task.setTaskCompleted(success: true)
        }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.PeterBalsamo.imagefetcher", using: nil) { task in
            self.fireBackgrounfNotification()
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        task.expirationHandler = {}
        fireBackgrounfNotification()
        task.setTaskCompleted(success: true)
    }

    func scheduleAppRefresh() {
        fireBackgrounfNotification()
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60) // App Refresh after 2 minute.

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Couldn't schedule app refresh: \(error)")
        }
    }

    func fireBackgrounfNotification() {
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
    }
}
@available(iOS 13.0, *)
extension AppDelegate {
    
    func cancelAllPandingBGTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
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

@available(iOS 13.0, *)
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
@available(iOS 13.0, *)
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

    }
}

 




