//
//  QPX_EX_APIController.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

class QPX_EX_APIController: NSObject, NSURLSessionDelegate
{
    func search(flightSearch: FlightSearch)
    {
        let defaultSession = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: defaultSession, delegate: self, delegateQueue: nil)
        
        let apikey = "AIzaSyBybYGqmWbmOSnBnRj_VlQXHCnQLmU9peQ"
        let baseURL = "https://www.googleapis.com/qpxExpress/v1/trips/search?key=" + apikey
        let url = NSURL(string: baseURL)
        let request = NSMutableURLRequest(
            URL: url!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 60.0)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        
        let requestJSON = getRequestJSON(flightSearch)
        
        do
        {
            let postData = try NSJSONSerialization.dataWithJSONObject(requestJSON, options: [])
            print(postData)
            request.HTTPBody = postData
        }
        catch let error as NSError
        {
            print("data could not be parsed \(error)")
        }
        
        session.dataTaskWithRequest(request) { (data, _, error) -> Void in
                if data != nil
                {
                    let parsedJSON = self.parseJSON(data!)
                    print(parsedJSON)
                }
                else
                {
                    print(error?.localizedDescription)
                }
            }.resume()
    }
    
    func parseJSON(data: NSData) -> NSDictionary?
    {
        do
        {
            let dictionary: NSDictionary! = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
            print("parsed darksky JSON")
            
            return dictionary
        }
        catch let error as NSError
        {
            print(error)
            return nil
        }
    }
    
    func getRequestJSON(flightSearch: FlightSearch) -> NSDictionary
    {
        let requestJSON : NSDictionary =
        
        [
            "request":
                [
                    "slice":
                        [
                            [
                                "origin": flightSearch.origin,
                                "destination": flightSearch.destination,
                                "date": flightSearch.date
                            ]
                    ],
                    "passengers":
                        [
                            "adultCount": flightSearch.adultCount,
                            "infantInLapCount": flightSearch.infantInLapCount,
                            "infantInSeatCount": flightSearch.infantInSeatCount,
                            "childCount": flightSearch.childCount,
                            "seniorCount": flightSearch.seniorCount
                    ],
                    "solutions": flightSearch.numberOfResults
            ]
        ]
        
        return requestJSON
    }
}
