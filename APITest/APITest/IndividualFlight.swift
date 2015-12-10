//
//  IndividualFlight.swift
//  APITest
//
//  Created by david on 12/10/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

class IndividualFlight
{
    let flightDuration          : Int
    let carrier                 : String
    let carrierNum              : String
    
    let cabin                   : String
    let aircraft                : String
    
    let arrivalTime             : String
    let departureTime           : String
    
    let origin                  : String
    let destination             : String
    
    let originTerminal          : String
    
    let onTimePerformance       : Int
    let mileage                 : Int
    
    init(
        
            flightDuration          : Int,
            carrier                 : String,
            carrierNum              : String,

            cabin                   : String,
            aircraft                : String,

            arrivalTime             : String,
            departureTime           : String,

            origin                  : String,
            destination             : String,

            originTerminal          : String,

            onTimePerformance       : Int,
            mileage                 : Int
    )
    {
        self.flightDuration     = flightDuration
        self.carrier            = carrier
        self.carrierNum         = carrierNum
        
        self.cabin              = cabin
        self.aircraft           = aircraft
        
        self.arrivalTime        = arrivalTime
        self.departureTime      = departureTime
        
        self.origin             = origin
        self.destination        = destination
        
        self.originTerminal     = originTerminal
        
        self.onTimePerformance  = onTimePerformance
        self.mileage            = mileage
    }
    
    static func individualFlightFromJSON(segment: NSDictionary) -> IndividualFlight?
    {
        let duration        = segment["duration"]           as? Int ?? 0
        
        let carrierAndNum   = segment["flight"]             as? NSDictionary ?? NSDictionary()
        let carrier         = carrierAndNum["carrier"]      as? String ?? ""
        let carrierNum      = carrierAndNum["number"]       as? String ?? ""
        
        let cabin           = segment["cabin"]              as? String ?? ""
        
        let legs            = segment["leg"]                as? [NSDictionary] ?? [NSDictionary]()
        if let leg          = legs.first
        {
            let aircraft        = leg["aircraft"]           as? String ?? ""
            
            let arrivalTime     = leg["arrivalTime"]        as? String ?? ""
            let departureTime   = leg["departureTime"]      as? String ?? ""
            
            let origin          = leg["origin"]             as? String ?? ""
            let destination     = leg["destination"]        as? String ?? ""
            
            let originTerminal  = leg["originTerminal"]     as? String ?? ""
            
            let onTime          = leg["onTimePerformance"]  as? Int ?? 0
            let mileage         = leg["mileage"]            as? Int ?? 0
            
            
            let individualFlight = IndividualFlight(
                
                flightDuration      : duration,
                carrier             : carrier,
                carrierNum          : carrierNum,
                
                cabin               : cabin,
                aircraft            : aircraft,
                
                arrivalTime         : arrivalTime,
                departureTime       : departureTime,
                
                origin              : origin,
                destination         : destination,
                
                originTerminal      : originTerminal,
                
                onTimePerformance   : onTime,
                mileage             : mileage
            )
            
            return individualFlight
        }
        else
        {
            return nil
        }
    }
}