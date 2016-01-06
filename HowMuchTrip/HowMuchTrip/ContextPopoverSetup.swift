//
//  ContextPopoverSetup.swift
//  HowMuchTrip
//
//  Created by david on 12/22/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

/// Class  used to create a standard context popover used during the CreateTrip process
class ContextPopoverSetup
{
    class func setup(confirmButton: UIButton, cancelButton: UIButton)
    {
        confirmButton.alpha = 0
        
//        /// Options to confirm context popover selection
//        let confirmations = [
//            "Okay",
//            "All set",
//            "Looks good"
//        ]
//        
//        /// Options to cancel context popover selection
//        let cancellations = [
//            "Never mind",
//            "Just kidding",
//            "Forget it"
//        ]
//        
//        let confirmation = confirmations[Int(arc4random() % 3)]
//        let cancellation = cancellations[Int(arc4random() % 3)]
        
        confirmButton.setTitle("Next", forState: .Normal)
        cancelButton.setTitle("Cancel", forState: .Normal)
    }
}