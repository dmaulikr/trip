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
import Parse

protocol TripWasSavedDelegate
{
    func tripWasSaved(savedTrip: Trip)
}

class CreateTripTableViewController:
    UITableViewController,
    UITextFieldDelegate,
    UIPopoverPresentationControllerDelegate,
    DateWasChosenFromCalendarProtocol,
    CalculationFinishedDelegate,
    MapsAPIResultsProtocol
{
    
    // MARK: - Labels
    
    @IBOutlet weak var budgetRemainingLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var saveTripButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contextButton: UIButton!
    @IBOutlet weak var contextButtonImg: UIImageView!
    
    // MARK: - Text Fields
    
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
    
    var shownTextField: UITextField!
    var textFields = [UITextField]()
    
    // MARK: - Graph Properties
    
    @IBOutlet weak var graphCell: UITableViewCell!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var legendContainerView: UIView!
    
    var childViewControler: UIViewController?
    
    var contextPopover: UIViewController? {
        didSet {
            contextPopover!.view.appearWithFade(0.25)
            contextPopover!.view.slideVerticallyToOrigin(0.25, fromPointY: self.view.frame.height)
        }
    }
    
    // MARK: - Other Properties
    var dataSource = CreateTripDataSource()
    var delegate: TripWasSavedDelegate?
    
    var allProperties = [String]()
    var propertyDictionary = [String: String]()
    var calculator: Calculator!
    var trip = Trip()
    var trips = [Trip]()
    
    var mapsAPIController: MapsAPIController?
    
    var buttons = [UIButton!]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let delegate = navigationController?.viewControllers[0] as? SuggestedTripsTableViewController
        {
            self.delegate = delegate
        }
        else if let delegate = navigationController?.viewControllers[0] as? TripListTableViewController
        {
            self.delegate = delegate
        }
        
        dataSource.initialSetup(self) //allProperties and textFields assigned here
        dataSource.hideTextFieldsAndClearText(textFields, delegate: self)
        
        cycleToTextField(0)
    }
    
    // MARK: - UITextField Stuff
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        var rc = false
        
        let (selectedTextField, indexOfTextField) = dataSource.getSelectedTextFieldAndIndex(textField, textFields: textFields)
        
        if selectedTextField.text != ""
        {
            rc = true
            selectedTextField.resignFirstResponder()
            
            let propertyKey = allProperties[indexOfTextField]
            propertyDictionary[propertyKey] = selectedTextField.text
            
            checkForLocation(textField)
            
            let property = allProperties[indexOfTextField]
            
            calculate(true, property: property, value: selectedTextField.text!)
            tableView.reloadData()
        }
        

        return rc
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if textField == dateToTextField || textField == dateFromTextField && textField.isFirstResponder()
        {
            textField.resignFirstResponder()
            
            if self.childViewControllers.count == 1
            {
                let contextPopStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
                let contextPopover = contextPopStoryboard.instantiateViewControllerWithIdentifier("calendarView") as! CalendarPopoverViewController
                self.addContextPopover(contextPopover)
                contextPopover.delegate = self
                contextPopover.textField = textField
//                
                contextPopover.view.appearWithFade(0.25)
                contextPopover.view.slideVerticallyToOrigin(0.25, fromPointY: self.view.frame.height / 2)
                
                self.contextPopover = contextPopover
            }
        }
        else
        {
            nextButton.enabled = true//textField.text?.characters.count > 0
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return dataSource.testCharacters(textField, string: string, superview: self)
    }
    
    func cycleToTextField(indexOfTextField: Int)
    {
        if indexOfTextField < textFields.count
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.shownTextField.hidden = true
                
                let nextTextField = self.textFields[indexOfTextField]
                let originalY = nextTextField.frame.origin.y
                self.shownTextField = nextTextField
                self.shownTextField.hidden = false
                self.shownTextField.text = ""
                self.shownTextField.frame.origin.y = 100
                
                self.promptLabel.alpha = 0
                self.promptLabel.text = self.dataSource.getPromptLabelText(indexOfTextField, aTrip: self.trip)
                
                self.dataSource.manageButtons(self)
                
                UIView.animateWithDuration(0.45, animations: { () -> Void in
                    self.shownTextField.frame.origin.y = originalY
                    self.shownTextField.alpha = 1
                    self.promptLabel.alpha = 1
                    
                    }, completion: { (_) -> Void in
                        self.shownTextField.becomeFirstResponder()
                })
            })
        }
        else
        {
            createTripComplete()
        }
    }
    
    // MARK: - Action Handlers
    
    @IBAction func nextButtonPressed(sender: UIButton)
    {
        textFieldShouldReturn(shownTextField)
        let nextIndex = textFields.indexOf(shownTextField)! + 1
        cycleToTextField(nextIndex)
    }
    
    @IBAction func backButtonPressed(sender: UIButton)
    {
        let previousTextFieldIndex = textFields.indexOf(shownTextField)! - 1
        self.cycleToTextField(previousTextFieldIndex)
    }
    
    @IBAction func clearButtonPressed(sender: UIBarButtonItem!)
    {
        clear()
    }
    
    @IBAction func contextButtonPressed(sender: UIButton)
    {
        switch sender.tag
        {
        case 70: //location
            locationButtonPressed(sender)
        case 71: //flight
            flightButtonPressed(sender)
        case 72: //hotel
            hotelButtonPressed(sender)
        default: print("context button unknown tag: \(sender.tag)")
        }
    }
    
    @IBAction func locationButtonPressed(sender: UIButton)
    {
        
    }
    
    @IBAction func flightButtonPressed(sender: UIButton)
    {
        let flightStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
        let contextPopover = flightStoryboard.instantiateViewControllerWithIdentifier("FlightPopover") as! FlightPopoverViewController
        self.addContextPopover(contextPopover)
    }
    
    @IBAction func hotelButtonPressed(sender: UIButton)
    {
        let contextStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
        let contextPopover = contextStoryboard.instantiateViewControllerWithIdentifier("HotelPopover") as! HotelPopoverViewController
        contextPopover.trip = trip
        self.addContextPopover(contextPopover)
    }
    
    
    @IBAction func saveButtonPressed(sender: UIButton!)
    {
        saveTrip(trip)
    }
    
    //MARK: - Location
    
    func checkForLocation(textField: UITextField)
    {
        if textField == destinationTextField
        {
            //DESTINATION
            
            if let term = destinationTextField.text
            {
                mapsAPIController = MapsAPIController(delegate: self)
                mapsAPIController?.searchGMapsFor(term, textField: destinationTextField)
            }
        }
        else if textField == departureLocationTextField
        {
            //ORIGIN
            
            if let term = departureLocationTextField.text
            {
                mapsAPIController = MapsAPIController(delegate: self)
                mapsAPIController?.searchGMapsFor(term, textField: departureLocationTextField)
            }
        }
    }
    
    func didReceiveMapsAPIResults(results: NSDictionary, textField: UITextField)
    {
        print("didReceiveMapsAPIResults")
        if let (lat, lng) = trip.tripCoordinateFromJSON(results)
        {
            switch textField
            {
            case destinationTextField:
                
                trip = calculator.assignValue(trip, propertyAndValue: ["destinationLat" : lat])
                trip = calculator.assignValue(trip, propertyAndValue: ["destinationLng" : lng])
                
//                calculate(false, property: "destinationLat", value: lat)
//                calculate(false, property: "destinationLng", value: lng)
                
            case departureLocationTextField:
                
                trip = calculator.assignValue(trip, propertyAndValue: ["departureLat" : lat])
                trip = calculator.assignValue(trip, propertyAndValue: ["departureLng" : lng])
                
//                calculate(false, property: "departureLat", value: lat)
//                calculate(false, property: "departureLng", value: lng)
                
            default: break
            }
        }
    }
    
    // MARK: - Graph Functions
    
    func dateWasChosen(date: Moment?, textField: UITextField)
    {
        dismissContextPopover(CalendarPopoverViewController)
        
        if date != nil
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                let dateStr = date!.format("MM/dd/yy")
                
                switch textField
                {
                case self.dateFromTextField:
                    if self.dateFromTextField.text == ""
                    {
                        self.dateFromTextField.text = dateStr
                        self.textFieldShouldReturn(self.dateFromTextField)
                        self.dateFromTextField.tag = 1000
                    }
                    //            self.calculate(false, property: "Date From", value: dateStr)
                case self.dateToTextField:
                    if self.dateToTextField.text == ""
                    {
                        self.dateToTextField.text   = dateStr
                        self.textFieldShouldReturn(self.dateToTextField)
                        self.dateToTextField.tag = 1001
                    }
                    //            self.calculate(false, property: "Date To", value: dateStr)
                default: print("default error in dateWasChosen -- unknown textField: \(textField)")
                }
            }
        }
    }
    
    //MARK: - Pie Graph Legend
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 1 && !dataSource.calculateFinished  { return 0 }
        else if indexPath.row == 1                              { return 440 }
        else if indexPath.row == 0 && !dataSource.tripCreated   { return 140 }
        else                                                    { return 0 }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    // MARK: - Private Functions
    
    func calculate(cycle: Bool, property: String, value: String)
    {
        calculator = {
            if cycle {
                return Calculator(delegate: self)
            }
            return Calculator(delegate: nil)
            }()
        
        print(cycle)
        
        trip = calculator.assignValue(trip, propertyAndValue: [property : value])
        
        budgetRemainingLabel.text = "Budget Remaining: $\(String(format: "%.2f", trip.budgetRemaining))"
        budgetRemainingLabel.slideVerticallyToOrigin(0.25, fromPointY: -100)
        budgetRemainingLabel.appearWithFade(0.25)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.dataSource.buildGraphAndLegend(self.trip, superview: self)
        }
