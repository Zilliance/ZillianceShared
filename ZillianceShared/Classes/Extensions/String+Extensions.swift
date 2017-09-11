//
//  String+Extensions.swift
//  Personal-Compass
//
//  Created by Philip Dow on 6/12/17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import UIKit

private let learnMoreColor = UIColor.aquaBlue

public extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public extension String {
    func learnMoreAttributedString(font: UIFont, color: UIColor) -> NSAttributedString {
        let string = self as NSString
        let attrString = NSMutableAttributedString(string: self, attributes: [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font,
        ])
        let range = string.range(of: "Learn More", options: .caseInsensitive, range: NSRange(location: 0, length: string.length))
        attrString.setAttributes([NSForegroundColorAttributeName: learnMoreColor], range: range)
        return attrString
    }
}
