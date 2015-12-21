//
//  TripListTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

class TripListTableViewController: UITableViewController, TripWasSavedDelegate, TripDidBeginEditingDelegate
{
    var trips = [Trip]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
//        title = "My Trips"

         self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        refreshList()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Description
     
     - Parameters:
     - one: some stuff about one
     
     - Parameter two: some stuff about two
     
     - Throws:
     
     - Returns:
     
     */
    func tripDetailDidBeginEditing()
    {
        navigationController?.popToRootViewControllerAnimated(true)
        performSegueWithIdentifier("createSegue", sender: "tripDetailDidBeginEditing")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let createTripVC = segue.destinationViewController as? CreateTripTableViewController, let trip = (sender as? Trip)
        {
            createTripVC.trip = trip
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return trips.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell

        let aTrip = trips[indexPath.row]
        
        cell.destinationLabel.text = aTrip.destination
        cell.budgetLabel.text = aTrip.budgetTotal.formatAsUSCurrency()

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let aTrip = trips[indexPath.row]
            trips.removeAtIndex(indexPath.row)
            // TODO: test unpin
            aTrip.unpinInBackground()
            aTrip.deleteEventually()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        }
    }
    
    /**
     Description
     
     - Parameters:
     - one: some stuff about one
     
     - Parameter two: some stuff about two
     
     - Throws:
     
     - Returns:
     
     */
    func tripWasSaved(savedTrip: Trip)
    {
        goToTripDetail(savedTrip)
    }
    
    /**
     Description
     
     - Parameters:
     - one: some stuff about one
     
     - Parameter two: some stuff about two
     
     - Throws:
     
     - Returns:
     
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedTrip = trips[indexPath.row]
        goToTripDetail(selectedTrip)
    }
    
    // MARK: - Shift View to TripDetailVC
    /**
    Description
    
    - Parameters: 
        - one: some stuff about one
    
    - Parameter two: some stuff about two
    
    - Throws:
    
    - Returns:
    
    */
    func goToTripDetail(selectedTrip: Trip)
    {
        let tripDetailStoryBoard = UIStoryboard(name: "TripDetail", bundle: nil)
        
        let tripDetailVC = tripDetailStoryBoard.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
        tripDetailVC.aTrip = selectedTrip
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }

    
    // MARK: - Parse Queries
    /// Function queries Parse local datastore, then Parse cloud storage for items that have been pinned and saved, respectively.
    func refreshList()
    {
        let query = Trip.query()
        // Sort results A-Z
        query!.orderByAscending("destination")
        // After sorting A-Z, then sort 1-999999
        query!.addAscendingOrder("budgetTotal")
        // First look in local datastore
        query!.fromLocalDatastore()
        // Second look for objects in Parse cloud
        query!.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil
            {
                // Save all the objects found in the trips array, then reload view
                self.trips = (objects as? [Trip])!
                self.tableView.reloadData()
            }
            else
            {
                print("refreshList error: \(error?.localizedDescription)")
            }
        }
    }
}
