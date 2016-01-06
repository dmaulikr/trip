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

class GraphLegendTableViewController:
    UITableViewController,
    UITextFieldDelegate,
    TripValueWasEditedDelegate
{
    var dataPoints = [String]()
    var values     = [Double]()
    var colors     = [UIColor]()
    
    var trip: Trip!
    var delegate: TripDidBeginEditingDelegate!
    var childViewController: UIViewController!
    
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
        
        var shownProperty: String!
        
        switch property
        {
        case "Budget Remaining"         :
            shownProperty    = "Budget Left"
        case "Transit"                  :
            shownProperty    = "Transit"
        case "Total Lodging"            :
            shownProperty    = "Lodging"
        case "Total Daily Food Cost"    :
            shownProperty    = "Food"
        case "Total Daily Other Cost"   :
            shownProperty    = "Daily Misc"
        case "Total One Time Costs"     :
            shownProperty    = "One-Time"
        default: print(property)
        }
        
        cell.propertyLabel.text = shownProperty
        cell.propertyCost.text  = value.formatCostAsUSD()
        cell.propertyColorView.backgroundColor = color
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        makeEditView(indexPath.row)
    }
    
    func makeEditView(index: Int)
    {
        var property = dataPoints[index]
        
        var value: Double!
        
        switch property
        {
        case "Budget Remaining"         :
            property    = "Budget" //this one's right, don't change it pls
            value       = trip.budgetTotal
        case "Transit"                  :
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
        
        print(property, value)
        
        let contextPopStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
        let contextPopover = contextPopStoryboard.instantiateViewControllerWithIdentifier("editValueView") as! EditValueViewController
        
        contextPopover.delegate = self
        contextPopover.property = property
        contextPopover.value = value
        
        parentViewController!.addContextPopover(contextPopover)
        
        contextPopover.view.frame = CGRect(
            x: 0, y: 0,
            width: contextPopover.view.frame.width,
            height: contextPopover.view.frame.height / 2
        )

        contextPopover.view.center = CGPoint(x: parentViewController!.view.center.x, y: parentViewController!.view.center.y - 160)
        
        if let parentVC = parentViewController as? TripDetailViewController
        {
            parentVC.contextPopover = contextPopover
            parentVC.contextPopover!.view.appearWithFade(0.25)
            parentVC.contextPopover!.view.slideVerticallyToOrigin(0.25, fromPointY: parentVC.view.frame.size.height / 2)
        }
        else if let parentVC = parentViewController as? CreateTripTableViewController
        {
            parentVC.contextPopover = contextPopover
            parentVC.contextPopover!.view.appearWithFade(0.25)
            parentVC.contextPopover!.view.slideVerticallyToOrigin(0.25, fromPointY: parentVC.view.frame.height / 2)
        }
        
        childViewController = contextPopover
    }
    
    func valueWasEdited(property: String, value: String?)
    {
        parentViewController!.dismissContextPopover(EditValueViewController)
        
        if value != nil
        {
            if let createTripVC = parentViewController as? CreateTripTableViewController
            {
                createTripVC.calculate(false, property: property, value: value!)
            }
            else if let tripDetailVC = parentViewController as? TripDetailViewController
            {
                let calculator = Calculator(delegate: nil)
                trip = calculator.assignValue(trip, propertyAndValue: [property : value!])
                tripDetailVC.buildGraphAndLegend(trip, superview: tripDetailVC)
            }
        }
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
