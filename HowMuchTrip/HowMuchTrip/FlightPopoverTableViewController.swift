//
//  FlightPopoverTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/21/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class FlightPopoverTableViewController: UITableViewController, QPX_EX_APIControllerDelegate, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    
    var trip: Trip! {
        didSet {
            loadAirports(trip.departureLocation)
        }
    }
    
    var flights = [FullFlight]()
    var airportCodes = [String]()
    var airportCities = [String]()
    var allAirports: NSArray!
    
    var airports: NSDictionary! {
        return [airportCities : airportCodes]
    }
    
    var flightSearchParameters: FlightSearch!
    
    var apiController: QPX_EX_APIController? {
        didSet {
//            apiController!.search(searchParameters)
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
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
        
        allAirports = loadJSON()
        
        searchingForAirports = true
        searchBar.delegate = self
//        searchParameters = FlightSearch()
        apiController = QPX_EX_APIController(delegate: self)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if searchBar.text != ""
        {
            loadAirports(searchBar.text!)
        }
    }
    
    func loadAirports(searchParameters: String)
    {
        airportCities.removeAll()
        airportCodes.removeAll()
        
        for airport in allAirports
        {
            let airportCity = airport["CITY_NAME"] as? String ?? ""
            let airportCode = airport["VENDOR_CODE"] as? String ?? ""
                    
            if searchParameters.containsString(airportCity) && airportCity != "" && airportCode != ""
            {
                print("contains")
                self.airportCities.append(airportCity)
                self.airportCodes.append(airportCode)
            }

            tableView.reloadData()
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
    
    // MARK: - Table View Functions
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
    
    // MARK: - Private Functions
    
    private func loadJSON() -> NSArray?
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

}