//        dataSource.buildGraphAndLegend(trip, superview: self)
    }
    
    func calculationFinished(overBudget: Bool)
    {
        if !overBudget
        {
            budgetRemainingLabel.textColor = UIColor.whiteColor()
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.shownTextField.alpha = 0
                }, completion: { (_) -> Void in
                    
                    let nextTextFieldIndex =
                    self.textFields.indexOf(self.shownTextField)! + 1
                    self.cycleToTextField(nextTextFieldIndex)
            })
        }
        else
        {
            didGoOverBudget()
        }
        
        print(trip.destinationLng, trip.destinationLat)
    }
    
    func flashLabel(label: UILabel!)
    {
        
    }
    
    func didGoOverBudget()
    {
        promptLabel.text = "Whoa there! Might have to plan a little smaller; looks like we're over budget."
        promptLabel.alpha = 0
        shownTextField.backgroundColor = UIColor.redColor()
        budgetRemainingLabel.textColor = UIColor.redColor()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.promptLabel.alpha = 1
            self.shownTextField.backgroundColor = UIColor.whiteColor()
            }, completion: { (_) -> Void in
                self.shownTextField.becomeFirstResponder()
                self.shownTextField.placeholder = self.shownTextField.text
                self.shownTextField.text = ""
        })
        
