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
    func didReceiveMapsAPIResults(results: NSDictionary, textFieldTag: Int)
}

protocol GooglePlacesAPIProtocol
{
    func didReceiveGooglePlacesAPIResults(predictions: [NSDictionary]?)
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
    func searchGMapsFor(searchTerm: String, textFieldTag: Int)
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
                if let resultsArr = results["results"] as? NSArray
                {
                    if resultsArr.count > 0
                    {
                        let result = resultsArr[0] as? NSDictionary ?? NSDictionary()
                        // Sends results back to the calling object via delegate
                        self.delegate!.didReceiveMapsAPIResults(result, textFieldTag: textFieldTag)
                    }
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

class GooglePlacesAPIController
{
    var delegate: GooglePlacesAPIProtocol?
    
    init(delegate: GooglePlacesAPIProtocol)
    {
        self.delegate = delegate
    }
    
    func searchGooglePlacesFor(var keyboardEntry: String)
    {
        keyboardEntry = keyboardEntry.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        let urlPath = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(keyboardEntry)&types=(cities)&key=AIzaSyDTPgYOHM31jzVcZFV-wdg2RmdleSkAF-4"
        let session = NSURLSession.sharedSession()
        if let url = NSURL(string: urlPath)
        {
            session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
                else
                {
                    if let dictionary = self.parseJSON(data!)
                    {
                        if let predictions = dictionary["predictions"] as? [NSDictionary]
                        {
                            self.delegate?.didReceiveGooglePlacesAPIResults(predictions)
                        }
                        else
                        {
                            self.delegate?.didReceiveGooglePlacesAPIResults(nil)
                        }
                    }
                    else
                    {
                        self.delegate?.didReceiveGooglePlacesAPIResults(nil)
                    }
                }
            }).resume()
        }

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
            self.delegate?.didReceiveGooglePlacesAPIResults(nil)
            return nil
        }
    }

}