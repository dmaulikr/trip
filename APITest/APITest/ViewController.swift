//
//  ViewController.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit

class ViewController: UITableViewController
{
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 0  : return 1
        default : return 20
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var identifier: String!
        switch indexPath.section
        {
        case 0  : identifier = "CityImageCell"
        default : identifier = "CityDataCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0  : return UITableViewAutomaticDimension
        default : return 50
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0  : return 200
        default : return 50
        }
    }
    
    // MARK: - Scroll view delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if let cell = tableView
            .cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? CityImageCell
        {
            cell.scrollViewDidScroll(scrollView)
        }
    }
}



