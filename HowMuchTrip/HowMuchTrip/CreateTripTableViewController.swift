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
import CoreLocation

/// Called when trip is successfully saved. Pops to the previous view controller and then pushes a detail page for the current trip on top of the navigation stack.
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
    UIGestureRecognizerDelegate,
    CLLocationManagerDelegate,
    FlightTicketPriceWasChosenProtocol,
    DropDownMenuOptionWasChosenProtocol
{
    
    // MARK: - Labels
    
    @IBOutlet weak var budgetRemainingLabel: UILabel!
    @IBOutlet weak var budgetRemainingBottomLabel: UILabel!
    
    @IBOutlet weak var prefixPromptLabel: UILabel!
    @IBOutlet weak var suffixPromptLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var flightButton: UIButton!
    
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
    @IBOutlet weak var locationSearchResultsContainerView: UIView!
    
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
    var googlePlacesAPIController: GooglePlacesAPIController?
    
    var locationManager: CLLocationManager? {
        willSet {
            UIApplication
                .sharedApplication()
                .networkActivityIndicatorVisible =
            !UIApplication
                .sharedApplication()
                .networkActivityIndicatorVisible
        }
    }
    var geocoder: CLGeocoder? {
        willSet {
            UIApplication
                .sharedApplication()
                .networkActivityIndicatorVisible =
            !UIApplication
                .sharedApplication()
                .networkActivityIndicatorVisible
        }
    }
    
    var flashTimer: NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        dataSource.initialSetup(self) //allProperties and textFields assigned here
        dataSource.hideTextFieldsAndClearText(textFields, delegate: self)
        
        dateFromTextField.tag = 80
        dateToTextField.tag = 81
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))

        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "initialCycle", userInfo: nil, repeats: false)
    }
    
    /// Performs the initial text field cycle and animation. This function is called when the view appears or when the clear button is pressed.
    func initialCycle()
    {
        cycleToTextField(0)
        textFieldBGView.alpha = 0
        textFieldBGView.appearWithFade(0.25)
    }
    
    /// Determines the current login information and processes it accordingly. If there is no login information, logs out of the current Parse session.
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
    
    /// Determines if the current input is valid. If so, dismisses the keyboard and scrolls the view to the bottom to prompt user to press the next button. If not, calls shakeTextField to inform user of incorrect or empty input.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        let (selectedTextField, indexOfTextField) = dataSource.getSelectedTextFieldAndIndex(textField, textFields: textFields)
        self.indexOfTextField = indexOfTextField
        
        if shownTextField.text != ""
        && shownTextField != dateFromTextField
        || shownTextField != dateToTextField
        {
            validTextFieldEntry(selectedTextField)
            
            return true
        }
        else if shownTextField == dateFromTextField
        || shownTextField == dateToTextField
        {
            print("date should return")
            if shownTextField.text == ""
            {
                print("date should return 2")
                validTextFieldEntry(selectedTextField)
            }
            else if Validator.validate("date", string: shownTextField.text!)
            {
                validTextFieldEntry(selectedTextField)
            }
            else
            {
                invalidTextFieldEntry()
            }
        }
        else
        {
            invalidTextFieldEntry()
        }
        
        return false
    }
    
    func validTextFieldEntry(selectedTextField: UITextField)
    {
        nextButton.enabled = true
        dataSource.appearButton(nextButton)
        selectedTextField.resignFirstResponder()
        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Bottom, animated: true)
        
        animateTextFieldBGSizeToDefault(nil)
    }
    
    func invalidTextFieldEntry()
    {
        shakeTextField(shownTextField)
        dataSource.fadeButton(nextButton)
        
        animateTextFieldBGSizeToDefault(nil)
    }
    
    /// Shakes the text field and text field background view to inform the user of incorrect or empty input.
    func shakeTextField(textField: UITextField)
    {
        let leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, -0.01)
        let rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, 0.01)
        
        textField.transform = leftWobble
        textFieldBGView.transform = leftWobble
