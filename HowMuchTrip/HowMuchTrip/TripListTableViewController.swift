//
//  TripListTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

/// View Controller for table of user's saved trips. User must be logged in to save a trip.
class TripListTableViewController: UITableViewController, TripWasSavedDelegate
{
    var trips = [Trip]()
    let settingsVC = SettingsViewController()
    
    var pulseTimer: NSTimer?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        
        // Set up activity indicator for Pull to Refresh action
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.layer.zPosition = self.tableView.backgroundView!.layer.zPosition + 1
        
        title = "My Trips"
        
        // Set up Navigation Bar attributes
        setNavBarAttributes()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        
        // If the user is not currently logged, send user to the Settings View Controller to log in
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
            
            refreshList()
        }
        
        // refreshList here, to prevent flash of emptyState cell
        refreshList()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
    }

    /// Sets attributes for the Navigation Tab Bar
    func setNavBarAttributes()
    {
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir-Light", size: 20)!
        ]
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
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
        // Show list of trips if there are trips in the trips array
        if trips.count != 0
        {
            return trips.count
        }
        // Show one cell for the empty state image
        else
        {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        // If trips array is not empty, display Trip objects
        if trips.count != 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
            self.navigationItem.leftBarButtonItem?.enabled = true
            cell.accessoryType = .DisclosureIndicator
            let aTrip = trips[indexPath.row]
            
            // If Trip does not have a Name, set label to Destination
            if aTrip.tripName != nil
            {
                cell.tripNameLabel.text = aTrip.tripName
            }
            else
            {
                cell.tripNameLabel.text = aTrip.destination
            }
            
            cell.destinationLabel.text = aTrip.destination
            cell.budgetLabel.text = aTrip.budgetTotal.formatAsUSCurrency()

            cell.destinationImageView.image = UIImage(named: aTrip.destinationImage)
            cell.overlayView.alpha = 0.6
            
            
            // Set up bar button to allow editing of the Trip List
            navigationItem.leftBarButtonItem = editButtonItem()
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("EmptyStateCell") as! EmptyStateCell
            // Turn off ability to delete empty state image
            self.navigationItem.leftBarButtonItem?.enabled = false

            cell.createTripButton.addTarget(self, action: Selector("createSegue"), forControlEvents: .TouchUpInside)
            cell.loginButton.addTarget(self, action: Selector("presentLogin"), forControlEvents: .TouchUpInside)
            
            if PFUser.currentUser() != nil
            {
                cell.loginView.hidden = true
            }
            else
            {
                cell.loginView.hidden = false
            }
            
            navigationItem.leftBarButtonItem = nil
            pulseTimer?.invalidate()
            pulseTimer = nil
            pulseTimer = NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "pulseAddButton", userInfo: nil, repeats: true)
            pulseAddButton()
            
            cell.contentView.appearWithFade(0.5)
            
            return cell
        }
    }
    
    func presentLogin()
    {
        let loginViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
        presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func createSegue()
    {
        performSegueWithIdentifier("createSegue", sender: nil)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // If trips array is not empty, allow editing. Otherwise, do not allow editing.
        if trips.count != 0
        {
            return true
        }
        else
        {
            return false
        }
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let aTrip = trips[indexPath.row]
            
            // Remove from trips array
            trips.removeAtIndex(indexPath.row)
            
            // Remove from local datastore
            aTrip.unpinInBackground()
            
            // Remove from Parse cloud
            aTrip.deleteEventually()
            
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        // Set height for displaying the empty state image in a single cell
        if trips.count == 0
        {
            return view.frame.height - (tabBarController!.tabBar.frame.height + navigationController!.navigationBar.frame.height)
        }
        else
        {
            return 125
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // If the trips array is not empty, go to the Trip Detail of the selected trip
        if trips.count != 0
        {
            let selectedTrip = trips[indexPath.row]
            goToTripDetail(selectedTrip)
        }
        else
        // If trips array is empty, go to the Create Trip view controller
        {
//            performSegueWithIdentifier("createSegue", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TripCell
        {
            UIView.animateWithDuration(0.25) { () -> Void in
                cell.overlayView.alpha = 0.2
            }
        }
    }
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TripCell
        {
            UIView.animateWithDuration(0.25) { () -> Void in
                cell.overlayView.alpha = 0.6
            }
        }
    }
    
    // MARK: - Shift View to TripDetailVC
    
    /// Function to segue to newly instantiated view controller on different storyboard, passing selected Trip object
    func goToTripDetail(selectedTrip: Trip)
    {
        let tripDetailStoryBoard = UIStoryboard(name: "TripDetail", bundle: nil)
        
        let tripDetailVC = tripDetailStoryBoard.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
        tripDetailVC.trip = selectedTrip
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    /// Function to move the view from Create Trip to Trip Detail
    func tripWasSaved(savedTrip: Trip)
    {
        // Refresh the Parse driven trips array, then move to the detail view of the newly created Trip
        refreshList()
        navigationController?.popToRootViewControllerAnimated(true)
        goToTripDetail(savedTrip)
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
                    self.presentErrorPopup("refreshList error: \(error?.localizedDescription)")
                    spinner.stopAnimating()
                }
            }
        }
        else
        // User is nil, clear the the trips array and Trip List
        {
            clearTripsArray()
            spinner.stopAnimating()
        }
        self.tableView.reloadData()

    }
    
    // MARK: - Misc Functions
    

    /// Pull to Refresh the list and stop the activity indicator
    func handleRefresh(refreshControl: UIRefreshControl)
    {
        refreshList()
        refreshControl.endRefreshing()
    }
    
    /// Clear the trips array and the cells of old data
    func clearTripsArray()
    {
        trips.removeAll()
        
        if let oldValues = tableView.visibleCells as? [TripCell]
        {
            for cells in oldValues
            {
                cells.destinationLabel.text = nil
                cells.budgetLabel.text = nil
            }
        }
    }
    
    /// Function to add a pulsing animation to the '+' Add Trip button
    func pulseAddButton()
    {
        let addButton = navigationItem.rightBarButtonItem!
        
        let pulseColor: UIColor = {
            if addButton.tag == 1999
            {
                addButton.tag = 1998
                return UIColor(red: 0.95, green: 0.71, blue: 0.31, alpha: 1)
            }
            else
            {
                addButton.tag = 1999
                return UIColor.whiteColor()
            }
        }()
        
        UIView.animateWithDuration(1.0, delay: 0, options: [.AllowUserInteraction], animations: { () -> Void in
            self.navigationItem.rightBarButtonItem?.tintColor = pulseColor
            
            let index = NSIndexPath(forRow: 0, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(index) as? EmptyStateCell
            {
                cell.createTripButton.backgroundColor = {
                    if pulseColor == UIColor.whiteColor()
                    {
                        return cell.loginButton.backgroundColor
                    }
                    else
                    {
                        return pulseColor
                    }
                }()
            }
            
            }, completion: nil)
    }
}
