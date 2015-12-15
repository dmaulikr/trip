//
//  ViewController.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

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
        switch indexPath.section
        {
        case 0:
            let identifier = "CityImageCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CityImageCell
            let mapView = cell.mapView
            mapView.mapType = MKMapType.Hybrid
            
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = 28.538336
            annotation.coordinate.longitude = -81.379234
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 15000, 15000)
            mapView.addAnnotation(annotation)
            mapView.setRegion(region, animated: true)
            
            return cell
            
        default:
            let identifier = "CityDataCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            
            return cell
        }
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



