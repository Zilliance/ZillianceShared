//
//  LocalNotificationsHelper.swift
//  Personal-Compass
//
//  Created by Ignacio Zunino on 05-06-17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import Foundation

import Foundation
import UserNotifications
import UIKit

public final class LocalNotificationsHelper: NSObject
{
    static let notificationCategory = "reminderNotification"
    
    public static let shared = LocalNotificationsHelper()
    
    fileprivate var waitingAuthorizationCompletion: ((Bool) -> ())?
    
    private func ownAuthorization(vc: UIViewController, completion: @escaping (Bool) -> ())
    {
        
        let alert = UIAlertController(title: "Allow Notifications", message: "Personal Compass would like to send you a notification reminder", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            completion(false)
        }))
        
        alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (_) in
            completion(true)
        }))
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    func getNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.getPendingNotificationRequests(completionHandler: { (notifications) in
                print(notifications)
            })
        } else {
            
            print(UIApplication.shared.scheduledLocalNotifications ?? "[]")
            
        }
    }
    
    public func requestAuthorization(inViewController viewController: UIViewController, completion: @escaping (Bool) -> ())
    {
        
        let ownAuthorization:() -> () =
        {
            self.ownAuthorization(vc: viewController, completion: { (authorized) in
                if (authorized)
                {
                    self.requestOSAuthorization(completion: completion)
                }
            })
        }
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings(completionHandler: {(settings) in
                
                DispatchQueue.main.async {
                    if (settings.authorizationStatus == .authorized)
                    {
                        completion(true)
                    }
                    else
                    {
                        if (settings.authorizationStatus == .notDetermined)
                        {
                            ownAuthorization()
                        }
                        else
                        {
                            completion(false)
                        }
                    }
                    
                }
            })
            
        } else {
            
            
            if let types = UIApplication.shared.currentUserNotificationSettings?.types, types.contains([.alert, .sound])
            {
                completion(true)
                return
            }
            else
            {
                ownAuthorization()
            }
            
            
        }
    }
    
    private func requestOSAuthorization(completion: ((Bool) -> ())?)
    {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
        } else {
            
            waitingAuthorizationCompletion = completion
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound], categories: nil))
            
        }
        
    }
    
    func authorizationReceived(authorized: Bool)
    {
        waitingAuthorizationCompletion?(authorized)
    }

    
    func removePendingNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()

        } else {
            // Fallback on earlier versions
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
    static func scheduleLocalNotification(title: String, body: String, date: Date, identifier: String, completion: ((Error?) -> ())? = nil)
    {
        if #available(iOS 10.0, *) {
            // no need to remove in iOS 10 since it's automatically updated using the identifier information
            
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = notificationCategory
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default()
            
            let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .month, .year], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            print(request)
            // Schedule the notification.
            center.add(request) { (error) in
                completion?(error)
            }
            
        } else {
            guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
                return
            }
            
            removeNotificationsForIdentifier(identifier: identifier)
            
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.alertTitle = title
            notification.alertBody = body
            notification.soundName = UILocalNotificationDefaultSoundName
            
            notification.userInfo = ["identifier": identifier]
            
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
    }
    
    static func getInformationForStoredNotification(identifier: String) -> (String, Date)? {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            
            let dispatchGroup = DispatchGroup()
            var previousRequest:UNNotificationRequest?
            
            dispatchGroup.enter()
            
            center.getPendingNotificationRequests(completionHandler: { (notificationRequest) in
                
                previousRequest = notificationRequest.first
                dispatchGroup.leave()
            })
            
            dispatchGroup.wait()
            
            if let previousRequest = previousRequest, let trigger = previousRequest.trigger as? UNCalendarNotificationTrigger, let date = trigger.nextTriggerDate() {
                
                return (previousRequest.content.body, date)
            }
            
            
        } else {
            
            let notifications = UIApplication.shared.scheduledLocalNotifications?.filter({ (notification) -> Bool in
                guard let userInfo = notification.userInfo, let nIdentifier = userInfo["identifier"] as? String else { return false }
                return nIdentifier == identifier
            })
            
            if let notification = notifications?.first, let text = notification.alertBody, let date = notification.fireDate {
                return (text, date)
            }
            
        }
        
        return nil
        
    }
    
    static func removeNotificationsForIdentifier(identifier: String) {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            
            
        } else {
            
            let notifications = UIApplication.shared.scheduledLocalNotifications?.filter({ (notification) -> Bool in
                guard let userInfo = notification.userInfo, let nIdentifier = userInfo["identifier"] as? String else { return false }
                return nIdentifier == identifier
            })
            
            if let notification = notifications?.first {
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }
}

extension LocalNotificationsHelper: UNUserNotificationCenterDelegate {
    
    public func listenToNotifications() {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
    }
    
    //for displaying notification when app is in foreground
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.badge])
    }
    
    // For handling tap and user actions. We need to have this here if not the local notification is received and we would show an alert as in iOS 9
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
    
}
