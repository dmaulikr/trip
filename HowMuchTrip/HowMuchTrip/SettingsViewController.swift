//
//  SettingsViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Parse
import ParseTwitterUtils

class SettingsViewController: UIViewController
    
{
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameCheckbox: UIImageView!
    @IBOutlet weak var facebookCheckbox: UIImageView!
    @IBOutlet weak var twitterCheckbox: UIImageView!
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Settings"
        setNavBarAttributes()
    }
    
    func setNavBarAttributes()
    {
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir-Light", size: 20)!
        ]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Avenir-Light", size: 20)!
            ], forState: .Normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Avenir-Light", size: 20)!
            ], forState: .Highlighted)
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
//        userImage.layer.borderWidth = 0.4
        
        //If the user is not nil, run the switch statement below to determine how they logged in
        if PFUser.currentUser() != nil
        {
            navigationItem.rightBarButtonItem?.title = "Logout"
            
            switch loggedInWith
            {
            case "Twitter":
                processTwitterData()
                twitterCheckbox.image = UIImage(named: "CheckBox_selected")
            case "Facebook":
                processFacebookData()
                facebookCheckbox.image = UIImage(named: "CheckBox_selected")
            case "Username":
                processUsernameData()
                usernameCheckbox.image = UIImage(named: "CheckBox_selected")
            default:
                PFUser.logOut()
                userImage.image = UIImage(named: "UserIcon")
                navigationItem.rightBarButtonItem?.title = "Login"
                userNameLabel.text = nil
                usernameCheckbox.image = UIImage(named: "CheckBox_unselected")
                facebookCheckbox.image = UIImage(named: "CheckBox_unselected")
                twitterCheckbox.image = UIImage(named: "CheckBox_unselected")
            }
        }
        else
        {
            //If the user is nil, make sure to end the login session and clear out any data left behind
            PFUser.logOut()
            userImage.image = UIImage(named: "UserIcon")
            userNameLabel.text = nil
            navigationItem.rightBarButtonItem?.title = "Login"
        }
    }
    
    // MARK: - Action Handlers
    
    @IBAction func pressedNavButtonRight(sender: UIBarButtonItem) //Create an IBAction
    {
        if PFUser.currentUser() == nil
        {
            //setting the button title here was unncecessary because viewWillAppear will get called when the login view controller is dismissed, and the button title will get set during viewWillAppear
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(viewController, animated: true, completion: { () -> Void in
                    self.tabBarController?.selectedIndex = 1
                })
            })

        }
        else if PFUser.currentUser() != nil
        {
            //Log the user out, set the name to nil, and set the generic image
            usernameCheckbox.image = UIImage(named: "CheckBox_unselected")
            twitterCheckbox.image = UIImage(named: "CheckBox_unselected")
            facebookCheckbox.image = UIImage(named: "CheckBox_unselected")
            PFUser.logOutInBackgroundWithBlock() { (error: NSError?) -> Void in
                if error != nil
                {
                    print("logout fail");
                    print(error)
                    
                    self.presentErrorPopup("Whoa, sorry. Looks like there was an issue logging you out.")
                }
                else
                {
                    print("logout success")
                    
                }
            }
            userNameLabel.text = ""
            userImage.image = UIImage(named: "UserIcon")
            navigationItem.rightBarButtonItem?.title = "Login"
            
        }
        
    }
    //Set the email text to a link that will open the users email app
    @IBAction func emailTapped(sender: UIButton)
    {
        let email = "support@howmuchtrip.com"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    
    // MARK: - Email Login/logout functions

    /// This function will run if the user created a custom username and password and did not login with social media
    func processUsernameData()
    {
        if PFUser.currentUser() != nil
        {
            //Set the username the user creates to the username key in Parse
            let pUserName = PFUser.currentUser()!["username"] as! String
        
            //Set the nameLabel and image on the SettingsVC
            self.userNameLabel?.text = "@" + pUserName
            self.userImage?.image = UIImage(named: "UserIcon")
        }
    }
    
    // MARK: - Facebook Login/logout functions

    /// This function will run if the user signed in with their Facebook account
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
    
    // MARK: - Twitter Login/logout functions
    
    /// This function will run if the user signed in with their Twitter account
    func processTwitterData()
    {
        if PFUser.currentUser() != nil
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
                self.navigationItem.rightBarButtonItem?.title = "Login"
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
    
}



