//
//  SuggestedTripsTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/13/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

var userLocale = "en_US"

/// Table view controller showing a list of static, Suggested Trips. Trip data sourced from a JSON file.
class SuggestedTripsTableViewController: UITableViewController, TripWasSavedDelegate
{
    var trips = [Trip]()
    let settingsVC = SettingsViewController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        
        // Set up activity indicator for Pull to Refresh function
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.layer.zPosition = self.tableView.backgroundView!.layer.zPosition + 1

        title = "Suggested Trips"
        
        // Load trips from JSON and display in table view
        loadTrips()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        
        // Switch user to Settings view controller if they are not currently logged in.
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
    }
        
    // MARK: - TripSaved Delegate
    
    /// When a Trip is saved, move to the Trip Detail view controller
    func tripWasSaved(savedTrip: Trip)
    {
        navigationController?.popToRootViewControllerAnimated(true)
        goToTripDetail(savedTrip)
    }
    
    // MARK: - Load Suggested Trips JSON
    
    /// Load SuggestedTrips from JSON
    func loadTrips()
    {
        if let path = NSBundle.mainBundle().pathForResource("suggestedTrips", ofType: "json"), let data = NSData(contentsOfFile: path)
        {
            do
            {
                let tripsJSON = try NSJSONSerialization
                    .JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
                for tripDict in tripsJSON
                {
                    // Send JSON results to the suggestedTripFromJSON function to assign the results to a Trip object
                    let aTrip = suggestedTripFromJSON(tripDict)
                    trips.append(aTrip)
                }
            }
            catch
            {
                self.presentErrorPopup("loadTrips error: \(error)")
            }
        }

    }
    
    /// Recieves JSON data from loadTrips function, then creates a Trip object with that data
    /// - Returns: a Trip object populated from JSON data, for trips array
    func suggestedTripFromJSON(suggestedTrip: NSDictionary) -> Trip
    {
        let trip: Trip = {
    
            var trip = Trip()
            trip.budgetTotal            = suggestedTrip["budgetTotal"]          as? Double ?? 0.0
            trip.subtotalOfProperties   = suggestedTrip["subtotalOfProperties"] as? Double ?? 0.0
            trip.budgetRemaining        = suggestedTrip["budgetRemaining"]      as? Double ?? 0.0
            trip.departureLocation      = suggestedTrip["departureLocation"]    as? String ?? ""
            trip.destination            = suggestedTrip["destination"]          as? String ?? ""
            trip.tripName               = suggestedTrip["tripName"]             as? String ?? ""
            trip.numberOfDays           = suggestedTrip["numberOfDays"]         as? Double ?? 0.0
            trip.numberOfNights         = suggestedTrip["numberOfNights"]       as? Double ?? 0.0
            trip.planeTicketCost        = suggestedTrip["planeTicketCost"]      as? Double ?? 0.0
            trip.dailyLodgingCost       = suggestedTrip["dailyLodgingCost"]     as? Double ?? 0.0
            trip.dailyFoodCost          = suggestedTrip["dailyFoodCost"]        as? Double ?? 0.0
            trip.dailyOtherCost         = suggestedTrip["dailyOtherCost"]       as? Double ?? 0.0
            trip.oneTimeCost            = suggestedTrip["oneTimeCost"]          as? Double ?? 0.0
            trip.totalLodgingCosts      = suggestedTrip["totalLodgingCosts"]    as? Double ?? 0.0
            trip.totalFoodCosts         = suggestedTrip["totalFoodCosts"]       as? Double ?? 0.0
            trip.totalOtherDailyCosts   = suggestedTrip["totalOtherDailyCosts"] as? Double ?? 0.0
            trip.departureLat           = suggestedTrip["departureLat"]         as? String ?? ""
            trip.departureLng           = suggestedTrip["departureLng"]         as? String ?? ""
            trip.destinationLat         = suggestedTrip["destinationLat"]       as? String ?? ""
            trip.destinationLng         = suggestedTrip["destinationLng"]       as? String ?? ""
            trip.destinationImage       = suggestedTrip["destinationImage"]     as? String ?? ""
            
            trip.dateFrom               = suggestedTrip["dateFrom"]             as? String ?? ""
            trip.dateTo                 = suggestedTrip["dateTo"]               as? String ?? ""
            
            // Send trip properties to the Calculator to get the trip totals
            let calculator = Calculator(delegate: nil)
            (trip, _) = calculator.getTotals(trip)
                
            return trip
            
        }()

        return trip
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return trips.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SuggestedTripCell", forIndexPath: indexPath) as! SuggestedTripCell

        let aTrip = trips[indexPath.row]
        
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
        cell.destinationImageView.image = UIImage(named: "\(aTrip.destinationImage)")

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedTrip = trips[indexPath.row]
        goToTripDetail(selectedTrip)
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
    
    // MARK: - Private Functions
    
    /// Function to handle Pull to Refresh action. Shuffles the order of the trips array when called.
    func handleRefresh(refreshControl: UIRefreshControl)
    {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        trips = trips.shuffle()
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

}
