//
//  AirportCodeAPI.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/21/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

protocol AirportCodeAPIResultsProtocol
{
    func didReceiveAirportCodeAPIResults(airportCode: String)
}

/// MapsAPIController allows user to find the Google Maps API data for a location
class AirportCodeAPI
{
    var delegate: AirportCodeAPIResultsProtocol?
    
    /**
     Initialzer creates a MapsAPIController object.
     
     - Parameters:
     - delegate: takes in a delegate passed from the MapsAPIResultsProtocol, transmitting the user-entered location string.
     
     
     - Returns: MapsAPIController object
     
     */
    init(delegate: AirportCodeAPIResultsProtocol)
    {
        self.delegate = delegate
    }
    
    /**
     Uses the user-entered data to search for nearest airport codes for location
     
     - Parameters:
     - searchTerm: Term entered by user, in 'City, State' format
     - textField: The textField in which the data is entered by the user
     
     Passes the data back to the calling object via the delegate.
     
     */
    func searchForNearestAirportCode(lat: String, lng: String)
    {
        // Format searchTerm correctly for url
        let url = "https://airport.api.aero/airport/nearest/\(lat)/\(lng)?maxAirports=1&user_key=9865af1174002a159f8a1960a8b81eba"
        let urlString = NSURL(string: url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(urlString!, completionHandler: {data, response, error -> Void in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            else if let results = self.parseJSON(data!)
            {
                let airportsArr = results["airports"] as? NSArray ?? NSArray()
                if let result = airportsArr[0] as? NSDictionary
                {
                    // Sends results back to the calling object via delegate
                    let airportCode = result["code"] as? String ?? ""
                    self.delegate!.didReceiveAirportCodeAPIResults(airportCode)
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

/*
callback({
    "processingDurationMillis": 6,
    "authorisedAPI": true,
    "success": true,
    "airline": null,
    "errorMessage": null,
    "airports": 
    [
        {
            "code": "MCO",
            "name": "Orlando Intl",
            "city": "Orlando",
            "country": "United States",
            "timezone": "America/Kentucky/Monticello",
            "lat": 28.429394,
            "lng": -81.308994,
            "terminal": null,
            "gate": null
        }
    ]
})
*/