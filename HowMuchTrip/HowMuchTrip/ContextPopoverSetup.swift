//
//  ContextPopoverSetup.swift
//  HowMuchTrip
//
//  Created by david on 12/22/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

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