//
//  ViewController.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit
import MapKit
import Charts

class TripDetailViewController: UITableViewController
{
    var aTrip: Trip!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var legendTableVC: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var saveTripButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        tableView.backgroundColor = UIColor(red:0.011, green:0.694, blue:0.921, alpha:1)
        tableView.backgroundColor = UIColor(red:0, green:0.658, blue:0.909, alpha:1)
    }
    
//    // MARK: - Table view data source
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
//    {
//        return 2
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return 1
//        
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        switch indexPath.section
//        {
//        case 0:
//            let identifier = "TripMapCell"
//            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TripMapCell
//            
//            setCellMap(cell)
//            
//            return cell
//            
//        default:
//            let identifier = "TripDataCell"
//            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TripDetailCell
//            
//            cell.backgroundColor = UIColor.clearColor()
//            cell.contentView.backgroundColor = UIColor.clearColor()
//            cell.selectionStyle = .None
//            
//            setCellLabels(cell)
//            
//            return cell
//        }
//    }
//    
//    func setCellMap(cell: TripMapCell)
//    {
//        let mapView = cell.mapView
//        mapView.mapType = MKMapType.Standard
//        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate.latitude = 28.538336
//        annotation.coordinate.longitude = -81.379234
//        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 15000, 15000)
////        mapView.addAnnotation(annotation)
//        mapView.setRegion(region, animated: true)
//        cell.sendSubviewToBack(mapView)
//    }
    
    func setCellLabels(cell: TripDetailCell)
    {
        if aTrip != nil
        {
            cell.destinationLabel.text = aTrip.destination
            cell.budgetLabel.text = String(aTrip.budgetTotal)
            cell.planeTicketLabel.text = String(aTrip.planeTicketCost)
            cell.totalLodgingLabel.text = String(aTrip.totalLodgingCosts)
            cell.totalFoodLabel.text = String(aTrip.totalFoodCosts)
            cell.totalOtherLabel.text = String(aTrip.totalOtherDailyCosts)
            cell.oneTimeCostLabel.text = String(aTrip.oneTimeCost)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0  : return UITableViewAutomaticDimension
        default : return self.view.bounds.height
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0  : return 200
        default : return self.view.bounds.height
        }
    }
    
    // MARK: - Scroll view delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if let cell = tableView
            .cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? TripMapCell
        {
            cell.scrollViewDidScroll(scrollView)
        }
    }
}

class TripDetailCell: UITableViewCell
{
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var planeTicketLabel: UILabel!
    @IBOutlet weak var totalLodgingLabel: UILabel!
    @IBOutlet weak var totalFoodLabel: UILabel!
    @IBOutlet weak var totalOtherLabel: UILabel!
    @IBOutlet weak var oneTimeCostLabel: UILabel!
}

class TripMapCell: UITableViewCell
{
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y >= 0
        {
            // scrolling up
//            containerView.clipsToBounds = true
            bottomSpaceConstraint?.constant = -scrollView.contentOffset.y / 2
            topSpaceConstraint?.constant = scrollView.contentOffset.y / 2
        }
        else
        {
            // scrolling down
            topSpaceConstraint?.constant = scrollView.contentOffset.y
//            containerView.clipsToBounds = false
        }
    }
}
