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
    func calculationFinished(overBudget: Bool)
}

/// The Calculator class performs mathematical calculations using user-entered data, to populate a Trip's properties.
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
    
    
    /**
     The calculate function uses user-entered data to calculate values that are then stored in a Trip object.
     
     - Parameters:
     - dictionary: A dictionary of String:String objects. Keys are Trip properties, and Values are the value of the properties.
     
     - Returns: A Trip object, populated with the user-entered data and the results of the 'calculate' function.
     
     */
    
    func assignValue(var trip: Trip?, propertyAndValue: [String : String]) -> Trip
    {
        if trip == nil
        {
            trip = Trip()
        }
        
        var trip = trip!
        
        // Set values in dictionary to Trip properties
        for (property, value) in propertyAndValue
        {
            switch property
            {
            case "Budget"               : trip.budgetTotal          = Double(value) ?? 0.0
            case "Departure Location"   : trip.departureLocation    = value
            case "Destination"          : trip.destination          = value
            case "Date From"            : trip.dateFrom             = value
            case "Date To"              : trip.dateTo               = value
            case "Plane Ticket Cost"    : trip.planeTicketCost      = Double(value) ?? 0.0
            case "Daily Lodging Cost"   : trip.dailyLodgingCost     = Double(value) ?? 0.0
            case "Daily Food Cost"      : trip.dailyFoodCost        = Double(value) ?? 0.0
            case "Daily Other Cost"     : trip.dailyOtherCost       = Double(value) ?? 0.0
            case "One Time Cost"        : trip.oneTimeCost          = Double(value) ?? 0.0
            case "destinationLat"       : trip.destinationLat       = value
            case "destinationLng"       : trip.destinationLng       = value
            case "departureLat"         : trip.departureLat         = value
            case "departureLng"         : trip.departureLng         = value 
            case "Name"                 : trip.tripName             = value
            default                     : print("invalid property \(property)")
            }
        }
        
        // Customizing the image set for user created trips
        trip.destinationImage = {
            var destination: String!
            if trip.destination.containsString(",")
            {
                let destinationComponents = trip.destination.componentsSeparatedByString(",")
                if destinationComponents.count > 1
                {
                    let shortDestination = destinationComponents[0] + ", " + destinationComponents[1]
                    destination = shortDestination
                }
            }
            else
            {
                destination = trip.destination
            }
            switch destination
            {
            case "Reno, NV", "Las Vegas, NV", "Atlantic City, NJ":
                return "slot-machines"
            case "New York, NY":
                return "brooklyn-bridge"
            case "San Francisco, CA", "San Jose, CA":
                return "golden-gate-bridge"
            case "Miami, FL", "Orlando, FL":
                return "miami-hotel"
            case "Denver, CO":
                return "denver"
            default:
                if (trip.destination.rangeOfString("beach") != nil)
                {
                    return "beach-jetty"
                }
                else if (trip.destination.rangeOfString("japan") != nil)
                {
                    return "japan-boat-market"
                }
                else
                {
                    let genericImages = [
                        "country-road",
                        "fancy-bar",
                        "fancy-dinner",
                        "fine-dining",
                        "fruit-market",
                        "hotel-room-service",
                        "mojito",
                        "outside-cafe",
                        "pond-cannonball",
                        "tulips"
                    ]
                    return genericImages[Int(arc4random() % UInt32(genericImages.count))]
                }
            }
        }()
        
        var overBudget: Bool
        (trip, overBudget) = getTotals(trip)
        
        // Check to see if calculation is finished, and if new entry has pushed Trip over the budget
        delegate?.calculationFinished(overBudget)
        
        return trip
    }
    
    /// Function to get Trip totals, and determine if trip is over budget
    /// - Returns: a Trip object, and Bool stating whether trip is overBudget
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
        
        // Sets dates into Moment objects if dateTo and dateFrom exists
        if let dateFrom = moment(trip.dateFrom, dateFormat: "MM/d/yy"),
            let dateTo = moment(trip.dateTo, dateFormat: "MM/d/yy")
        {
            let interval = dateTo.intervalSince(dateFrom)
            trip.numberOfDays = interval.days
            trip.numberOfNights = trip.numberOfDays - 1
        }
        else
        {
            // Sets Trip to a default of 1 day and 1 night duration
            trip.numberOfDays = 1
            trip.numberOfNights = 1
        }
        
        // If Budget Remaining for Trip is over budget, return true
        var overBudget: Bool {
            if trip.budgetRemaining >= -5.0 { return false }
            return true
        }
        
        return (trip, overBudget)
    }
}