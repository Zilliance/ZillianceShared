//
//  UITableViewCell+Extensions.swift
//  Zilliance
//
//  Created by Philip Dow on 4/28/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    func extendSeparatorInsets() {
        self.separatorInset = .zero
        self.layoutMargins = .zero
    }
    
    func hideSeparatorInsets() {
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.size.width)
    }
}
