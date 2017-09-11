//
//  UIViewController+Extensions.swift
//  Personal-Compass
//
//  Created by ricardo hernandez  on 5/22/17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func showAlert(title: String, message: String?, completion: (()->Void)?=nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion?()
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
}

