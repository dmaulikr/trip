//
//  CreateTripDataSource.swift
//  HowMuchTrip
//
//  Created by david on 12/17/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation
import Charts

class CreateTripDataSource
{
    var calculateFinished = false
    var tripCreated = false
//    var superview: CreateTripTableViewController?

    // MARK: - Initial View Setup
    func initialSetup(superview: CreateTripTableViewController)
    {
//        self.superview = superview
        
        let textFields = [
            superview.budgetTextField!,
            superview.destinationTextField!,
            superview.departureLocationTextField!,
            superview.dateFromTextField!,
            superview.dateToTextField!,
            superview.planeTicketTextField!,
            superview.dailyLodgingTextField!,
            superview.dailyFoodTextField!,
            superview.dailyOtherTextField!,
            superview.oneTimeCostTextField!
        ]
        
        superview.dateFromTextField.tag = 80
        superview.dateToTextField.tag = 81
        
        superview.textFields = textFields
        
        superview.shownTextField = superview.budgetTextField
        
        let allProperties =  [
            "Budget",
            "Destination",
            "Departure Location",
            "Date From",
            "Date To",
            "Plane Ticket Cost",
            "Daily Lodging Cost",
            "Daily Food Cost",
            "Daily Other Cost",
            "One Time Cost",
            "destinationLat",
            "destinationLng",
            "departureLat",
            "departureLng"
        ]
        
        superview.allProperties = allProperties
        
        let allButtons = [
            superview.nextButton,
//            superview.skipButton,
            superview.contextButton,
            superview.backButton
        ]
        
        superview.buttons = allButtons
        for button in superview.buttons
        {
            button.alpha = 0
            button.hidden = true
        }
        
        superview.contextButtonImg.image = nil
        
        let pieChartView = superview.pieChartView
        initialSetupPieChart(pieChartView)
        
        superview.budgetRemainingLabel.alpha = 0
        superview.saveTripButton.alpha = 0
        superview.saveTripButton.hidden = true
    }
    
    func initialSetupPieChart(pieChartView: PieChartView)
    {
        pieChartView.alpha = 0
        pieChartView.backgroundColor = UIColor.clearColor()
        pieChartView.holeTransparent = true
        pieChartView.holeAlpha = 0.0
        pieChartView.holeColor = UIColor.clearColor()
    }
    
    // MARK: - Getters
    
    func getPromptLabelText(indexOfTextField: Int, aTrip: Trip) -> String
    {
        var prefixes = [
            "Okay. ",
            "Alrighty. ",
            "Sounds good. ",
            "Cool cool cool. ",
            "Awesome. ",
            "Great. ",
            "All right. ",
            "Fantastic. ",
            "Perfect. "
        ]
        var suffix  : String!
        
        switch indexOfTextField
        {
        case 0:
            prefixes = [
                "First of all, ",
                "Let's get started: ",
                "To begin with, ",
                "Let's start: ",
                "Let's kick it off: ",
                "Square one: ",
                "A journey of a thousand miles begins with a single budget. So ",
                "Investment in travel is an investment in yourself. So "
            ]
            suffix = "what's your budget for this trip?"
        case 1:
            if aTrip.budgetTotal > 2000
            {
                prefixes = [
                    "Pulling out all the stops, I see! :) ",
                    "Been saving for this one for a while? :) ",
                    "Holiday bonus come early? :) "
                ]
            }
            
            suffix = "Where are you planning on going?"
            
            
            
        case 2:
            prefixes = [
                "Sounds nice. ",
                "Never been there. ",
                "Always wanted to go there. "
            ]
            if aTrip.destination == ""
            {
                prefixes = [""]
            }
            
            suffix = "Where are you leaving from?"
        case 3:
            prefixes += [
                "Oh, I have an aunt there! ",
                "Ah, \(aTrip.departureLocation). "
            ]
            
            if aTrip.departureLocation == ""
            {
                prefixes = [""]
            }
            
            suffix = "When are you planning on leaving?"
        case 4:
            suffix = "When are you planning on going back home?"
        case 5:
            suffix = "How about the price for the plane ticket?"
            //TODO:
            //subtitleLabel.text = "Press the PLANE button if you want to look up some prices.
        case 6:
            switch aTrip.planeTicketCost
            {
            case 0.0           : prefixes = [""]
            case 0.1 ... 300.0 : prefixes = ["Pretty cheap! "]
            case 300.0...600.0 : prefixes = ["Not bad. "]
            default            : prefixes = ["Ticket prices, am I right? "]
            }
            suffix = "How much is lodging going to cost?"
            //TODO:
            //subtitleLabel.text = "Press the HOTEL button if you want to look up some prices.
        case 7:
            if aTrip.dailyLodgingCost == 0.0
            {
                suffix = "Crashing on a couch or camping? "
            }
            suffix = "How about your daily food costs?"
        case 8:
            if aTrip.dailyFoodCost > 100
            {
                prefixes = ["Planning on some good eats! "]
            }
            suffix = "Any other daily costs we should put in the books?"
        case 9:
            suffix = "Any one-time costs we should put down? (Show tickets, tour, etc)"
        default: print("no")
        }
        
        let index_rand = Int(arc4random() % UInt32(prefixes.count))
        let promptLabelText = "\(prefixes[index_rand])\(suffix)"
        
        return promptLabelText
    }
    
