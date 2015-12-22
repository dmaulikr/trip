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
    var flights = [FullFlight]()
    var apiController: QPX_EX_APIController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("got here")
        
        let searchParameters = FlightSearch()
        apiController = QPX_EX_APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        apiController!.search(searchParameters)
    }
    
    func didReceiveQPXResults(results: NSDictionary?)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if results != nil
            {
                if let flights = FullFlight.fullFlightsFromJSON(results!)
                {
                    self.flights = flights
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
        return flights.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("FlightSearchResultCell", forIndexPath: indexPath)
        
        let flight = flights[indexPath.row]
        
        cell.detailTextLabel?.text = flight.duration
        cell.textLabel?.text = flight.saleTotal
        
        return cell
    }

}
