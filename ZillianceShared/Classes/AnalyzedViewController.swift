//
//  AnalyzedViewController.swift
//  Think Shift Release
//
//  Created by Ignacio Zunino on 04-09-17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import UIKit

extension NSObject {
    open var analyticsObjectName: String {
        return NSStringFromClass(type(of: self))
    }
}

open class AnalyzedViewController: UIViewController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let viewName = self.analyticsObjectName
        
        ZillianceAnalytics.analyticsService.send(event: ZillianceAnalytics.DetailedEvents.viewControllerShown(viewName))

    }
    
}
