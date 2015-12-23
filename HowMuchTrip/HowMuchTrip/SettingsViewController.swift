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

class SettingsViewController: UIViewController
    
{
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var loginLogoutButton: UIButton!
    
    let aParseUser = ParseUser()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Settings"
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        //Make the users profile image circular instead of square
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        userImage.layer.borderColor = UIColor.blackColor().CGColor
        userImage.layer.borderWidth = 1
        
        //If the user is not nil, run the switch statement below to determine how they logged in
        if PFUser.currentUser() != nil
        {
            switch loggedInWith
            {
            case "Twitter":
                processTwitterData()
                loginLogoutButton.setTitle("Logout", forState: .Normal)
            case "Facebook":
                processFacebookData()
                loginLogoutButton.setTitle("Logout", forState: .Normal)
            case "Username":
                processUsernameData()
                loginLogoutButton.setTitle("Logout", forState: .Normal)
            default:
                PFUser.logOut()
                loginLogoutButton.setTitle("Login", forState: .Normal)
                userImage.image = UIImage(named: "GenericUserImage")
                userNameLabel.text = nil
            }
        }
        else
        {
            //If the user is nil, make sure to end the login session and clear out any data left behind
            PFUser.logOut()
            loginLogoutButton.setTitle("Login", forState: .Normal)
            userImage.image = UIImage(named: "GenericUserImage")
            userNameLabel.text = nil
        }
    }
    
    //Log the user in our out of the app
    @IBAction func logOutAction(sender: UIButton)
    {
        
        if PFUser.currentUser() == nil
        {
            //If the user is nil, set the title of the button to "Logout", and send the user to the login view, before leaving set the tab bar back to position 0 so after logging in the user is directed back to the main view of the app
            sender.setTitle("Logout", forState: .Normal)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(viewController, animated: true, completion: { () -> Void in
                    self.tabBarController?.selectedIndex = 0
                })
            })
            
        }
        else if PFUser.currentUser() != nil
        {
            // Send a request to log out a user
            sender.setTitle(("Login"), forState: .Normal)
            
            //Log the user out, set the name to nil, and set the generic image
            PFUser.logOutInBackgroundWithBlock() { (error: NSError?) -> Void in if error != nil { print("logout fail"); print(error) } else { print("logout success") } }
            userNameLabel.text = nil
            userImage.image = UIImage(named: "GenericUserImage")
        }
    }
    
    //This function will run if the user created a custom username and password and did not login with social media
    func processUsernameData()
    {
        if PFUser.currentUser() != nil
        {
            //Set the username the user creates to the username key in Parse
            let pUserName = PFUser.currentUser()!["username"] as! String
        
            //Set the nameLabel and image on the SettingsVC
            self.userNameLabel?.text = "@" + pUserName
            self.userImage?.image = UIImage(named: "GenericUserImage")
        }
    }
    
    //This function will run if the user signed in with their Facebook account
    func processFacebookData()
    {
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
            
            if(error != nil)
            {
                //Display the localized error and capitalize the first letter of the error string
                let description = error!.localizedDescription
                let first = description.startIndex
                let rest = first.advancedBy(1)..<description.endIndex
                let capitalized = description[first...first].uppercaseString + description[rest]

                //Create the AlertController
                let alert = UIAlertController(title: "Error", message: capitalized, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "OK", style: .Default) {(action) in
                }
                alert.addAction(confirmAction)
                self.presentViewController(alert, animated: true, completion: nil)
                }
            
            if(result != nil)
            {
                //Set the approrpriate keys in Parse for the information pulled from Facebook
                let userId:String = result["id"] as! String
                let userFirstName:String? = result["first_name"] as? String
                let userLastName:String? = result["last_name"] as? String
                let userEmail:String? = result["email"] as? String
                
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
                    //set the nameLabel to the user first and last name as taken from Facebook
                    self.userNameLabel?.text = "\(firstName) \(lastName)"
                }

                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    
                    let profilePictureUrl = NSURL(string: userProfile)
                    
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    self.userImage?.image = UIImage(data: profilePictureData!)
                    
                    if(profilePictureData != nil)
                    {
                        //Set the users profile picture from Facebook for the key in Parse
                        let profileFileObject = PFFile(data:profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "profile_picture")
                    }
                    
                    //Save the user data in Parse
                    myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if(success)
                        {
                            print("User details are now updated")
                        }
                        
                    })
                    
                })
                
            }

        }
    }
    
    //This function will run if the user signed in with their Twitter account
    func processTwitterData()
    {
        //Get username of currently logged in user
        let pfTwitter = PFTwitterUtils.twitter()
        let twitterUsername = pfTwitter?.screenName
        
        //Request Twitter API by appending users twitter username to the end of the url below
        var userDetailsUrl:String = "https://api.twitter.com/1.1/users/show.json?screen_name="
        userDetailsUrl = userDetailsUrl + twitterUsername!
        
        let myUrl = NSURL(string: userDetailsUrl)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "GET"
        
        //Request the Twitter API
        pfTwitter?.signRequest(request)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, error in
            
            if error != nil
            {
                //Display the localized error and capitalize the first letter of the error string
                let description = error!.localizedDescription
                let first = description.startIndex
                let rest = first.advancedBy(1)..<description.endIndex
                let capitalized = description[first...first].uppercaseString + description[rest]

                //Create the AlertController
                let alert = UIAlertController(title: "Alert", message: capitalized, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(confirmAction)
                self.presentViewController(alert, animated: true, completion: nil)
                
                //Log the user out if there was an error
                PFUser.logOut()
                return
                
            }
        do
            {
            
            //Parse the JSON returned from the Twitter API
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            
            if let parseJSON = json
            {
                //Get the value for the image key in Twitter JSON
                if let profileImageUrl = parseJSON["profile_image_url"] as? String
                {
                    //Request the high quality user profile image
                    let hiResProfileImageUrl = profileImageUrl.stringByReplacingOccurrencesOfString("_normal", withString: "")
                    let hiResProfilePictureUrl = NSURL(string: hiResProfileImageUrl)
                    let profilePictureData = NSData(contentsOfURL: hiResProfilePictureUrl!)
                    
                    if (profilePictureData != nil)
                    {
                        //Store the user image in Parse and set it as the image that is displayed in SettingsVC
                        let profileFileObject = PFFile(data: profilePictureData!)
                        PFUser.currentUser()?.setObject(profileFileObject!, forKey: "profile_picture")
                        self.userImage?.image = UIImage(data: profilePictureData!)
                    }
                    
                    //Set the Twitter user as the current user in Parse and store their Twitter username under the first name key in Parse
                    PFUser.currentUser()?.username = twitterUsername
                    PFUser.currentUser()?.setObject(twitterUsername!, forKey: "first_name")
                    PFUser.currentUser()?.setObject(" ", forKey: "last_name")
                    
                    //Set the username constant to the users twitter name and then display that in the userNameLabel on SettingsVC
                    if let username = PFUser.currentUser()?["first_name"] as? String
                    {
                        self.userNameLabel?.text = "@" + username
                    }
                }

                }
             })
            
        }
//        catch
//            {
//                print(error)
//            }
        
        }
         task.resume()
    }
    
}

