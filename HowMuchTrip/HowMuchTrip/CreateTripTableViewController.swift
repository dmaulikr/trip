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
    UIGestureRecognizerDelegate,
    FlightTicketPriceWasChosenProtocol
{
    
    // MARK: - Labels
    
    @IBOutlet weak var budgetRemainingLabel         : UILabel!
    @IBOutlet weak var budgetRemainingBottomLabel   : UILabel!
    
    @IBOutlet weak var prefixPromptLabel            : UILabel!
    @IBOutlet weak var suffixPromptLabel            : UILabel!
    
    @IBOutlet weak var nextButton                   : UIButton!
    @IBOutlet weak var backButton                   : UIButton!
    
    @IBOutlet weak var locationButton               : UIButton!
    @IBOutlet weak var flightButton                 : UIButton!
    @IBOutlet weak var calendarButton               : UIButton!
    
    var buttons                                     = [UIButton!]()
    
    // MARK: - Text Fields
    
    @IBOutlet weak var budgetTextField              : UITextField!
    @IBOutlet weak var departureLocationTextField   : UITextField!
    @IBOutlet weak var destinationTextField         : UITextField!
    @IBOutlet weak var dateFromTextField            : UITextField!
    @IBOutlet weak var dateToTextField              : UITextField!
    @IBOutlet weak var planeTicketTextField         : UITextField!
    @IBOutlet weak var dailyLodgingTextField        : UITextField!
    @IBOutlet weak var dailyFoodTextField           : UITextField!
    @IBOutlet weak var dailyOtherTextField          : UITextField!
    @IBOutlet weak var oneTimeCostTextField         : UITextField!
    @IBOutlet weak var tripNameTextField            : UITextField!
    
    @IBOutlet weak var textFieldBGView              : UIView!
    
    var shownTextField  : UITextField!
    var textFields      = [UITextField]()
    
    // MARK: - Graph Properties
    
    @IBOutlet weak var pieChartView                         : PieChartView!
    @IBOutlet weak var legendContainerView                  : UIView!
    @IBOutlet weak var locationSearchResultsContainerView   : UIView!
    
    var contextPopover      : UIViewController?
    
    // MARK: - Other Properties
    
    var dataSource              : CreateTripDataSource!
    var animator                : CreateTripTableViewControllerAnimationManager!
    var locationManagerManager  : CreateTripTableViewControllerLocationManager!
    var popoverManager          : CreateTripTableViewControllerContextPopoverManager!
    
    var delegate            : TripWasSavedDelegate?
    
    var indexOfTextField = 0
    
    var allProperties       = [String]()
    var propertyDictionary  = [String: String]()
    var calculator          : Calculator!
    
    var trip                = Trip()
    var trips               = [Trip]()
    
    var mapsAPIController: MapsAPIController?
    var googlePlacesAPIController: GooglePlacesAPIController?
    
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
    
    var pulseButtonTimer: NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        animator                = CreateTripTableViewControllerAnimationManager(controller: self)
        locationManagerManager  = CreateTripTableViewControllerLocationManager(controller: self)
        dataSource              = CreateTripDataSource(controller: self)
        popoverManager          = CreateTripTableViewControllerContextPopoverManager(controller: self)
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "initialCycle", userInfo: nil, repeats: false)
    }
    
    /// Performs the initial text field cycle and animation. This function is called when the view appears or when the clear button is pressed.
    func initialCycle()
    {
        cycleToTextField(0)
    }
    
    /// Determines the current login information and processes it accordingly. If there is no login information, logs out of the current Parse session.
    override func viewWillAppear(animated: Bool)
    {
        let settingsVC = SettingsViewController()
        
        //(tabBarController!.viewControllers![2] as! UINavigationController).viewControllers.first as! SettingsViewController
        
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
        
        let entry: Bool = {
            return shownTextField.text != ""
        }()
        
        if entry
        && shownTextField != dateFromTextField
        || shownTextField != dateToTextField
        {
            validTextFieldEntry(selectedTextField)
            
            return true
        }
            
        else if shownTextField == dateFromTextField
        ||      shownTextField == dateToTextField
        {
            if !entry
            {
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
        animator.appearButton(nextButton)
        selectedTextField.resignFirstResponder()
        
//        let index = NSIndexPath(forRow: 0, inSection: 0)
//        tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Bottom, animated: true)
        
        animator.animateTextFieldBGSizeToDefault(nil)
    }
    
    func invalidTextFieldEntry()
    {
        shakeTextField(shownTextField)
        animator.fadeButton(nextButton)
        
        animator.animateTextFieldBGSizeToDefault(nil)
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
            animator.appearButton(nextButton)
        }
        else if textField == dateFromTextField || textField == dateToTextField
        {
            nextButton.enabled = true
            animator.appearButton(nextButton)
        }
        else
        {
            nextButton.enabled = false
            animator.fadeButton(nextButton)
        }
    }
    
    /// Disables and fades the next button when the user begins entering their value. When the return button is pressed, this operation is reversed.
    func textFieldDidBeginEditing(textField: UITextField)
    {
        nextButton.enabled = false
        animator.fadeButton(nextButton)
    }
    

    
    /// Checks the keyboard type and adds a done button to the keyboard if there is no built in return key on the current keyboard type.
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        addDoneButtonOnKeyboard(self.shownTextField)
        return true
    }
    
    /// Limts the user input to the appropriate characters in order to reduce error.
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField.text?.characters.count >= 1
        {
            if shownTextField.text == "" && textFieldBGView.frame.size.height != 40
            {
                animator.animateTextFieldBGSizeToDefault(nil)
            }
            else if shownTextField.text != ""
            {
                animator.dropDownMenu(textField)?.search()
            }
        }

        return dataSource.testCharacters(textField, string: string)
    }
    
    /// Determines the current textfield and cycles to the next one. Handles the cycling animation and assigns the prompt text. Presents the calendar if the appropriate text field is currently displayed. Also determines if the user has cycled through all available text fields and calls the createTripComplete function in this event.
    func cycleToTextField(indexOfTextField: Int)
    {
        if indexOfTextField < textFields.count
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.shownTextField.hidden = true
                
                let nextTextField = self.textFields[indexOfTextField]
                
                self.shownTextField = nextTextField
                
                let (prefix, suffix) = self.dataSource.getPromptLabelText(indexOfTextField, aTrip: self.trip)
                
                self.prefixPromptLabel.text = prefix
                self.suffixPromptLabel.text = suffix
                
                self.dataSource.manageButtons()
                
                self.animator.doCycleToTextFieldAnimation()
            })
        }
        else
        {
            print("create trip complete")
            createTripComplete()
        }
    }
    
    func cycleToTextFieldAnimationDidComplete()
    {
        switch shownTextField
        {
        case dateFromTextField:
            popoverManager.presentCalendarPopover(dateFromTextField.tag)
        case dateToTextField:
            popoverManager.presentCalendarPopover(dateToTextField.tag)
        default:
            shownTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - Action Handlers
    
    /// Called when the next button is pressed. Starts the calculation with the current value from the shown textfield and the corresponding property. Scrolls back to the top of the view for ease of use for the user and to prepare them to enter in the next value.
    @IBAction func nextButtonPressed(sender: UIButton)
    {
        animator.animateTextFieldBGSizeToDefault(nil)
        
        if !dataSource.tripCreated
        {
            switch shownTextField
            {
            case tripNameTextField: nextButton.setTitle("S A V E  T R I P", forState: .Normal)
            case dateToTextField: textFieldShouldReturn(dateToTextField)
            case dateFromTextField: textFieldShouldReturn(dateFromTextField)
            default: break
            }
            
            let propertyKey = allProperties[indexOfTextField]
            propertyDictionary[propertyKey] = shownTextField.text
            
            locationManagerManager.checkForLocation(shownTextField)
            
            let property = allProperties[indexOfTextField]
            
            calculate(true, property: property, value: shownTextField.text!)
        }
        else ///cycled through all the text fields, save button is shown
        {
            saveButtonPressed(sender)
        }
        
//        let index = NSIndexPath(forRow: 0, inSection: 0)
//        tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: true)
    }
    
    /// Called when the back button is pressed. Determines the current shown step and cycles one step back.
    @IBAction func backButtonPressed(sender: UIButton)
    {
        let previousTextFieldIndex = textFields.indexOf(shownTextField)! - 1
        animator.animateTextFieldBGSizeToDefault(nil)
        self.cycleToTextField(previousTextFieldIndex)
        
        animator.invalidatePulseButtonTimer()
        
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
        animator.animateTextFieldBGSizeToDefault(nil)
        locationManagerManager.configureLocationManager()
    }
    
    /// Called when the context button is pressed while in the flight button state. If trip dates have been chosen, presents a pop up to allow the user to search for ticket prices. If trip dates have not been chosen, presents an error popup to inform the user of this issue and prompts them to enter a date range.
    @IBAction func flightButtonPressed(sender: UIButton)
    {
        popoverManager.presentFlightPopover()
    }
    
    @IBAction func calendarButtonPressed(sender: UIButton)
    {
        popoverManager.presentCalendarPopover(shownTextField.tag)
    }
    
    /// Called when the context button is pressed while in the hotel button state. This function has not been implemented.
    @IBAction func hotelButtonPressed(sender: UIButton)
    {
        
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
        
        processLoginData()
    }
    
    // MARK: - Context Popover Delegate Functions
    
    /// Date was chosen from calendar popup, dismisses calendar and fills dateFrom or dateTo textField with chosen date
    func dateWasChosen(date: Moment?, textFieldTag: Int)
    {
//        dismissContextPopover(CalendarPopoverViewController)
        dismissViewControllerAnimated(true, completion: nil)
        view.removeDimmedOverlayView()
        view.removeDimmedOverlayView()
        
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
    
    func locationManagerManagerDidFindLocation(locationString: String)
    {
        departureLocationTextField.text = locationString
        textFieldShouldReturn(departureLocationTextField)
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
                self.dataSource.buildGraphAndLegend()
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
        suffixPromptLabel.text = "Might have to plan a little smaller; looks like we're over budget. Let's enter a cost that's in budget, or you can edit your budget using the pie chart legend."
        suffixPromptLabel.alpha = 0
        
        budgetRemainingLabel.textColor = UIColor.redColor()
        UIView.animateWithDuration(0.45, animations: { () -> Void in
            self.suffixPromptLabel.alpha = 1
            }, completion: { (_) -> Void in
                self.shownTextField.becomeFirstResponder()
                self.shownTextField.placeholder = self.shownTextField.text
                self.shownTextField.text = ""
        })
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
        
        animator.animateTextFieldBGSizeToDefault(nil)
        
        propertyDictionary.removeAll()
        
        textFieldBGView.alpha = 1
        nextButton.setTitle("N E X T", forState: .Normal)
        
        animator.invalidatePulseButtonTimer()
        
        dataSource.initialSetup()
        
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
        nextButton.setTitle("S A V E  T R I P", forState: .Normal)
        
        animator.doTripCompletedAnimation()
        
        dataSource.tripCreated = true
        
        dataSource.hideButtons(buttons)
        
        shownTextField.resignFirstResponder()
        
        pulseButton()
        if pulseButtonTimer != nil
        {
            pulseButtonTimer = nil
        }
        pulseButtonTimer = NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "pulseButton", userInfo: nil, repeats: true)
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
        return 580
    }
    
    /// Adds a return button to the top of number pad keyboard.
    func addDoneButtonOnKeyboard(textField: UITextField!)
    {
        if textField.keyboardType == .NumberPad
        {
            
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
            //        doneToolbar.barStyle = .Black
            doneToolbar.barTintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:0.6)
            doneToolbar.translucent = false
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            flexSpace.tintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:1)
            let doneButton = UIBarButtonItem(title: "Next", style: .Done, target: self, action: Selector("doneButtonAction"))
            let dismissButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("dismissButtonAction"))
            doneButton.tintColor = UIColor.whiteColor()
            dismissButton.tintColor = UIColor.whiteColor()
            
            doneToolbar.items = [dismissButton, flexSpace, doneButton]
            doneToolbar.sizeToFit()
            
            textField.inputAccessoryView = doneToolbar
        }
    }
    
    /// Handles the above return button press. Dismisses the current text fields keyboard.
    func doneButtonAction()
    {
        textFieldShouldReturn(shownTextField)
        animator.animateTextFieldBGSizeToDefault(nil)
//        shownTextField.resignFirstResponder()
        nextButtonPressed(nextButton)
    }
    
    func dismissButtonAction()
    {
        shownTextField.resignFirstResponder()
        animator.animateTextFieldBGSizeToDefault(nil)
    }
    
    func processLoginData()
    {
        let settingsVC = (tabBarController!.viewControllers![2] as! UINavigationController).viewControllers.first as! SettingsViewController
        
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
}