//        contextButton.transform = leftWobble
        
        UIView.animateWithDuration(0.15, delay: 0,
            options: [.Repeat, .Autoreverse],
            animations: { () -> Void in
            UIView.setAnimationRepeatCount(1)
            textField.transform = rightWobble
            self.textFieldBGView.transform = rightWobble
//            self.contextButton.transform = rightWobble
                
            }) { (_) -> Void in
                textField.transform = CGAffineTransformIdentity
                self.textFieldBGView.transform = CGAffineTransformIdentity
//                self.contextButton.transform = CGAffineTransformIdentity
        }
    }
    
    /// Determines the index of the current text field. Disables the next button if there is no input or enables it if there is input.
    func textFieldDidEndEditing(textField: UITextField)
    {
        let (_, indexOfTextField) = dataSource.getSelectedTextFieldAndIndex(textField, textFields: textFields)
        self.indexOfTextField = indexOfTextField
        
        if shownTextField.text != "" && textField != dateFromTextField || textField != dateToTextField
        {
            nextButton.enabled = true
            dataSource.appearButton(nextButton)
        }
        else if textField == dateFromTextField || textField == dateToTextField
        {
            nextButton.enabled = true
            dataSource.appearButton(nextButton)
        }
        else
        {
            nextButton.enabled = false
            dataSource.fadeButton(nextButton)
        }
    }
    
    /// Disables and fades the next button when the user begins entering their value. When the return button is pressed, this operation is reversed.
    func textFieldDidBeginEditing(textField: UITextField)
    {
        nextButton.enabled = false
        dataSource.fadeButton(nextButton)
    }
    
    func animateTextFieldBGSizeToDefault(textField: UITextField?)
    {
        locationSearchResultsContainerView.hideWithFade(0.10)
        if textFieldBGView.frame.size.height != 40
        {
            UIView.animateWithDuration(0.25) { () -> Void in
                self.textFieldBGView.frame = CGRectMake(
                    self.textFieldBGView.frame.origin.x,
                    self.textFieldBGView.frame.origin.y,
                    self.textFieldBGView.frame.size.width,
                    40)
            }
        }
        
        //function was called from the drop down menu
        if textField != nil
        {
            textFieldShouldReturn(textField!)
        }
    }
    
    func animateTextFieldBGSizeToSearch()
    {
        if textFieldBGView.frame.size.height != 240
        {
            let newFrame = CGRectMake(
                self.textFieldBGView.frame.origin.x,
                self.textFieldBGView.frame.origin.y,
                self.textFieldBGView.frame.size.width,
                240)
                self.locationSearchResultsContainerView.alpha = 0
                self.locationSearchResultsContainerView.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.textFieldBGView.frame = newFrame
                }, completion: { (_) -> Void in
                    
                    self.locationSearchResultsContainerView.appearWithFade(0.10)
            })
        }
    }
    
    /// Checks the keyboard type and adds a done button to the keyboard if there is no built in return key on the current keyboard type.
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        addDoneButtonOnKeyboard(self.shownTextField)
        return true
    }
    
    /// Presents an interactive calendar popup to allow the user to choose their trip dates.
    func presentCalendar(textFieldTag: Int)
    {
        let contextPopStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
        let contextPopover = contextPopStoryboard.instantiateViewControllerWithIdentifier("calendarView") as! CalendarPopoverViewController
        self.addContextPopover(contextPopover)
        contextPopover.delegate = self
        contextPopover.textFieldTag = textFieldTag
        contextPopover.trip = trip
        
        self.contextPopover = contextPopover
        nextButton.enabled = true//textField.text?.characters.count > 0
    }
    
    /// Limts the user input to the appropriate characters in order to reduce error.
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField.text?.characters.count >= 1
        {
            if shownTextField.text == "" && textFieldBGView.frame.size.height != 40
            {
                animateTextFieldBGSizeToDefault(nil)
            }
            else if shownTextField.text != ""
                && textField == departureLocationTextField
                || textField == destinationTextField
            {
                searchForLocation(textField)
            }
            else if shownTextField.text != ""
                && textField == budgetTextField
                || textField == dailyLodgingTextField
                || textField == dailyFoodTextField
                || textField == dailyOtherTextField
                || textField == oneTimeCostTextField
            {
                searchForCost(textField)
            }
        }

        return dataSource.testCharacters(textField, string: string, superview: self)
    }
    
    func searchForLocation(textField: UITextField)
    {
        if Reachability.isConnectedToNetwork()
        {
            animateTextFieldBGSizeToSearch()
            
            for childVC in self.childViewControllers
            {
                if let locationSearchTableVC = childVC as? LocationSearchTableViewController
                {
                    locationSearchTableVC.delegate = self
                    locationSearchTableVC.textField = textField
                    locationSearchTableVC.searchForLocation()
                }
            }

        }
    }
    
    func searchForCost(textField: UITextField)
    {
        animateTextFieldBGSizeToSearch()
        
        for childVC in self.childViewControllers
        {
            if let locationSearchTableVC = childVC as? LocationSearchTableViewController
            {
                locationSearchTableVC.delegate = self
                locationSearchTableVC.textField = textField
                locationSearchTableVC.searchForCost()
            }
        }
    }
    
    /// Determines the current textfield and cycles to the next one. Handles the cycling animation and assigns the prompt text. Presents the calendar if the appropriate text field is currently displayed. Also determines if the user has cycled through all available text fields and calls the createTripComplete function in this event.
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
                self.shownTextField.layer.zPosition =
                    self.textFieldBGView.layer.zPosition + 1
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
    }
    
    
    // MARK: - Action Handlers
    
    /// Called when the next button is pressed. Starts the calculation with the current value from the shown textfield and the corresponding property. Scrolls back to the top of the view for ease of use for the user and to prepare them to enter in the next value.
    @IBAction func nextButtonPressed(sender: UIButton)
    {
        animateTextFieldBGSizeToDefault(shownTextField)
        
        if !dataSource.tripCreated
        {
            switch shownTextField
            {
            case tripNameTextField: nextButton.setTitle("S A V E  T R I P", forState: .Normal)
            case dateToTextField: textFieldShouldReturn(dateToTextField)
            case dateFromTextField: textFieldShouldReturn(dateFromTextField)
            default: break
            }
            
//            textFieldShouldReturn(shownTextField)
            print(indexOfTextField, allProperties.count)
            let propertyKey = allProperties[indexOfTextField]
            propertyDictionary[propertyKey] = shownTextField.text
            
            checkForLocation(shownTextField)
            
            let property = allProperties[indexOfTextField]
            
            print(property)
            
            calculate(true, property: property, value: shownTextField.text!)
            
            UIView.animateWithDuration(0.50, animations: { () -> Void in
                self.textFieldBGView.hideWithFade(0.5)
                }, completion: { (_) -> Void in
                    self.textFieldBGView.appearWithFade(0.5)
            })
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
    
    /// Called when the back button is pressed. Determines the current shown step and cycles one step back.
    @IBAction func backButtonPressed(sender: UIButton)
    {
        let previousTextFieldIndex = textFields.indexOf(shownTextField)! - 1
        animateTextFieldBGSizeToDefault(nil)
        self.cycleToTextField(previousTextFieldIndex)
        
        nextButton.setTitle("N E X T", forState: .Normal)
    }
    
    /// Called when the clear button is pressed. Clears all current values and restores the view to the initial start state.
    @IBAction func clearButtonPressed(sender: UIBarButtonItem?)
    {
        clear()
    }
    
    /// Called when the context button is pressed while in the location button state. Configures the location manager and requests permission to use location services; if this request is granted, the location search will start automatically.
    @IBAction func locationButtonPressed(sender: UIButton)
    {
        shownTextField.resignFirstResponder()
        animateTextFieldBGSizeToDefault(nil)
        configureLocationManager()
    }
    
    /// Called when the context button is pressed while in the flight button state. If trip dates have been chosen, presents a pop up to allow the user to search for ticket prices. If trip dates have not been chosen, presents an error popup to inform the user of this issue and prompts them to enter a date range.
    @IBAction func flightButtonPressed(sender: UIButton)
    {
        shownTextField.resignFirstResponder()
        animateTextFieldBGSizeToDefault(nil)
        if trip.dateFrom != ""
        {
            let flightStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
            let contextPopover = flightStoryboard.instantiateViewControllerWithIdentifier("FlightPopover") as! FlightPopoverViewController
            contextPopover.trip = trip
            contextPopover.delegate = self
            self.addContextPopover(contextPopover)
        }
        else
        {
            presentErrorPopup("Please go back and specify a date range if you'd like to look up flights! :)")
        }
    }
    
    /// Called when the context button is pressed while in the hotel button state. This function has not been implemented.
    @IBAction func hotelButtonPressed(sender: UIButton)
    {
//        let contextStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
//        let contextPopover = contextStoryboard.instantiateViewControllerWithIdentifier("HotelPopover") as! HotelPopoverViewController
//        contextPopover.trip = trip
//        self.addContextPopover(contextPopover)
    }
    
    /// Called when the next button is pressed while in its save button state. If there is no current Parse user, promps user to login to save their trip and modally presents the login screen. If there is a current Parse user, saves the trip to the user's trip list.
    @IBAction func saveButtonPressed(sender: UIButton!)
    {
        if PFUser.currentUser()?.username == nil
        {
            presentLoginPopup()
        }
        else
        {
            saveTrip(trip)
        }
        
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

    /// Function called when next button is pressed. Passes in a textfield; if the textfield is the destination or departure location text field, starts a google maps api call to find the lat and lng of the location.
    func checkForLocation(textField: UITextField)
    {
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        
        if textField == destinationTextField || textField == departureLocationTextField
        {
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
    }
    
    /// Function called when the google maps api finished its search. If the search was successful, assigns the found lat and lng to their respective values in the current trip object.
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
    
    
    // MARK: - Context Popover Delegate Functions
    
    /// Date was chosen from calendar popup, dismisses calendar and fills dateFrom or dateTo textField with chosen date
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
                    }
                case self.dateToTextField.tag:
                    if self.dateToTextField.text == ""
                    {
                        self.dateToTextField.text   = dateStr
                        self.textFieldShouldReturn(self.dateToTextField)
                    }
                default: print("default error in dateWasChosen -- unknown textField: \(textFieldTag)")
                }
            }
        }
        else
        {
            switch textFieldTag
            {
            case dateFromTextField.tag:
                dateFromTextField.becomeFirstResponder()
                dateFromTextField.text = ""
                textFieldShouldReturn(dateFromTextField)
            case dateToTextField.tag:
                dateToTextField.becomeFirstResponder()
                dateToTextField.text = ""
                textFieldShouldReturn(dateToTextField)
            default: print("default error in dateWasChosen -- unknown textField: \(textFieldTag)")
            }
        }
    }
    
    /// Ticket price was chosen from flight popup, dismisses flight popup and fills planeTicketTextField with chosen price
    func flightTicketPriceWasChosen(price: String)
    {
        dismissContextPopover(FlightPopoverViewController)
        planeTicketTextField.becomeFirstResponder()
        if price != ""
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.planeTicketTextField.text = price
                self.textFieldShouldReturn(self.planeTicketTextField)
            })
        }
    }
    
    
    // MARK: - Private Functions
    
    /**
    Assigns the chosen value with the corresponding trip property, builds the pie chart and legend, and performs the necessary animations.
    If 'cycle' is set to true, 'calculationFinished' will be called.
    **/
    func calculate(cycle: Bool, property: String, value: String)
    {
        calculator = {
            if cycle {
                return Calculator(delegate: self)
            }
            return Calculator(delegate: nil)
            }()
        
        let lastBudget = trip.budgetRemaining
        
        trip = calculator.assignValue(trip, propertyAndValue: [property : value])
        
        if trip.budgetRemaining != lastBudget
        {
            budgetRemainingLabel.text = trip.budgetRemaining.formatAsUSCurrency()
            budgetRemainingLabel.slideVerticallyToOrigin(0.25, fromPointY: -100)
            budgetRemainingLabel.appearWithFade(0.25)
            
            budgetRemainingBottomLabel.appearWithFade(0.25)
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.dataSource.buildGraphAndLegend(self.trip, superview: self)
            }
        }
    }
    
    /// Function called when the trip calculator is finished assigning trip values. 'didGoOverBudget' is called here if the trip budget remaining falls below 0.
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
    }
    
    /// Function called when the trip budget remaining falls below 0. Handles the UI response to inform the user of this event.
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
        
