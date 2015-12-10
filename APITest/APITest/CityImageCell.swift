//
//  CityImageCell.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit

class CityImageCell: UITableViewCell
{
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y >= 0
        {
            // scrolling up
            containerView.clipsToBounds = true
            bottomSpaceConstraint?.constant = -scrollView.contentOffset.y / 2
            topSpaceConstraint?.constant = scrollView.contentOffset.y / 2
        }
        else
        {
            // scrolling down
            topSpaceConstraint?.constant = scrollView.contentOffset.y
            containerView.clipsToBounds = false
        }
    }
}