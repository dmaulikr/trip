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

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Suggested"
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        loadTrips()
        trips.shuffleInPlace()
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if PFUser.currentUser()?.username == nil
        {
            let loginViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
    }
    
    func tripWasSaved(savedTrip: Trip)
    {
        print("trip was saved")
        navigationController?.popToRootViewControllerAnimated(false)
        tableView.reloadData()
        
        let selectedTrip = savedTrip
        
        let tripDetailStoryBoard = UIStoryboard(name: "TripDetail", bundle: nil)
        
        let tripDetailVC = tripDetailStoryBoard.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
        tripDetailVC.aTrip = selectedTrip
        navigationController?.pushViewController(tripDetailVC, animated: false)
    }
    
    func loadTrips()
    {
        if let path = NSBundle.mainBundle().pathForResource("suggestedTrips", ofType: "json"), let data = NSData(contentsOfFile: path)
        {
            do
            {
                let tripsJSON = try NSJSONSerialization
                    .JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
//                print(tripsJSON)
                for tripDict in tripsJSON
                {
                    let aTrip = suggestedTripFromJSON(tripDict)
                    trips.append(aTrip)
//                    trips.shuffleInPlace()
                }
            }
            catch
            {
                print(error)
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
        
        var trip: Trip {
    
        let trip = Trip()
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
        return trip
            
        }

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
        cell.budgetLabel.text = formatCost(aTrip.budgetTotal)

        return cell
    }
    
    func formatCost(numberToFormat: Double) -> String
    {
        // Format budgetTotal into US currency style
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: userLocale)
        if let budgetTotalString = formatter.stringFromNumber(numberToFormat)
        {
            return budgetTotalString
        }
        else
        {
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        goToTripDetail(indexPath.row)
    }

    func goToTripDetail(indexPath: Int)
    {
        let selectedTrip = trips[indexPath]
        
        let tripDetailStoryBoard = UIStoryboard(name: "TripDetail", bundle: nil)
        
        let tripDetailVC = tripDetailStoryBoard.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
        tripDetailVC.aTrip = selectedTrip
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
