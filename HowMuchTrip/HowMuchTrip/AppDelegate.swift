//
//  AppDelegate.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit
import Bolts
import Parse
import ParseTwitterUtils
import FBSDKCoreKit
import ParseFacebookUtilsV4
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Adds Fabric Pod, with Crashlytics, Answers and Beta kits
        Fabric.with([Crashlytics.self])
        
        // Adds Parse Local Datastore capabilities
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("iTbTjpq7M0vfed6Axq9D8Hi9EmBsIkpLy4krP7Tq",
            clientKey: "olFFyKQE7RoCTjssTFx3l885RrJd2Yml14wyv0DZ")
        
        // Parse: Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Set Twitter application consumer key
        PFTwitterUtils.initializeWithConsumerKey("kk94RLfsKXk48oJVYS8Cu9oMU",  consumerSecret:"yrPyx1iVNWq1jIDaMSQrRGVKofg8eoRuJhqEvQPbERTXkDUBvG")
        
        // Add Facebook Utilities for login
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        window?.tintColor = UIColor(red: 0.45, green: 0.8, blue: 0.9, alpha: 1)

        // Adds navigation tab bar attributes
        UITabBar.appearance().translucent = true
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir-Light", size: 20)!
        ]
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor.blackColor()
        
        UIBarButtonItem.appearance()
            .setTitleTextAttributes(UINavigationBar.appearance().titleTextAttributes, forState: .Normal)
        
        let tabBar = window?.rootViewController as! UITabBarController
        tabBar.selectedIndex = 1
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        // Required for Facebook login functions
        FBSDKAppEvents.activateApp()
    }


    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        // Required for Facebook login functions
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

}

