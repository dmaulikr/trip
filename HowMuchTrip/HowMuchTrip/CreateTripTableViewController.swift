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
    MapsAPIResultsProtocol,
    UIGestureRecognizerDelegate
{
    
    // MARK: - Labels
    
    @IBOutlet weak var budgetRemainingLabel: UILabel!
    @IBOutlet weak var budgetRemainingBottomLabel: UILabel!
    
    @IBOutlet weak var prefixPromptLabel: UILabel!
    @IBOutlet weak var suffixPromptLabel: UILabel!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var saveTripButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contextButton: UIButton!
    @IBOutlet weak var contextButtonImg: UIImageView!
    
    var buttons = [UIButton!]()
    
    var pulseButtonTimer: NSTimer?
    
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

    @IBOutlet weak var tripNameTextField: UITextField!
    
    @IBOutlet weak var textFieldBGView: UIView!
    
    var shownTextField: UITextField!
    var textFields = [UITextField]()
    let settingsVC = SettingsViewController()
    
    // MARK: - Graph Properties
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var legendContainerView: UIView!
    
    var childViewControler: UIViewController?
    
    var contextPopover: UIViewController?
    
    // MARK: - Other Properties
    var dataSource = CreateTripDataSource()
    var delegate: TripWasSavedDelegate?
    
    var indexOfTextField = 0
    
    var allProperties = [String]()
    var propertyDictionary = [String: String]()
    var calculator: Calculator!
    var trip = Trip()
    var trips = [Trip]()
    
    var mapsAPIController: MapsAPIController?
    
    var cycleCount = 0
    var flashCount = 0
    var flashTimer: NSTimer?
    
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
        
        dateFromTextField.tag = 80
        dateToTextField.tag = 81
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        
        setupDismissTapGesture()
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "initialCycle", userInfo: nil, repeats: false)
    }
    
    func initialCycle()
    {
        cycleToTextField(0)
        textFieldBGView.alpha = 0
        textFieldBGView.appearWithFade(0.25)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        switch loggedInWith
        {
        case "Twitter":
            settingsVC.processTwitterData()
        case "Facebook":
            settingsVC.processFacebookData()
        case "Username":
            settingsVC.processUsernameData()
        default:
            PFUser.logOut()
        }
    }
    
    // MARK: - UITextField Stuff
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        var rc = false
        
        let (selectedTextField, indexOfTextField) = dataSource.getSelectedTextFieldAndIndex(textField, textFields: textFields)
        self.indexOfTextField = indexOfTextField
        
        if shownTextField.text != ""
        {
            rc = true
            nextButton.enabled = true
            dataSource.appearButton(nextButton)
            selectedTextField.resignFirstResponder()
            
            let index = NSIndexPath(forRow: 0, inSection: 0)
            tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Bottom, animated: true)
        }
        else
        {
            nextButton.enabled = false
            dataSource.fadeButton(nextButton)
            flashTimer = NSTimer.scheduledTimerWithTimeInterval(0.025, target: self, selector: "flashTextField", userInfo: nil, repeats: true)
        }
        
        return rc
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        let (_, indexOfTextField) = dataSource.getSelectedTextFieldAndIndex(textField, textFields: textFields)
        self.indexOfTextField = indexOfTextField
        
        if shownTextField.text != ""
        {
            nextButton.enabled = true
            dataSource.appearButton(nextButton)
//            
//            nextButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//            nextButton.backgroundColor = UIColor(red:0.471, green:0.799, blue:0.896, alpha:1)
        }
        else
        {
            nextButton.enabled = false
            dataSource.fadeButton(nextButton)
//            nextButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
//            nextButton.backgroundColor = UIColor(red:0.471, green:0.799, blue:0.896, alpha:0.3)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        nextButton.enabled = false
        dataSource.fadeButton(nextButton)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        if textField.keyboardType != .Default
        {
            print("addDoneButton")
            self.addDoneButtonOnKeyboard(self.shownTextField)
        }
        return true
    }
    
    func presentCalendar(textFieldTag: Int)
    {
        if self.childViewControllers.count == 1
        {
            let contextPopStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
            let contextPopover = contextPopStoryboard.instantiateViewControllerWithIdentifier("calendarView") as! CalendarPopoverViewController
            self.addContextPopover(contextPopover)
            contextPopover.delegate = self
            contextPopover.textFieldTag = textFieldTag
//                
//                contextPopover.view.appearWithFade(0.25)
//                contextPopover.view.slideVerticallyToOrigin(0.25, fromPointY: self.view.frame.height / 2)
            
            self.contextPopover = contextPopover
        }
        nextButton.enabled = true//textField.text?.characters.count > 0
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
                self.shownTextField.alpha = 0
                self.shownTextField.text = ""
                self.shownTextField.frame.origin.y = 100
                self.textFieldBGView.frame.origin.y = 100
                
                self.prefixPromptLabel.alpha = 0
                self.suffixPromptLabel.alpha = 0
                
                let (prefix, suffix) = self.dataSource.getPromptLabelText(indexOfTextField, aTrip: self.trip)
                
                self.prefixPromptLabel.text = prefix
                self.suffixPromptLabel.text = suffix
                
//                self.promptLabel.text = self.dataSource.getPromptLabelText(indexOfTextField, aTrip: self.trip)
                
                self.dataSource.manageButtons(self)
                
                self.dataSource.fadeButton(self.nextButton)
//                
//                self.nextButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
//                self.nextButton.backgroundColor = UIColor(red:0.471, green:0.799, blue:0.896, alpha:0.3)
                
                UIView.animateWithDuration(0.45, animations: { () -> Void in
                    self.shownTextField.frame.origin.y = originalY
                    self.shownTextField.alpha = 1
                    
                    self.prefixPromptLabel.alpha = 1
                    self.suffixPromptLabel.alpha = 1
                    
//                    self.promptLabel.alpha = 1
                    
                    }, completion: { (_) -> Void in
                        if self.shownTextField.tag == 81
                        {
//                            self.dateToTextField.tag = 80
                            self.presentCalendar(self.dateToTextField.tag)
                        }
                        else if self.shownTextField.tag == 80
                        {
//                            self.dateFromTextField.tag = 81
                            self.presentCalendar(self.dateFromTextField.tag)
                        }
                        else
                        {
                            self.shownTextField.becomeFirstResponder()
                            
                        }
                })
            })
        }
        else
        {
            print("create trip complete")
            createTripComplete()
        }
        
        print("text field index: \(indexOfTextField) should == cycle count: \(cycleCount)")
        cycleCount++
    }
    
    // MARK: - Action Handlers
    
    @IBAction func nextButtonPressed(sender: UIButton)
    {
        if !dataSource.tripCreated
        {
            if shownTextField == tripNameTextField
            {
                nextButton.setTitle("S A V E  T R I P", forState: .Normal)
            }
//            textFieldShouldReturn(shownTextField)
            print(indexOfTextField, allProperties.count)
            let propertyKey = allProperties[indexOfTextField]
            propertyDictionary[propertyKey] = shownTextField.text
            
            checkForLocation(shownTextField)
            
            let property = allProperties[indexOfTextField]
            
            calculate(true, property: property, value: shownTextField.text!)
        }
        else
        {
            print("save button pressed")
            saveButtonPressed(sender)
        }
        
        if flashTimer != nil
        {
            flashTimer = nil
            textFieldBGView.backgroundColor = UIColor.whiteColor()
        }
        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: true)
    }
    
    @IBAction func backButtonPressed(sender: UIButton)
    {
        let previousTextFieldIndex = textFields.indexOf(shownTextField)! - 1
        self.cycleToTextField(previousTextFieldIndex)
        
        nextButton.setTitle("N E X T", forState: .Normal)
    }
    
    @IBAction func clearButtonPressed(sender: UIBarButtonItem?)
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
        contextPopover.trip = trip
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
        if PFUser.currentUser()?.username == nil
        {
            
            let alert = UIAlertController(title: "Login", message: "Please login to save your trip.", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default){ (action) in
                let loginViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(loginViewController, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        saveTrip(trip)
        switch loggedInWith
        {
            case "Twitter":
                settingsVC.processTwitterData()
            case "Facebook":
                settingsVC.processFacebookData()
            case "Username":
                settingsVC.processUsernameData()
            default:
                PFUser.logOut()
        }

    }

    
    //MARK: - Location
    
    func checkForLocation(textField: UITextField)
    {
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)

        dispatch_async(backgroundQueue) { () -> Void in
            if textField == self.destinationTextField
            {
                //DESTINATION
                
                if let term = self.destinationTextField.text
                {
                    self.mapsAPIController = MapsAPIController(delegate: self)
                    self.destinationTextField.tag = 60
                    self.mapsAPIController?.searchGMapsFor(term, textFieldTag: self.destinationTextField.tag)
                }
            }
            else if textField == self.departureLocationTextField
            {
                //ORIGIN
                
                if let term = self.departureLocationTextField.text
                {
                    self.mapsAPIController = MapsAPIController(delegate: self)
                    self.departureLocationTextField.tag = 61
                    self.mapsAPIController?.searchGMapsFor(term, textFieldTag: self.departureLocationTextField.tag)
                }
            }
        }

    }
    
    func didReceiveMapsAPIResults(results: NSDictionary, textFieldTag: Int)
    {
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        
        dispatch_async(backgroundQueue) { () -> Void in
            if let (lat, lng) = self.trip.tripCoordinateFromJSON(results)
            {
                switch textFieldTag
                {
                case self.destinationTextField.tag:
                    
                    self.trip = self.calculator.assignValue(self.trip, propertyAndValue: ["destinationLat" : lat])
                    self.trip = self.calculator.assignValue(self.trip, propertyAndValue: ["destinationLng" : lng])
                    
                    //                calculate(false, property: "destinationLat", value: lat)
                    //                calculate(false, property: "destinationLng", value: lng)
                    
                case self.departureLocationTextField.tag:
                    
                    self.trip = self.calculator.assignValue(self.trip, propertyAndValue: ["departureLat" : lat])
                    self.trip = self.calculator.assignValue(self.trip, propertyAndValue: ["departureLng" : lng])
                    
                    //                calculate(false, property: "departureLat", value: lat)
                    //                calculate(false, property: "departureLng", value: lng)
                    
                default: break
                }
            }
        }
        
        print("didReceiveMapsAPIResults")
    }
    
    // MARK: - Graph Functions
    
    func dateWasChosen(date: Moment?, textFieldTag: Int)
    {
        dismissContextPopover(CalendarPopoverViewController)
        
        if date != nil
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                let dateStr = date!.format("MM/dd/yy")
                
                switch textFieldTag
                {
                case self.dateFromTextField.tag:
                    if self.dateFromTextField.text == ""
                    {
                        self.dateFromTextField.text = dateStr
                        self.textFieldShouldReturn(self.dateFromTextField)
//                        self.dateFromTextField.tag = 1000
                    }
                    //            self.calculate(false, property: "Date From", value: dateStr)
                case self.dateToTextField.tag:
                    if self.dateToTextField.text == ""
                    {
                        self.dateToTextField.text   = dateStr
                        self.textFieldShouldReturn(self.dateToTextField)
//                        self.dateToTextField.tag = 1001
                    }
                    //            self.calculate(false, property: "Date To", value: dateStr)
                default: print("default error in dateWasChosen -- unknown textField: \(textFieldTag)")
                }
            }
        }
    }
    
    //MARK: - Pie Graph Legend
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
//    {
//        if indexPath.row == 1 && !dataSource.calculateFinished  { return 0 }
//        else if indexPath.row == 1                              { return 440 }
//        else if indexPath.row == 0 && !dataSource.tripCreated   { return 180 }
//        else                                                    { return 0 }
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return 2
//    }
    
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
        
        let lastBudget = trip.budgetRemaining
        
        trip = calculator.assignValue(trip, propertyAndValue: [property : value])
        
        if trip.budgetRemaining != lastBudget
        {
            budgetRemainingLabel.text = "$\(String(format: "%.2f", trip.budgetRemaining))"
            budgetRemainingLabel.slideVerticallyToOrigin(0.25, fromPointY: -100)
            budgetRemainingLabel.appearWithFade(0.25)
            
            budgetRemainingBottomLabel.appearWithFade(0.25)
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.dataSource.buildGraphAndLegend(self.trip, superview: self)
            }
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
        let prefixes = [
            "Whoa there.",
            "One sec.",
            "Hold up."
        ]
        prefixPromptLabel.text = prefixes[Int(arc4random() % UInt32(prefixes.count))]
        suffixPromptLabel.text = "Might have to plan a little smaller; looks like we're over budget."
        suffixPromptLabel.alpha = 0
        
        budgetRemainingLabel.textColor = UIColor.redColor()
        UIView.animateWithDuration(0.45, animations: { () -> Void in
            self.suffixPromptLabel.alpha = 1
            }, completion: { (_) -> Void in
                self.shownTextField.becomeFirstResponder()
                self.shownTextField.placeholder = self.shownTextField.text
                self.shownTextField.text = ""
        })
        
        flashTimer = NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "pulseTextField", userInfo: nil, repeats: true)
        pulseTextField()
    }
    
    func clear()
    {
        trip = Trip()
        
        dataSource.hideTextFieldsAndClearText(textFields, delegate: self)
        dataSource.calculateFinished = false
        dataSource.tripCreated = false
        
        dismissContextPopover(FlightPopoverViewController)
        dismissContextPopover(CalendarPopoverViewController)
        dismissContextPopover(EditValueViewController)
        
        propertyDictionary.removeAll()
        
        textFieldBGView.alpha = 1
        nextButton.setTitle("N E X T", forState: .Normal)
        
        if flashTimer != nil
        {
            flashTimer?.invalidate()
            flashTimer = nil
            textFieldBGView.backgroundColor = UIColor.whiteColor()
        }
        
        if pulseButtonTimer != nil
        {
            pulseButtonTimer?.invalidate()
            pulseButtonTimer = nil
            nextButton.backgroundColor = UIColor(red:0.45, green:0.8, blue:0.898, alpha:1)
        }
        
//        pieChartView.hideWithFade(0.25)
//        legendContainerView.hideWithFade(0.25)
//        promptLabel.hideWithFade(0.25)
//        
//        dataSource.hideButtons(buttons)
//        
//        if budgetRemainingLabel.alpha != 0
//        {
//            budgetRemainingLabel.hideWithFade(0.25)
//        }
        dataSource.initialSetup(self)
        
//        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
//        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        initialCycle()
        
        tableView.reloadData()
    }
    
    func saveTrip(trip: Trip)
    {
        if let user = PFUser.currentUser()?.username
        {
            trip.user = user
            trips.append(trip)
            trip.pinInBackground()
            trip.saveEventually()
            
            delegate?.tripWasSaved(trip)
        }
        else
        {
            //prompt to sign in
        }
    }
    
    func createTripComplete()
    {
        prefixPromptLabel.text = "Perfect."
        suffixPromptLabel.text = "Everything look good?"
        
//        budgetRemainingLabel.text = "Everything look good?"
//        budgetRemainingLabel.alpha = 0
//        budgetRemainingBottomLabel.alpha = 0
        dataSource.tripCreated = true
        
        nextButton.setTitle("S A V E  T R I P", forState: .Normal)
        nextButton.appearWithFade(0.5)
        nextButton.slideVerticallyToOrigin(0.5, fromPointY: nextButton.frame.size.height)
        
        dataSource.hideButtons(buttons)
        
        shownTextField.alpha = 0
        shownTextField.hidden = true
        textFieldBGView.alpha = 0
        
        if pulseButtonTimer != nil
        {
            pulseButtonTimer = nil
        }
        
        pulseButtonTimer = NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "pulseButton", userInfo: nil, repeats: true)
        pulseButton()
    }
    
    func pulseButton()
    {
        //david fix this
        if pulseButtonTimer != nil
        {
            let nextColor: UIColor = {
                if nextButton.tag == 999
                {
                    nextButton.tag = 998
                    return UIColor(red: 0.95, green: 0.71, blue: 0.31, alpha: 1)
                }
                else
                {
                    nextButton.tag = 999
                    return UIColor(red:0.45, green:0.8, blue:0.898, alpha:1)
                }
            }()
            
            UIView.animateWithDuration(1) { () -> Void in
                self.nextButton.backgroundColor = nextColor
            }
        }
    }
    
    // MARK: - Tap Gesture Recognizers
    
    func setupDismissTapGesture()
    {
        let tapOutsideTextField = UITapGestureRecognizer(target: self, action: "dismissKeyboardUponTouch")
        tapOutsideTextField.delegate = self
        
        tableView.addGestureRecognizer(tapOutsideTextField)
    }
    
    func dismissKeyboardUponTouch()
    {
        if shownTextField.isFirstResponder()
        {
            shownTextField.resignFirstResponder()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        let legendView = self.childViewControllers[0] as! GraphLegendTableViewController
        legendView.tableView.reloadData()
        
        let pointInView = touch.locationInView(legendView.tableView)
        if CGRectContainsPoint(legendView.tableView.frame, pointInView)
        {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if view.frame.size.height > 600
        {
            return view.frame.size.height - 96
        }
        else
        {
            return 600
        }
    }
    
    func addDoneButtonOnKeyboard(textField: UITextField!)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
//        doneToolbar.barStyle = .Black
        doneToolbar.barTintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:0.6)
        doneToolbar.translucent = false
        
        let confirmations = [
            "Okay",
            "All set",
            "Looks good"
        ]
        let confirmation = confirmations[Int(arc4random() % 3)]
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        flexSpace.tintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:1)
        let doneButton = UIBarButtonItem(title: confirmation, style: .Done, target: self, action: Selector("doneButtonAction"))
        doneButton.tintColor = UIColor.whiteColor()
        
        doneToolbar.items = [flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction()
    {
        textFieldShouldReturn(shownTextField)
    }
    
    func pulseTextField()
    {
        if flashTimer != nil
        {
            let nextColor: UIColor = {
            if textFieldBGView.tag == 2999
            {
                textFieldBGView.tag = 2998
                return UIColor(red: 0.95, green: 0.71, blue: 0.31, alpha: 1)
            }
            else
            {
                textFieldBGView.tag = 2999
                return UIColor.whiteColor()
            }
            }()
            
            UIView.animateWithDuration(1) { () -> Void in
                self.textFieldBGView.backgroundColor = nextColor
            }
        }
    }
}

