//
//  PhotoUtils.swift
//  Think Shift Release
//
//  Created by Ignacio Zunino on 04-08-17.
//  Copyright © 2017 Zilliance. All rights reserved.
//

import Foundation
import Photos

public final class PhotoUtils {
    
    public static func getPhoto(assetURL: URL) -> UIImage? {
        
        var retrievedPhoto: UIImage?
        
        let fetchResults = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil)
        
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        
        fetchResults.enumerateObjects(using: { asset, index, _ in
            PHImageManager.default().requestImage(for: asset, targetSize:  PHImageManagerMaximumSize , contentMode: .aspectFill, options: options, resultHandler: {(image, info) in
                
                retrievedPhoto = image
                
            })
        })
        
        return retrievedPhoto
        
    }
    
    public static func fetchImages(for urls:[URL], completion: @escaping ([URL: UIImage]) -> () ) {
        
        var tempImages: [URL: UIImage] = [:]
        
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        
        let dispatchGroup = DispatchGroup()
        
        for url in urls {
            
            dispatchGroup.enter()
            
            let fetchResults = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
            
            if let asset = fetchResults.firstObject {
                PHImageManager.default().requestImage(for: asset, targetSize:  CGSize(width: 300.0, height: 300.0) , contentMode: .aspectFill, options: options, resultHandler: {(image, info) in
                    if let image = image {
                        tempImages[url] = image
                        dispatchGroup.leave()
                    }
                })
            }
            else {
                dispatchGroup.leave()
            }
            
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            
            completion(tempImages)
            
        }
        
    }
    
}
