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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ContextPopoverSetup.setup(confirmButton, cancelButton: cancelButton)
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

class ContextPopoverSetup
{
    class func setup(confirmButton: UIButton, cancelButton: UIButton)
    {
        confirmButton.alpha = 0
        
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
        
        let confirmation = confirmations[Int(arc4random() % 3)]
        let cancellation = cancellations[Int(arc4random() % 3)]
        
        confirmButton.setTitle(confirmation, forState: .Normal)
        cancelButton.setTitle(cancellation, forState: .Normal)
    }
}
