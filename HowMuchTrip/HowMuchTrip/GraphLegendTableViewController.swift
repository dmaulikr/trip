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
        
        tableView.separatorStyle = .None
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
        
        let property  = dataPoints[indexPath.row]
        let value     = values[indexPath.row]
        let color     = colors[indexPath.row]
        


        cell.propertyLabel.text = property
        cell.propertyCost.text  = formatCost(value)
        cell.propertyColorView.backgroundColor = color
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        makeAlert(indexPath.row)
    }
    
    func makeAlert(index: Int)
    {
        let property = dataPoints[index]
        
        let alert = UIAlertController(title: "Edit", message: "Editing \(property)", preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default) { (_) -> Void in
            if let newValue = alert.textFields![0].text
            {
                self.didEditValue(property, newValue: newValue)
            }
        }
        
        alert.addAction(confirmAction)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            let value = self.values[index]
            textField.placeholder = self.formatCost(value)
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func didEditValue(property: String, newValue: AnyObject)
    {
        if let createTripVC = parentViewController as? CreateTripTableViewController
        {
//            createTripVC.propertyDictionary[property] =
//            createTripVC.calculate()
        }
        else if let tripDetailVC = parentViewController as? TripDetailViewController
        {
            
        }
    }
    
    func formatCost(value: Double) -> String
    {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.stringFromNumber(value)!
    }
}
