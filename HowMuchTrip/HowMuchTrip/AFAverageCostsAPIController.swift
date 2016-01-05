//
//  AFAverageCostsAPIController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/18/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//protocol AverageCostsAPIResultsProtocol
//{
//    func didReceiveAverageCosts(results: NSDictionary)
//}

class AFAverageCostsAPIController
{
    //    var averageCostsDelegate: AverageCostsAPIResultsProtocol?
    //
    //    init(averageCostsDelegate: AverageCostsAPIResultsProtocol)
    //    {
    //        self.averageCostsDelegate = averageCostsDelegate
    //    }
    
    func searchLocationForGeonameid(lat: Double, lng: Double)
    {
        
        let apiKey = "jen@jshamilton.net"
        let baseURL = "http://www.budgetyourtrip.com/api/v3/"
        let geodataSearch = "/search/geodata/\(lat),\(lng)"
        let completeURL = "\(baseURL)\(geodataSearch)"
        let headers = ["X-API-KEY": apiKey]
        
        // 1
        Alamofire.request(.GET, completeURL, headers: headers).responseJSON { response in
            switch response.result
            {
            case .Success(let data):

                if let dictionary = self.parseJSON(data as! NSData)
                {
                    if let dataArray: NSArray = dictionary["data"] as? NSArray
                    {
                        if let innerResultDictionary = dataArray[0] as? NSDictionary
                        {
                            print(innerResultDictionary)
                            //                            self.averageCostsDelegate!.didReceiveAverageCostsAPIResults(innerResultDictionary)
                        }
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }

        
        // 2
//        Alamofire.request(.GET, completeURL, headers: headers).responseJSON { response in
//            print(response.request)  // original URL request
//            print(response.response) // URL response
//            print(response.data)     // server data
//            print(response.result)   // result of response serialization
//            
//            if let JSON = response.result.value {
//                print("JSON: \(JSON)")
//                
//                if let dictionary = self.parseJSON(JSON as! NSData)
//                {
//                    if let dataArray: NSArray = dictionary["data"] as? NSArray
//                    {
//                        if let innerResultDictionary = dataArray[0] as? NSDictionary
//                        {
//                            //                            self.averageCostsDelegate!.didReceiveAverageCostsAPIResults(innerResultDictionary)
//                        }
//                    }
//                    
//                }
//
//                
//            }
//            
//        }
    }
    
    func searchGeonameidForCosts(geonameid: String)
    {
        let apiKey = "jen@jshamilton.net"
        let baseURL = "http://www.budgetyourtrip.com/api/v3/"
        let geodataSearch = "/costs/location/\(geonameid)"
        let completeURL = "\(baseURL)\(geodataSearch)"
        let headers = ["X-API-KEY": apiKey]
        
        // 1
        Alamofire.request(.GET, completeURL, headers: headers).responseJSON { response in
            switch response.result
            {
            case .Success(let data):
                
                if let dictionary = self.parseJSON(data as! NSData)
                {
                    if let dataArray: NSArray = dictionary["data"] as? NSArray
                    {
                        if let innerResultDictionary = dataArray[0] as? NSDictionary
                        {
                            print(innerResultDictionary)
                            //                            self.averageCostsDelegate!.didReceiveAverageCostsAPIResults(innerResultDictionary)
                        }
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
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
            return nil
        }
    }
    
}

    
/*
    
    func searchAverageCostsFor(lat: Double, lng: Double)
    {
        
        let apiKey = "jen@jshamilton.net"
        let baseURL = "http://www.budgetyourtrip.com/api/v3/"
        let geodataSearch = "/search/geodata/\(lat),\(lng)"
        let completeURL = "\(baseURL)\(geodataSearch)"
        let session = NSURLSession.sharedSession()
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: completeURL)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.HTTPMethod = "GET"
        do
        {
            let getData = try NSJSONSerialization.dataWithJSONObject(completeURL, options: NSJSONWritingOptions.PrettyPrinted)
            request.HTTPBody = getData
        }
        catch let error as NSError
        {
            print("data couldn't be parsed: \(error)")
        }
        
        
        let getDataTask = session.dataTaskWithRequest(request) {
            data, response, error -> Void in
            if error == nil
            {
                print("\(data)")
                do
                {
                    if let dictionary = self.parseJSON(data!)
                    {
                        if let dataArray: NSArray = dictionary["data"] as? NSArray
                        {
                            if let innerResultDictionary = dataArray[0] as? NSDictionary
                            {
                                //                            self.averageCostsDelegate!.didReceiveAverageCostsAPIResults(innerResultDictionary)
                            }
                        }
                        
                    }                }
                catch let error as NSError
                {
                    print("data couldn't be parsed: \(error)")
                }
                
                
            }
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
            return nil
        }
    }
}

*/

/*
SAMPLE RESULT from geodata request:

{
    status: true,
    data: [
        {
            "geonameid": "4167147",
            "name": "Orlando",
            "asciiname": "Orlando",
            "alternativenames": "32801,32802,32803,32804,32805,32806,32807,32808,32809,32810,32811,32812,32813,32814,32816,32817,32818,32819,32820,32821,32822,32824,32825,32826,32827,32828,32829,32830,32831,32832,32833,32834,32835,32836,32837,32839,32853,32854,32855,32856,32857,32858,32859,32860,32861,32862,32867,32868,32869,32872,32877,32878,32886,32887,32889,32890,32891,32893,32897,32898,Orlando,ao lan duo,orando,ÐžÑ€Ð»Ð°Ð½Ð´Ð¾,××•×¨×œ× ×“×•,ã‚ªãƒ¼ãƒ©ãƒ³ãƒ‰,å¥¥å…°å¤š",
            "latitude": "28.5383355000",
            "longitude": "-81.3792365000",
            "feature_class": "P",
            "feature_code": "PPL",
            "country_code": "US",
            "admin1_code": "FL",
            "timezone": "America/New_York",
            "country_name": "United States of America ",
            "negotiate": "0",
            "currency_code": "USD",
            "currency": "Dollar (United States)",
            "symbol": "$",
            "statename": "Florida"
        },
        {},{},...
    ]
}

*/