//
//  ToPopoverViewController.swift
//  APITest
//
//  Created by david on 12/14/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit

class ToPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let popover = segue.destinationViewController as? CalendarViewController
        {
            popover.popoverPresentationController?.delegate = self
            let width = self.view.frame.width
            popover.preferredContentSize = CGSizeMake(width, width)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
