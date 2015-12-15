//
//  GraphLegendTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/15/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class GraphLegendTableViewController: UITableViewController
{
    var dataPoints = [String]()
    var values     = [Double]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return dataPoints.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("GraphLegendCell") as! GraphLegendCell
        
        let dataPoint = dataPoints[indexPath.row]
        let value     = values[indexPath.row]
        
        cell.propertyLabel.text = dataPoint
        cell.propertyCost.text = String(value)
        
        return cell
    }
}
