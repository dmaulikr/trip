//
//  LocationSearchTableViewController.swift
//  HowMuchTrip
//
//  Created by david on 1/4/16.
//  Copyright © 2016 HowMuchTrip. All rights reserved.
//

import UIKit

protocol LocationWasChosenProtocol
{
    func animateTextFieldBGSizeToDefault(textField: UITextField?)
}

class LocationSearchTableViewController: UITableViewController, GooglePlacesAPIProtocol
{
    var results = [String]()
    var textField: UITextField!
    var apiController: GooglePlacesAPIController?
    var delegate: LocationWasChosenProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
            
            cell.textLabel?.text = result
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let result = results[indexPath.row]
        
        if let parentVC = parentViewController as? CreateTripTableViewController
        {
            switch textField
            {
            case parentVC.destinationTextField: parentVC.destinationTextField.text = result
            case parentVC.departureLocationTextField: parentVC.departureLocationTextField.text = result
            default: print(textField)
            }
            delegate?.animateTextFieldBGSizeToDefault(textField)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 44.0
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if let parentVC = parentViewController as? CreateTripTableViewController
        {
            if parentVC.shownTextField.isFirstResponder()
            {
                parentVC.shownTextField.resignFirstResponder()
            }
        }
    }
    
    func searchForLocation()
    {
        apiController = GooglePlacesAPIController(delegate: self)
        apiController?.searchGooglePlacesFor(textField.text!)
    }
    
    func didReceiveGooglePlacesAPIResults(predictions: [NSDictionary])
    {
        results.removeAll()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            for prediction in predictions
            {
                let description = prediction["description"] as? String ?? ""
                self.results.append(description)
                self.tableView.reloadData()
            }
        }

    }
}
