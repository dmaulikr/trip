//
//  SettingsViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import ParseTwitterUtils
// TODO: Remove emails for security
//emails for project:
//howmuchtrip@gmail.com
//support@howmuchtrip.com
//feedback@howmuchtrip.com
//Password for all: tiyios2015(edited)

class SettingsViewController: UIViewController
{
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Settings"
        
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        userImage.layer.borderColor = UIColor.blackColor().CGColor
        userImage.layer.borderWidth = 1

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        checkForUser()
        
        switch loggedInWith
        {
        case "Twitter":
            processTwitterData()
        case "Facebook":
            processFacebookData()
        case "Username":
            processUsernameData()
        default:
            userNameLabel.text = "Unknown User"
            userImage.image = UIImage(named: "GenericUserImage")
            
        }
    }
    
    @IBAction func logOutAction(sender: UIButton)
    {
        // Send a request to log out a user
        PFUser.logOut()
        userNameLabel.text = nil
        userImage.image = nil
        

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
            self.presentViewController(viewController, animated: true, completion: { () -> Void in
                self.tabBarController?.selectedIndex = 0
            })
        })
        
    }
    
    func processUsernameData()
    {
        let pUserName = PFUser.currentUser()?["username"] as? String
        
            self.userNameLabel.text = "@" + pUserName!
            self.userImage.image = UIImage(named: "GenericUserImage")
    }
    
    func processFacebookData()
    {
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
            
            if(error != nil)
            {
                let description = error!.localizedDescription
                let first = description.startIndex
                let rest = first.advancedBy(1)..<description.endIndex
                let capitalized = description[first...first].uppercaseString + description[rest]

                let alert = UIAlertController(title: "Error", message: capitalized, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "OK", style: .Default) {(action) in
                }
                alert.addAction(confirmAction)
                self.presentViewController(alert, animated: true, completion: nil)
                }
            
            if(result != nil)
            {
//                let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//                spinningActivity.labelText = "Loading"
//                spinningActivity.detailsLabelText = "Please wait"
                
                let userId:String = result["id"] as! String
                let userFirstName:String? = result["first_name"] as? String
                let userLastName:String? = result["last_name"] as? String
                let userEmail:String? = result["email"] as? String
                
                
                print("\(userEmail)")
                
                let myUser:PFUser = PFUser.currentUser()!
                
                // Save first name
                if(userFirstName != nil)
                {
                    myUser.setObject(userFirstName!, forKey: "first_name")
                    
                }
                
                //Save last name
                if(userLastName != nil)
                {
                    myUser.setObject(userLastName!, forKey: "last_name")
                }
                
                // Save email address
                if(userEmail != nil)
                {
                    myUser.setObject(userEmail!, forKey: "email")
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                if let firstName = PFUser.currentUser()?["first_name"] as? String, let lastName = PFUser.currentUser()?["last_name"] as? String
                {
                    self.userNameLabel?.text = "\(firstName) \(lastName)"
                }

               // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    
                    let profilePictureUrl = NSURL(string: userProfile)
                    
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    self.userImage?.image = UIImage(data: profilePictureData!)
                    
                    if(profilePictureData != nil)
                    {
                        let profileFileObject = PFFile(data:profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "profile_picture")
                    }
                    
                    
                    myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if(success)
                        {
//                            spinningActivity.hide(true)
                            print("User details are now updated")
                        }
                        
                    })
                    
                })
                
            }

        }
    }
    
    
    
    func processTwitterData()
    {
        
        let pfTwitter = PFTwitterUtils.twitter()
        let twitterUsername = pfTwitter?.screenName
        
//        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//            spinningActivity.labelText = "Loading"
//            spinningActivity.detailsLabelText = "Please wait"

        var userDetailsUrl:String = "https://api.twitter.com/1.1/users/show.json?screen_name="
        userDetailsUrl = userDetailsUrl + twitterUsername!
        
        let myUrl = NSURL(string: userDetailsUrl)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "GET"
        
        pfTwitter?.signRequest(request)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, error in
            
            if error != nil
            {
                //self.hideLoadingHUD()
                let description = error!.localizedDescription
                let first = description.startIndex
                let rest = first.advancedBy(1)..<description.endIndex
                let capitalized = description[first...first].uppercaseString + description[rest]

                
                let alert = UIAlertController(title: "Alert", message: capitalized, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(confirmAction)
                self.presentViewController(alert, animated: true, completion: nil)
                PFUser.logOut()
                return
                
            }
            
            
        do
            {
            //self.hideLoadingHUD()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            
            if let parseJSON = json
            {
                if let profileImageUrl = parseJSON["profile_image_url"] as? String
                {
                    let hiResProfileImageUrl = profileImageUrl.stringByReplacingOccurrencesOfString("_normal", withString: "")
                    let hiResProfilePictureUrl = NSURL(string: hiResProfileImageUrl)
                    let profilePictureData = NSData(contentsOfURL: hiResProfilePictureUrl!)
                    
                    if (profilePictureData != nil)
                    {
                        let profileFileObject = PFFile(data: profilePictureData!)
                        PFUser.currentUser()?.setObject(profileFileObject!, forKey: "profile_picture")
                        self.userImage?.image = UIImage(data: profilePictureData!)
                    }
                    
                    PFUser.currentUser()?.username = twitterUsername
                    PFUser.currentUser()?.setObject(twitterUsername!, forKey: "first_name")
                    PFUser.currentUser()?.setObject(" ", forKey: "last_name")
                    
                    if let username = PFUser.currentUser()?["first_name"] as? String
                    {
//                        spinningActivity.hide(true)
                        self.userNameLabel?.text = "@" + username
                    }
                }

                }
             })
            
        }
        catch
            {
                print(error)
            }
        
        }
         task.resume()
    }
    
    
    func checkForUser()
    {
        if (PFUser.currentUser() == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }
        //Above will redirect the user to the login screen if a user is not currently logged in.
    }
    
    func showLoadingHUD()
    {
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.labelText = "Loading"
        spinningActivity.detailsLabelText = "Please wait"
    }
    
    func hideLoadingHUD()
    {
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.hide(true)
    }
}

