//
//  Notification.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 17-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import RealmSwift

@objc public enum dayOfTheWeek: Int32 {
    case sun = 0
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    
}

public class DayObject: Object {
    dynamic public var internalValue: dayOfTheWeek = .sun
    
    var rawValue: Int {
        return Int(internalValue.rawValue)
    }
    
    convenience public init(internalValue: dayOfTheWeek) {
        self.init()
        self.internalValue = internalValue
    }
    
}

public class RecurrentInstance: Object {
    dynamic var id: String?
    dynamic var date: Date?
    
    convenience init(id: String, date: Date) {
        self.init()
        self.id = id
        self.date = date
    }
}

public class Notification: Object{
    
    @objc public enum NotificationType: Int32 {
        case local
        case calendar
    }
    
    @objc public enum Recurrence: Int32 {
        case daily
        case weekly
        case none
    }
    
    public dynamic var notificationId: String?
    
    override public class func primaryKey() -> String? {
        return "notificationId"
    }
    
    public dynamic var associatedObjectId: String?
    
    public dynamic var startDate: Date?
    public dynamic var type: NotificationType = .local
    public dynamic var recurrence: Recurrence = .none
    
    public dynamic var dateAdded = Date()
    
    public dynamic var title: String = ""
    public dynamic var body: String = ""
    
    public let weekDays = List<DayObject>()
    
    public let scheduledInstances = List<RecurrentInstance>()
    
    //if there's one day for the weekdays selected that is after today, select that one.
    //if not, the first one can be
    
    public func getNextWeekDate(fromDate: Date) -> Date? {

        guard weekDays.count > 0 else {
            return nil
        }
        
        let nextWeekFromCreation = dateAdded.addingTimeInterval(7 * 60 * 60 * 24)

        for weekDay in weekDays {
            let nextInstance = fromDate.nextDateWithWeekDate(weekDay: weekDay.rawValue)
            if (nextInstance > fromDate) {
                if (nextInstance > nextWeekFromCreation && self.recurrence == .none) {
                    return nil
                }
                return nextInstance
            }
        }
        
        guard let firstDay = weekDays.first else {
            return nil
        }
        
        let nextDate = fromDate.nextDateWithWeekDate(weekDay: firstDay.rawValue).addingTimeInterval(60 * 60 * 24 * 7)
        
        
        if (nextDate > nextWeekFromCreation && self.recurrence == .none) {
            return nil
        }
        
        return nextDate
        
    }
    
    func nextNotificationDate(fromDate: Date = Date()) -> Date? {
        
        guard let startDate = startDate else {
            return nil
        }
        
        if (startDate > fromDate) {
            return startDate
        }
        
        guard let nextWeekDate = getNextWeekDate(fromDate: fromDate), (nextWeekDate > startDate || recurrence == .weekly) else {
            return nil
        }
        
        return nextWeekDate
        
    }
    
}
