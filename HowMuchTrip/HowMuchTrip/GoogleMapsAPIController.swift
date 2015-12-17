//
//  GoogleMapsAPIController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/17/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

class GoogleZipAPIController
{
//    var googleAPI: GoogleZipAPIControllerProtocol
    var task: NSURLSessionDataTask!
    
//    init(delegate: GoogleZipAPIControllerProtocol)
//    {
//        self.googleAPI = delegate
//    }
//    
    func search(searchTerm: String, cc: String)
    {
        var urlString = ""
        
        
        
        print(cc)
        
        switch cc
        {
        case "zip": urlString =  "https://maps.googleapis.com/maps/api/geocode/json?address=santa+cruz&components=postal_code:\(searchTerm)&sensor=false"
        case "city":
            let formattedSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            //            let escapedSearchTerm = formattedSearchTerm.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
            urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(formattedSearchTerm)&components=postal_code:&sensor=false"
            print(urlString)
            
        default: print("cc was invalid")
        }
        
        let url = NSURL(string: urlString)
        
        let session = NSURLSession.sharedSession()
        task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            print("Task completed")
            if error != nil
            {
                print(error!.localizedDescription)
            }
            else
            {
                if let results = self.parseJSON(data!)
                {
                    if let results: NSArray = results["results"] as? NSArray
                    {
//                        self.googleAPI.googleSearchWasCompleted(results)
                        //                        if let dictionary = results[0] as? NSDictionary
                        //                        {
                        //                            self.googleAPI.googleSearchWasCompleted(dictionary)
                        //                        }
                    }
                }
            }
        })
        task.resume()
    }
    
    func parseJSON(data: NSData) -> NSDictionary?
    {
        do
        {
            let dictionary: NSDictionary! = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
            print("parseJSON")
            
            return dictionary
        }
        catch let error as NSError
        {
            print(error)
            return nil
        }
    }
    
    func cancelSearch()
    {
        task.cancel()
    }
    
    
}