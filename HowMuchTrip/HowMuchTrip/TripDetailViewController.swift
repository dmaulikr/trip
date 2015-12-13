//
//  TripDetailViewController.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/10/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class TripDetailViewController: UIViewController
{
    var aTrip = Trip()
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var planeTicketLabel: UILabel!
    @IBOutlet weak var totalLodgingLabel: UILabel!
    @IBOutlet weak var totalFoodLabel: UILabel!
    @IBOutlet weak var totalOtherLabel: UILabel!
    @IBOutlet weak var oneTimeCostLabel: UILabel!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Trip Detail"
        destinationLabel.text = aTrip.destination
        budgetLabel.text = String(aTrip.budgetTotal)
        planeTicketLabel.text = String(aTrip.planeTicketCost)
        totalLodgingLabel.text = String(aTrip.totalLodgingCosts)
        totalFoodLabel.text = String(aTrip.totalFoodCosts)
        totalOtherLabel.text = String(aTrip.totalOtherDailyCosts)
        oneTimeCostLabel.text = String(aTrip.oneTimeCost)
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


}
