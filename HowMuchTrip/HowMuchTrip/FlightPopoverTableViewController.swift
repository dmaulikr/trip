//
//  FlightPopoverTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/21/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class FlightPopoverTableViewController: UITableViewController, QPX_EX_APIControllerDelegate
{
    var trip: Trip! {
        didSet {
            loadAirports()
        }
    }
    
    var flights = [FullFlight]()
    var airportCodes = [String]()
    var airportCities = [String]()
    
    var airports: NSDictionary! {
        return [airportCities : airportCodes]
    }
    
    var searchParameters: FlightSearch!
    
    var apiController: QPX_EX_APIController? {
        didSet {
            apiController!.search(searchParameters)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    
    var searchingForAirports: Bool! {
        didSet {
            if searchingForAirports == true {
                searchingForFlights = false
            }
        }
    }
    
    var searchingForDestinationAirports = false
    
    var searchingForFlights: Bool! {
        didSet {
            if searchingForFlights == true {
                searchingForAirports = false
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchingForAirports = true
        
        searchParameters = FlightSearch()
        apiController = QPX_EX_APIController(delegate: self)
    }
    
    func loadAirports()
    {
        if let allAirportsArray = loadJSON()
        {
            for airport in allAirportsArray
            {
                let airportCity = airport["CITY_NAME"] as? String ?? ""
                let airportCode = airport["VENDOR_CODE"] as? String ?? ""
                
                print(airportCity, airportCode)
                
                var row = 0
                
                if searchingForDestinationAirports
                {
                    if trip.destination.containsString(airportCity) && airportCity != "" && airportCode != ""
                    {
                        print("contains")
                        self.airportCities.append(airportCity)
                        self.airportCodes.append(airportCode)
                        
                        row = airportCities.indexOf(airportCity)!
                    }
                }
                else
                {
                    if trip.departureLocation.containsString(airportCity) && airportCity != "" && airportCode != ""
                    {
                        print("contains")
                        self.airportCities.append(airportCity)
                        self.airportCodes.append(airportCode)
                        
                        row = airportCities.indexOf(airportCity)!
                    }
                }
                
                let indexPath = NSIndexPath(forRow: row, inSection: 0)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
    
    func loadJSON() -> NSArray?
    {
        do
        {
            let filePath = NSBundle.mainBundle().pathForResource("airports", ofType: "json")
            let data = NSData(contentsOfFile: filePath!)
            let airportData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [NSDictionary]
            return airportData
            
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func didReceiveQPXResults(results: NSDictionary?)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if results != nil
            {
                if let flights = FullFlight.fullFlightsFromJSON(results!)
                {
                    for flight in flights
                    {
                        self.flights.append(flight)
                    }
                }
                else
                {
                    print("no dice")
                }
            }
            else
            {
                print("results were nil")
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch searchingForAirports
        {
        case true: return airportCodes.count
        default: return flights.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch searchingForAirports
        {
        case true:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FlightSearchResultCell", forIndexPath: indexPath)
            
            let airportCode = airportCodes[indexPath.row]
            let airportCity = airportCities[indexPath.row]
            
            cell.detailTextLabel?.text = airportCode
            cell.textLabel?.text = airportCity
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("FlightSearchResultCell", forIndexPath: indexPath)
            
            let flight = flights[indexPath.row]
            
            cell.detailTextLabel?.text = flight.duration
            cell.textLabel?.text = flight.saleTotal
            
            return cell
        }
    }

}
