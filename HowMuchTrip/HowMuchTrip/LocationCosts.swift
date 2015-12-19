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

    let lat: String
    let lng: String
    let geonameid: String
    
    let valueBudget1: String
    let valueMidrange1: String
    let valueLuxury1: String
    
    let valueBudget2: String
    let valueMidrange2: String
    let valueLuxury2: String
    
    let valueBudget0: String
    let valueMidrange0: String
    let valueLuxury0: String
    
    
    init(lat: String, lng: String, geonameid: String?,
         valueBudget1: String?, valueMidrange1: String?, valueLuxury1: String?,
         valueBudget2: String?, valueMidrange2: String?, valueLuxury2: String?,
         valueBudget0: String?, valueMidrange0: String?, valueLuxury0: String?
        )
    {
        let propertyValueDictionary = [geonameid, valueBudget0, valueBudget1, valueBudget2, valueMidrange0, valueMidrange1, valueMidrange2, valueLuxury0, valueLuxury1, valueLuxury2]

        self.lat = lat
        self.lng = lng
        
        for propertyValue in propertyValueDictionary
        {
            if propertyValue != ""
            {
                self.property = propertyValue!
            }
        }
        
    }
    
    static func geonameidWithJSON(results: NSArray) -> Location
    {
        var location: Location!
        
        if results.count > 0
        {
            for result in results
            {
                let geonameid = result["geonameid"] as? String ?? ""
                let lat = result["latitude"] as? String ?? ""
                let lng = result["longitude"] as? String ?? ""

                location = Location(lat: lat, lng: lng, geonameid: geonameid)
            }
        }
        
        return location
    }
    
    // FIXME: this may not work - check to see if object still holds lat & lng
    static func costsFromGeonameidWithJSON(results: NSArray) -> Location
    {
        var location: Location!
        
        if results.count > 0
        {
            for result in results
            {
                var categoryID = result["category_id"] as? String ?? ""
                switch categoryID
                {
                    case 1:
                    let valueBudget1 = result["value_budget"] as? String ?? ""
                    let valueMidrange1 = result["value_midrange"] as? String ?? ""
                    let valueLuxury1 = result["value_luxury"] as? String ?? ""
                    case 2:
                    let valueBudget2 = result["value_budget"] as? String ?? ""
                    let valueMidrange2 = result["value_midrange"] as? String ?? ""
                    let valueLuxury2 = result["value_luxury"] as? String ?? ""
                    default:
                    let valueBudget0 = result["value_budget"] as? String ?? ""
                    let valueMidrange0 = result["value_midrange"] as? String ?? ""
                    let valueLuxury0 = result["value_luxury"] as? String ?? ""
                    
                    
                }
                
            }
        }
        
        return location
    }
}

/*

Response for Geodata: 

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

*/

/*

Response for Costs:
NOTE: In many cases, not all categories for a location will have travel costs data, and will be missing in the response data.
CATEGORY 1: Accomodation
CATEGORY 2: 
CATEGORY 0: Total, Actual travel costs for location


"category_id": "1",
"value_budget": "28.8283804572",
"value_midrange": "78.608090767",
"value_luxury": "231.253493979",
"geonameid": "2988507"
},
{
"category_id": "2",
"value_budget": "20.6112419345",
"value_midrange": "56.5147812001",
"value_luxury": "167.930090327",
"geonameid": "2988507"
},
{},{},...,
{
"value_budget": "46.7539020441",
"value_midrange": "124.232080451",
"value_luxury": "348.080379669",
"geonameid": "2988507",
"category_id": "0"

*/

