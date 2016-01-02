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
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem)
    {
        let button = tabBar.preferredFocusedView!
        button.appearWithFade(0.25)
    }
}