    func getGraphValues(trip: Trip) -> [Double]
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
    
    func getSelectedTextFieldAndIndex(textField: UITextField, textFields: [UITextField]) -> (UITextField, Int)
    {
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

        return (selectedTextField, indexOfTextField)
    }
    
    func getGraphColors() -> [UIColor]
    {
//        let colors = [
//            UIColor(red:0.51, green:0.65, blue:0.65, alpha:1.0),
//            UIColor(red:0.00, green:0.20, blue:0.35, alpha:1.0),
//            UIColor(red:0.53, green:0.59, blue:0.70, alpha:1.0),
//            UIColor(red:0.04, green:0.32, blue:0.34, alpha:1.0),
//            UIColor(red:0.32, green:0.54, blue:0.79, alpha:1.0),
//            UIColor(red:0.92, green:0.82, blue:0.67, alpha:1.0),
//            UIColor(red:0.36, green:0.33, blue:0.42, alpha:1.0),
//            UIColor(red:0.77, green:0.77, blue:0.77, alpha:1.0)
//        ]
        let colors = [
            UIColor(red: 0.9, green: 0.29, blue: 0.29, alpha: 1),
            UIColor(red: 0.07, green: 0.17, blue: 0.2, alpha: 1),
            UIColor(red: 0.31, green: 0.65, blue: 0.85, alpha: 1),
            UIColor(red: 0.27, green: 0.81, blue: 0.8, alpha: 1),
            UIColor(red: 0, green: 0.41, blue: 0.55, alpha: 1),
            UIColor(red: 0.64, green: 0.75, blue: 0.93, alpha: 1)
        ]
        
        return colors
    }
    
    func getGraphValuesAndProperties(aTrip: Trip) -> ([Double], [String])
    {
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
        
        return (values, graphProperties)
    }

    // MARK: - Presentation Functions
    
    func hideTextFieldsAndClearText(textFields: [UITextField], delegate: CreateTripTableViewController)
    {
        for field in textFields
        {
            field.text = ""
            field.hidden = true
            field.alpha = 0
            field.delegate = delegate
        }
    }
    
    func hideButtons(buttons: [UIButton!])
    {
        for button in buttons
        {
            if button.alpha != 0
            {
                button.hideWithFade(0.25)
            }
        }
    }
    
