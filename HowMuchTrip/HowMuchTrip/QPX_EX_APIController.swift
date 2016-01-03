//
//  QPX_EX_APIController.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

protocol QPX_EX_APIControllerDelegate
{
    func didReceiveQPXResults(results: NSDictionary?)
}

class QPX_EX_APIController: NSObject, NSURLSessionDelegate
{
    var delegate: QPX_EX_APIControllerDelegate?
    
    init(delegate: QPX_EX_APIControllerDelegate)
    {
        self.delegate = delegate
    }
    
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
            request.HTTPBody = postData
        }
        catch let error as NSError
        {
            print("data could not be parsed \(error)")
        }
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if data != nil
                {
                    if let parsedJSON = self.parseJSON(data!)
                    {
                        self.delegate?.didReceiveQPXResults(parsedJSON)
                    }
                    else
                    {
                        self.delegate?.didReceiveQPXResults(nil)
                    }
                }
                else
                {
                    print(error?.localizedDescription)
                    self.delegate?.didReceiveQPXResults(nil)
                }
            }.resume()
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
            self.delegate?.didReceiveQPXResults(nil)
            return nil
        }
    }
    
    func getRequestJSON(flightSearch: FlightSearch) -> NSDictionary
    {
        let request : NSDictionary = [
            "request":
                [
                    "slice":
                    [
                            [
                                "origin"        : flightSearch.origin,
                                "destination"   : flightSearch.destination,
                                "date"          : flightSearch.date,
                                //                                "maxStops"      : flightSearch.maxStops,
//                                "preferredCabin": flightSearch.preferredCabin
                            ]
                    ],
                    "passengers":
                        [
                            "adultCount"        : 1,//flightSearch.adultCount,
                            "infantInLapCount"  : 0,//flightSearch.infantInLapCount,
                            "infantInSeatCount" : 0,//flightSearch.infantInSeatCount,
                            "childCount"        : 0,//flightSearch.childCount,
                            "seniorCount"       : 0,//flightSearch.seniorCount
                    ],
                    "solutions"     : 10,//flightSearch.numberOfResults,
//                    "maxPrice"      : flightSearch.maxPrice,
//                    "saleCountry"   : flightSearch.saleCountry,
                    "refundable"    : false//flightSearch.refundable
            ]

        ]
//        let requestJSON : NSDictionary = request
//        print(requestJSON)
        
        print(request)
        return request
    }
}
