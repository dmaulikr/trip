//
//  APIController.swift
//  Forecaster
//
//  Created by Jennifer Hamilton on 10/29/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

class MapsAPIController
{
//    var cityDelegate: MapsAPIResultsProtocol?
//    
//    init(cityDelegate: MapsAPIResultsProtocol)
//    {
//        self.cityDelegate = cityDelegate
//    }
    
    func searchGMapsFor(searchTerm: String)
    {
        let escapedSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(escapedSearchTerm)&components=postal_code:&sensor=false"
        let urlString = NSURL(string: url)
        print(urlString)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(urlString!, completionHandler: {data, response, error -> Void in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            else
            {
                if let dictionary = self.parseJSON(data!)
                {
                    if let resultArray: NSArray = dictionary["results"] as? NSArray
                    {
                        if let cityInnerResultDictionary = resultArray[0] as? NSDictionary
                        {
//                            self.cityDelegate!.didReceiveMapsAPIResults(cityInnerResultDictionary)
                        }
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
            return dictionary
        }
        catch let error as NSError
        {
            print(error)
            return nil
        }
    }
}