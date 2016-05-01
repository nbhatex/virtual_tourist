//
//  FlickrManager.swift
//  Virtual Tourist
//
//  Created by Narasimha Bhat on 27/03/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation
import CoreData

let API_URL = "https://api.flickr.com/services/rest/"
let API_KEY = "24e13b089c1b2fa03b81a1c555fc83d7"
let API_METHOD = "flickr.photos.search"

class FlickrManager {
    
    let session = NSURLSession.sharedSession()
    
    static let sharedInstance = FlickrManager()
    private init() {}
    
    func search(pin:Pin,completionHandler:([[String:AnyObject]])->(),failureHandler:(String)->()) {
        
        let methodArguments: [String:String!] = [
            "method" : API_METHOD,
            "api_key": API_KEY,
            "lat"    : "\(pin.latitude!)",
            "lon"    : "\(pin.longitude!)",
            "format" : "json",
            "extras" : "url_m",
            "safe_search" : "1",
            "accuracy" : "11",
            "nojsoncallback": "1"
            
        ]
        
        let requestURL = "\(API_URL)\(escapedParameters(methodArguments))"
        
        let request = NSMutableURLRequest(URL: NSURL(string: requestURL)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data,response,error) in
            
            let errorMessage = self.checkForError(data, response: response, error: error)
            
            guard( errorMessage == nil) else {
                failureHandler(errorMessage!)
                return
            }
            
            var parsedResult:AnyObject
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            }catch {
                failureHandler("Error while parsing")
                return
            }
            let result = parsedResult["photos"] as? [String:AnyObject]
            guard(result != nil) else {
                failureHandler("Error while getting photos \(parsedResult)")
                return
            }
            let total = result!["total"] as! String
            if Int(total) < 1 {
                print("No images found for this place")
                failureHandler("No images found for this place")
            }
            let photosFromResult = result!["photo"] as! [[String:AnyObject]]
            
            
            
            completionHandler(photosFromResult)
            
        })
        task.resume()
    }
    
    func getImage(url:String,completionHandler:(data:NSData)->(),failureHandler:(String)->()) {
        let request = NSURLRequest(URL: NSURL(string: url)!)
        
        let task = session.dataTaskWithRequest(request,completionHandler:{(data,response,error) in
            
            let errorMessage = self.checkForError(data, response: response, error: error)
            
            guard( errorMessage == nil) else {
                failureHandler(errorMessage!)
                return
            }
            
            completionHandler(data: data!)
        })
        task.resume()
    }
    
    func checkForError(data:NSData?,response:NSURLResponse?,error:NSError?)->String? {
        
        guard(error == nil) else {
            return (error?.localizedDescription)!
        }
        
        guard let statusCode = ( response as? NSHTTPURLResponse )?.statusCode where statusCode >= 200 && statusCode < 300 else {
            let statusCode = (response as? NSHTTPURLResponse )?.statusCode
            return "\(statusCode) - Error returned for request"
        }
        return nil
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
}