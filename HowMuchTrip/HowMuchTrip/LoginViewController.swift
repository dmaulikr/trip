//
//  LoginViewController.swift
//  HowMuchTrip
//
//  Created by Chris Stomp on 12/14/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse
import ParseTwitterUtils
import ParseFacebookUtilsV4
import FBSDKCoreKit

var name = ""
var loggedInWith = ""

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //usernameField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue){
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        print(textField)
        if textField == usernameField
        { // Switch focus to other text field
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField
        {
            resignFirstResponder()
        }
        return true
    }
    
    @IBAction func loginAction(sender: AnyObject)
    {
        
        loggedInWith = "Username"
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        // Validate the text fields
        if username?.characters.count < 5
        {
            
            let alert = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else if password?.characters.count < 8
        {
            
            let alert = UIAlertController(title: "Invalid", message: "Password must be greater than 7 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else
        {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil)
                {
//                    let alert = UIAlertController(title: "Success", message: "Logged In", preferredStyle: .Alert)
//                    let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                        self.dismissViewControllerAnimated(true, completion: nil)
//                    }
//                    alert.addAction(confirmAction)
//                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else
                {
                    
                    let alert = UIAlertController(title: "Error", message: "Username or Password is Invalid", preferredStyle: .Alert)
                    let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        self.usernameField.text = ""
                        self.passwordField.text = ""
                        self.usernameField.becomeFirstResponder()
                    
                    }
                    alert.addAction(confirmAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func loginWithTwitterTapped(sender: AnyObject)
    {
        loggedInWith = "Twitter"
        
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew
                {
                    let alert = UIAlertController(title: "Success", message: "Signed Up", preferredStyle: .Alert)
                    let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                        self.dismissViewControllerAnimated(true, completion: nil)
                        print("User signed up and logged in with Twitter!")
                    }
                    alert.addAction(confirmAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else
                {
//                    let alert = UIAlertController(title: "Success", message: "Logged In", preferredStyle: .Alert)
//                    let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        print("User logged in with Twitter!")
//                    }
//                    alert.addAction(confirmAction)
//                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else
            {
                print("The user cancelled the Twitter login.")
            }
        }
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject)
    {
        loggedInWith = "Facebook"
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew
                {
                    let alert = UIAlertController(title: "Success", message: "Signed Up", preferredStyle: .Alert)
                    let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                        self.dismissViewControllerAnimated(true, completion: nil)
                        print("User signed up and logged in through Facebook!")
                    }
                    alert.addAction(confirmAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                else
                {
//                    let alert = UIAlertController(title: "Success", message: "Logged In", preferredStyle: .Alert)
//                    let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                        self.dismissViewControllerAnimated(true, completion: nil)
                        print("User logged in with Facebook!")
//                    }
//                    alert.addAction(confirmAction)
//                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else
            {
                print("The user cancelled the Facebook login.")
            }
        }
    }
}