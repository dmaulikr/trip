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
    
    var pulseTimer: NSTimer?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.layer.zPosition = self.tableView.backgroundView!.layer.zPosition + 1
        title = "My Trips"
        
        setNavBarAttributes()

        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    func setNavBarAttributes()
    {
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir-Light", size: 20)!
        ]
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
        
        view.appearWithFade(0.25)
        view.slideVerticallyToOrigin(0.25, fromPointY: 200)
        
        refreshList()
        tableView.reloadData()

    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        refreshList()
        tableView.reloadData()
        
        if pulseTimer != nil
        {
            pulseTimer = nil
        }
        else if trips.count == 0 && pulseTimer == nil
        {
            pulseTimer = NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "pulseAddButton", userInfo: nil, repeats: true)
            pulseAddButton()
        }
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
        if trips.count != 0
        {
            return trips.count
        }
        else
        {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell

        if trips.count != 0
        {
            let aTrip = trips[indexPath.row]
            
            if aTrip.tripName != nil
            {
                cell.tripNameLabel.text = aTrip.tripName
            }
            else
            {
                cell.tripNameLabel.text = aTrip.destination
            }
            
//            cell.overlayView.alpha = 0.6

    //        cell.departureLocationLabel.text = aTrip.departureLocation
            cell.destinationLabel.text = aTrip.destination
            cell.budgetLabel.text = aTrip.budgetTotal.formatAsUSCurrency()
            
            
            cell.destinationImageView.image = UIImage(named: "denver") //<<<<<<<<<

            cell.overlayView.alpha = 0.6
            
            return cell
        }
        else
        {
            self.navigationItem.leftBarButtonItem?.enabled = false

            cell.destinationImageView.image = UIImage(named: "notrips")
            cell.accessoryType = .None
            cell.overlayView.alpha = 0
            return cell
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if trips.count == 0
        {
            return view.frame.height
        }
        else
        {
            return 125
        }
    }
    
    func tripWasSaved(savedTrip: Trip)
    {
        refreshList()
        navigationController?.popToRootViewControllerAnimated(true)
        goToTripDetail(savedTrip)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if trips.count != 0
        {
            let selectedTrip = trips[indexPath.row]
            goToTripDetail(selectedTrip)
        }
        else
        {
            performSegueWithIdentifier("createSegue", sender: self)
        }
    }
    
    // MARK: - Shift View to TripDetailVC
    
    /// Function to segue to newly instantiated view controller on different storyboard
    func goToTripDetail(selectedTrip: Trip)
    {
        let tripDetailStoryBoard = UIStoryboard(name: "TripDetail", bundle: nil)
        
        let tripDetailVC = tripDetailStoryBoard.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
        tripDetailVC.trip = selectedTrip
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
            let oldValues = tableView.visibleCells as! [TripCell]
            
            for cells in oldValues
            {
                cells.destinationLabel.text = nil
                cells.budgetLabel.text = nil
                print("clear cell")
                
            }
            spinner.stopAnimating()
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl)
    {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        refreshList()
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
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
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.navigationItem.rightBarButtonItem?.tintColor = pulseColor
            }, completion: nil)
    }
}
