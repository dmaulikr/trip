//
//  CreateTripTableViewControllerAnimationManager.swift
//  HowMuchTrip
//
//  Created by david on 1/6/16.
//  Copyright © 2016 HowMuchTrip. All rights reserved.
//

import UIKit

class CreateTripTableViewControllerAnimationManager: DropDownMenuOptionWasChosenProtocol
{
    var controller: CreateTripTableViewController!
    var pulseButtonTimer: NSTimer?
    
    init(controller: CreateTripTableViewController)
    {
        self.controller = controller
    }
    
    func dropDownMenu(textField: UITextField) -> LocationSearchTableViewController?
    {
        for childViewController in controller.childViewControllers
        {
            if let locationSearchTableViewController = childViewController as? LocationSearchTableViewController
            {
                locationSearchTableViewController.parent = controller
                locationSearchTableViewController.delegate = self
                locationSearchTableViewController.textField = textField
                return locationSearchTableViewController
            }
        }
        return nil
    }
    
    func animateTextFieldBGSizeToDefault(textField: UITextField?)
    {
        controller.locationSearchResultsContainerView.hideWithFade(0.10)
        if controller.textFieldBGView.frame.size.height != 40
        {
            UIView.animateWithDuration(0.25) { () -> Void in
                self.controller.textFieldBGView.frame = CGRectMake(
                    self.controller.textFieldBGView.frame.origin.x,
                    self.controller.textFieldBGView.frame.origin.y,
                    self.controller.textFieldBGView.frame.size.width,
                    40)
            }
        }
        
        //function was called from the drop down menu
        if textField != nil
        {
            controller.textFieldShouldReturn(textField!)
        }
    }
    
    func animateTextFieldBGSizeToSearch()
    {
        if controller.textFieldBGView.frame.size.height != 240
        {
            let newFrame = CGRectMake(
                controller.textFieldBGView.frame.origin.x,
                controller.textFieldBGView.frame.origin.y,
                controller.textFieldBGView.frame.size.width,
                240)
            controller.locationSearchResultsContainerView.alpha = 0
            controller.locationSearchResultsContainerView.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.controller.textFieldBGView.frame = newFrame
                }, completion: { (_) -> Void in
                    
                    self.controller.locationSearchResultsContainerView.appearWithFade(0.10)
            })
        }
    }
    
    func shakeButton(button: UIButton!)
    {
        
        let leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, -0.05)
        let rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, 0.05)
        
        button.transform = leftWobble
        
        UIView.animateWithDuration(0.15, delay: 0,
            options: [.Repeat, .Autoreverse],
            animations: { () -> Void in
                UIView.setAnimationRepeatCount(3)
                button.transform = rightWobble
                
            }) { (_) -> Void in
                button.transform = CGAffineTransformIdentity
        }
    }
    
    func fadeButton(button: UIButton)
    {
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            button.backgroundColor = UIColor(red:0.45, green:0.8, blue:0.898, alpha:0.3)
            }) { (_) -> Void in
        }
    }
    
    func appearButton(button: UIButton)
    {
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            button.backgroundColor = UIColor(red:0.45, green:0.8, blue:0.898, alpha:1)
            }) { (_) -> Void in
        }
    }
    
    func doCycleToTextFieldAnimation()
    {
        fadeButton(controller.nextButton)
        
        controller.shownTextField.hidden = false
        let originalY = controller.shownTextField.frame.origin.y
        controller.shownTextField.hidden = false
        controller.shownTextField.layer.zPosition =
            controller.textFieldBGView.layer.zPosition + 1
        controller.shownTextField.alpha = 0
        controller.shownTextField.text = ""
        
        controller.shownTextField.frame.origin.y = 100
        controller.textFieldBGView.frame.origin.y = 100
        
        controller.prefixPromptLabel.alpha = 0
        controller.suffixPromptLabel.alpha = 0
        
        controller.textFieldBGView.alpha = 0.4
        
        UIView.animateWithDuration(0.45, animations: { () -> Void in
            
            self.controller.shownTextField.frame.origin.y = originalY
            self.controller.shownTextField.alpha = 1
            
            self.controller.prefixPromptLabel.alpha = 1
            self.controller.suffixPromptLabel.alpha = 1
            
            self.controller.textFieldBGView.alpha = 1
            
            }, completion: { (_) -> Void in
                self.controller.cycleToTextFieldAnimationDidComplete()
        })
    }
    
    func doTripCompletedAnimation()
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.controller.prefixPromptLabel.appearWithFade(0.25)
            self.controller.suffixPromptLabel.appearWithFade(0.25)
            
            self.controller.nextButton.appearWithFade(0.5)
            self.controller.nextButton.slideVerticallyToOrigin(0.5, fromPointY: self.controller.nextButton.frame.size.height)
            
            self.controller.shownTextField.alpha = 0
            self.controller.shownTextField.hidden = true
            self.controller.textFieldBGView.alpha = 0
        }
    }
    
    func invalidatePulseButtonTimer()
    {
        if controller.pulseButtonTimer != nil
        {
            controller.pulseButtonTimer?.invalidate()
            controller.pulseButtonTimer = nil
            controller.nextButton.backgroundColor = UIColor(red:0.45, green:0.8, blue:0.898, alpha:1)
        }
    }
}
