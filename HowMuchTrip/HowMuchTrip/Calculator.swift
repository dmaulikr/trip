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
    func calculationFinished(overBudget: Bool)
}

class Calculator
{
    var delegate: CalculationFinishedDelegate?

    init(delegate: CalculationFinishedDelegate?)
    {
        if delegate != nil
        {
            self.delegate = delegate
        }
    }
    
    func assignValue(var trip: Trip?, propertyAndValue: [String : String]) -> Trip
    {
        if trip == nil
        {
            trip = Trip()
        }
        
        var trip = trip!
        
        for (property, value) in propertyAndValue
        {
            switch property
            {
            case "Budget"               : trip.budgetTotal = Double(value)!
            case "Departure Location"   : trip.departureLocation = value
            case "Destination"          : trip.destination = value
            case "Date From"            : trip.dateFrom = value
            case "Date To"              : trip.dateTo = value
            case "Plane Ticket Cost"    : trip.planeTicketCost = Double(value)!
            case "Daily Lodging Cost"   : trip.dailyLodgingCost = Double(value)!
            case "Daily Food Cost"      : trip.dailyFoodCost = Double(value)!
            case "Daily Other Cost"     : trip.dailyOtherCost = Double(value)!
            case "One Time Cost"        : trip.oneTimeCost = Double(value)!
            case "destinationLat"       : trip.destinationLat = value
            case "destinationLng"       : trip.destinationLng = value
            case "departureLat"         : trip.departureLat = value
            case "departureLng"         : trip.departureLng = value
            default                     : print("invalid property \(property)")
            }
        }
        
        var overBudget: Bool
        (trip, overBudget) = getTotals(trip)
        
        delegate?.calculationFinished(overBudget)
        
        return trip
    }
    
    func getTotals(trip: Trip) -> (Trip, Bool)
    {
        trip.totalLodgingCosts =
            trip.dailyLodgingCost *
            trip.numberOfNights
        
        trip.totalFoodCosts =
            trip.dailyFoodCost *
            trip.numberOfDays
        
        trip.totalOtherDailyCosts =
            trip.dailyOtherCost *
            trip.numberOfDays
        
        trip.subtotalOfProperties =
            trip.planeTicketCost +
            trip.totalLodgingCosts +
            trip.totalFoodCosts +
            trip.totalOtherDailyCosts +
            trip.oneTimeCost
        
        trip.budgetRemaining =
            trip.budgetTotal -
            trip.subtotalOfProperties
        
        if let dateFrom = moment(trip.dateFrom, dateFormat: "MM/d/yy"),
            let dateTo = moment(trip.dateTo, dateFormat: "MM/d/yy")
        {
            let interval = dateTo.intervalSince(dateFrom)
            trip.numberOfDays = interval.days
            trip.numberOfNights = trip.numberOfDays - 1
        }
        else
        {
            trip.numberOfDays = 1
            trip.numberOfNights = 1
        }
        
        var overBudget: Bool {
            if trip.budgetRemaining >= -5.0 { return false }
            return true
        }
        
        return (trip, overBudget)
    }
    
    /*
    func calculate(dictionary: [String:String]) -> Trip
    {
        for (key, value) in dictionary
        {
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
        
        aTrip.propertyDictionary = dictionary

        return aTrip
    }
*/
    
    
    func clearCalculator()
    {
//        aTrip.budgetTotal = 0.0
//        aTrip.subtotalOfProperties = 0.0
//        aTrip.budgetRemaining = 0.0
//        
//        aTrip.departureLocation = ""
//        aTrip.destination = ""
//        
//        aTrip.dateFrom = ""
//        aTrip.dateTo = ""
//        aTrip.numberOfDays = 0.0
//        aTrip.numberOfNights = 0.0
//        
//        aTrip.planeTicketCost = 0.0
//        aTrip.dailyLodgingCost = 0.0
//        aTrip.dailyFoodCost = 0.0
//        aTrip.dailyOtherCost = 0.0
//        aTrip.oneTimeCost = 0.0
//       
//        aTrip.totalLodgingCosts = 0.0
//        aTrip.totalFoodCosts = 0.0
//        aTrip.totalOtherDailyCosts = 0.0
//        
//        aTrip.departureLat = ""
//        aTrip.departureLng = ""
//        
//        aTrip.destinationLat = ""
//        aTrip.destinationLng = ""

    }
}
