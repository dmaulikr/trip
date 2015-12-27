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

class SuggestedTripsTableViewController: UITableViewController, TripWasSavedDelegate
{
    var trips = [Trip]()
    var userDefinedBudget = 1000.0
    let settingsVC = SettingsViewController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)

        title = "Suggested"
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        loadTrips()
        trips.shuffleInPlace()
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
    
    func tripWasSaved(savedTrip: Trip)
    {
        navigationController?.popToRootViewControllerAnimated(true)
        goToTripDetail(savedTrip)
    }
    
    // MARK: - Load Suggested Trips JSON
    
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
                    let aTrip = suggestedTripFromJSON(tripDict)
                    trips.append(aTrip)
                }
            }
            catch
            {
                print("loadTrips error: \(error)")
            }
        }

    }
    
    func suggestedTripFromJSON(suggestedTrip: NSDictionary) -> Trip
    {
        let budgetTotal             = suggestedTrip["budgetTotal"]          as? Double ?? 0.0
        let subtotalOfProperties    = suggestedTrip["subtotalOfProperties"] as? Double ?? 0.0
        let budgetRemaining         = suggestedTrip["budgetRemaining"]      as? Double ?? 0.0
        let departureLocation       = suggestedTrip["departureLocation"]    as? String ?? ""
        let destination             = suggestedTrip["destination"]          as? String ?? ""
        let tripName                = suggestedTrip["tripName"]             as? String ?? ""
        let numberOfDays            = suggestedTrip["numberOfDays"]         as? Double ?? 0.0
        let numberOfNights          = suggestedTrip["numberOfNights"]       as? Double ?? 0.0
        let planeTicketCost         = suggestedTrip["planeTicketCost"]      as? Double ?? 0.0
        let dailyLodgingCost        = suggestedTrip["dailyLodgingCost"]     as? Double ?? 0.0
        let dailyFoodCost           = suggestedTrip["dailyFoodCost"]        as? Double ?? 0.0
        let dailyOtherCost          = suggestedTrip["dailyOtherCost"]       as? Double ?? 0.0
        let oneTimeCost             = suggestedTrip["oneTimeCost"]          as? Double ?? 0.0
        let totalLodgingCosts       = suggestedTrip["totalLodgingCosts"]    as? Double ?? 0.0
        let totalFoodCosts          = suggestedTrip["totalFoodCosts"]       as? Double ?? 0.0
        let totalOtherDailyCosts    = suggestedTrip["totalOtherDailyCosts"] as? Double ?? 0.0
        
        let trip: Trip = {
    
            var trip = Trip()
            trip.budgetTotal            = budgetTotal
            trip.subtotalOfProperties   = subtotalOfProperties
            trip.budgetRemaining        = budgetRemaining
            trip.departureLocation      = departureLocation
            trip.destination            = destination
            trip.tripName               = tripName
            trip.numberOfDays           = numberOfDays
            trip.numberOfNights         = numberOfNights
            trip.planeTicketCost        = planeTicketCost
            trip.dailyLodgingCost       = dailyLodgingCost
            trip.dailyFoodCost          = dailyFoodCost
            trip.dailyOtherCost         = dailyOtherCost
            trip.oneTimeCost            = oneTimeCost
            trip.totalLodgingCosts      = totalLodgingCosts
            trip.totalFoodCosts         = totalFoodCosts
            trip.totalOtherDailyCosts   = totalOtherDailyCosts
            
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
        
        cell.tripNameLabel.text = aTrip.tripName
        cell.departureLocationLabel.text = aTrip.departureLocation
        cell.destinationLabel.text = aTrip.destination
        cell.budgetLabel.text = aTrip.budgetTotal.formatAsUSCurrency()

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedTrip = trips[indexPath.row]
        goToTripDetail(selectedTrip)
    }
    
    // MARK: - Shift View to TripDetailVC

    func goToTripDetail(selectedTrip: Trip)
    {
        let tripDetailStoryBoard = UIStoryboard(name: "TripDetail", bundle: nil)
        
        let tripDetailVC = tripDetailStoryBoard.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
        tripDetailVC.aTrip = selectedTrip
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        trips.shuffleInPlace()
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

}
