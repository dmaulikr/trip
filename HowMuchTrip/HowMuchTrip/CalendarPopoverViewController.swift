//
//  CalendarViewController.swift
//  APITest
//
//  Created by david on 12/14/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit
import CalendarView
import SwiftMoment

protocol DateWasChosenFromCalendarProtocol
{
    func dateWasChosen(date: Moment?, textFieldTag: Int)
}

class CalendarPopoverViewController: UIViewController, CalendarViewDelegate
{
    @IBOutlet weak var calendar: CalendarView!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var leftArrow: UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var textFieldTag: Int!
    var selectedDate: Moment!
    var trip: Trip!
    
    var delegate: DateWasChosenFromCalendarProtocol?
    
    let confirmations = [
        "Okay",
        "All set",
        "Looks good"
    ]
    
    let cancellations = [
        "Never mind",
        "Just kidding",
        "Forget it"
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        confirmButton.alpha = 0
        
        setCalendarPrefs()

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.leftArrow.alpha = 0
            self.leftArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        }
        
        let confirmation = confirmations[Int(arc4random() % 3)]
        let cancellation = cancellations[Int(arc4random() % 3)]
        
        confirmButton.setTitle(confirmation, forState: .Normal)
        cancelButton.setTitle(cancellation, forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.monthLabel.text = ("\(moment().monthName) \(moment().year)")
        }
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton)
    {
        delegate?.dateWasChosen(selectedDate, textFieldTag: textFieldTag)
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton)
    {
        delegate?.dateWasChosen(nil, textFieldTag: textFieldTag)
    }
    
    func calendarDidSelectDate(date: Moment)
    {
        if date.intervalSince(moment()).days < 0
        {
            confirmButton.hideWithFade(0.25)
            parentViewController?.presentErrorPopup("Looks like you're trying to pick a date ealier than the current date. We won't be implementing time travel functionality until version 2.0. Sorry about that! :)")
        }
        else
        {
            if let departure = moment(trip.dateFrom, dateFormat: "MM/d/yy")
            {
                if date.intervalSince(departure).days < 0
                {
                    confirmButton.hideWithFade(0.25)
                    parentViewController?.presentErrorPopup("Looks like you're trying to choose a return date that's earlier than your departure date. We won't be implementing time travel functionality until version 2.0. Sorry about that! :)")
                }
                else
                {
                    validEntry(date)
                }
            }
            else
            {
                validEntry(date)
            }
        }
    }
    
    func validEntry(date: Moment)
    {
        selectedDate = date
        confirmButton.appearWithFade(0.25)
    }
    
    func setCalendarPrefs()
    {
        calendar.delegate = self
        calendar.selectedDayOnPaged = nil
        
        CalendarView.daySelectedBackgroundColor = UIColor.whiteColor()
        CalendarView.daySelectedTextColor = UIColor(red:0.028, green:0.275, blue:0.36, alpha: 1)

        CalendarView.todayBackgroundColor = UIColor(white: 0.0, alpha: 0.3)
        CalendarView.todayTextColor = UIColor.whiteColor()
        CalendarView.otherMonthBackgroundColor = UIColor.clearColor()
        CalendarView.otherMonthTextColor = UIColor(white: 1.0, alpha: 0.3)
        CalendarView.dayTextColor = UIColor(white: 1.0, alpha: 0.6)
        CalendarView.dayBackgroundColor = UIColor.clearColor()
        CalendarView.weekLabelTextColor = UIColor(white: 1.0, alpha: 0.3)

    }
    
    func calendarDidPageToDate(date: Moment)
    {
        monthLabel.hideWithFade(0.1)
        monthLabel.text = ("\(date.monthName) \(date.year)")
        monthLabel.hidden = false
        UIView.animateWithDuration(0.1) { () -> Void in
            self.monthLabel.alpha = 1
        }
        
        if date.monthName == moment().monthName && date.year == moment().year
        {
            leftArrow.hideWithFade(0.25)
        }
        else if leftArrow.alpha == 0
        {
            leftArrow.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.leftArrow.alpha = 0.5
            })
        }
    }
}
