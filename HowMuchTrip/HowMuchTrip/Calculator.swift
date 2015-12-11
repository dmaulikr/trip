//
//  Calculator.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

class Calculator
{
    init(dictionary: [String:String])
    {
        
    }
    
    func calculate(dictionary: [String:String]) -> Trip
    {
        let aTrip = Trip()
        
        for (key, value) in dictionary
        {
            switch key
            {
            case "Budget":
                aTrip.budgetTotal = Double(value)!
            case "Departure Location":
                aTrip.departureLocation = value
            case "Destination":
                aTrip.destination = value
            case "Date From":
                aTrip.dateFrom = Double(value)!
            case "Date To":
                aTrip.dateTo = Double(value)!
            case "Plane Ticket Cost":
                aTrip.planeTicketCost = Double(value)!
            case "Daily Lodging Cost":
                aTrip.dailyLodgingCost = Double(value)!
            case "Daily Food Cost":
                aTrip.dailyFoodCost = Double(value)!
            case "Daily Other Cost":
                aTrip.dailyOtherCost = Double(value)!
            case "One Time Cost":
                aTrip.oneTimeCost = Double(value)!
            default:
                break
            }
        }

        if aTrip.dateFrom > 1.0 && aTrip.dateTo > 1.0
        {
            aTrip.numberOfDays = aTrip.dateFrom - aTrip.dateTo
            aTrip.numberOfNights = aTrip.numberOfDays - 1
        }
        else
        {
            aTrip.numberOfDays = 1
            aTrip.numberOfNights = 1
        }

        aTrip.totalLodgingCosts = (aTrip.dailyLodgingCost * aTrip.numberOfNights)
        aTrip.totalFoodAndOtherCosts = ((aTrip.dailyFoodCost + aTrip.dailyOtherCost) * aTrip.numberOfDays)
        
        aTrip.subtotalOfProperties = aTrip.planeTicketCost + aTrip.totalLodgingCosts + aTrip.totalFoodAndOtherCosts + aTrip.oneTimeCost
        aTrip.budgetRemaining = aTrip.budgetTotal - aTrip.subtotalOfProperties
        
         return aTrip
    }
    
    func clearCalculator()
    {
        
//        budgetTotal = 0.0
//        subtotalOfProperties = 0.0
//        budgetRemaining = 0.0
//        
//        departureLocation = ""
//        destination = ""
//        
//        dateFrom = 0.0
//        dateTo = 0.0
//        numberOfDays = 0.0
//        numberOfNights = 0.0
//        
//        planeTicketCost = 0.0
//        dailyLodgingCost = 0.0
//        dailyFoodCost = 0.0
//        dailyOtherCost = 0.0
//        oneTimeCost = 0.0
//       
//        resultsDictionary.removeAll()
    }
}
