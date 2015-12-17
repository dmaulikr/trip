//
//  Trip.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation
import Parse

class Trip: PFObject, PFSubclassing
{
    @NSManaged var budgetTotal: Double
    @NSManaged var subtotalOfProperties: Double
    @NSManaged var budgetRemaining: Double
    
    @NSManaged var departureLocation: String
    @NSManaged var destination: String
    
    @NSManaged var dateFrom: String
    @NSManaged var dateTo: String
    @NSManaged var numberOfDays: Double
    @NSManaged var numberOfNights: Double
    
    @NSManaged var planeTicketCost: Double
    @NSManaged var dailyLodgingCost: Double
    @NSManaged var dailyFoodCost: Double
    @NSManaged var dailyOtherCost: Double
    @NSManaged var oneTimeCost: Double
    
    @NSManaged var totalLodgingCosts: Double
    @NSManaged var totalFoodCosts: Double
    @NSManaged var totalOtherDailyCosts: Double
    
    @NSManaged var departureLat: String
    @NSManaged var departureLng: String
    
    @NSManaged var destinationLat: String
    @NSManaged var destinationLng: String
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Trip"
    }
}

