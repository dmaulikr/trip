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
import SwiftMoment

class TripDetailViewController: UITableViewController
{
    var trip: Trip!
    let dataSource = CreateTripDataSource()
    var viewAppeared = false
    
    @IBOutlet weak var backupImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var legendContainerView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var budgetRemainingLabel: UILabel!
    
    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var tripDepartureAndDestinationLabel: UILabel!
    @IBOutlet weak var tripDepatureTimeLabel: UILabel!
    
    var cameFromSuggested: SuggestedTripsTableViewController?
    
    var calculator: Calculator!
    var propertyDictionary = [String : String]()
    
    var contextPopover: UIViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        backgroundImageView.alpha = 0
        dataSource.initialSetupPieChart(pieChartView)

//        tableView.backgroundColor = UIColor(red:0, green:0.658, blue:0.909, alpha:1)
        
        if trip.tripName != nil || trip.tripName != ""
        {
            tripNameLabel.text = trip.tripName
        }
        else
        {
            tripNameLabel.text = trip.destination
        }
        
        if trip.departureLocation != "" && trip.destination != ""
        {
            tripDepartureAndDestinationLabel.text = "\(trip.departureLocation) to \(trip.destination)"
        }
        else
        {
            tripDepartureAndDestinationLabel.text = "Here to Somewhere Else"
        }
        
        if cameFromSuggested != nil
        {
            tripNameLabel.text = trip.destination
        }
            
        
        if trip.dateFrom != "" && trip.dateTo != ""
        {
            tripDateLabel.text = "\(trip.dateFrom) - \(trip.dateTo)"
            if let dateFrom    = moment(trip.dateFrom, dateFormat: "MM/d/yy")
            {
                let interval    = dateFrom.intervalSince(moment()).days
                var formattedInterval = String(interval).componentsSeparatedByString(".")[0] + " day until this trip!"
                if interval > 1.9
                {
                    formattedInterval = formattedInterval.stringByReplacingOccurrencesOfString("day", withString: "days")
                }
//                var formattedInterval = interval.componentsSeparatedByString(" ")[0] + interval.componentsSeparatedByString(" ")[1]
//                formattedInterval = formattedInterval.stringByReplacingOccurrencesOfString("d", withString: " day")
//                formattedInterval = formattedInterval.stringByReplacingOccurrencesOfString("w", withString: " week, ")
//                formattedInterval = formattedInterval.stringByReplacingOccurrencesOfString("m", withString: " month, ")
                
                tripDepatureTimeLabel.text = formattedInterval
            }
            
        }
        else
        {
            tripDateLabel.text = ""
            tripDepatureTimeLabel.text = ""
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        viewAppeared = false
        mapView.hidden = true
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        viewAppeared = true
        
        doSetup()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        updateTrip(trip)
        cameFromSuggested = nil
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - Initial View Setup
    
    func doSetup()
    {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
        setMap()
        
        buildGraphAndLegend(trip, superview: self)
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "delayedSetup", userInfo: nil, repeats: false)
        
        tableView.reloadData()
    }
    
    func delayedSetup()
    {
        backgroundImageView.appearWithFade(0.25)
    }

    func setMap()
    {
        mapView.hidden = false
        var lat: Double!
        var lng: Double!
            
        if trip.destinationLat != "" && trip.destinationLng != ""
        {
            lat = Double(trip.destinationLat)
            lng = Double(trip.destinationLng)
            
            mapView.mapType = MKMapType.Standard
            let annotation = MKPointAnnotation()
            
            annotation.coordinate.latitude = lat
            annotation.coordinate.longitude = lng
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 15000, 15000)
            
            mapView.setRegion(region, animated: true)
        }
        else
        {
            // TODO: - set generic vacation image in place of mapView if there is no lat and lng for location
            mapView.hidden = true
            backupImageView.hidden = false
            backupImageView.image = UIImage(named: trip.destinationImage)
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.row
        {
        case 0  :
            if viewAppeared
            {
                return UITableViewAutomaticDimension
            }
            else
            {
                return 0
            }
            
        default : return self.view.bounds.height
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0  :
            if viewAppeared
            {
                return 200
            }
            else
            {
                return 0
            }
            
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
    
    // MARK: - Build Graph
    
    func buildGraphAndLegend(trip: Trip, superview: TripDetailViewController)
    {
        let (values, dataPoints) = dataSource.getGraphValuesAndProperties(trip)
        buildLegend(values, dataPoints: dataPoints, superview: superview)
        buildGraph(values, dataPoints: dataPoints, superview: superview)
    }
    
    private func buildGraph(values: [Double], dataPoints: [String], superview: TripDetailViewController)
    {
        budgetRemainingLabel.text = trip.budgetRemaining.formatCostAsUSD()
        
        var dataEntries = [ChartDataEntry]()
        
        for i in 0..<dataPoints.count
        {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        var points = [String]()
        for _ in dataPoints
        {
            points.append(" ")
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        pieChartDataSet.colors = dataSource.getGraphColors()
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        superview.pieChartView.data = pieChartData
        
        superview.pieChartView.appearWithFade(0.25)
        superview.pieChartView.slideHorizontallyToOrigin(0.25, fromPointX: -superview.pieChartView.frame.width)
    }
    
    private func buildLegend(values: [Double], dataPoints: [String], superview: TripDetailViewController)
    {
        if let legendTableVC = superview.childViewControllers[0] as? GraphLegendTableViewController
        {
            legendTableVC.dataPoints = dataPoints
            legendTableVC.values     = values
            legendTableVC.colors     = dataSource.getGraphColors()
            legendTableVC.trip       = trip
            
//            let tripListTableVC      = tabBarController?.viewControllers![1] as! TripListTableViewController
//            legendTableVC.delegate   = tripListTableVC
            legendTableVC.tableView.reloadData()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.legendContainerView.appearWithFade(0.25)
                self.legendContainerView.slideHorizontallyToOrigin(0.25, fromPointX: superview.legendContainerView.frame.width)
            })
        }
        else
        {
            print("no child view")
        }
        

    }
    
    func calculate(cycle: Bool)
    {
        buildGraphAndLegend(trip, superview: self)
    }
    
    func updateTrip(trip: Trip)
    {
        trip.saveEventually()
        trip.pinInBackground()
    }
}

// MARK: - Detail View Cells

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
