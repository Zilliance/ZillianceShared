//
//  NotificationsManager+ViewModel.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 17-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation

public protocol NotificationTableViewModel {
    
    func getNextNotifications() -> [NotificationTableItemViewModel]
    
}

public struct NotificationTableItemViewModel {
    public var type: Notification.NotificationType = .local
    public var recurrence: Notification.Recurrence = .none
    public var title: String = ""
    public var body: String = ""
    public var nextDate: Date!
    public var notificationId: String
}

extension NotificationsManager: NotificationTableViewModel {
    
    public func getNextNotifications() -> [NotificationTableItemViewModel] {
        
        let numberOfDays = 6
        
        var futureNotifications: [NotificationTableItemViewModel] = []
        
        let endDate = Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * numberOfDays)).endOfDay()
        
        let notifications = getNotifications(numberOfDays: numberOfDays)
        
        notifications.forEach({ (notification) in
            
            guard let notificationId = notification.notificationId else {
                assertionFailure()
                return
            }
            
            var newDate = Date()
            
            while let nextDate = notification.nextNotificationDate(fromDate: newDate), nextDate < endDate {
                
                let newItem = NotificationTableItemViewModel(type: notification.type, recurrence: notification.recurrence, title: notification.title, body: notification.body, nextDate: nextDate, notificationId: notificationId)
                
                futureNotifications.append(newItem)
                
                newDate = nextDate
            }
            
        })
        
        futureNotifications = futureNotifications.sorted { $0.0.nextDate < $0.1.nextDate }
        
        return futureNotifications
        
    }
    
}
