//
//  ViewController.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit

protocol QPX_EX_APIControllerDelegate
{
    func didReceiveQPXResults(results: NSDictionary)
}

class ViewController: UITableViewController, QPX_EX_APIControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(red:0.011, green:0.694, blue:0.921, alpha:1)
        
        let flightSearch = FlightSearch()
        
        let QPXAPIController = QPX_EX_APIController(delegate: self)
        QPXAPIController.search(flightSearch)
    }
    
    func didReceiveQPXResults(results: NSDictionary)
    {
        
    }
    
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
//        case 1  : return 1
        default : return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var identifier: String!
        switch indexPath.section
        {
        case 0  : identifier = "CityImageCell"
//        case 1  : identifier = "ButtonCell"
        default : identifier = "CityDataCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0  : return UITableViewAutomaticDimension
//        case 1  : return 0
        default : return self.view.bounds.height
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0  : return 200
//        case 1  : return 0
        default : return self.view.bounds.height
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
//        if let cell = tableView
//            .cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? CityImageCell
//        {
//            cell.scrollViewDidScroll(scrollView)
//        }
    }
}



