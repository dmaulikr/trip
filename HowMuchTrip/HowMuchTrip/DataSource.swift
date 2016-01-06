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
    var controller: CreateTripTableViewController!
    
    init(controller: CreateTripTableViewController)
    {
        self.controller = controller
        initialSetup()
        hideTextFieldsAndClearText(controller.textFields, delegate: controller)
    }
    
    init()
    {

    }

    // MARK: - Initial View Setup
    func initialSetup()
    {
        if let delegate = controller.navigationController?.viewControllers[0] as? SuggestedTripsTableViewController
        {
            controller.delegate = delegate
        }
        else if let delegate = controller.navigationController?.viewControllers[0] as? TripListTableViewController
        {
            controller.delegate = delegate
        }
        
        controller.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        
        let textFields = [
            controller.budgetTextField!,
            controller.destinationTextField!,
            controller.departureLocationTextField!,
            controller.dateFromTextField!,
            controller.dateToTextField!,
            controller.planeTicketTextField!,
            controller.dailyLodgingTextField!,
            controller.dailyFoodTextField!,
            controller.dailyOtherTextField!,
            controller.oneTimeCostTextField!,
            controller.tripNameTextField!
        ]
        
        controller.dateFromTextField.tag = 80
        controller.dateToTextField.tag = 81
        
        controller.textFields = textFields
        
        controller.shownTextField = controller.budgetTextField
        
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
        
        controller.allProperties = allProperties
        
        let allButtons = [
            controller.nextButton,
            controller.locationButton,
            controller.flightButton,
            controller.calendarButton,
            controller.backButton
        ]
        
        controller.buttons = allButtons
        for button in controller.buttons
        {
            button.alpha = 0
            button.hidden = true
        }
        
        let nextButton = controller.nextButton
        nextButton.enabled = false
        controller.animator.fadeButton(nextButton)
        
        let pieChartView = controller.pieChartView
        initialSetupPieChart(pieChartView)
        
        controller.legendContainerView.alpha = 0
        
        controller.budgetRemainingLabel.alpha = 0
        controller.budgetRemainingBottomLabel.alpha = 0
        
        controller.prefixPromptLabel.text = ""
        controller.suffixPromptLabel.text = ""
        
        controller.textFieldBGView.alpha = 0
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
            suffix = "How much do you think transit will cost? (Plane ticket, gas costs, etc.)"
            //TODO:
            //subtitleLabel.text = "Press the PLANE button if you want to look up some prices.
        case 6:
//            switch aTrip.planeTicketCost
//            {
//            case 0.0           : prefixes = [""]
//            case 0.1 ... 300.0 : prefixes = ["Pretty cheap! "]
//            case 300.0...600.0 : prefixes = ["Not bad. "]
//            default            : prefixes = ["Ticket prices, am I right? "]
//            }
            suffix = "How much will you allot for each night's lodging?"
            //TODO:
            //subtitleLabel.text = "Press the HOTEL button if you want to look up some prices.
        case 7:
            if aTrip.dailyLodgingCost == 0.0
            {
                prefixes = ["Crashing on a couch or camping?"]
            }
            suffix = "How about your daily food costs?"
        case 8:
            if aTrip.dailyFoodCost > 100
            {
                prefixes = ["Planning on some good eats!"]
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
            "Transit",
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
    
    func manageButtons()
    {
        if controller.shownTextField != controller.budgetTextField
        {
            if controller.backButton.alpha == 0
            {
                controller.backButton.appearWithFade(0.25)
            }
        }
        
        if controller.flightButton.alpha != 0
        {
            controller.flightButton.hideWithFade(0.25)
        }
        
        if controller.locationButton.alpha != 0
        {
            controller.locationButton.hideWithFade(0.25)
        }
        
        if controller.calendarButton.alpha != 0
        {
            controller.calendarButton.hideWithFade(0.25)
        }
        
        switch controller.shownTextField
        {
        case controller.budgetTextField:
            controller.nextButton.appearWithFade(0.25)
            if controller.backButton.alpha != 0
            {
                controller.backButton.hideWithFade(0.25)
                controller.backButton.hidden = true
            }

        case controller.departureLocationTextField:
//            controller.skipButton.appearWithFade(0.25)
            controller.backButton.hidden = false
            controller.backButton.appearWithFade(0.25)
            
            if Reachability.isConnectedToNetwork()
            {
                controller.locationButton.appearWithFade(0.25)
                controller.animator.shakeButton(controller.locationButton)
            }
            
        case controller.planeTicketTextField:
            
            if Reachability.isConnectedToNetwork()
            {
                controller.flightButton.appearWithFade(0.25)
                controller.animator.shakeButton(controller.flightButton)
            }
            
        case controller.dateToTextField, controller.dateFromTextField:
            
            controller.calendarButton.appearWithFade(0.25)
            controller.animator.shakeButton(controller.calendarButton)
            
        case controller.dailyLodgingTextField: print("deprecated")
            
//            if controller.trip.destinationLat != "" && controller.trip.destinationLng != "" && Reachability.isConnectedToNetwork()
//            {
//                let hotel = UIImage(named: "hotel")
//                print(hotel)
//                controller.contextButton.setImage(hotel, forState: .Normal)
//                
//                controller.contextButton.tag = 72
//                controller.contextButton.appearWithFade(0.25)
//                shakeButton(controller.contextButton)
//            }
            
        default: break
        }
    }

    // MARK: - Build Graph
    
    func buildGraphAndLegend()
    {
        let aTrip = controller.trip
        let (values, dataPoints) = getGraphValuesAndProperties(aTrip)
        buildLegend(values, dataPoints: dataPoints)
        buildGraph(values, dataPoints: dataPoints)
    }
    
    private func buildGraph(values: [Double], dataPoints: [String])
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
        controller.pieChartView.data = pieChartData
        
        if !calculateFinished
        {
            controller.pieChartView.appearWithFade(0.25)
            controller.pieChartView.slideHorizontallyToOrigin(0.25, fromPointX: -controller.pieChartView.frame.width)
            
            controller.legendContainerView.appearWithFade(0.25)
            controller.legendContainerView.slideHorizontallyToOrigin(0.25, fromPointX: controller.legendContainerView.frame.width)
        }
        
        calculateFinished = true
    }
    
    private func buildLegend(values: [Double], dataPoints: [String])
    {
        if let legendTableVC = controller.childViewControllers[0] as? GraphLegendTableViewController
        {
            let trip = controller.trip
            
            legendTableVC.dataPoints = dataPoints
            legendTableVC.values     = values
            legendTableVC.colors     = getGraphColors()
            legendTableVC.trip       = trip
            legendTableVC.tableView.reloadData()
        }
    }
    
    // MARK: - Text Field Validation
    
    func testCharacters(textField: UITextField, string: String) -> Bool
    {
        var invalidCharacters: NSCharacterSet!
        
        if textField == controller.destinationTextField || textField == controller.departureLocationTextField
        {
            invalidCharacters = NSCharacterSet(charactersInString: "0123456789")
            if let _ = string
                .rangeOfCharacterFromSet(invalidCharacters, options: [],
                    range:Range<String.Index>(start: string.startIndex, end: string.endIndex))
            {
                return false
            }
        }
        else if textField == controller.tripNameTextField
        {
            invalidCharacters = NSCharacterSet(charactersInString: "")
        }
        else if textField == controller.dateToTextField || textField == controller.dateFromTextField
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