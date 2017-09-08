//
//  CalendarHelper.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/20/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import EventKit

public enum CalendarError: Error {
    case notGranted
    case errorSavingEvent
    case noCalendar
}

public final class CalendarHelper {
    
    public static let shared = CalendarHelper()
    
    public typealias CalendarClosure = (String?, CalendarError?) -> Void
    typealias EventsClosure = ([EKEvent]?, CalendarError?) -> Void
    
    static let calendarName = "Balance Pie"

    
    /// adds an event to calendar
    ///
    /// - Parameters:
    ///   - title: the title of the event
    ///   - date: the date of the event
    ///   - calendarClosure: completion closure
    public func addEvent(with title: String, notes: String?, date:Date, calendarClosure: @escaping CalendarClosure) {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { (granted, error) in
            guard granted else {
                calendarClosure(nil, .notGranted)
                return
            }
            
            let event = EKEvent(eventStore: store)
            event.title = title
            event.startDate = date
            
            event.addAlarm(EKAlarm(relativeOffset: 0))
            
            if let eventNotes = notes {
                event.notes = eventNotes
            }
            
            event.endDate = event.startDate.addingTimeInterval(3600) // 1 hour event
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent)
                DispatchQueue.main.async { calendarClosure(event.eventIdentifier, nil) }
            } catch {
                DispatchQueue.main.async { calendarClosure(nil, .errorSavingEvent) }
            }
        }
        
    }
    
    func getEvents(numberOfDays: Int, completion: EventsClosure? = nil) {
        let store = EKEventStore()
        store.requestAccess(to: .event) { (granted, error) in
            
            guard granted else {
                completion?(nil, .notGranted)
                return
            }
            
            let endDate = Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * numberOfDays)).endOfDay()
            
            let predicate = store.predicateForEvents(withStart: Date(), end: endDate, calendars: nil)
            
            let events = store.events(matching: predicate)
            
            completion?(events,  nil)

        }
    }
    
    func removeEvent(eventId: String) {
        
        let store = EKEventStore()
        
        guard let event = store.event(withIdentifier: eventId) else {
//            return assertionFailure()
            return
        }
        
        do {
            
            try store.remove(event, span: .futureEvents)
            
        } catch {
            
            print("error removing an event")
            assertionFailure()
            
        }
        
    }
}
