//
//  UIClosureBarButtonItem.swift
//  Think Shift Release
//
//  Created by Philip Dow on 8/4/17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import UIKit

public final class UIClosureBarButtonItem: UIBarButtonItem {
    private var handler: ((Void) -> Void)?
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, handler: ((Void) -> Void)?) {
        self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.handler = handler
    }
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, handler: ((Void) -> Void)?) {
        self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.handler = handler
    }
    
    func barButtonItemPressed(sender: UIBarButtonItem) {
        handler?()
    }
}

