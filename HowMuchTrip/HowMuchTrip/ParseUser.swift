//
//  ParseUser.swift
//  
//
//  Created by Chris Stomp on 12/21/15.
//
//

import Foundation
import Parse

class ParseUser: PFUser
{
    
    @NSManaged var loggedInWithTwitter: Bool
    @NSManaged var loggedInWithFacebook: Bool
    @NSManaged var loggedInWithUsername: Bool
    @NSManaged var displayName: String
    @NSManaged var parseUsername: String
    
    override class func initialize()
    {
        struct Static
        {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken)
            {
                self.registerSubclass()
        }
    }
}
