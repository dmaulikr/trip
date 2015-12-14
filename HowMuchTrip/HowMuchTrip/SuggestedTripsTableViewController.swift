//
//  SuggestedTripsTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/13/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

var userLocale = "en_US"

class SuggestedTripsTableViewController: UITableViewController
{
    var trips = [Trip]()
    var userDefinedBudget = 1000.0

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Suggested"
//        
//        let fakeTrip = Trip()
//        
//        fakeTrip.budgetTotal = 1000.0
//        fakeTrip.subtotalOfProperties = 0.0
//        fakeTrip.budgetRemaining = 540.0
//        
//        fakeTrip.departureLocation = ""
//        fakeTrip.destination = "Fakesville, ND"
//        
//        fakeTrip.dateFrom = 0.0
//        fakeTrip.dateTo = 0.0
//        fakeTrip.numberOfDays = 1.0
//        fakeTrip.numberOfNights = 1.0
//        
//        fakeTrip.planeTicketCost = 250.0
//        fakeTrip.dailyLodgingCost = 100.0
//        fakeTrip.dailyFoodCost = 50.0
//        fakeTrip.dailyOtherCost = 0.0
//        fakeTrip.oneTimeCost = 60.0
//        
//        fakeTrip.totalLodgingCosts = 100.0
//        fakeTrip.totalFoodCosts = 50.0
//        fakeTrip.totalOtherDailyCosts = 0.0
//        
//        trips.append(fakeTrip)

        loadTrips()
        
    }
    
    func loadTrips()
    {
        if let path = NSBundle.mainBundle().pathForResource("suggestedTrips", ofType: "json"), let data = NSData(contentsOfFile: path) {
            do
            {
                let tripsJSON = try NSJSONSerialization
                    .JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
                print(tripsJSON)
                for tripDict in tripsJSON
                {
                    let aTrip = suggestedTripFromJSON(tripDict)
                    trips.append(aTrip)
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
        //we can put this in the trip object swift
        /*
        let budgetTotal             = suggestedTrip["budgetTotal"]          as? Double ?? 0.0
        var budgetRemaining         = budgetTotal
        
        let destination             = suggestedTrip["destination"]          as? String ?? ""
        let departureLocation       = suggestedTrip["departureLocation"]    as? String ?? "Orlando, FL"
        
        var days: Double {
            let numberOfSecondsInDay = (86400.0)
            let maxNumOfDays: UInt32 = 20
            return (Double(arc4random() % maxNumOfDays) * (numberOfSecondsInDay))
        }
        
        let dateFrom                = NSDate(timeInterval: days, sinceDate: NSDate())
        let dateTo                  = NSDate(timeInterval: days, sinceDate: dateFrom)
        print(dateTo)
        
        let numberOfDays            = days / 86400.0
        let numberOfNights          = numberOfDays
        
        var random1to10: Double {
            return Double(arc4random() % 10)
        }
    
        let planeTicketCost         = String(random1to10 * 50.0)
        
        let dailyLodgingCost        = String(random1to10 * 10.0)
        
        let dailyFoodCost           = String(random1to10 * 5.0)
        let dailyOtherCost          = String(random1to10 * 2.0)
        
        let oneTimeCost             = String(0.0)
//        let totalLodgingCosts  
        
        var allProperties = [String : String]()
        
        allProperties = [
            "Budget"                : String(budgetTotal),
            "Departure Location"    : departureLocation,
            "Destination"           : destination,
            "Date From"             : String(0.0),
            "Date To"               : String(0.0),
            "Plane Ticket Cost"     : String(planeTicketCost),
            "Daily Lodging Cost"    : String(dailyLodgingCost),
            "Daily Food Cost"       : String(dailyFoodCost),
            "Daily Other Cost"      : String(dailyOtherCost),
            "One Time Cost"         : String(oneTimeCost)
        ]
        
        let aTrip = Calculator(dictionary: allProperties)
        
        return aTrip
        */
    }
    
//    func makeTrip(fromDictionary: Dictionary) -> Trip?
//    {
//        
//    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return trips.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SuggestedTripCell", forIndexPath: indexPath) as! SuggestedTripCell

        let aTrip = trips[indexPath.row]
        
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
