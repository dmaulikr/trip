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
    let dataSource = CreateTripDataSource()
    var viewAppeared = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var legendContainerView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var saveTripButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dataSource.initialSetupPieChart(pieChartView)
        tableView.backgroundColor = UIColor(red:0, green:0.658, blue:0.909, alpha:1)
        
//        dataSource.initialSetupPieChart(pieChartView)
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
        
        NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "viewDidAppearSetup", userInfo: nil, repeats: false)
    }
    
    func viewDidAppearSetup()
    {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
        setMap()
        tableView.reloadData()
        
        doSetup()
    }

    func setMap()
    {
        mapView.hidden = false
        var lat: Double!
        var lng: Double!
            
        if aTrip.destinationLat != nil && aTrip.destinationLng != nil
        {
            lat = Double(aTrip.destinationLat!)
            lng = Double(aTrip.destinationLng!)
        }
        else
        {
            lat = 28.538336
            lng = -81.379234
        }
        
        mapView.mapType = MKMapType.Standard
        let annotation = MKPointAnnotation()
        
        annotation.coordinate.latitude = lat
        annotation.coordinate.longitude = lng
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 15000, 15000)

        mapView.setRegion(region, animated: true)
    }
    
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
    
    func doSetup()
    {
        buildGraphAndLegend(aTrip, superview: self)
    }
    
    func buildGraphAndLegend(aTrip: Trip, superview: TripDetailViewController)
    {
        let (values, dataPoints) = dataSource.getGraphValuesAndProperties(aTrip)
        buildLegend(values, dataPoints: dataPoints, superview: superview)
        buildGraph(values, dataPoints: dataPoints, superview: superview)
    }
    
    private func buildGraph(values: [Double], dataPoints: [String], superview: TripDetailViewController)
    {
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
