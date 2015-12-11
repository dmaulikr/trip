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
    let allProperties = [
        "Budget",
        "Departure Location",
        "Destination",
        "Date From",
        "Date To",
        "Plane Ticket Cost",
        "Daily Lodging Cost",
        "Daily Food Cost",
        "Daily Other Cost",
        "One Time Cost"
    ]
    
    var propertyDictionary = [String: String]()
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
    
    var textFields = [UITextField]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Create Your Trip"
        budgetRemainingLabel.hidden = true
        
        
        textFields = [
            budgetTextField!,
            departureLocationTextField!,
            destinatinTextField!,
            dateFromTextField!,
            dateToTextField!,
            planeTicketTextField!,
            dailyLodgingTextField!,
            dailyFoodTextField!,
            dailyOtherTextField!,
            oneTimeCostTextField!
        ]
        
        for textField in textFields
        {
            textField.delegate = self
        }
        
        budgetTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        var rc = false
       
        var selectedTextField: UITextField!
        var indexOfTextField: Int!
        
        for field in textFields
        {
            if textField == field
            {
                selectedTextField = field
                indexOfTextField = textFields.indexOf(field)
                
            }
        }
        
        // TODO: Add validation to the fields - type, format and non-negative
        // TODO: change date fields from doubles to actual dates, validate
        
        if selectedTextField.text != ""
        {
            rc = true
            selectedTextField.resignFirstResponder()
            
            
            // Add to dictionary that will pass to the calculator
            let propertyKey = allProperties[indexOfTextField]
            propertyDictionary[propertyKey] = selectedTextField.text
            
            if indexOfTextField + 1 < textFields.count
            {
                let nextTextField = textFields[indexOfTextField + 1]
                nextTextField.becomeFirstResponder()
            }
            else
            {
                calculate()
            }
        }
        

        calculate()
        tableView.reloadData()
        return rc
    }
    
    // MARK: - Private Functions

    func calculate()
    {
        calculator = Calculator(dictionary: propertyDictionary)
        
        let aTrip = calculator.calculate(propertyDictionary)
        budgetRemainingLabel.hidden = false
        
        budgetRemainingLabel.text = "Budget Remaining: $\(String(format: "%.2f", aTrip.budgetRemaining))"
        
        // TODO: use below values for donut graph
        print("Budget: \(String(aTrip.budgetTotal))")
        print("Subtotal: \(String(aTrip.subtotalOfProperties))")
        print("Budget Remaining: \(String(aTrip.budgetRemaining))")
        print("Plane Ticket: \(String(aTrip.planeTicketCost))")
        print("Daily Lodging: \(String(aTrip.dailyLodgingCost))")
        print("Daily Food: \(String(aTrip.dailyFoodCost))")
        print("Daily Other: \(String(aTrip.dailyOtherCost))")
        print("Total Daily Other: \(String(aTrip.totalFoodAndOtherCosts))")
        print("One Time: \(String(aTrip.oneTimeCost))")
        
        buildGraph()
    }
    
    // TODO: Obvs, build it up
    func buildGraph()
    {
        
    }
    
    @IBAction func clearButtonPressed(sender: UIBarButtonItem!)
    {
        clear()
    }
    
    func clear()
    {
        for field in textFields
        {
            field.text = ""
        }
        budgetRemainingLabel.hidden = true
        propertyDictionary.removeAll()
        calculator.clearCalculator()
    }

}
