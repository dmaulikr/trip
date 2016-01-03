//
//  ResetPasswordViewController.swift
//  HowMuchTrip
//
//  Created by Chris Stomp on 12/14/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

protocol ResetRequestWasSentProtocol
{
    func resetRequestWasSent()
}

/// Resets password for email/username accounts
class ResetPasswordViewController: UIViewController
{
    @IBOutlet weak var emailField: UITextField!
    
    var delegate: ResetRequestWasSentProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        emailField.becomeFirstResponder()
    }
    
    // Resets the users password via email
    @IBAction func passwordReset(sender: AnyObject)
    {
        // Remove any whitespaces added to the beginning or end of an email entry
        let email: String = {
            if let email = emailField.text
            {
                return email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            else
            {
                return ""
            }
        }()
        
        // Validates that the entered email is in the correct format
        if Validator.validate("email", string: email)
        {
            //Send a request to reset a password
            PFUser.requestPasswordResetForEmailInBackground(email)
            
            //Create AlertController to let the user know that an email to reset password has been sent
            let alert = UIAlertController (title: "Password Reset", message: "An email containing information on how to reset your password has been sent to " + email + ".", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (_) -> Void in
                self.delegate?.resetRequestWasSent()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            //invalid email AlertController
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "Okay", style: .Default) {(action) in
                self.emailField.text = ""
                self.emailField.placeholder = "Email Address"
                self.emailField.becomeFirstResponder()
            }
            alert.addAction(confirmAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
}
