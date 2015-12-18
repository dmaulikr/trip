//
//  APIController.swift
//  Forecaster
//
//  Created by Jennifer Hamilton on 10/29/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

protocol MapsAPIResultsProtocol
{
    func didReceiveMapsAPIResults(results: NSDictionary, textField: UITextField)
}

class MapsAPIController
{
    var delegate: MapsAPIResultsProtocol?
    
    init(delegate: MapsAPIResultsProtocol)
    {
        self.delegate = delegate
    }
    
    func searchGMapsFor(searchTerm: String, textField: UITextField)
    {
        let escapedSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(escapedSearchTerm)&components=postal_code:&sensor=false"
        let urlString = NSURL(string: url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(urlString!, completionHandler: {data, response, error -> Void in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            else if let results = self.parseJSON(data!)
            {
                let resultsArr = results["results"] as? NSArray ?? NSArray()
                if let result = resultsArr[0] as? NSDictionary
                {
                    self.delegate!.didReceiveMapsAPIResults(result, textField: textField)
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