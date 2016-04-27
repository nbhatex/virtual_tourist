//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 05/04/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit

class ImageCache {
    var cache = NSCache()
    
    class func sharedInstance() -> ImageCache {
        struct Static {
            static let instance = ImageCache()
        }
        
        return Static.instance
    }
    
    func getImage(identifier:String)->UIImage? {
        let path = pathForIdentifier(identifier)
        
        // First try the memory cache
        if let image = cache.objectForKey(path) as? UIImage {
            return image
        }
        
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func storeImage(identifier:String,image:UIImage) {
        let path = pathForIdentifier(identifier)
        cache.setObject(image, forKey: path)
        // And in documents directory
        let data = UIImagePNGRepresentation(image)!
        data.writeToFile(path, atomically: true)
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        print(fullURL.path!)
        return fullURL.path!
    }
    
    func removeImageFromStore(identifier:String) {
        let path = pathForIdentifier(identifier)
        if fileManager.fileExistsAtPath(path) {
            do {
                try fileManager.removeItemAtPath(path)
            }catch  {
                print(error)
            }
        }
    }
    
    var fileManager:NSFileManager {
        return NSFileManager.defaultManager()
    }
    
}