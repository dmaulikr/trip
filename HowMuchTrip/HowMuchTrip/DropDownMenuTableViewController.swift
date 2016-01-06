//
//  LocationSearchTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 1/4/16.
//  Copyright © 2016 HowMuchTrip. All rights reserved.
//

import UIKit

protocol DropDownMenuOptionWasChosenProtocol
{
    func animateTextFieldBGSizeToDefault(textField: UITextField?)
}

class LocationSearchTableViewController: UITableViewController, GooglePlacesAPIProtocol
{
    var results = [String]()
    var textField: UITextField!
    var apiController: GooglePlacesAPIController?
    var delegate: DropDownMenuOptionWasChosenProtocol?
    var parent: CreateTripTableViewController!
    var searchingForCost: Bool?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.separatorStyle = .None
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return results.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationSearchResultCell", forIndexPath: indexPath)

        if results.count != 0
        {
            let result = results[indexPath.row]
            
            cell.textLabel?.text = {
                if searchingForCost == true
                {
                    return "$" + result
                }
                else
                {
                    return result
                }
            }()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let result = results[indexPath.row]
        
        if let parentVC = parentViewController as? CreateTripTableViewController
        {
            parentVC.shownTextField.text = result
            delegate?.animateTextFieldBGSizeToDefault(textField)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 46.0
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        parent.shownTextField.resignFirstResponder()
    }
    
    func search()
    {
        searchingForCost = {
            switch textField
            {
            case parent.departureLocationTextField, parent.destinationTextField:
                return false
            case parent.budgetTextField, parent.dailyLodgingTextField, parent.dailyFoodTextField,
            parent.dailyOtherTextField, parent.oneTimeCostTextField, parent.planeTicketTextField:
                return true
            default:
                return nil
            }
        }()
        
        if searchingForCost != nil
        {
            if searchingForCost == true
            {
//                searchForCost()
            }
            else
            {
                searchForLocation()
            }
        }
    }
    
    func searchForCost()
    {
        parent?.animator.animateTextFieldBGSizeToSearch()
        
        searchingForCost = true
        if let digit = textField.text
        {
            results = [
                (digit),
                (digit + "0"),
                (digit + "5"),
                (digit + "00"),
                (digit + "50"),
                (digit + "000"),
                (digit + "500")
            ]
        }

        tableView.reloadData()
    }
    
    func searchForLocation()
    {
        parent?.animator.animateTextFieldBGSizeToSearch()
        
        if !UIApplication.sharedApplication().networkActivityIndicatorVisible
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        
        searchingForCost = false
        apiController = GooglePlacesAPIController(delegate: self)
        apiController?.searchGooglePlacesFor(textField.text!)
    }
    
    func didReceiveGooglePlacesAPIResults(predictions: [NSDictionary]?)
    {
        if predictions != nil
        {
            results.removeAll()
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                for prediction in predictions!
                {
                    let description = prediction["description"] as? String ?? ""
                    self.results.append(description)
                    self.tableView.reloadData()
                }
            }
        }
        else
        {
            parentViewController?.presentErrorPopup("Looks like there was an issue retrieving your location results. Sorry about that!")
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
