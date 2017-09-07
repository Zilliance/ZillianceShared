//
//  Analytics.swift
//  Pods
//
//  Created by Ignacio Zunino on 06-09-17.
//
//

import Foundation

//utilities to allow splitting a String when there's an uppercase
extension Sequence {
    func splitBefore(
        separator isSeparator: (Iterator.Element) throws -> Bool
        ) rethrows -> [AnySequence<Iterator.Element>] {
        var result: [AnySequence<Iterator.Element>] = []
        var subSequence: [Iterator.Element] = []
        
        var iterator = self.makeIterator()
        while let element = iterator.next() {
            if try isSeparator(element) {
                if !subSequence.isEmpty {
                    result.append(AnySequence(subSequence))
                }
                subSequence = [element]
            }
            else {
                subSequence.append(element)
            }
        }
        result.append(AnySequence(subSequence))
        return result
    }
}

extension Character {
    var isUpperCase: Bool { return String(self) == String(self).uppercased() }
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

public protocol AnalyticEvent {
    
    var name: String {get}
    var data: [String: Any]? {get}
    
}

extension RawRepresentable where RawValue == String, Self: AnalyticEvent {
    
    public var name: String {
        return self.rawValue.characters
            .splitBefore(separator: { $0.isUpperCase })
            .map{(String($0)).capitalizingFirstLetter()}.joined(separator: " ")
    }
    
    public var data: [String: Any]? {
        return nil
    }
    
}


//
public protocol AnalyticsService {
    func send(event: AnalyticEvent)
}

open class ZillianceAnalytics {
    
    static var projectName: String = ""
    
    static var analyticsService: AnalyticsService!
    
    public static func initialize(projectName: String, analyticsService: AnalyticsService) {
        ZillianceAnalytics.projectName = projectName
        ZillianceAnalytics.analyticsService = analyticsService
    }
    
    public enum DetailedEvents: AnalyticEvent {
        
        case tourPagedViewed(Int)
        case tourClosed(Int)
        case viewControllerShown(String)
        
        public var name: String {
            switch self {
            case .tourPagedViewed(_):
                return "Tour Paged Viewed"
            case .viewControllerShown(let name):
                var name = name.replacingOccurrences(of: "CollectionViewController", with: "")
                name = name.replacingOccurrences(of: "ViewController", with: "")
                name = name.replacingOccurrences(of: ZillianceAnalytics.projectName, with: "")
                return "View Shown - " + name
            case .tourClosed(_):
                return "Tour Closed"
            }
            
        }
        
        public var data: [String : Any]? {
            
            switch self {
            case .tourPagedViewed(let page):
                return ["Page": page]
            case .tourClosed(let page):
                return ["Page": page]
            case .viewControllerShown(_):
                return nil
            }
        }
    }
    
    public enum BaseEvents: String, AnalyticEvent {
        
        //Plan?
        case planViewed
        case calendarEventAdded
        case reminderAdded
        case repeatingReminderAdded
        
        // Sidebar
        case faqViewed
        case companyViewed
        case privacyPolycyViewed
        case termsOfServicesViewed
        
        //Summary/sharing
        case summaryViewed
        case summaryShared
        
    }
    
}



