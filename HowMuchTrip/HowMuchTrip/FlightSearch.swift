//
//  FlightSearch.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

struct FlightSearch
{
    let origin: String!
    let destination: String!
    let dateFrom: String!// = "2016-01-12"
    let dateTo: String!
    
    init(
        origin: String!,
        destination: String!,
        dateFrom: String!,
        dateTo: String!
        )
    {
        self.origin = origin
        self.destination = destination

        self.dateFrom = {
            let components = dateFrom.componentsSeparatedByString("/")
            
            let month = components[0]
            let day = components[1]
            
            var year = components[2]
            year = "20" + year
            
            let date = "\(year)-\(month)-\(day)"
            print(date)
            return date
        }()
        
        self.dateTo = {
            let components = dateTo.componentsSeparatedByString("/")
            
            let month = components[0]
            let day = components[1]
            
            var year = components[2]
            year = "20" + year
            
            let date = "\(year)-\(month)-\(day)"
            print(date)
            return date
            }()
    }
}
