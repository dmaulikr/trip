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
        
        if let delegate = superview.navigationController?.viewControllers[0] as? SuggestedTripsTableViewController
        {
            superview.delegate = delegate
        }
        else if let delegate = superview.navigationController?.viewControllers[0] as? TripListTableViewController
        {
            superview.delegate = delegate
        }
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
            superview.oneTimeCostTextField!,
            superview.tripNameTextField!
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
//            "destinationLat",
//            "destinationLng",
//            "departureLat",
//            "departureLng",
            "Name"
        ]
        
        superview.allProperties = allProperties
        
        let allButtons = [
            superview.nextButton,
            superview.locationButton,
            superview.flightButton,
            superview.calendarButton,
            superview.backButton
        ]
        
        superview.buttons = allButtons
        for button in superview.buttons
        {
            button.alpha = 0
            button.hidden = true
        }
        
        let nextButton = superview.nextButton
        nextButton.enabled = false
        fadeButton(nextButton)
        
//        superview.contextButtonImg.image = nil
        
        let pieChartView = superview.pieChartView
        initialSetupPieChart(pieChartView)
        
        superview.legendContainerView.alpha = 0
        
        superview.budgetRemainingLabel.alpha = 0
        superview.budgetRemainingBottomLabel.alpha = 0
        
        superview.prefixPromptLabel.text = ""
        superview.suffixPromptLabel.text = ""
        
        superview.textFieldBGView.alpha = 0
        
//        superview.saveTripButton.alpha = 0
//        superview.saveTripButton.hidden = true
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
    
    func getPromptLabelText(indexOfTextField: Int, aTrip: Trip) -> (String, String)
    {
        var prefixes = [
            "Okay. ",
            "Alrighty. ",
            "Sounds good. ",
            "Awesome. ",
            "Great. ",
            "All right. ",
            "Fantastic. ",
            "Perfect. ",
            "Lookin' great so far."
        ]
        var suffix  : String!
        
        switch indexOfTextField
        {
        case 0:
            prefixes = [
                "First of all;",
                "Let's get started:",
                "To begin with;",
                "Let's start:",
                "Let's kick it off:",
                "Square one:",
                "A journey of a thousand miles begins with a single budget.",
                "Investment in travel is an investment in yourself.",
                "Let's begin."
            ]
            suffix = "What's your budget for this trip?"
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
        case 10:
            suffix = "What should we name this trip?"
            if aTrip.budgetRemaining > 100
            {
                prefixes = [
                    "Nice!",
                    "Great job!"
                ]
                suffix = "Looks like you've tallied everything and still have some breathing room. What should we name this trip?"
            }
        default: print("no")
        }
        
        let prefix = prefixes[Int(arc4random() % UInt32(prefixes.count))]
//        let promptLabelText = "\(prefixes[index_rand])\(suffix)"
        
        return (prefix, suffix)
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
        let colors = [
//            UIColor(red: 0, green: 0.41, blue: 0.55, alpha: 0.6),
            UIColor(red:0.028, green:0.275, blue:0.36, alpha: 1),
//            UIColor(red: 1, green: 1, blue: 1, alpha: 0.2),
            UIColor(red: 0.5, green: 0.85, blue: 0.85, alpha: 1),
            UIColor(red: 0.14, green: 0.75, blue: 0.73, alpha: 1),
            UIColor(red: 0.41, green: 0.76, blue: 0.87, alpha: 1),
            UIColor(red: 0.95, green: 0.71, blue: 0.31, alpha: 1),
            UIColor(red: 0.87, green: 0.51, blue: 0.98, alpha: 1),
        ]
        
        return colors
    }
    
    func getGraphValuesAndProperties(aTrip: Trip) -> ([Double], [String])
    {
        let values = [
            aTrip.budgetRemaining,
            aTrip.planeTicketCost,
            aTrip.totalLodgingCosts,
            aTrip.totalFoodCosts,
            aTrip.totalOtherDailyCosts,
            aTrip.oneTimeCost
        ]
        
        let graphProperties = [
            "Budget Remaining",
            "Plane Ticket",
            "Total Lodging",
            "Total Daily Food Cost",
            "Total Daily Other Cost",
            "Total One Time Costs"
        ]
        
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
        if superview.shownTextField != superview.budgetTextField
        {
            if superview.backButton.alpha == 0
            {
                superview.backButton.appearWithFade(0.25)
            }
        }
        
        if superview.flightButton.alpha != 0
        {
            superview.flightButton.hideWithFade(0.25)
        }
        
        if superview.locationButton.alpha != 0
        {
            superview.locationButton.hideWithFade(0.25)
        }
        
        if superview.calendarButton.alpha != 0
        {
            superview.calendarButton.hideWithFade(0.25)
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
                superview.locationButton.appearWithFade(0.25)
                shakeButton(superview.locationButton)
            }
            
        case superview.planeTicketTextField:
            
            if Reachability.isConnectedToNetwork()
            {
                superview.flightButton.appearWithFade(0.25)
                shakeButton(superview.flightButton)
            }
            
        case superview.dateToTextField, superview.dateFromTextField:
            
            superview.calendarButton.appearWithFade(0.25)
            shakeButton(superview.calendarButton)
            
        case superview.dailyLodgingTextField: print("deprecated")
            
//            if superview.trip.destinationLat != "" && superview.trip.destinationLng != "" && Reachability.isConnectedToNetwork()
//            {
//                let hotel = UIImage(named: "hotel")
//                print(hotel)
//                superview.contextButton.setImage(hotel, forState: .Normal)
//                
//                superview.contextButton.tag = 72
//                superview.contextButton.appearWithFade(0.25)
//                shakeButton(superview.contextButton)
//            }
            
        default: break
        }
    }
    
    func shakeButton(button: UIButton!)
    {

        let leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, -0.05)
        let rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, 0.05)
        
        button.transform = leftWobble
        
        UIView.animateWithDuration(0.15, delay: 0,
            options: [.Repeat, .Autoreverse],
            animations: { () -> Void in
                UIView.setAnimationRepeatCount(3)
                button.transform = rightWobble
                
            }) { (_) -> Void in
                button.transform = CGAffineTransformIdentity
        }
    }
    
    func fadeButton(button: UIButton)
    {
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            button.backgroundColor = UIColor(red:0.45, green:0.8, blue:0.898, alpha:0.3)
            }) { (_) -> Void in
        }
    }
    
    func appearButton(button: UIButton)
    {
//        UIView.animateWithDuration(0.25, animations: { () -> Void in
//            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//            button.backgroundColor = UIColor(red:0.471, green:0.799, blue:0.896, alpha:1)
//            }, completion: nil)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            button.backgroundColor = UIColor(red:0.45, green:0.8, blue:0.898, alpha:1)
            }) { (_) -> Void in
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
        else if textField == superview.tripNameTextField
        {
            invalidCharacters = NSCharacterSet(charactersInString: "")
        }
        else if textField == superview.dateToTextField || textField == superview.dateFromTextField
        {
            invalidCharacters = NSCharacterSet(charactersInString: "0123456789/").invertedSet //only includes 0-9
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