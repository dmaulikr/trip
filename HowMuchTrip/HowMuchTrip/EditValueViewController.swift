//
//  EditValueViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/22/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

protocol TripValueWasEditedDelegate
{
    func valueWasEdited(property: String, value: String?)
}

class EditValueViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var editTextField: UITextField!
    
    var delegate: TripValueWasEditedDelegate?
    
    let confirmations = [
        "Okay",
        "All set",
        "Looks good"
    ]
    
    let cancellations = [
        "Never mind",
        "Just kidding",
        "Forget it"
    ]
    
    var property: String!
    var value: Double!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        confirmButton.alpha = 0
        editTextField.delegate = self
        
        let confirmation = confirmations[Int(arc4random() % 3)]
        let cancellation = cancellations[Int(arc4random() % 3)]
        
        confirmButton.setTitle(confirmation, forState: .Normal)
        cancelButton.setTitle(cancellation, forState: .Normal)
        
        topLabel.text = "Editing \(property)"
        editTextField.placeholder = value.formatCostAsUSD()
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton)
    {
        if editTextField.text != ""
        {
            delegate?.valueWasEdited(property, value: editTextField.text!)
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton)
    {
        delegate?.valueWasEdited(property, value: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField.text != ""
        {
            delegate?.valueWasEdited(property, value: editTextField.text!)
            return true
        }
        return false
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField.text != "" && confirmButton.alpha == 0 {
            confirmButton.appearWithFade(0.25)
        }
        return testCharacters(textField, string: string)
    }
    
    func testCharacters(textField: UITextField, string: String) -> Bool
    {
        let invalidCharacters = NSCharacterSet(charactersInString: "0123456789.").invertedSet //only includes 0-9
        
        if let _ = string
            .rangeOfCharacterFromSet(invalidCharacters, options: [],
                range:Range<String.Index>(start: string.startIndex, end: string.endIndex))
        {
            return false
        }
        
        return true
    }
}
