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
    var dataSource = CreateTripDataSource()
    var delegate: TripWasSavedDelegate?
    
    var allProperties = [String]()
    var propertyDictionary = [String: String]()
    var calculator: Calculator!
    var trip = Trip()
    var trips = [Trip]()
    
    @IBOutlet weak var budgetRemainingLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var saveTripButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var contextButton: UIButton!
    
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
    
    var mapsAPIController: MapsAPIController?
    
    var shownTextField: UITextField!
    var textFields = [UITextField]()
    var buttons = [UIButton!]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        view.backgroundColor = UIColor(red:0, green:0.658, blue:0.909, alpha:1)
        
//        tableView.backgroundColor = UIColor(red:0, green:0.658, blue:0.909, alpha:1)
        
        if let delegate = navigationController?.viewControllers[0] as? SuggestedTripsTableViewController
        {
            self.delegate = delegate
        }
        else if let delegate = navigationController?.viewControllers[0] as? TripListTableViewController
        {
            self.delegate = delegate
        }
        
        print(delegate)
    
        dataSource.initialSetup(self) //allProperties and textFields assigned here
        dataSource.hideTextFieldsAndClearText(textFields, delegate: self)
        
        cycleToNextField(0)
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
        }
        
        checkForLocation(textField)
        
        calculate()
        tableView.reloadData()
        return rc
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if textField.tag == 80 || textField.tag == 81 && textField.isFirstResponder()
        {
            textField.resignFirstResponder()
            performSegueWithIdentifier("calendarPopover", sender: textField)
        }
        else if textField == budgetTextField
        {
            nextButton.enabled = textField.text?.characters.count > 0
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return dataSource.testCharacters(textField, string: string, superview: self)
    }
    
    func cycleToNextField(indexOfTextField: Int)
    {
        if indexOfTextField < textFields.count
        {
            shownTextField.hidden = true
            
            let nextTextField = textFields[indexOfTextField]
            let originalY = nextTextField.frame.origin.y
            shownTextField = nextTextField
            shownTextField.hidden = false
            shownTextField.frame.origin.y = 100

            dataSource.manageButtons(self)
            
            
            
            promptLabel.alpha = 0
            promptLabel.text = dataSource.getPromptLabelText(indexOfTextField, aTrip: trip)
            
            UIView.animateWithDuration(0.45, animations: { () -> Void in
                self.shownTextField.frame.origin.y = originalY
                self.shownTextField.alpha = 1
                self.promptLabel.alpha = 1
                
                }, completion: { (_) -> Void in
                    self.shownTextField.becomeFirstResponder()
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
    }
    
    @IBAction func clearButtonPressed(sender: UIBarButtonItem!)
    {
        clear()
    }
    
    @IBAction func contextButtonPressed(sender: UIButton)
    {
        let buttonImg = sender.imageForState(.Normal)
        
        if buttonImg == UIImage(named: "pin")
        {
            //TODO
        }
        else if buttonImg == UIImage(named: "plane")
        {
            //TODO
        }
        else if buttonImg == UIImage(named: "hotel")
        {
            //TODO
        }
    }
    
    func clear()
    {
        dataSource.hideTextFieldsAndClearText(textFields, delegate: self)
        
        if calculator != nil
        {
            calculator.clearCalculator()
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
        
        cycleToNextField(0)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton!)
    {
        saveTrip(trip)
        
        
    }
    
    // MARK: - Private Functions

    func calculate()
    {
        calculator = Calculator(dictionary: propertyDictionary)
        calculator.delegate = self
        
        trip = calculator.calculate(propertyDictionary)
        
        budgetRemainingLabel.text = "Budget Remaining: $\(String(format: "%.2f", trip.budgetRemaining))"
        budgetRemainingLabel.slideVerticallyToOrigin(0.25, fromPointY: -100)
        budgetRemainingLabel.appearWithFade(0.25)
        
        dataSource.buildGraphAndLegend(trip, superview: self)
    }
    
    func calculationFinished(validCalc: Bool)
    {
        if validCalc
        {
            budgetRemainingLabel.textColor = UIColor.whiteColor()
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.shownTextField.alpha = 0
                }, completion: { (_) -> Void in
                    
                    let nextTextFieldIndex =
                        self.textFields.indexOf(self.shownTextField)! + 1
                    self.cycleToNextField(nextTextFieldIndex)
            })
        }
        else
        {
            promptLabel.text = "Whoa there! Might have to plan a little smaller; looks like we're over budget."
            promptLabel.alpha = 0
            shownTextField.backgroundColor = UIColor.redColor()
            budgetRemainingLabel.textColor = UIColor.redColor()
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.promptLabel.alpha = 1
                self.shownTextField.backgroundColor = UIColor.whiteColor()
                }, completion: { (_) -> Void in
            })
        }
    }
    
    // MARK: - Save Trip
    
    func saveTrip(trip: Trip)
    {
        
        
        trips.append(trip)
        trip.pinInBackground()
        trip.saveEventually()
        print(trip.destinationLng)
        
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
    
    // MARK: - Graph Functions
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController)
    {
        view.removeDimmedOverlayView()
    }
    
    // MARK: - Calendar Popover
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let calendarPopover = segue.destinationViewController as? CalendarPopoverViewController
        {
            view.addDimmedOverlayView()
            
            calendarPopover.textFieldTag = sender?.tag
            calendarPopover.popoverPresentationController?.delegate = self
            calendarPopover.delegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    func dateWasChosen(date: Moment, textFieldTag: Int)
    {
        view.removeDimmedOverlayView()
        
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
    
    //MARK: - Pie Graph Legend
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 1 && !dataSource.calculateFinished
        {
            return 0
        }
        else if indexPath.row == 1
        {
            return 440
        }
        else if indexPath.row == 0 && !dataSource.tripCreated
        {
            return 140
        }
        else
        {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
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
//                mapsAPIController = MapsAPIController(delegate: self)
                mapsAPIController?.searchGMapsFor(term, textField: departureLocationTextField)
            }
        }
    }
    
    func didReceiveMapsAPIResults(results: NSDictionary, textField: UITextField)
    {
        if let (lat, lng) = trip.tripCoordinateFromJSON(results)
        {
            switch textField
            {
            case destinationTextField:
                propertyDictionary["destinationLat"] = String(lat)
                propertyDictionary["destinationLng"] = lng
                trip.destinationLat = lat
                trip.destinationLng = lng
            case departureLocationTextField:
                propertyDictionary["departureLat"] = lat
                propertyDictionary["departureLng"] = lng
//                trip.departureLat = lat
//                trip.departureLng = lng
            default: break
            }
            
            print(trip.destinationLng, trip.destinationLat)
        }
        calculate()
    }
}

