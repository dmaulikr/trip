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
    var budgetTotal = 0.0
    var subtotalOfProperties = 0.0
    var budgetRemaining = 0.0
    
    var departureLocation = ""
    var destination = ""
    
    var dateFrom = 0.0
    var dateTo = 0.0
    var numberOfDays = 0.0
    var numberOfNights = 0.0
    
    var planeTicketCost = 0.0
    var dailyLodgingCost = 0.0
    var dailyFoodCost = 0.0
    var dailyOtherCost = 0.0
    var oneTimeCost = 0.0
    
    var resultsDictionary = [String:String]()
    
    init(dictionary: [String:String])
    {
        
    }
    
    func calculate(dictionary: [String:String]) -> [String:String]
    {
        for (key, value) in dictionary
        {
            switch key
            {
            case "Budget":
                budgetTotal = Double(value)!
            case "Departure Location":
                departureLocation = value
            case "Destination":
                destination = value
            case "Date From":
                dateFrom = Double(value)!
            case "Date To":
                dateTo = Double(value)!
            case "Plane Ticket Cost":
                planeTicketCost = Double(value)!
            case "Daily Lodging Cost":
                dailyLodgingCost = Double(value)!
            case "Daily Food Cost":
                dailyFoodCost = Double(value)!
            case "Daily Other Cost":
                dailyOtherCost = Double(value)!
            case "One Time Cost":
                oneTimeCost = Double(value)!
            default:
                break
            }
        }
        

        if dateFrom > 1.0 && dateTo > 1.0
        {
            numberOfDays = dateFrom - dateTo
            numberOfNights = numberOfDays - 1
        }
        else
        {
            numberOfDays = 1
            numberOfNights = 1
        }

        
        subtotalOfProperties = (planeTicketCost + (dailyLodgingCost * numberOfNights) + ((dailyFoodCost + dailyOtherCost) * numberOfDays) + oneTimeCost)
        budgetRemaining = budgetTotal - subtotalOfProperties

        resultsDictionary["Budget"] = String(budgetTotal)
        resultsDictionary["Subtotal"] = String(subtotalOfProperties)
        resultsDictionary["Budget Remaining"] = String(budgetRemaining)
        resultsDictionary["Departure Location"] = String(departureLocation)
        resultsDictionary["Destination"] = String(destination)
        resultsDictionary["Date From"] = String(dateFrom)
        resultsDictionary["Date To"] = String(dateTo)
        resultsDictionary["Number of Days"] = String(numberOfDays)
        resultsDictionary["Number of Nights"] = String(numberOfNights)
        resultsDictionary["Plane Ticket Cost"] = String(planeTicketCost)
        resultsDictionary["Daily Lodging Cost"] = String(dailyLodgingCost)
        resultsDictionary["Daily Food Cost"] = String(dailyFoodCost)
        resultsDictionary["Daily Other Cost"] = String(dailyOtherCost)
        resultsDictionary["One Time Cost"] = String(oneTimeCost)
        
        return resultsDictionary
    }
    
    func clearCalculator()
    {
        budgetTotal = 0.0
        subtotalOfProperties = 0.0
        budgetRemaining = 0.0
        
        departureLocation = ""
        destination = ""
        
        dateFrom = 0.0
        dateTo = 0.0
        numberOfDays = 0.0
        numberOfNights = 0.0
        
        planeTicketCost = 0.0
        dailyLodgingCost = 0.0
        dailyFoodCost = 0.0
        dailyOtherCost = 0.0
        oneTimeCost = 0.0
       
        resultsDictionary.removeAll()
    }
}
