//
//  Date+Extensions.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 12-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
extension Date {
    
    func weekDay() -> Int {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.weekday], from: self)
        
        //this should never be nil
        return components.weekday! - 1
    }
    
    func nextDateWithWeekDate(weekDay: Int) -> Date {
        
        let weekDayForToday = self.weekDay()
        
        let difference = weekDay - weekDayForToday
        
        return self.addingTimeInterval(TimeInterval(60 * 60 * 24 * difference))
        
    }
    
    
    func endOfDay() -> Date {
                
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.minute = 59
        components.second = 59
        components.hour = 23
                
        //this should never be nil
        return calendar.date(from: components)!
        
    }
    
    func secondsPrecision() -> Date {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month, .day, .minute, .second, .hour], from: self)
        components.minute = 59
        components.second = 59
        components.hour = 23
        
        //this should never be nil
        return calendar.date(from: components)!
    }
    
}
