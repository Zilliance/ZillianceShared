//
//  UIDevice+Extensions.swift
//  Balance Pie
//
//  Created by Philip Dow on 3/15/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

fileprivate let screenWidth = UIScreen.main.bounds.size.width
fileprivate let iPhone5Width: CGFloat = 320.0
fileprivate let iPhone6Width: CGFloat = 375.0

public extension UIDevice {
    static let isSmallerThaniPhone6 = screenWidth < iPhone6Width
}
