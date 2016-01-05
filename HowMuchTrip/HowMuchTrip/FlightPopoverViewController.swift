//
//  FlightPopoverViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/21/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class FlightPopoverViewController: UIViewController
{
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    
    var trip: Trip!
    var delegate: FlightTicketPriceWasChosenProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ContextPopoverSetup.setup(confirmButton, cancelButton: cancelButton)
        
        let childViewController = childViewControllers.first as! FlightPopoverTableViewController
        childViewController.trip = trip
        childViewController.delegate = delegate
        
        activityView.hidden = true
    }
    
    func showActivityView()
    {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.activityView.alpha = 0.6
        }
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton)
    {
        //delegate.priceWasChosen
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton)
    {
        if let parentVC = parentViewController as? CreateTripTableViewController
        {
            parentVC.dismissContextPopover(FlightPopoverViewController)
        }
        else if let parentVC = parentViewController as? TripDetailViewController
        {
            parentVC.dismissContextPopover(FlightPopoverViewController)
        }
    }
}
