//
//  LoginViewController.swift
//  HowMuchTrip
//
//  Created by Chris Stomp on 12/14/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        // Validate the text fields
        if username?.characters.count < 5 {
            
            let alert = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
            
        } else if password?.characters.count < 8 {
            
            let alert = UIAlertController(title: "Invalid", message: "Password must be greater than 7 characters", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(confirmAction)
            presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    
                    let alert = UIAlertController(title: "Success", message: "Logged In", preferredStyle: .Alert)
                    let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SuggestedTrips") as! SuggestedTripsTableViewController
                            //self.presentViewController(storyboard, animated: true, completion: nil)
                        })

                    }
                    alert.addAction(confirmAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    
                }
                else
                {
                    
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(confirmAction)
                   self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
}