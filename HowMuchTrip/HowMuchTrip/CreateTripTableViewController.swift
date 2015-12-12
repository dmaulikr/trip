//
//  CreateTripTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Charts

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
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    var textFields = [UITextField]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Create Your Trip"
        
        pieChartView.noDataText = "You need to provide data for the chart."
        
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
//                calculate()
            }
        }
        

        calculate()
        tableView.reloadData()
        return rc
    }
    
    // MARK: - Action Handlers
    
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
        
        if calculator != nil
        {
            calculator.clearCalculator()
        }
    }
    
    @IBAction func calculateButtonPressed(sender: UIButton!)
    {
        calculate()
    }
    
    
    // MARK: - Private Functions

    func calculate()
    {
        calculator = Calculator(dictionary: propertyDictionary)
        
        let aTrip = calculator.calculate(propertyDictionary)
        
        budgetRemainingLabel.hidden = false
        budgetRemainingLabel.text = "Budget Remaining: $\(String(format: "%.2f", aTrip.budgetRemaining))"
        
        var values = [aTrip.budgetRemaining, aTrip.planeTicketCost, aTrip.totalLodgingCosts, aTrip.totalFoodAndOtherCosts, aTrip.oneTimeCost]
        var graphProperties = ["Budget Remaining","Plane Ticket","Total Lodging","Total Daily Food & Other","Total One Time Costs"]
        
        // Remove '0' value entries for graphing
        for x in values
        {
            if x == 0
            {
                let index = values.indexOf(x)
                values.removeAtIndex(index!)
                graphProperties.removeAtIndex(index!)
            }
        }
        buildGraph(graphProperties, values: values)
        
    }
    
    // MARK: - Graph Functions
    
    func getValues(trip: Trip) -> [Double]
    {
        var values = [Double]()
        
        let mirrored_object = Mirror(reflecting: trip)
        
        for (_, attr) in mirrored_object.children.enumerate()
        {
            if let value = attr.value as? Double
            {
                values.append(value)
            }
        }
        
        return values
    }
    
    func buildGraph(dataPoints: [String], values: [Double])
    {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count
        {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        var points = [String]()
        for _ in dataPoints
        {
            points.append(" ")
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Budget")
        let pieChartData = PieChartData(xVals: [""], dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        setGraphColors(dataPoints, pieChartDataSet: pieChartDataSet)
 
    }
    
    func setGraphColors(dataPoints: [String], pieChartDataSet: PieChartDataSet)
    {
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count
        {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
    }


}
