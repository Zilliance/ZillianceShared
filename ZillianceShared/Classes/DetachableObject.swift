//
//  DetachableObject.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 13-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import RealmSwift

public protocol DetachableObject: AnyObject {
    
    func detached() -> Self
    
}

extension Object: DetachableObject {
    
    public func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? DetachableObject {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
    
}

extension List: DetachableObject {
    
    public func detached() -> List<Element> {
        let result = List<Element>()
        forEach {
            result.append($0.detached())
        }
        return result
    }
    
}
