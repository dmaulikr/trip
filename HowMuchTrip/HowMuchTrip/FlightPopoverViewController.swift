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
    
    var trip: Trip!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ContextPopoverSetup.setup(confirmButton, cancelButton: cancelButton)
        
        let childViewController = childViewControllers.first as! FlightPopoverTableViewController
        childViewController.trip = trip
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
