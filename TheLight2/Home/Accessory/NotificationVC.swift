//
//  NotificationController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/20/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import UserNotifications

@available(iOS 13.0, *)
final class NotificationVC: UIViewController {
    
    @IBOutlet weak var scrollWiew: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var customMessage: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var frequencySegmentedControl : UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    
    private let celltitle = Font.celltitle18r
    let center = UNUserNotificationCenter.current()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        
        view.backgroundColor = .secondarySystemGroupedBackground
        self.scrollWiew.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.customMessage.clearButtonMode = .always
        self.customMessage!.font = celltitle
        self.customMessage.placeholder = "enter notification"
        
        self.saveButton.setTitleColor(.white, for: .normal)
        self.saveButton.backgroundColor = .systemOrange
        self.saveButton.layer.cornerRadius = 24.0
        self.saveButton.layer.borderColor = UIColor.systemOrange.cgColor
        self.saveButton.layer.borderWidth = 3.0
        
        UITextField.appearance().tintColor = .systemOrange
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(NotificationVC.actionButton))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(NotificationVC.editButton))
        navigationItem.rightBarButtonItems = [editButton, actionButton]
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Notifications"
        } else {
            navigationItem.title = "Notifications"
        }
    }
    
    // MARK: - localNotification
    
    @available(iOS 13.0, *)
    @IBAction func datePickerDidSelectNewDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        print("Selected date: \(selectedDate)")
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.scheduleNotification(at: selectedDate)
    }
    
    @IBAction func sendNotification(_ sender:AnyObject) {
        
       // if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            content.title = "Message from TheLight 🏀"
            content.body = customMessage.text!
            content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "myCategory"
            
            let imageName = "calendar"
            guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
            let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
            content.attachments = [attachment]
            
            let month = datePicker.calendar.component(.month, from: datePicker.date)
            let day = datePicker.calendar.component(.day, from: datePicker.date)
            let hour = datePicker.calendar.component(.hour, from: datePicker.date)
            let minute = datePicker.calendar.component(.minute, from: datePicker.date)
            
            var dateComponents = DateComponents()
            dateComponents.timeZone = .current
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
            
            self.customMessage.text! = ""
            
//        } else {
//
//        let notifications:UILocalNotification = UILocalNotification()
//        notifications.timeZone = .current
//        notifications.fireDate = fixedNotificationDate(datePicker.date)
//
//        switch(frequencySegmentedControl.selectedSegmentIndex){
//        case 0:
//            //notifications.repeatInterval = NSCalendar.Unit.
//            break;
//        case 1:
//            notifications.repeatInterval = .day
//            break;
//        case 2:
//            notifications.repeatInterval = .weekday
//            break;
//        case 3:
//            notifications.repeatInterval = .year
//            break;
//        default:
//            //notifications.repeatInterval = Calendar.init(identifier: 0)
//            break;
//        }
//
//        notifications.alertBody = customMessage.text
//        notifications.alertAction = "Hey you! Yeah you! Swipe to unlock!"
//        notifications.category = "status"
//        notifications.userInfo = [ "value": "inactiveMembership"]
//        notifications.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
//        notifications.soundName = "Tornado.caf"
//        UIApplication.shared.scheduleLocalNotification(notifications)
//        self.customMessage.text = ""
//        }
    }
    
    
    func memberNotification() {

        let content = UNMutableNotificationContent()
        content.title = "Membership Status 🏀"
        content.body = "Our system has detected that your membership is inactive."
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Tornado.caf"))
        content.categoryIdentifier = "myCategory"

        let imageName = "applelogo"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]

        //content.userInfo = ["customNumber": 100]
        content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request, withCompletionHandler: nil)
    }
    
    
    func blogNotification() {

        let content = UNMutableNotificationContent()
        content.title = "Blog Post 🏀"
        content.subtitle = "New message posted"
        content.body = "TheLight just posted a new message"
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Tornado.caf"))
        content.categoryIdentifier = "myCategory"

        let imageURL = Bundle.main.url(forResource: "comments", withExtension: "png")
        let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
        content.attachments = [attachment]
        content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request, withCompletionHandler: nil)
    }
    
    func HeyYouNotification() {
        //setup for 2:30PM
        let content = UNMutableNotificationContent()
        content.title = "Work-Out and be awesome! 🏀"
        content.body = "Hey you! Yeah you! Time to Workout!"
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Tornado.caf"))
        content.categoryIdentifier = "myCategory"

        let imageName = "applelogo"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]

        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request, withCompletionHandler: nil)
    }
    
    
    //Here we are going to set the value of second to zero
    func fixedNotificationDate(_ dateToFix: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: dateToFix)
        dateComponents.second = 0
        let fixedDate: Date = Calendar.current.date(from: dateComponents)!
        
        return fixedDate
    }
    
    // MARK: - Button
    
    @objc func actionButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        
        let buttonSix = UIAlertAction(title: "Membership Status", style: .default, handler: { (action)  in
            self.memberNotification()
        })
        
        let newBog = UIAlertAction(title: "New Blog Posted", style: .default, handler: { (action)  in
            self.blogNotification()
        })
        let heyYou = UIAlertAction(title: "Hey You", style: .default, handler: { (action)  in
            self.HeyYouNotification()
        })
        
        let promo = UIAlertAction(title: "Promo Code", style: .default, handler: { (action)  in
            //self.promoNotification()
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action)  in
            
        }
        alertController.addAction(buttonSix)
        alertController.addAction(newBog)
        alertController.addAction(heyYou)
        alertController.addAction(promo)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true)
    }
    
    @objc func editButton(_ sender:AnyObject) {
        self.performSegue(withIdentifier: "notificationdetailsegue", sender: self)
    }
    
}