//        flashTimer = NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "pulseTextField", userInfo: nil, repeats: true)
//        pulseTextField()
    }
    
    /// Function called when user presses the right navigation bar 'Clear' button. Clears out all current values and resets the view to the initial starting state.
    func clear()
    {
        trip = Trip()
        
        dataSource.hideTextFieldsAndClearText(textFields, delegate: self)
        dataSource.calculateFinished = false
        dataSource.tripCreated = false
        
        dismissContextPopover(FlightPopoverViewController)
        dismissContextPopover(CalendarPopoverViewController)
        dismissContextPopover(EditValueViewController)
        
        animateTextFieldBGSizeToDefault(nil)
        
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
        
        dataSource.initialSetup(self)
        
        initialCycle()
        
        tableView.reloadData()
    }
    
    /// Function called when the save trip button is pressed and there is a valid current user. Saves the current trip to Parse.
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
    }
    
    /// Function called when all trip values have been assigned (or skipped). Handles the UI response to inform the user of this event, including changing the next button to the save button.
    func createTripComplete()
    {
        prefixPromptLabel.text = "Perfect."
        suffixPromptLabel.text = "Everything look good?"
        
        prefixPromptLabel.appearWithFade(0.25)
        suffixPromptLabel.appearWithFade(0.25)
        
        dataSource.tripCreated = true
        
        dataSource.hideButtons(buttons)
        
        nextButton.setTitle("S A V E  T R I P", forState: .Normal)
        nextButton.appearWithFade(0.5)
        nextButton.slideVerticallyToOrigin(0.5, fromPointY: nextButton.frame.size.height)
        
        shownTextField.alpha = 0
        shownTextField.hidden = true
        textFieldBGView.alpha = 0
        
        if pulseButtonTimer != nil
        {
            pulseButtonTimer = nil
        }
        
        pulseButton()
        pulseButtonTimer = NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "pulseButton", userInfo: nil, repeats: true)
        
        shownTextField.resignFirstResponder()
    }
    
    /// Pulses the save button orange and blue to inform user of completion and to encourage pressing
    func pulseButton()
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
        
        UIView.animateWithDuration(1, delay: 0, options: [.AllowUserInteraction], animations: { () -> Void in
            self.nextButton.backgroundColor = nextColor
            }, completion: nil)
    }
    
    // MARK: - Tap Gesture Recognizers
    
    /// Adds a tap gesture to the view that dismisses the keyboard upon touch.
    func setupDismissTapGesture()
    {
        let tapOutsideTextField = UITapGestureRecognizer(target: self, action: "dismissKeyboardUponTouch")
        tapOutsideTextField.delegate = self
        tapOutsideTextField.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapOutsideTextField)
    }
    
    /// Function that is called when the above tap gesture is invoked. Dismisses the current text fields keyboard.
    func dismissKeyboardUponTouch()
    {
        if shownTextField.isFirstResponder()
        {
            shownTextField.resignFirstResponder()
        }
    }
    
    /// Removes the pie chart legend from participation above tap gesture recognizer, as the pie chart legend has its own touch events to handle trip value editing and the dismiss event would otherwise interfere
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
    
    // MARK: - Misc UI
    
    /// Returns a static 580 for height unless the view can be larger than 580; in that case, returns the current view height. (affordance for taller/larger screens.)
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if view.frame.size.height > 580
        {
            return view.frame.size.height - 96
        }
        else
        {
            return 580
        }
    }
    
    /// Adds a return button to the top of number pad keyboard.
    func addDoneButtonOnKeyboard(textField: UITextField!)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
