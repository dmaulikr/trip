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
    
    var property: String!
    var value: Double!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ContextPopoverSetup.setup(confirmButton, cancelButton: cancelButton)
        
        topLabel.text = "Editing \(property)"
        
        editTextField.delegate = self
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
