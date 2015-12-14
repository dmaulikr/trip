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

var firstRun = true

protocol DateWasChosenFromCalendarProtocol
{
    func dateWasChosen(date: Moment, textFieldTag: Int)
}

class CalendarPopoverViewController: UIViewController, CalendarViewDelegate
{
    @IBOutlet weak var calendar: CalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var leftArrow: UIImageView!
    
    var textFieldTag: Int!
    
    var delegate: DateWasChosenFromCalendarProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if firstRun
        {
            
        }
        
        self.preferredContentSize = CGSizeMake(400, 400)
        setCalendarPrefs()

        monthLabel.text = ("\(moment().monthName), \(moment().year)")
        leftArrow.alpha = 0
        leftArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
    }
    
    func setCalendarPrefs()
    {
        calendar.delegate = self
        calendar.selectedDayOnPaged = nil
        
        CalendarView.daySelectedBackgroundColor = UIColor(red:0.011, green:0.694, blue:0.921, alpha:1)
        CalendarView.daySelectedTextColor = UIColor.whiteColor()
        CalendarView.todayBackgroundColor = UIColor(white: 0.0, alpha: 0.3)
        CalendarView.todayTextColor = UIColor.whiteColor()
        CalendarView.otherMonthBackgroundColor = UIColor.clearColor()
        CalendarView.otherMonthTextColor = UIColor(white: 1.0, alpha: 0.3)
        CalendarView.dayTextColor = UIColor(white: 1.0, alpha: 0.6)
        CalendarView.dayBackgroundColor = UIColor.clearColor()
        CalendarView.weekLabelTextColor = UIColor(white: 1.0, alpha: 0.3)
    }
    
    func calendarDidSelectDate(date: Moment)
    {
        delegate?.dateWasChosen(date, textFieldTag: textFieldTag)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calendarDidPageToDate(date: Moment)
    {
        monthLabel.hideWithFade(0.1)
        monthLabel.text = ("\(date.monthName), \(date.year)")
        UIView.animateWithDuration(0.1) { () -> Void in
            self.monthLabel.alpha = 1
        }
        
        if date.monthName == moment().monthName && date.year == moment().year
        {
            leftArrow.hideWithFade(0.25)
        }
        else if leftArrow.alpha == 0
        {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.leftArrow.alpha = 0.5
            })
        }
    }
}
