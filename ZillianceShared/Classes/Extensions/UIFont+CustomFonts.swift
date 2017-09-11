//
//  UIFont+CustomFonts.swift
//  Personal Compass
//
//  Created by ricardo hernandez  on 1/16/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

public extension UIFont {
    
    class func muliLight(size: (CGFloat)) -> UIFont {
        return UIFont(name: "Muli-Light", size: size)!
    }
    
    class func muliItalic(size: (CGFloat)) -> UIFont {
        return UIFont(name: "Muli-Italic", size: size)!
    }
    
    class func muliLightItalic(size: (CGFloat)) -> UIFont {
        return UIFont(name: "Muli-LightItalic", size: size)!
    }
    
    class func muliBlack(size: (CGFloat)) -> UIFont {
        return UIFont(name: "Muli-Black", size: size)!
    }
    
    class func muliRegular(size: (CGFloat)) -> UIFont {
        return UIFont(name: "Muli-Regular", size: size)!
    }
    
    class func muliSemiBold(size: (CGFloat)) -> UIFont {
        return UIFont(name: "Muli-Semibold", size: size)!
    }
    
    class func muliBold(size: (CGFloat)) -> UIFont {
        return UIFont(name: "Muli-Bold", size: size)!
    }
}
