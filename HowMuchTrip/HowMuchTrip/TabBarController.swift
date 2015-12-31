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
//        button.slideVerticallyToOrigin(0.15, fromPointY: button.frame.size.height)
        
//        tabBar.preferredFocusedView?.alpha = 0
        
//
//        
//        for subview in view.subviews
//        {
//            subview.alpha = 0.7
//        }
//        UIView.animateWithDuration(0.15, animations: { () -> Void in
//            for subview in self.view.subviews
//            {
//                subview.alpha = 1
//            }
//            }) { (_) -> Void in
//                
//        }
    }
}
