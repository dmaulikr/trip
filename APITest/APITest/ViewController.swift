//
//  ViewController.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLSessionDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        
        let origin = "SFO"
        let destination = "LAX"
        let date = "2015-12-10"
        
        let adultCount = 1
        let infantInLapCount = 0
        let infantInSeatCount = 0
        let childCount = 0
        let seniorCount = 0
        
        let numberOfResults = 5
        
        let requestJSON : NSDictionary =
        [
            "request" :
            [
                "slice":
                [
                    [
                        "origin": origin,
                        "destination": destination,
                        "date": date
                    ]
                ],
                "passengers":
                [
                    "adultCount": adultCount,
                    "infantInLapCount": infantInLapCount,
                    "infantInSeatCount": infantInSeatCount,
                    "childCount": childCount,
                    "seniorCount": seniorCount
                ],
                "solutions": numberOfResults
            ]
        ]
        
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
        
        let postDataTask = session.dataTaskWithRequest(request) {
            data, response, error -> Void in
            
            if data != nil
            {
                let parsedJSON = self.parseJSON(data!)
                print(parsedJSON)
            }
        }
        
        postDataTask.resume()
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
}

