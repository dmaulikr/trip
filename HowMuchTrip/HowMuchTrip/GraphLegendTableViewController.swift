//
//  GraphLegendTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/15/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

protocol TripDidBeginEditingDelegate
{
    func tripDetailDidBeginEditing()
}

class GraphLegendTableViewController: UITableViewController, UITextFieldDelegate
{
    var dataPoints = [String]()
    var values     = [Double]()
    var colors     = [UIColor]()
    
    var trip: Trip!
    var delegate: TripDidBeginEditingDelegate!
    
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
        
//        switch parentViewController
//        {
//        case is CreateTripTableViewController: makeAlert(indexPath.row)
//        default: delegate?.tripDidBeginEditing()
//        }
        
//        makeAlert(indexPath.row)
    }
    
    func makeAlert(index: Int)
    {
        var property = dataPoints[index]
        
        var value: Double!
        
        switch property
        {
        case "Budget Remaining"         :
            property    = "Budget"
            value       = trip.budgetTotal
        case "Plane Ticket"             :
            property    = "Plane Ticket Cost"
            value       = trip.planeTicketCost
        case "Total Lodging"            :
            property    = "Daily Lodging Cost"
            value       = trip.dailyLodgingCost
        case "Total Daily Food Cost"    :
            property    = "Daily Food Cost"
            value       = trip.dailyFoodCost
        case "Total Daily Other Cost"   :
            property    = "Daily Other Cost"
            value       = trip.dailyOtherCost
        case "Total One Time Costs"     :
            property    = "Daily Other Cost"
            value       = trip.dailyOtherCost
        default: print(property)
        }
        
        let alert = UIAlertController(title: "Edit", message: "Editing \(property)", preferredStyle: .Alert)
        
        let confirmations = [
            "Okay",
            "All set",
            "Looks good"
        ]
        
        let confirmation = confirmations[Int(arc4random() % UInt32(confirmations.count))]
        
        let confirmAction = UIAlertAction(title: confirmation, style: .Default) { (_) -> Void in
            if let textField = alert.textFields?.first
            {
                textField.delegate = self
                self.didEditValue(property, newValue: textField.text!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        let cancellations = [
            "Never mind",
            "Just kidding",
            "Forget it"
        ]
        
        let cancellation = cancellations[Int(arc4random() % UInt32(cancellations.count))]
        
        let cancelAction = UIAlertAction(title: cancellation, style: .Cancel) { (_) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
            textField.placeholder = self.formatCost(value)
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func didEditValue(property: String, newValue: String)
    {
        if let createTripVC = parentViewController as? CreateTripTableViewController
        {
//            createTripVC.propertyDictionary[property] = newValue
//            createTripVC.calculate(false)
            
            let calculator = Calculator(delegate: nil)
            trip = calculator.assignValue(trip, propertyAndValue: [property : newValue])
            
            createTripVC.dataSource.buildGraphAndLegend(trip, superview: createTripVC)
            
            
            // TODO: - change calculator "xxx Cost" into just "xxx"
        }
        else if let tripDetailVC = parentViewController as? TripDetailViewController
        {
//            var propertyDictionary = trip.propertyDictionary
//            print(propertyDictionary)
//            propertyDictionary[property] = newValue

            let calculator = Calculator(delegate: nil)
            trip = calculator.assignValue(trip, propertyAndValue: [property : newValue])
            tripDetailVC.buildGraphAndLegend(trip, superview: tripDetailVC)
            
            
            
            
            
            
            
            
            //calculate here as well
//            tripDetailVC.propertyDictionary[property] = newValue
//            tripDetailVC.calculate(false)

//            delegate.tripDetailDidBeginEditing()
//            navigationController?.popToRootViewControllerAnimated(true)
            
//            tripDetailVC.calculate(false)
            
            print(tripDetailVC)
        }
    }
    
    func formatCost(value: Double) -> String
    {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.stringFromNumber(value)!
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return textField.testCharacters("numbers")
    }
}

extension UITextField
{
    func testCharacters(control: String) -> Bool
    {
        var invalidCharacters: NSCharacterSet!
        
        if self.text != ""
        {
            if control == "string"
            {
                invalidCharacters = NSCharacterSet(charactersInString: "0123456789")
                if let _ = self.text!
                    .rangeOfCharacterFromSet(invalidCharacters, options: [],
                        range:Range<String.Index>(start: self.text!.startIndex, end: self.text!.endIndex))
                {
                    return false
                }
            }
            else if control == "numbers"
            {
                invalidCharacters = NSCharacterSet(charactersInString: "0123456789.").invertedSet //only includes 0-9
                
                if let _ = self.text!
                    .rangeOfCharacterFromSet(invalidCharacters, options: [],
                        range:Range<String.Index>(start: self.text!.startIndex, end: self.text!.endIndex))
                {
                    return false
                }
            }
        }
        

        
        return true
    }
}
