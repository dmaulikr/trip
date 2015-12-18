//
//  ResetPasswordViewController.swift
//  HowMuchTrip
//
//  Created by Chris Stomp on 12/14/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func passwordReset(sender: AnyObject) {
        let email = self.emailField.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let validator = Validator()
        if validator.validate("email", string: finalEmail)
        {
            //send reset email
            // Send a request to reset a password
            PFUser.requestPasswordResetForEmailInBackground(finalEmail)
            
            let alert = UIAlertController (title: "Password Reset", message: "An email containing information on how to reset your password has been sent to " + finalEmail + ".", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            //invalid email
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default) {(action) in
                self.emailField.text = ""
                self.emailField.becomeFirstResponder()
            }
            
                
            alert.addAction(confirmAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
}
