//
//  SuggestedTripCell.swift
//  HowMuchTrip
//
//  Created by Jennifer Hamilton on 12/13/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

class SuggestedTripCell: UITableViewCell
{
    @IBOutlet weak var tripNameLabel: UILabel!
//    @IBOutlet weak var departureLocationLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var destinationImageView: UIImageView!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
