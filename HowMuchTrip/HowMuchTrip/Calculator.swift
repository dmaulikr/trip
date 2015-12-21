//
//  Calculator.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation
import SwiftMoment

/// Delegate passes a notification to the CreateTrip class signaling that the calcualtion is finished and within budget.
protocol CalculationFinishedDelegate
{
    func calculationFinished(validCalc: Bool)
}

/// The Calculator class performs mathematical calculations using user-entered data, to populate a Trip's properties.
class Calculator
{
    let aTrip = Trip()
    var delegate: CalculationFinishedDelegate?

    init(dictionary: [String:String])
    {
        
    }
    
    /**
     The calculate function uses user-entered data to calcualte values that are then stored in a Trip object. 
     
     - Parameters: 
        - dictionary: A dictionary of String:String objects. Keys are Trip properties, and Values are the value of the properties.
     
     - Returns: A Trip object, populated with the user-entered data and the results of the 'calculate' function.

    */
    func calculate(dictionary: [String:String]) -> Trip
    {
        for (key, value) in dictionary
        {
            // Sets the relevant value to the correct key
            switch key
            {
            case "Budget":
                aTrip.budgetTotal = Double(value)!
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
            case "destinationLat":
                aTrip.destinationLat = value
            case "destinationLng":
                aTrip.destinationLng = value
            case "departureLat":
                aTrip.departureLat = value
            case "departureLng":
                aTrip.departureLng = value
            default:
                break
            }
        }
        
        let dateFrom = moment(aTrip.dateFrom, dateFormat: "MM/d/yy")
        let dateTo   = moment(aTrip.dateTo, dateFormat: "MM/d/yy")
        
        // Calculate the total days and nights of the trip. Assumes the standard trip is x days and x-1 nights.
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

        // Uses the number of days and nights to determine the subtotal for lodging, food and other daily costs.
        aTrip.totalLodgingCosts = (aTrip.dailyLodgingCost * aTrip.numberOfNights)
        aTrip.totalFoodCosts = (aTrip.dailyFoodCost * aTrip.numberOfDays)
        aTrip.totalOtherDailyCosts = (aTrip.dailyOtherCost * aTrip.numberOfDays)
        
        // Deterimines the subtotal of all travel expenses
        aTrip.subtotalOfProperties =
            aTrip.planeTicketCost +
            aTrip.totalLodgingCosts +
            aTrip.totalFoodCosts +
            aTrip.totalOtherDailyCosts +
            aTrip.oneTimeCost
        
        // Determines the amount of funds left after all expenses are covered.
        aTrip.budgetRemaining =
            aTrip.budgetTotal -
            aTrip.subtotalOfProperties
        
        
        // Prevents the user from spending more than allocated by budget.
        var validCalc = false
        if aTrip.budgetRemaining >= -5.0
        {
            validCalc = true
        }
        
        // Signals that the calcuation is finished, and the user has not gone over budget.
        delegate?.calculationFinished(validCalc)

        return aTrip
    }
    
    
    func clearCalculator()
    {
        // TODO: delete func
    }
}
