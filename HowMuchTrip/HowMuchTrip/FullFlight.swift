//
//  Flight.swift
//  APITest
//
//  Created by david on 12/10/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

class FullFlight
{
    let fullFlightID        : String
    let duration            : String
    
    let baseFareTotal       : String
    let saleTaxTotal        : String
    let saleTotal           : String
    
    let individualFlights   : [IndividualFlight]?
    
    init(
        
        fullFlightID        : String,
        duration            : String,
        
        baseFareTotal       : String,
        saleTaxTotal        : String,
        saleTotal           : String,
    
        individualFlights   : [IndividualFlight]?
    )
    {
        self.fullFlightID       = fullFlightID
        self.duration           = duration
        
        self.baseFareTotal      = baseFareTotal
        self.saleTaxTotal       = saleTaxTotal
        self.saleTotal          = saleTotal
        
        self.individualFlights  = individualFlights
    }
    
    static func fullFlightsFromJSON(searchResult: NSDictionary) -> [FullFlight]?
    {
        if let trips        = searchResult["trips"]         as? NSDictionary
        {
            var flights = [FullFlight]()
            
            let tripOptions      = trips["tripOption"]      as? [NSDictionary] ?? [NSDictionary]()
            
            for option in tripOptions
            {
                let pricing          = option["pricing"]         as? [NSDictionary] ?? [NSDictionary]()
                var baseFareTotal    = pricing.first!["baseFareTotal"] as? String ?? ""
                var saleTaxTotal     = pricing.first!["saleTaxTotal"]  as? String ?? ""
                var saleTotal       = option["saleTotal"]       as? String ?? ""
                
                baseFareTotal = baseFareTotal.stringByReplacingOccurrencesOfString("USD", withString: "$ ")
                saleTaxTotal  = saleTaxTotal.stringByReplacingOccurrencesOfString("USD", withString: "$ ")
                saleTotal     = saleTotal.stringByReplacingOccurrencesOfString("USD", withString: "$ ")
                
                let fullFlightID    = option["id"]              as? String ?? ""
                
                var individualFlights = [IndividualFlight]()
                
                let slices          = option["slice"]           as? [NSDictionary] ?? [NSDictionary]()
                let slice = slices.first!

                let rawDuration     = slice["duration"]         as? Int ?? 0
                let hours = (rawDuration / 60)
                let minutes = (rawDuration - (hours * 60))
                var duration = ("\(hours) hrs")
                if minutes != 0
                {
                    duration += (", \(minutes) mins")
                }

                
                let segments        = slice["segment"]          as? [NSDictionary] ?? [NSDictionary]()
                for segment in segments
                {
                    if let individualFlight = IndividualFlight.individualFlightFromJSON(segment)
                    {
                        individualFlights.append(individualFlight)
                    }
                }
                
                let flight = FullFlight(
                    
                    fullFlightID        : fullFlightID,
                    duration            : duration,
                    
                    baseFareTotal       : baseFareTotal,
                    saleTaxTotal        : saleTaxTotal,
                    saleTotal           : saleTotal,
                    
                    individualFlights   : individualFlights
                )
                flights.append(flight)
            }
            
            return flights
        }
        else
        {
            return nil
        }
    }
}