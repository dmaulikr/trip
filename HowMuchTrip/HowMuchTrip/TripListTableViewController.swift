//
//  TripListTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

class TripListTableViewController: UITableViewController, TripWasSavedDelegate
{
    var trips = [Trip]()
    let settingsVC = SettingsViewController()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        title = "My Trips"

        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        
        if PFUser.currentUser() != nil
        {
            switch loggedInWith
            {
            case "Twitter":
                settingsVC.processTwitterData()
            case "Facebook":
                settingsVC.processFacebookData()
            case "Username":
                settingsVC.processUsernameData()
            default:
                PFUser.logOut()
            }
        }
        
        refreshList()
        tableView.reloadData()

    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        refreshList()
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
        
        if aTrip.tripName != nil
        {
            cell.tripNameLabel.text = aTrip.tripName
        }
        else
        {
            cell.tripNameLabel.text = aTrip.destination
        }

//        cell.departureLocationLabel.text = aTrip.departureLocation
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
            // Remove from local datastore
            aTrip.unpinInBackground()
            // Remove from Parse cloud
            aTrip.deleteEventually()
            // Delete row in table
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        }
    }
    
    func tripWasSaved(savedTrip: Trip)
    {
        goToTripDetail(savedTrip)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedTrip = trips[indexPath.row]
        goToTripDetail(selectedTrip)
    }
    
    // MARK: - Shift View to TripDetailVC
    
    /// Function to segue to newly instantiated view controller on different storyboard
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
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
        spinner.startAnimating()

        let query = Trip.query()
        if PFUser.currentUser()?.username != nil
        {
            query!.whereKey("user", equalTo: PFUser.currentUser()!.username!)
            print(PFUser.currentUser()!.username!)
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
                    spinner.stopAnimating()
                }
                else
                {
                    print("refreshList error: \(error?.localizedDescription)")
                    spinner.stopAnimating()
                }
            }
        }
        else
        {
            let oldValues = self.tableView.visibleCells as! Array<TripCell>
            
            for cells in oldValues
            {
                cells.destinationLabel.text = nil
                cells.budgetLabel.text = nil
                print("clear cell")
                
            }
            spinner.stopAnimating()
        }
        
        if trips.count == 0
        {
            tableView.backgroundView = UIImageView(image: UIImage(named: "emptyState2"))
        }
        else
        {
            tableView.backgroundView = UIImageView(image: UIImage(named: "blank-background"))
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        refreshList()
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
}
