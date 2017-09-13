//
//  ZillianceShared.swift
//  Pods
//
//  Created by Ignacio Zunino on 12-09-17.
//
//

import Foundation

public final class ZillianceSharedBundle {
    
    public static var resourcesBundle: Bundle! {
        let podBundle = Bundle(for: ZillianceSharedBundle.self)
        guard let bundleURL = podBundle.url(forResource: "Resources", withExtension: "bundle"), let bundle = Bundle(url: bundleURL) else {
            assertionFailure()
            return nil
        }
        
        return bundle
    }
    
}
