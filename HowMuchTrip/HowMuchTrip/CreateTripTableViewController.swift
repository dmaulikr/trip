//
//  CreateTripTableViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Charts
import SwiftMoment

class CreateTripTableViewController:
    UITableViewController,
    UITextFieldDelegate,
    UIPopoverPresentationControllerDelegate,
    DateWasChosenFromCalendarProtocol
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
    var aTrip = Trip()
    var trips = [Trip]()
    
    @IBOutlet var budgetRemainingLabel: UILabel!
    
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var departureLocationTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var dateFromTextField: UITextField!
    @IBOutlet weak var dateToTextField: UITextField!
    @IBOutlet weak var planeTicketTextField: UITextField!
    @IBOutlet weak var dailyLodgingTextField: UITextField!
    @IBOutlet weak var dailyFoodTextField: UITextField!
    @IBOutlet weak var dailyOtherTextField: UITextField!
    @IBOutlet weak var oneTimeCostTextField: UITextField!
    
    @IBOutlet weak var graphCell: UITableViewCell!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var legendContainerView: UIView!
    
    var calculateFinished = false
    
    var textFields = [UITextField]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Create Your Trip"
        
        budgetRemainingLabel.alpha = 0
        
        textFields = [
            budgetTextField!,
            departureLocationTextField!,
            destinationTextField!,
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
        dateFromTextField.tag = 80
        dateToTextField.tag = 81
        pieChartView.alpha = 0
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
        
        if calculator != nil
        {
            calculator.clearCalculator()
        }
        
        propertyDictionary.removeAll()
        pieChartView.hideWithFade(0.25)
        legendContainerView.hideWithFade(0.25)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.budgetRemainingLabel.alpha = 0
            }) { (_) -> Void in
                self.budgetRemainingLabel.text = ""
        }
        
        calculateFinished = false
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton!)
    {
        saveTrip(aTrip)
    }
    
    // MARK: - Private Functions

    func calculate()
    {
        calculator = Calculator(dictionary: propertyDictionary)
        
        aTrip = calculator.calculate(propertyDictionary)
        
        budgetRemainingLabel.text = "Budget Remaining: $\(String(format: "%.2f", aTrip.budgetRemaining))"
        budgetRemainingLabel.slideVerticallyToOrigin(0.25, fromPointY: -100)
        budgetRemainingLabel.appearWithFade(0.25)
        
        var values = [
            aTrip.budgetRemaining,
            aTrip.planeTicketCost,
            aTrip.totalLodgingCosts,
            aTrip.totalFoodCosts,
            aTrip.totalOtherDailyCosts,
            aTrip.oneTimeCost
        ]
        
        var graphProperties = [
            "Budget Remaining",
            "Plane Ticket",
            "Total Lodging",
            "Total Daily Food Cost",
            "Total Daily Other Cost",
            "Total One Time Costs"
        ]
        
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
        
        graphCell.hidden = false
        
        buildGraph(graphProperties, values: values)
        updateGraphLegend(graphProperties, values: values)
    }
    
    func saveTrip(aTrip: Trip)
    {
        trips.append(aTrip)
        aTrip.pinInBackground()
        aTrip.saveEventually()
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
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        pieChartDataSet.colors = getGraphColors()
        // TODO: format xVals to display nicely, or add a legend to make readable
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        if !calculateFinished
        {
            pieChartView.appearWithFade(0.25)
            pieChartView.slideHorizontallyToOrigin(0.25, fromPointX: -pieChartView.frame.width)
            
            legendContainerView.appearWithFade(0.25)
            legendContainerView.slideHorizontallyToOrigin(0.25, fromPointX: legendContainerView.frame.width)
        }
        
        calculateFinished = true
    }
    
    func getGraphColors() -> [UIColor]
    {
        let colors = [
            UIColor(red:0.51, green:0.65, blue:0.65, alpha:1.0),
            UIColor(red:0.00, green:0.20, blue:0.35, alpha:1.0),
            UIColor(red:0.53, green:0.59, blue:0.70, alpha:1.0),
            UIColor(red:0.04, green:0.32, blue:0.34, alpha:1.0),
            UIColor(red:0.32, green:0.54, blue:0.79, alpha:1.0),
            UIColor(red:0.92, green:0.82, blue:0.67, alpha:1.0),
            UIColor(red:0.36, green:0.33, blue:0.42, alpha:1.0),
            UIColor(red:0.77, green:0.77, blue:0.77, alpha:1.0)
        ]
        
        return colors
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let calendarPopover = segue.destinationViewController as? CalendarPopoverViewController
        {
            calendarPopover.textFieldTag = sender?.tag
            calendarPopover.popoverPresentationController?.delegate = self
            calendarPopover.delegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if textField.isFirstResponder() && textField.tag == 80 || textField.tag == 81
        {
            textField.resignFirstResponder()
            performSegueWithIdentifier("calendarPopover", sender: textField)
        }
    }
    
    func dateWasChosen(date: Moment, textFieldTag: Int)
    {
        let dateStr = date.format("MM/dd/yy")
        
        switch textFieldTag
        {
        case 80: dateFromTextField.text = dateStr
                 textFieldShouldReturn(dateFromTextField)
        case 81: dateToTextField.text   = dateStr
                 textFieldShouldReturn(dateToTextField)
        default: print(textFieldTag)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField != destinationTextField || textField != departureLocationTextField
        {
            let invalidCharacters = NSCharacterSet(charactersInString: "0123456789.").invertedSet //only includes 0-9
            if let _ = string
                .rangeOfCharacterFromSet(invalidCharacters, options: [],
                    range:Range<String.Index>(start: string.startIndex, end: string.endIndex))
            {
                return false
            }
        }
        return true
    }
    
    //MARK: - Pie Graph Legend
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 1 && calculateFinished == false
        {
            return 0
        }
        else if indexPath.row == 1
        {
            return 440
        }
        else
        {
            return 400
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func updateGraphLegend(dataPoints: [String], values: [Double])
    {
        if let legendTableVC = self.childViewControllers[0] as? GraphLegendTableViewController
        {
            legendTableVC.dataPoints = dataPoints
            legendTableVC.values     = values
            legendTableVC.colors     = getGraphColors()
            legendTableVC.tableView.reloadData()
        }
    }
}