    func manageButtons(superview: CreateTripTableViewController)
    {
        //        let textFields = [
        //            superview.budgetTextField!,
        //            superview.destinationTextField!,
        //            superview.departureLocationTextField!,
        //            superview.dateFromTextField!,
        //            superview.dateToTextField!,
        //            superview.planeTicketTextField!,
        //            superview.dailyLodgingTextField!,
        //            superview.dailyFoodTextField!,
        //            superview.dailyOtherTextField!,
        //            superview.oneTimeCostTextField!
        //        ]
        
        if superview.contextButton.alpha != 0
        {
            superview.contextButton.hideWithFade(0.25)
            superview.contextButtonImg.hideWithFade(0.25)
        }
        
        switch superview.shownTextField
        {
        case superview.budgetTextField:
            superview.nextButton.appearWithFade(0.25)
            if superview.backButton.alpha != 0
            {
                superview.backButton.hideWithFade(0.25)
                superview.backButton.hidden = true
            }

        case superview.departureLocationTextField:
//            superview.skipButton.appearWithFade(0.25)
            superview.backButton.hidden = false
            superview.backButton.appearWithFade(0.25)
            
            if Reachability.isConnectedToNetwork()
            {
                if let pin = UIImage(named: "pin")
                {
                    superview.contextButtonImg.image = pin
                }
                superview.contextButton.setTitle(" Tap to get your current location", forState: .Normal)
                superview.contextButton.tag = 70
                superview.contextButton.appearWithFade(0.25)
            }
            
        case superview.planeTicketTextField:
            
            if Reachability.isConnectedToNetwork()
            {
                let plane = UIImage(named: "plane")
                superview.contextButtonImg.image = plane
                
                superview.contextButton.setTitle(" Tap to get average ticket prices", forState: .Normal)
                superview.contextButton.tag = 71
                superview.contextButton.appearWithFade(0.25)
            }
            
        case superview.dailyLodgingTextField:
            
            if superview.trip.destinationLat != "" && superview.trip.destinationLng != "" && Reachability.isConnectedToNetwork()
            {
                let hotel = UIImage(named: "hotel")
                superview.contextButtonImg.image = hotel
                
                superview.contextButton.setTitle(" Tap to get average hotel prices", forState: .Normal)
                superview.contextButton.tag = 72
                superview.contextButton.appearWithFade(0.25)
            }
            
        default: break;
        }
    }
    
    // MARK: - Build Graph
    
    func buildGraphAndLegend(aTrip: Trip, superview: CreateTripTableViewController)
    {
        let (values, dataPoints) = getGraphValuesAndProperties(aTrip)
        buildLegend(values, dataPoints: dataPoints, superview: superview, trip: aTrip)
        buildGraph(values, dataPoints: dataPoints, superview: superview)
    }
    
    private func buildGraph(values: [Double], dataPoints: [String], superview: CreateTripTableViewController)
    {
        var dataEntries = [ChartDataEntry]()
        
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
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        superview.pieChartView.data = pieChartData
        
        if !calculateFinished
        {
            superview.pieChartView.appearWithFade(0.25)
            superview.pieChartView.slideHorizontallyToOrigin(0.25, fromPointX: -superview.pieChartView.frame.width)
            
            superview.legendContainerView.appearWithFade(0.25)
            superview.legendContainerView.slideHorizontallyToOrigin(0.25, fromPointX: superview.legendContainerView.frame.width)
        }
        
        calculateFinished = true
    }
    
    private func buildLegend(values: [Double], dataPoints: [String], superview: CreateTripTableViewController, trip: Trip)
    {
        if let legendTableVC = superview.childViewControllers[0] as? GraphLegendTableViewController
        {
            legendTableVC.dataPoints = dataPoints
            legendTableVC.values     = values
            legendTableVC.colors     = getGraphColors()
            legendTableVC.trip       = trip
            legendTableVC.tableView.reloadData()
        }
    }
    
    // MARK: - Text Field Validation
    
    func testCharacters(textField: UITextField, string: String, superview: CreateTripTableViewController) -> Bool
    {
        var invalidCharacters: NSCharacterSet!
        
        if textField == superview.destinationTextField || textField == superview.departureLocationTextField
        {
            invalidCharacters = NSCharacterSet(charactersInString: "0123456789")
            if let _ = string
                .rangeOfCharacterFromSet(invalidCharacters, options: [],
                    range:Range<String.Index>(start: string.startIndex, end: string.endIndex))
            {
                return false
            }
        }
        else
        {
            invalidCharacters = NSCharacterSet(charactersInString: "0123456789.").invertedSet //only includes 0-9
        }
        
        if let _ = string
            .rangeOfCharacterFromSet(invalidCharacters, options: [],
                range:Range<String.Index>(start: string.startIndex, end: string.endIndex))
        {
            return false
        }
        
        return true
    }
    

}