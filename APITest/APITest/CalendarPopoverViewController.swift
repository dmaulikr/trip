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
    func dateWasChosen(date: Moment)
}

class CalendarViewController: UIViewController, CalendarViewDelegate
{
    @IBOutlet weak var calendar: CalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var leftArrow: UIImageView!
    
    var delegate: DateWasChosenFromCalendarProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setCalendarSettings()
        calendar.delegate = self

        monthLabel.text = moment().monthName
        leftArrow.alpha = 0
        leftArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
    }
    
    func setCalendarSettings()
    {
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
        print(date.format("MMMM d, yyyy"))
        
//        delegate?.dateWasChosen(date)
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calendarDidPageToDate(date: Moment)
    {
        print(date.format("MMMM d, yyyy"))
        monthLabel.text = date.monthName
        if date.monthName == moment().monthName
        {
            leftArrow.disappearWithFade(0.25)
        }
        else
        {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.leftArrow.alpha = 1
            })
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView
{
    func appearWithFade(duration: Double)
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
//            self.alpha = 0
            UIView.animateWithDuration(duration) { () -> Void in
                self.alpha = 1
            }
        }
    }
    
    func disappearWithFade(duration: Double)
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.alpha = 1
            UIView.animateWithDuration(duration) { () -> Void in
                self.alpha = 0
            }
        }
    }
}
