//
//  BYTAPIController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/17/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

class AverageCostsAPIController
{
//    var averageCostsDelegate: AverageCostsAPIResultsProtocol?
//    
//    init(averageCostsDelegate: AverageCostsAPIResultsProtocol)
//    {
//        self.averageCostsDelegate = averageCostsDelegate
//    }
    
    
    func searchAverageCostsFor(lat: Double, lng: Double)
    {
        // TODO: waiting on API key from Budget Your Trip
        let url = NSURL(string: "/search/geodata//\(lat),\(lng)")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            else
            {
                if let dictionary = self.parseJSON(data!)
                {
//                    self.averageCostsDelegate!.didReceiveAverageCostsAPIResults(dictionary)
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