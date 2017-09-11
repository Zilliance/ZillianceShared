//
//  NSString+Ranges.swift
//  Personal-Compass
//
//  Created by Philip Dow on 8/25/17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import Foundation

public extension NSString {
    func ranges(of searchString: String) -> [NSRange] {
        var ranges = [NSRange]()
        
        var searchRange = NSRange(location: 0, length: self.length)
        var foundRange = NSRange(location: NSNotFound, length: 0)
        
        while searchRange.location < self.length {
            searchRange.length = self.length - searchRange.location
            foundRange = self.range(of: searchString, options: [], range: searchRange)
            
            if foundRange.location != NSNotFound {
                searchRange.location = foundRange.location + foundRange.length
                ranges.append(foundRange)
            } else {
                break
            }
        }
        
        return ranges
    }
}