//        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "flashLabel: budgetRemainingLabel", userInfo: nil, repeats: true)
    }
    
    func clear()
    {
        dataSource.hideTextFieldsAndClearText(textFields, delegate: self)
        
        if calculator != nil
        {
            dataSource.calculateFinished = false
        }
        
        propertyDictionary.removeAll()
        pieChartView.hideWithFade(0.25)
        legendContainerView.hideWithFade(0.25)
        promptLabel.hideWithFade(0.25)
        
        dataSource.hideButtons(buttons)
        
        if budgetRemainingLabel.alpha != 0
        {
            budgetRemainingLabel.hideWithFade(0.25)
        }
        
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        cycleToTextField(0)
    }
    
    func saveTrip(trip: Trip)
    {
        trip.user = PFUser.currentUser()!.username!
        trips.append(trip)
        trip.pinInBackground()
        trip.saveEventually()
        
        delegate?.tripWasSaved(trip)
    }
    
    func createTripComplete()
    {
        promptLabel.text = ""
        budgetRemainingLabel.text = "Everything look good?"
        budgetRemainingLabel.alpha = 0
        dataSource.tripCreated = true
        
        dataSource.hideButtons(buttons)
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            let index = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
            }) { (_) -> Void in
                
                self.saveTripButton.hidden = false
                self.saveTripButton.appearWithFade(0.25)
                self.saveTripButton.slideVerticallyToOrigin(0.45, fromPointY: self.saveTripButton.frame.height)
                
                self.budgetRemainingLabel.appearWithFade(0.25)
                self.budgetRemainingLabel.slideVerticallyToOrigin(0.45, fromPointY: self.saveTripButton.frame.height)
        }
        
        //        performSegueWithIdentifier(<#T##identifier: String##String#>, sender: <#T##AnyObject?#>)
        
        
        //        switch trip.budgetRemaining
    }
    
}

