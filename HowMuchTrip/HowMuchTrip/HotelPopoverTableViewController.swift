//
//  HotelPopoverTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/22/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class HotelPopoverTableViewController: UITableViewController, AverageCostsAPIResultsProtocol
{
    var apiController: AverageCostsAPIController?
    
    var trip: Trip! {
        didSet {
            startSearch()
            print("didSet")
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    func startSearch()
    {
        apiController = AverageCostsAPIController(averageCostsDelegate: self)
                
        let lat = Double(trip.destinationLat) ; let lng = Double(trip.destinationLng)

        apiController?.searchAverageCostsFor(lat!, lng: lng!)
    }
    
    func didReceiveAverageCostsAPIResults(results: NSDictionary)
    {
        print(results)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */
}
