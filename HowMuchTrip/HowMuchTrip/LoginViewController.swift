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
/// Global variable that helps identify how a user is logged in
var loggedInWith = ""

class LoginViewController: UIViewController, UITextFieldDelegate, ResetRequestWasSentProtocol
{
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        usernameField.becomeFirstResponder()
        usernameField.layer.zPosition = 1
        passwordField.layer.zPosition = 1
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    
    // MARK: - UITextField Delegate
    
    /// If user presses return in the usernameField, cursor will move to the passwordField, then resign if return is tapped again
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        print(textField)
        if textField == usernameField
        {
            // Switch focus to other text field
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField
        {
            resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Action Handlers
    
    /// If the X button is tapped on ResetPasswordVC or SignUpVC the user will return to LoginVC
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue)
    {
    }
    
    /// Dismisses the login screen if you choose not to login
    @IBAction func dismissLoginTapped(sender: UIButton)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// Handles logic when "Login" is tapped
    @IBAction func loginAction(sender: AnyObject)
    {
        /// Global variable that identifies how a user is logged in
        loggedInWith = "Username"
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        // Validate the text fields
        if username?.characters.count < 5
        {
            // Verify that the username meets the minimum length requirements
            let alert = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else if password?.characters.count < 8
        {
            // Verify that the password meets the minimum length requirements
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
                    // If user is not nil, dismiss the view and return to the app
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else
                {
                    // If user is nil, create an alert controller that displays an error message
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
    
    // MARK: - Twitter Login Functions
    
    /// Log user in with Twitter
    @IBAction func loginWithTwitterTapped(sender: AnyObject)
    {
        // Global variable that identifies how the user is logged in
        loggedInWith = "Twitter"
        
        // Logs user into parse with their Twitter ID
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew
                {
                    // If the user is a new entry, create an AlertController letting them know they were successfully signed up
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
                        // If user was previously signed up, dismiss the loginVC
                        self.dismissViewControllerAnimated(true, completion: nil)
                        print("User logged in with Twitter!")
                }
            }
            else
            {
                // The login was cancelled by the user before it was completed
                print("The user cancelled the Twitter login.")
            }
        }
    }
    
    // MARK: - Facebook Login Functions
    
    /// Log the user in with Facebook
    @IBAction func loginWithFacebook(sender: AnyObject)
    {
        /// Global variable that identifies how the user logged in
        loggedInWith = "Facebook"
        
        /// Logs user into parse with their Facebook ID
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew
                {
                    // If the user is a new entry, create an AlertController letting them know they were successfully signed up
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
                    // If user was previously signed up, dismiss the loginVC
                    self.dismissViewControllerAnimated(true, completion: nil)
                    print("User logged in with Facebook!")
                }
            }
            else
            {
                // The login was cancelled by the user before it was completed
                print("The user cancelled the Facebook login.")
            }
        }
    }
    
    // MARK: - Navigation
    
    /// Segues to the password reset view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let resetPasswordVC = segue.destinationViewController as? ResetPasswordViewController
        {
            resetPasswordVC.delegate = self
        }
    }
    
    /// Dismisses the view controller when the password reset request is sent
    func resetRequestWasSent()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}