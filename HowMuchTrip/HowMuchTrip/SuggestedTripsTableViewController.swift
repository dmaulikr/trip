//
//  SuggestedTripsTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/13/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class SuggestedTripsTableViewController: UITableViewController
{
    var trips = [Trip]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Suggested"
        
        let fakeTrip = Trip()
        
        fakeTrip.budgetTotal = 1000.0
        fakeTrip.subtotalOfProperties = 0.0
        fakeTrip.budgetRemaining = 540.0
        
        fakeTrip.departureLocation = ""
        fakeTrip.destination = "Fakesville, ND"
        
        fakeTrip.dateFrom = 0.0
        fakeTrip.dateTo = 0.0
        fakeTrip.numberOfDays = 1.0
        fakeTrip.numberOfNights = 1.0
        
        fakeTrip.planeTicketCost = 250.0
        fakeTrip.dailyLodgingCost = 100.0
        fakeTrip.dailyFoodCost = 50.0
        fakeTrip.dailyOtherCost = 0.0
        fakeTrip.oneTimeCost = 60.0
        
        fakeTrip.totalLodgingCosts = 100.0
        fakeTrip.totalFoodCosts = 50.0
        fakeTrip.totalOtherDailyCosts = 0.0
        
        trips.append(fakeTrip)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SuggestedTripCell", forIndexPath: indexPath) as! SuggestedTripCell

        let aTrip = trips[indexPath.row]
        
        // Format budgetTotal into US currency style
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let budgetTotalString = formatter.stringFromNumber(aTrip.budgetTotal)
        
        cell.destinationLabel.text = aTrip.destination
        cell.budgetLabel.text = budgetTotalString

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedTrip = trips[indexPath.row]
        let tripDetailVC = storyboard?.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
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
