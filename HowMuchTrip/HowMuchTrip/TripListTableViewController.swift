//
//  TripListTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

class TripListTableViewController: UITableViewController
{
    var trips = [Trip]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "My Trips"
        
        refreshList()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
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

        // Format budgetTotal into US currency style
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let budgetTotalString = formatter.stringFromNumber(aTrip.budgetTotal)
        
        cell.destinationLabel.text = aTrip.destination
        cell.budgetLabel.text = budgetTotalString


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
            aTrip.deleteInBackground()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedTrip = trips[indexPath.row]
        let tripDetailVC = storyboard?.instantiateViewControllerWithIdentifier("TripDetail") as! TripDetailViewController
        tripDetailVC.aTrip = selectedTrip
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    // MARK: - Parse Queries
    
    func refreshList()
    {
        
//        if PFUser.currentUser() != nil
//        {
        
            let query = Trip.query()
            query!.orderByAscending("destination")
            query!.addAscendingOrder("budgetTotal")
            query!.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil
                    {
                        self.trips = (objects as? [Trip])!
                        self.tableView.reloadData()
                    }
                    else
                    {
                        print(error?.localizedDescription)
                    }
            }
//        }
        
    }

}
