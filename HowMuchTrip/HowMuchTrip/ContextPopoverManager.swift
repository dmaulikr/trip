//
//  ContextPopoverManager.swift
//  HowMuchTrip
//
//  Created by david on 1/6/16.
//  Copyright © 2016 HowMuchTrip. All rights reserved.
//

import Foundation
import UIKit

class CreateTripTableViewControllerContextPopoverManager
{
    var controller: CreateTripTableViewController!
    
    init(controller: CreateTripTableViewController)
    {
        self.controller = controller
    }
    
    func presentFlightPopover()
    {
        controller.shownTextField.resignFirstResponder()
        controller.animator.animateTextFieldBGSizeToDefault(nil)
        if controller.trip.dateFrom != ""
        {
            let flightStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
            let contextPopover = flightStoryboard.instantiateViewControllerWithIdentifier("FlightPopover") as! FlightPopoverViewController
            contextPopover.trip = controller.trip
            contextPopover.delegate = controller
            controller.addContextPopover(contextPopover)
        }
        else
        {
            controller.presentErrorPopup("Please go back and specify a date range if you'd like to look up flights! :)")
        }
    }
    
    /// Presents an interactive calendar popup to allow the user to choose their trip dates.
    func presentCalendarPopover(textFieldTag: Int)
    {
        controller.animator.animateTextFieldBGSizeToDefault(nil)
        
        let contextPopStoryboard = UIStoryboard(name: "ContextPopovers", bundle: nil)
        let contextPopover = contextPopStoryboard.instantiateViewControllerWithIdentifier("calendarView") as! CalendarPopoverViewController
        contextPopover.modalPresentationStyle = .OverFullScreen
        
        //self.addContextPopover(contextPopover)
        contextPopover.delegate = controller
        contextPopover.textFieldTag = textFieldTag
        contextPopover.trip = controller.trip
        
        controller.contextPopover = contextPopover
        controller.nextButton.enabled = true//textField.text?.characters.count > 0
        
        controller.view.addDimmedOverlayView()
        
        controller.navigationController?.presentViewController(contextPopover, animated: true, completion: nil)
    }
}