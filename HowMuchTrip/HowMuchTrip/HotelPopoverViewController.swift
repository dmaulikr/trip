//
//  HotelPopoverViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/22/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class HotelPopoverViewController: UIViewController
{
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var trip: Trip!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ContextPopoverSetup.setup(confirmButton, cancelButton: cancelButton)
        
        let childVC = childViewControllers.first as! HotelPopoverTableViewController
        childVC.trip = self.trip
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
