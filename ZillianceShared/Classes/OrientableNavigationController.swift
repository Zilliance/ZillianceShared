//
//  OrientableNavigationController.swift
//  Think Shift Release
//
//  Created by Philip Dow on 7/23/17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

//  @a.ricardo

//  Use subclass names that describe what the class does. "CustomNavigationController" is too generic and tells us nothing about what the class's behavior is. Let's use "OrientableNavigationController" instead, for example.

//  We also want to write code that adapts to future change without requiring a rewrite. When supportedInterfaceOrientations returns .portrait by default, if we want to change the default orientation in another application we have to make another subclass or change the method implementation here. Instead let's use a static var with a default value that another application could set if it needs to.

//  When we provide a default implementation we are also overriding the behavior for every view controller on the navigation stack. Normally a view controller determines its own interface orietnations. If we want to support that behavior again, we have to change the code.

//  Instead, let's use protocol oriented programming so that a view controller can adopt the "OrientableViewController" protocol if it needs to and provide a custom implementation of supportedInterfaceOrientations, which is the variable the framework already supplies. Now our implementation can ask if the top view controller is orientable, and if it is, let it orient itself using the tools the framework of the framework, and if it isn't, return our static default orientation.

import UIKit

public protocol OrientableViewController {
    var supportedInterfaceOrientations: UIInterfaceOrientationMask { get }
}

public class OrientableNavigationController: UINavigationController {
    
    static var defaultInterfaceOrientations: UIInterfaceOrientationMask = .portrait
    
    override public var shouldAutorotate: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topViewController = self.topViewController as? OrientableViewController {
            return topViewController.supportedInterfaceOrientations
        } else {
            return OrientableNavigationController.defaultInterfaceOrientations
        }
    }
    
}
