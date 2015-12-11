//
//  Trip.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

class Trip
{
//    Properties: budget, destination, to/from dates, numberOfDays, numberOfNights, plane ticket cost, daily lodging costs, daily food costs, daily other expenses, one time costs
    
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

    var totalLodgingCosts = 0.0
    var totalFoodAndOtherCosts = 0.0
    
    init()
    {
        
    }
}