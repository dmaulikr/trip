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
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()

        title = "Settings"
        if let pUserName = PFUser.currentUser()?["username"] as? String
        {
            self.userNameLabel?.text = "@" + pUserName
            //userImage.image
        }
        
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        
        userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
            
            if(error != nil)
            {
                print("\(error.localizedDescription)")
                return
            }
            
            if(result != nil)
            {
                
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
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    
                    let profilePictureUrl = NSURL(string: userProfile)
                    
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    self.userImage?.image = UIImage(data: profilePictureData!)
                    
//                    self.userImage.downloadImgFrom(<#T##imageURL: String##String#>, contentMode: .AspectFill)
                    
                    
                    if(profilePictureData != nil)
                    {
                        let profileFileObject = PFFile(data:profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "profile_picture")
                    }
                    
                    
                    myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if(success)
                        {
                            print("User details are now updated")
                        }
                        
                    })
                    
                }
                
            }
            
        }
        


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

//extension UIImageView
//{
//    func downloadImgFrom(imageURL: String, contentMode: UIViewContentMode)
//    {
//        if let url = NSURL(string: imageURL)
//        {
//            var task: NSURLSessionDataTask!
//            task = NSURLSession.sharedSession().dataTaskWithURL(url,
//                completionHandler: { (data, response, error) -> Void in
//                    if data != nil
//                    {
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            let image = UIImage(data: data!)
//                            self.image = image
//                            self.contentMode = contentMode
//                            task.cancel()
//                        })
//                    }
//            })
//            
//            task.resume()
//        }
//        else
//        {
//            print("url \(imageURL) was invalid")
//        }
//    }
//}
