//
//  Location.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/17/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

class Location
{
    let city: String
    let lat: String
    let lng: String
    let state: String
    
    var imgHasBeenAnimated = false
    
    init(city: String, state: String, lat: String, lng: String)
    {
        self.city = city
        self.state = state
        self.lat = lat
        self.lng = lng
        
    }
    
    static func locationWithJSON(results: NSArray) -> Location
    {
        var location: Location
        var city = ""
        var state = ""
        var latStr = ""
        var lngStr = ""
        
        if results.count > 0
        {
            for result in results
            {
                if let formattedAddress = result["formatted_address"] as? String
                {
                    let addressComponentsForCity = formattedAddress.componentsSeparatedByString(",")
                    city = String(addressComponentsForCity[0])
                    
                    let stateZip = String(addressComponentsForCity[1])
                    state = stateZip.componentsSeparatedByString(" ")[1]
                }
                
                if let geometry = result["geometry"] as? NSDictionary
                {
                    let latLong = geometry["location"] as? NSDictionary
                    if latLong != nil
                    {
                        let lat = latLong?["lat"] as! Double
                        let lng = latLong?["lng"] as! Double
                        
                        latStr = String(lat)
                        lngStr = String(lng)
                    }
                }
            }
        }
        
        location = Location(city: city, state: state, lat: latStr, lng: lngStr)
        
        return location
    }
}