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
    var colors     = [UIColor]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clearColor()
        view.backgroundColor = UIColor.clearColor()
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
        let color     = colors[indexPath.row]
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let propertyCostString = formatter.stringFromNumber(value)

        cell.propertyLabel.text = dataPoint
        cell.propertyCost.text = propertyCostString
        cell.propertyColorView.backgroundColor = color
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        return cell
    }
}
