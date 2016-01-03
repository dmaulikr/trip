//
//  SignUpViewController.swift
//  HowMuchTrip
//
//  Created by Chris Stomp on 12/14/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController
{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        usernameField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //Signs the user up if they dont already have an account
    @IBAction func signUpAction(sender: UIButton)
    {
        //Global variable that identifies how the user logged in
        loggedInWith = "Username"
        let username = self.usernameField.text
        let password = self.passwordField.text
        
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
        
        //Eliminates any white spaces on the beginning or end of email entered
        
        // Validate the text fields
        if username?.characters.count < 6
        {
            //Verify that the username meets the minimum length requirements
            let alert = UIAlertController(title: "Invalid", message: "Username must be at least 6 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
        
        }
        else if password?.characters.count < 7
        {
            //Verify that the password meets the minimum length requirements
            let alert = UIAlertController(title: "Invalid", message: "Password must be at least 7 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else if email.characters.count < 5 && Validator.validate("email", string: email) //addition
        {
            //Verify that the email meets the minimum length requirements
            let alert = UIAlertController(title: "Invalid", message: "Please enter a valid email address", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else
        {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            //Create new entries in Parse for the user
            newUser.username = username
            newUser.password = password
            newUser.email = email
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil)
                {
                    //Display the localized error and capitalize the first letter of the error string
                    let description = error!.localizedDescription
                    let first = description.startIndex
                    let rest = first.advancedBy(1)..<description.endIndex
                    let capitalized = description[first...first].uppercaseString + description[rest]
                    
                    //Create the AlertController
                    let alert = UIAlertController(title: "Error", message: capitalized, preferredStyle: .Alert)
                    
                    let confirmAction = UIAlertAction(title: "Okay", style: .Default) {(action) in
                        self.emailField.text = ""
                        self.usernameField.text = ""
                        self.passwordField.text = ""
                        print("error")
                    }
                    alert.addAction(confirmAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                else
                {
                    //Create AlertController to notify the user they have successfully signed up
                    let alert = UIAlertController(title: "Success", message: "Signed up and logged in.", preferredStyle: .Alert)
                    let confirmAction = UIAlertAction(title: "Okay", style: .Default) {(action) in
                        
                        //Dismiss the previous two VCs on the stack
                        self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: {})
                    }
                    alert.addAction(confirmAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
}
