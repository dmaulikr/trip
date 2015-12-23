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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signUpAction(sender: UIButton)
    {
        loggedInWith = "Username"
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
        if username?.characters.count < 6
        {
            let alert = UIAlertController(title: "Invalid", message: "Username must be at least 6 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
        
        }
        else if password?.characters.count < 7
        {
            let alert = UIAlertController(title: "Invalid", message: "Password must be at least 7 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else if email?.characters.count < 5
        {
            
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
            
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil)
                {
                    let description = error!.localizedDescription
                    let first = description.startIndex
                    let rest = first.advancedBy(1)..<description.endIndex
                    let capitalized = description[first...first].uppercaseString + description[rest]
                    
                    // TODO: capitalize first letter of error sentence
                    let alert = UIAlertController(title: "Error", message: capitalized, preferredStyle: .Alert)
                    
                    let confirmAction = UIAlertAction(title: "OK", style: .Default) {(action) in
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
                    
                    let alert = UIAlertController(title: "Success", message: "Signed Up", preferredStyle: .Alert)
                    let confirmAction = UIAlertAction(title: "OK", style: .Default) {(action) in
                        
                        self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: {})
                    }
                    alert.addAction(confirmAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
}