//        doneToolbar.barStyle = .Black
        doneToolbar.barTintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:0.6)
        doneToolbar.translucent = false
        
        let confirmations = [
            "Okay  ",
            "All set  ",
            "Looks good  "
        ]
        
        let cancellations = [
            "  Never mind",
            "  Just kidding",
            "  Forget it"
        ]
        
        let confirmation = confirmations[Int(arc4random() % 3)]
        let cancellation = cancellations[Int(arc4random() % 3)]
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        flexSpace.tintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:1)
        let doneButton = UIBarButtonItem(title: confirmation, style: .Done, target: self, action: Selector("doneButtonAction"))
        let dismissButton = UIBarButtonItem(title: cancellation, style: .Plain, target: self, action: Selector("dismissButtonAction"))
        doneButton.tintColor = UIColor.whiteColor()
        dismissButton.tintColor = UIColor.whiteColor()
        
        doneToolbar.items = [dismissButton, flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    /// Handles the above return button press. Dismisses the current text fields keyboard.
    func doneButtonAction()
    {
        textFieldShouldReturn(shownTextField)
        animateTextFieldBGSizeToDefault(nil)
//        shownTextField.resignFirstResponder()
        nextButtonPressed(nextButton)
    }
    
    func dismissButtonAction()
    {
        shownTextField.resignFirstResponder()
        animateTextFieldBGSizeToDefault(nil)
    }
    
    // MARK: - Location Manager
    
    /// Function called when location button is pressed. Prompts user for permission to use location services in order to determine departure location. Presents an error popup if there is no current network connection.
    func configureLocationManager()
    {
        if CLLocationManager.authorizationStatus() != .Denied
        && CLLocationManager.authorizationStatus() != .Restricted
        && Reachability.isConnectedToNetwork()
        {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            
            if CLLocationManager.authorizationStatus() == .NotDetermined
            {
                locationManager?.requestWhenInUseAuthorization()
            }
            
            locationManager?.startUpdatingLocation()
        }
        else if !Reachability.isConnectedToNetwork()
        {
            presentErrorPopup("Couldn't access an active network connection. Please try again later. Sorry about that!")
        }
    }

    /// Presents an error popup if the location manager fails to find location.
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError)
    {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        presentErrorPopup("Something went wrong while trying to find your location. Please try again later. Sorry about that!")
    }
    
    /// Function called when location manager successfully finds user location. Fills in the departure location text field with the user's current location, or presents an error popup if the location manager errors during this step.
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            geocoder = CLGeocoder()
            geocoder?.reverseGeocodeLocation(location,
                completionHandler: { (placemarks, error) -> Void in
                    if error == nil
                    {
                        self.locationManager?.stopUpdatingLocation()
                        self.locationManager = nil
                        
                        let locality: String! = placemarks!.first!.locality
                        let country: String! = placemarks!.first!.country
                        let state: String! = placemarks!.first!.administrativeArea
                        
                        self.departureLocationTextField.text =
                        "\(locality), \(state), \(country)"
                        self.textFieldShouldReturn(self.departureLocationTextField)
                        
                        UIApplication
                            .sharedApplication()
                            .networkActivityIndicatorVisible = false
                    }
                    else
                    {
                        self.locationManager?.stopUpdatingLocation()
                        self.locationManager = nil
                        
                        print(error?.localizedDescription)
                        self.presentErrorPopup("Something went wrong while trying to find your location. Please try again later. Sorry about that!")
                    }
            })
        }
        else
        {
            self.locationManager?.stopUpdatingLocation()
            self.locationManager = nil
            
            presentErrorPopup("Something went wrong while trying to find your location. Please try again later. Sorry about that!")
        }
    }
}

