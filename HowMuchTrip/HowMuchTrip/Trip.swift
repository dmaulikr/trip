//
//  Trip.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation
import Parse

/// A Trip object, holding all the static elements of a Trip.

class Trip: PFObject, PFSubclassing
{
    /// Username, derived from PFUser.currentUser()!.username!
    @NSManaged var user: String
    
    /// Total budget, as entered by user
    @NSManaged var budgetTotal: Double
    /// The subtotal of the expense properties
    @NSManaged var subtotalOfProperties: Double
    /// Budget, less the total of the expense properties
    @NSManaged var budgetRemaining: Double
    
    /// The name of the departure location in "City, State (or Country)" format
    @NSManaged var departureLocation: String
    /// The name of the destination location in "City, State (or Country)" format
    @NSManaged var destination: String
    /// A string with the user selected trip name
    @NSManaged var tripName: String?
    
    /// The date of the first day of the trip, uses 'Moments' Pod
    @NSManaged var dateFrom: String
    /// The date of the last day of the trip, uses 'Moments' Pod
    @NSManaged var dateTo: String
    /// The calculated number of days of the trip
    @NSManaged var numberOfDays: Double
    /// The calculated number of nights of the trip (one less than the days)
    @NSManaged var numberOfNights: Double
    
    /// The saved cost of the plane ticket - user entered
    @NSManaged var planeTicketCost: Double
    /// The daily cost of lodging - user entered
    @NSManaged var dailyLodgingCost: Double
    /// The daily cost of food - user entered
    @NSManaged var dailyFoodCost: Double
    /// Other daily costs that the user may enter
    @NSManaged var dailyOtherCost: Double
    /// One time costs such as concert tickets, Eurail pass, visa
    @NSManaged var oneTimeCost: Double
    
    /// The calculated costs of lodging: numberOfNights * dailyLodgingCost
    @NSManaged var totalLodgingCosts: Double
    /// The calculated costs of food: numberOfDays * dailyFoodCost
    @NSManaged var totalFoodCosts: Double
    /// The calculated costs of other: numberOfDays * dailyOtherCost
    @NSManaged var totalOtherDailyCosts: Double
    
    /// The latitude of the departure location
    @NSManaged var departureLat: String
    /// The longitude of the departure location
    @NSManaged var departureLng: String
    
    /// The latitude of the destination location
    @NSManaged var destinationLat: String
    /// The longitude of the destination location
    @NSManaged var destinationLng: String

    /// Destination airport code from Sabre Dev JSON file 'airports'
    @NSManaged var destinationAirportCode: String
    /// Origin airport code from Sabre Dev JSON file 'airports'
    @NSManaged var originAirportCode: String
    
    /// Image holder for destinationLocation
    @NSManaged var destinationImage: String
    
    /**
    Initializes the Trip class as a Parse subclass
     
     - Returns: An empty trip object, which is a PFObject subclass.
     
    */
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
    
    /**
     Method to set JSON results from Google Maps API to object properties
      
     - Parameters:
        - results: A dictionary with JSON results from the API Controller class
     
     - Returns: A dictionary with the latitude and longitude of the trip coordinates.
     
     */
    func tripCoordinateFromJSON(results: NSDictionary) -> (String, String)?
    {
        if let geometry = results["geometry"] as? NSDictionary
        {
            let location = geometry["location"] as? NSDictionary
            
            if location != nil
            {
                let lat = location!["lat"] as! Double
                let lng = location!["lng"] as! Double
                
                return (String(lat),String(lng))
                
            }
            else
            {
                print("couldn't find lat, lng")
            }
        }
        else
        {
            print(results)
        }
        return nil
    }

}

