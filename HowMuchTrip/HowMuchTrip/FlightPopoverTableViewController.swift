//
//  FlightPopoverTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/21/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

protocol FlightTicketPriceWasChosenProtocol
{
    func flightTicketPriceWasChosen(price: String)
}

class FlightPopoverTableViewController: UITableViewController, QPX_EX_APIControllerDelegate, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: FlightTicketPriceWasChosenProtocol?
    
    var trip: Trip! {
        didSet {
            searchBar.delegate = self
            searchBar.text = trip.departureLocation
            searchBarSearchButtonClicked(searchBar)
            print(searchBar.text!)
//            loadAirports(trip.departureLocation)
        }
    }
    
    let isOldDevice: Bool = {
        if UIScreen.mainScreen().bounds.size.height <= 568
        {
            return true
        }
        return false
    }()
    
    var flights = [FullFlight]()
    var airportCodes = [String]()
    var airportLocation = [String]()
    var allAirports: NSArray!
    
    var originAirportCode: String!
    var destinationAirportCode: String!
    
    var flightSearchParameters: FlightSearch!
    
    var apiController: QPX_EX_APIController? {
        didSet {
            UIApplication.sharedApplication().networkActivityIndicatorVisible =
            !UIApplication.sharedApplication().networkActivityIndicatorVisible
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
        
        tableView.separatorColor = UIColor.whiteColor()
        
        searchingForAirports = true
        searchBar.delegate = self
        let searchBarTextField = searchBar.valueForKey("searchField") as! UITextField
        searchBarTextField.textColor = UIColor(red:0.003, green:0.41, blue:0.544, alpha:1)
        searchBar.placeholder = "Origin Airport City"
        
//        searchParameters = FlightSearch()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        searchBar.text = trip.departureLocation
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        if searchBar.text != ""
        {
            loadAirports(searchBar.text!)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if !isOldDevice && searchBar.text != ""
        {
            loadAirports(searchBar.text!)
        }
    }
    
    func loadAirports(searchParameters: String)
    {
        airportLocation.removeAll()
        airportCodes.removeAll()
        
        for airport in allAirports
        {
            let cityName = airport["CITY_NAME"] as? String ?? ""
            let stateCode = airport["STATE_CODE"] as? String ?? ""
            let countryCode = airport["COUNTRY_CODE"] as? String ?? ""
            
            let airportLocation: String! = {
                if stateCode != ""
                {
                    return "\(cityName), \(stateCode), \(countryCode)"
                }
                else
                {
                    return "\(cityName), \(countryCode)"
                }
            }()
            
            let airportCode = airport["VENDOR_CODE"] as? String ?? ""

            if searchParameters.lowercaseString.rangeOfString(cityName.lowercaseString) != nil
            && airportCode != ""
            {
                print("contains")
                self.airportLocation.append(airportLocation)
                self.airportCodes.append(airportCode)
            }

            tableView.reloadData()
        }
    }
    
    func didReceiveQPXResults(results: NSDictionary?)
    {        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if results != nil
            {
                let parentVC = self.parentViewController as! FlightPopoverViewController
                parentVC.activityView.hidden = true
                
                if let flights = FullFlight.fullFlightsFromJSON(results!)
                {
                    for flight in flights
                    {
                        self.flights.append(flight)
                    }
                    
                    if flights.count == 0
                    {
                        self.presentErrorPopup("Couldn't find any results matching your search. Sorry about that!")
                        self.delegate?.flightTicketPriceWasChosen("")
                    }
                }
                else
                {
                    print("no dice")
                    self.presentErrorPopup("Looks like there was an issue pulling your flight results from the QPX Express flight search service. Please try again later. Sorry about that!")
                    self.delegate?.flightTicketPriceWasChosen("")
                }
            }
            else
            {
                print("results were nil")
                self.presentErrorPopup("Looks like there was an issue contacting the QPX Express flight search service. Please try again later. Sorry about that!")
                self.delegate?.flightTicketPriceWasChosen("")
            }
            
            self.apiController = nil
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
            let airportCity = airportLocation[indexPath.row]
            
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        searchBar.resignFirstResponder()
        
        if searchingForAirports == true
        {
            let selectedAirportCode = airportCodes[indexPath.row]
            if originAirportCode == nil || originAirportCode == ""
            {
                animateSelection()
                originAirportCode = selectedAirportCode
                searchBar.text = trip.destination
                searchBarSearchButtonClicked(searchBar)
                
                searchBar.placeholder = "Destination Airport City"
                
            }
            else if destinationAirportCode == nil || destinationAirportCode == ""
            {
                animateSelection()
                
                let parentVC = self.parentViewController as! FlightPopoverViewController
                parentVC.activityView.hidden = false
                
                destinationAirportCode = selectedAirportCode
                searchingForAirports = false
                
                let flightSearch = FlightSearch(origin: originAirportCode, destination: destinationAirportCode, dateFrom: trip.dateFrom, dateTo: trip.dateTo)
                
                apiController = QPX_EX_APIController(delegate: self)
                apiController?.search(flightSearch)
                
                searchBar.placeholder = "Searching for flights"
                searchBar.text = ""
                
                tableView.reloadData()
            }
            else
            {
                print("problem assigning airport codes to variables")
            }
        }
        else
        {
            animateSelection()
            let selectedFlight = flights[indexPath.row]
            let formattedPrice = selectedFlight.saleTotal
                .stringByReplacingOccurrencesOfString("$", withString: "")
                .stringByReplacingOccurrencesOfString(" ", withString: "")
            delegate?.flightTicketPriceWasChosen(formattedPrice)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func animateSelection()
    {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tableView.hideWithFade(0.25)
            }) { (_) -> Void in
                self.tableView.appearWithFade(0.25)
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