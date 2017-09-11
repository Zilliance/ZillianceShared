//
//  TimeInterval+Extensions.swift
//  Think Shift Release
//
//  Created by Ignacio Zunino on 02-08-17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import Foundation

public extension TimeInterval {
    var stringFormat: String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
}
