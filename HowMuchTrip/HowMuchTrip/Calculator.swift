//
//  Calculator.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation
import SwiftMoment

protocol CalculationFinishedDelegate
{
    func calculationFinished(validCalc: Bool)
}

class Calculator
{
    let aTrip = Trip()
    var delegate: CalculationFinishedDelegate?

    init(dictionary: [String:String])
    {
        
    }
    
    func calculate(dictionary: [String:String]) -> Trip
    {
        for (key, var value) in dictionary
        {
            if key == "Budget"
            || key == "Plane Ticket Cost"
            || key == "Daily Lodging Cost"
            || key == "Daily Food Cost"
            || key == "Daily Other Cost"
            || key == "One Time Cost"
            {
                value = value.stringByReplacingOccurrencesOfString(",", withString: "")
            }
            
            switch key
            {
            case "Budget":
                aTrip.budgetTotal = Double(value.stringByReplacingOccurrencesOfString(",", withString: ""))!
            case "Departure Location":
                aTrip.departureLocation = value
            case "Destination":
                aTrip.destination = value
            case "Date From":
                aTrip.dateFrom = value
            case "Date To":
                aTrip.dateTo = value
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

        let dateFrom = moment(aTrip.dateFrom, dateFormat: "MM/d/yy")
        let dateTo   = moment(aTrip.dateTo, dateFormat: "MM/d/yy")
        
        if dateFrom != nil && dateTo != nil
        {
            let interval = dateTo?.intervalSince(dateFrom!)
            aTrip.numberOfDays = interval!.days
            aTrip.numberOfNights = aTrip.numberOfDays - 1
        }
        else
        {
            aTrip.numberOfDays = 1
            aTrip.numberOfNights = 1
        }

        aTrip.totalLodgingCosts = (aTrip.dailyLodgingCost * aTrip.numberOfNights)
        aTrip.totalFoodCosts = (aTrip.dailyFoodCost * aTrip.numberOfDays)
        aTrip.totalOtherDailyCosts = (aTrip.dailyOtherCost * aTrip.numberOfDays)
        
        aTrip.subtotalOfProperties =
            aTrip.planeTicketCost +
            aTrip.totalLodgingCosts +
            aTrip.totalFoodCosts +
            aTrip.totalOtherDailyCosts +
            aTrip.oneTimeCost
        
        aTrip.budgetRemaining =
            aTrip.budgetTotal -
            aTrip.subtotalOfProperties
        
        var validCalc = false
        if aTrip.budgetRemaining >= -5.0
        {
            validCalc = true
        }
        delegate?.calculationFinished(validCalc)

        return aTrip
    }
    
    
    func clearCalculator()
    {
        aTrip.budgetTotal = 0.0
        aTrip.subtotalOfProperties = 0.0
        aTrip.budgetRemaining = 0.0
        
        aTrip.departureLocation = ""
        aTrip.destination = ""
        
        aTrip.dateFrom = ""
        aTrip.dateTo = ""
        aTrip.numberOfDays = 0.0
        aTrip.numberOfNights = 0.0
        
        aTrip.planeTicketCost = 0.0
        aTrip.dailyLodgingCost = 0.0
        aTrip.dailyFoodCost = 0.0
        aTrip.dailyOtherCost = 0.0
        aTrip.oneTimeCost = 0.0
       
        aTrip.totalLodgingCosts = 0.0
        aTrip.totalFoodCosts = 0.0
        aTrip.totalOtherDailyCosts = 0.0

    }
}
