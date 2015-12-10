//
//  CreateTripTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class CreateTripTableViewController: UITableViewController, UITextFieldDelegate
{
    let allProperties = ["Budget", "Departure Location", "Destination", "Date From", "Date To", "Plane Ticket Cost", "Daily Lodging Cost", "Daily Food Cost", "Daily Other Cost", "One Time Cost"]
    var propertyDictionary = [String: String]()
    var resultDictionary = [String: String]()
    var calculator: Calculator!
    @IBOutlet var budgetRemainingLabel: UILabel!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Create Your Trip"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case 0:
            return allProperties.count
        default:
            return 1
        }
        
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch indexPath.section
        {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TripPropertyCell", forIndexPath: indexPath) as! TripPropertyCell
            let unitString = allProperties[indexPath.row]
            
            cell.propertyLabel.text = unitString
            
            let valueString = resultDictionary[unitString]
            if valueString == nil
            {
                cell.propertyTextField.delegate = self
            }
            else
            {
                cell.propertyTextField.text = valueString
            }
            
            
            if cell.propertyTextField.text == "" && indexPath.row == 0
            {
                cell.propertyTextField.becomeFirstResponder()
            }
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TripGraphCell", forIndexPath: indexPath) as! TripGraphCell
            
            // TODO: graph for budget
            
            
            return cell
            
        }
        

        
    }
    
    // MARK: - UITestField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        var rc = false
        
        let contentView = textField.superview
        let cell = contentView?.superview as! TripPropertyCell
        let indexPath = tableView.indexPathForCell(cell)
        let propertyValueString = allProperties[indexPath!.row]
        
        if textField.text != ""
        {
            rc = true
            textField.resignFirstResponder()
            propertyDictionary[propertyValueString] = textField.text

        }
        
        calculate()
        tableView.reloadData()
        return rc
    }

    func calculate()
    {
        calculator = Calculator(dictionary: propertyDictionary)
        resultDictionary = calculator.calculate(propertyDictionary)
        
        budgetRemainingLabel.text = resultDictionary["Budget Remaining"]
        
        // TODO: use below values for donut graph
        print("Budget: \(resultDictionary["Budget"])")
        print("Subtotal: \(resultDictionary["Subtotal"])")
        print("Budget Remaining: \(resultDictionary["Budget Remaining"])")
        print("Plane Ticket: \(resultDictionary["Plane Ticket Cost"])")
        print("Daily Lodging: \(resultDictionary["Daily Lodging Cost"])")
        print("Daily Food: \(resultDictionary["Daily Food Cost"])")
        print("Daily Other: \(resultDictionary["Daily Other Cost"])")
        print("One Time: \(resultDictionary["One Time Cost"])")
    }

}
