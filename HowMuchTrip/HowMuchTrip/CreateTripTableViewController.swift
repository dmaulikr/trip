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
//    let allProperties = ["Budget", "Departure Location", "Destination", "Date From", "Date To", "Plane Ticket Cost", "Daily Lodging Cost", "Daily Food Cost", "Daily Other Cost", "One Time Cost"]
    var propertyDictionary = [String: String]()
//    var resultDictionary = [String: String]()
    var calculator: Calculator!
    @IBOutlet var budgetRemainingLabel: UILabel!
    
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var departureLocationTextField: UITextField!
    @IBOutlet weak var destinatinTextField: UITextField!
    @IBOutlet weak var dateFromTextField: UITextField!
    @IBOutlet weak var dateToTextField: UITextField!
    @IBOutlet weak var planeTicketTextField: UITextField!
    @IBOutlet weak var dailyLodgingTextField: UITextField!
    @IBOutlet weak var dailyFoodTextField: UITextField!
    @IBOutlet weak var dailyOtherTextField: UITextField!
    @IBOutlet weak var oneTimeCostTextField: UITextField!
    
    
    
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
            return 1
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
//        resultDictionary = calculator.calculate(propertyDictionary)
        let aTrip = calculator.calculate(propertyDictionary)
        
        budgetRemainingLabel.text = String(aTrip.budgetRemaining)
        
        // TODO: use below values for donut graph
        print("Budget: \(String(aTrip.budgetTotal))")
        print("Subtotal: \(String(aTrip.subtotalOfProperties))")
        print("Budget Remaining: \(String(aTrip.budgetRemaining))")
        print("Plane Ticket: \(String(aTrip.planeTicketCost))")
        print("Daily Lodging: \(String(aTrip.dailyLodgingCost))")
        print("Daily Food: \(String(aTrip.dailyFoodCost))")
        print("Daily Other: \(String(aTrip.dailyOtherCost))")
        print("One Time: \(String(aTrip.oneTimeCost))")
    }

}
