//
//  TabBarController.swift
//  HowMuchTrip
//
//  Created by david on 12/31/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set universal application navigation bar attributes
        tabBar.backgroundImage = UIImage(named: "background")
        tabBar.contentMode = .Bottom
        
        tabBar.autoresizesSubviews = false
        tabBar.clipsToBounds = true
        
        let titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 10)!
        ]
        
        let unselectedTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
            NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 10)!
        ]
        //        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        
        let tabBarItems = tabBar.items
        
        for tabBarItem in tabBarItems!
        {
            tabBarItem.setTitleTextAttributes(unselectedTitleTextAttributes, forState: .Normal)
            tabBarItem.setTitleTextAttributes(titleTextAttributes, forState: .Selected)
        }
        
        tabBarController?.selectedIndex = 0
    }
    

    
    /// Adds animation to the navigation tab bar
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem)
    {
        let button = tabBar.preferredFocusedView!
        button.appearWithFade(0.25)
    }
}
