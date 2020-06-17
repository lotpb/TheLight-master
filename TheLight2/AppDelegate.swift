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
import CoreLocation
import UserNotifications
import BackgroundTasks

let primaryColor = UIColor(red: 210/255, green: 109/255, blue: 180/255, alpha: 1)
let secondaryColor = UIColor(red: 52/255, green: 148/255, blue: 230/255, alpha: 1)


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

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        registerCategories()
        registerLocalNotification()
        set3DTouch()

        // MileIQ
        if (defaults.bool(forKey: "geotifyKey"))  {
            center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
                if granted {
                    self.locationManager.requestAlwaysAuthorization()
                    self.locationManager.startMonitoringVisits()
                    self.locationManager.delegate = self
                    self.locationManager.allowsBackgroundLocationUpdates = true
                    //self.locationManager.pausesLocationUpdatesAutomatically = false
                    self.locationManager.startUpdatingLocation()  // 2
                }
            }
        }

        /// MARK: -  BackGround Tasks
        if UserDefaults.standard.bool(forKey: "AllowBackgroundFetch") {

            let dispatch = DispatchQueue.global()
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.PeterBalsamo.imagefetcher", using: dispatch) { task in
                self.fireBackgrounfNotification()
            }

            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: dispatch) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
            print("Background task called...")
            print("\(Date()): notification posted, running background if available")

        } else {
            print("Background task disabled")
        }

        //Firebase
        FirebaseApp.configure()
        //Google/Facebook
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        //Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookDidHandle = ApplicationDelegate.shared.application(app,
                                                                       open: url,
                                                                       sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                                       annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        let googleDidhandle = GIDSignIn.sharedInstance().handle(url)
        return googleDidhandle || facebookDidHandle
    }
    
    // MARK: - Facebook
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
        application.applicationIconBadgeNumber = 0 //dont work anymore
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
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 10)

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
    //BackGround Tasks
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
    //func handleEvent(forRegion region: CLRegion!, didEnter: Bool) {
    func handleEvent(forRegion region: CLRegion) {
        
        //let message = didEnter ? "Alert! You have entered the region" : "Alert! You have exited the region ⚾️"
        //let geoTitle = note(from: region.identifier)
        guard let message = note(from: region.identifier) else { return }
        
        if UIApplication.shared.applicationState == .active {

            //guard let message = note(from: region.identifier) else { return }
            window?.rootViewController?.showAlert(title: nil, message: message)
            
        } else {

            guard let body = note(from: region.identifier) else { return }
            let content = UNMutableNotificationContent()
            content.title = message
            content.body = body
            content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Tornado.caf")) //UNNotificationSound.default()
            content.categoryIdentifier = "myCategory"
            
            let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            center.add(request, withCompletionHandler: nil)
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
            let newDate = Date(timeInterval: 1, since: Date())
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
            //handleEvent(forRegion: region, didEnter: true)
            handleEvent(forRegion: region)
            UserWarningSpeakManager.warning.startSpeaking("Alert! You have entered the region")
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.warning)
            //geoSubtitle = "enter \(region.notifyOnEntry), \(region.notifyOnExit)"
        }
    }
    
    /// Method is called when the device exits a CLRegion.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            //handleEvent(forRegion: region, didEnter: false)
            handleEvent(forRegion: region)
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
        ]
        recordVisitReference
            .child("\(visit.arrivalDate)")
            .setValue(object)
        //----------------------------------------------------------------------------------

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

}
