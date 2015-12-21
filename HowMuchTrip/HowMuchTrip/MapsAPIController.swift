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

/// MapsAPIController allows user to find the Google Maps API data for a location
class MapsAPIController
{
    var delegate: MapsAPIResultsProtocol?
    
    /**
     Initialzer creates a MapsAPIController object.
     
     - Parameters: 
        - delegate: takes in a delegate passed from the MapsAPIResultsProtocol, transmitting the user-entered location string.
     
     
     - Returns: MapsAPIController object
     
    */
    init(delegate: MapsAPIResultsProtocol)
    {
        self.delegate = delegate
    }
    
    /**
     Uses the user-entered data to search Google Maps for location information
     
     - Parameters: 
        - searchTerm: Term entered by user, in 'City, State' format
        - textField: The textField in which the data is entered by the user
     
     Passes the data back to the calling object via the delegate.
     
    */
    func searchGMapsFor(searchTerm: String, textField: UITextField)
    {
        // Format searchTerm correctly for url
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
                    // Sends results back to the calling object via delegate
                    self.delegate!.didReceiveMapsAPIResults(result, textField: textField)
                }
            }
        })
        task.resume()
    }
 
    /**
     Serializes json results from API request. Returns as a dictionary.
     
     - Parameters: 
        - data: data returned from task in searchGMapsFor function
     
     - Returns: NSDictionary
     
    */
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