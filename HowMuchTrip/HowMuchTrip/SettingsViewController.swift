//
//  SettingsViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController
{
//    @IBOutlet weak var userNameLabel: UILabel!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        title = "Settings"
//        if let pUserName = PFUser.currentUser()?["username"] as? String
//        {
//            self.userNameLabel.text = "@" + pUserName
//        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            })
            
            //Above will redirect the user to the login screen if a user is not currently logged in.
        }
    }
    
    @IBAction func logOutAction(sender: UIButton)
    {
        // Send a request to log out a user
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
            self.presentViewController(viewController, animated: true, completion: { () -> Void in
                self.tabBarController?.selectedIndex = 0
            })
        })
    }
}
