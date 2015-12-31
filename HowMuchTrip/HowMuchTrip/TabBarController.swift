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
